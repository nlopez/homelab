#!/usr/bin/env python3
"""Fail when a Helm app's values.yaml overrides the version of an image its chart ships.

A chart's images, templates, and CRDs are released and tested together, and
Renovate updates the chart. An image tag set in values.yaml outlives chart
updates: the app keeps the pinned image after the chart moves on. So a values
file may set images the chart doesn't ship (sidecars, plugins, our own builds)
but not change the tag of one it does, unless the line carries a reason:

    tag: v3.4.1  # pin: the immich chart lags the app and expects the tag set

For each app, the chart is rendered twice with `helm template`: with the app's
values.yaml minus every image tag (what the chart ships; the rest of the
values stay, since many charts don't render without them), and with
values.yaml as written. An image whose repository is in the first render but
whose tag differs in the second is an override.

Usage:
  helm-pins.py check <app>...        render each kubernetes/apps/<app> chart and check it
  helm-pins.py changed <path>...     print the Helm apps the given changed paths touch
  helm-pins.py compare <defaults.yaml> <rendered.yaml> <values.yaml> <app>
                                     check two renders already on disk (for tests)
"""
import pathlib
import re
import subprocess
import sys
import tempfile

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[2]
APPS = ROOT / "kubernetes" / "apps"
KUBE_VERSION = "1.36.0"


def split_image(ref):
    """(repository, tag-or-digest) of an image reference, with docker.io spelled out."""
    ref = ref.strip()
    repo, sep, digest = ref.partition("@")
    tag = digest if sep else ""
    last = repo.rsplit("/", 1)[-1]
    if ":" in last:
        repo, _, t = repo.rpartition(":")
        tag = t + (f"@{digest}" if digest else "")
    parts = repo.split("/")
    if len(parts) == 1:
        repo = f"docker.io/library/{repo}"
    elif "." not in parts[0] and ":" not in parts[0] and parts[0] != "localhost":
        repo = f"docker.io/{repo}"
    return repo, tag


def images(rendered):
    """{repository: {tags}} of every container image in a rendered manifest stream."""
    found = {}

    def walk(node):
        if isinstance(node, dict):
            for key, value in node.items():
                if key in ("containers", "initContainers", "ephemeralContainers") and isinstance(value, list):
                    for container in value:
                        if isinstance(container, dict) and isinstance(container.get("image"), str):
                            repo, tag = split_image(container["image"])
                            found.setdefault(repo, set()).add(tag)
                walk(value)
        elif isinstance(node, list):
            for item in node:
                walk(item)

    for doc in yaml.safe_load_all(rendered):
        walk(doc)
    return found


def pinned_with_reason(values_text, tag):
    """Whether a values.yaml line that sets this tag carries a `# pin:` reason."""
    bare = tag.split("@")[0]
    for line in values_text.splitlines():
        code, _, comment = line.partition("#")
        if bare and bare in code and comment.strip().startswith("pin:"):
            return True
    return False


def compare(defaults, rendered, values_text, app):
    """Lines describing each override of an image the chart ships."""
    # An image the chart renders without a tag is one it doesn't version.
    shipped = {repo: tags - {""} for repo, tags in images(defaults).items() if tags - {""}}
    problems = []
    for repo, tags in sorted(images(rendered).items()):
        if repo not in shipped:
            continue
        for tag in sorted(tags - shipped[repo]):
            if pinned_with_reason(values_text, tag):
                continue
            ships = ", ".join(sorted(shipped[repo]))
            problems.append(
                f"{app}: values.yaml runs {repo}:{tag}, but the chart ships {ships}. "
                "Drop the override so the chart decides, or add `# pin: <reason>` to the line.")
    return problems


TAG_KEYS = ("tag", "digest", "version")


ANY = object()


def without_tags(node, chart=ANY):
    """A copy of a values tree without image tags: `tag`, `digest`, and `version`
    under any `image` mapping, and the tag of any `image: repo:tag` string.

    With chart (the chart's own default values), only tags the chart also sets
    are removed: a chart that requires a tag it doesn't ship (an external-dns
    webhook, say) won't render without it, and that image isn't the chart's to
    version anyway."""
    def sub(value, key):
        if chart is ANY:
            return ANY
        return chart.get(key) if isinstance(chart, dict) else None

    if isinstance(node, list):
        return [without_tags(item, ANY if chart is ANY else None) for item in node]
    if not isinstance(node, dict):
        return node
    out = {}
    for key, value in node.items():
        defaults = sub(value, key)
        if key == "image" and isinstance(value, dict):
            out[key] = {k: without_tags(v, ANY if defaults is ANY else (defaults or {}).get(k) if isinstance(defaults, dict) else None)
                        for k, v in value.items()
                        if k not in TAG_KEYS or not (defaults is ANY or (isinstance(defaults, dict) and defaults.get(k)))}
        elif key == "image" and isinstance(value, str):
            out[key] = split_image(value)[0] if defaults is ANY or defaults else value
        else:
            out[key] = without_tags(value, defaults)
    return out


def chart_source(app):
    """(chart reference, helm args) of the app's chart, or None for a plain app."""
    path = APPS / app / "application.yaml"
    if not path.exists():
        return None
    spec = yaml.safe_load(path.read_text()).get("spec") or {}
    for source in spec.get("sources") or [spec.get("source") or {}]:
        repo, version = source.get("repoURL", ""), str(source.get("targetRevision", ""))
        if source.get("chart"):
            return source["chart"], ["--repo", repo, "--version", version]
        if repo.startswith("oci://"):
            return repo, ["--version", version]
    return None


def helm_template(app, ref, args, values=None):
    cmd = ["helm", "template", app, ref, *args, "--namespace", app, "--kube-version", KUBE_VERSION]
    if values:
        cmd += ["-f", str(values)]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"helm template failed for {app}: {result.stderr.strip()}")
    return result.stdout


def render_with(app, ref, args, tree):
    with tempfile.NamedTemporaryFile("w", suffix=".yaml") as values:
        yaml.safe_dump(tree, values)
        values.flush()
        return helm_template(app, ref, args, values.name)


def helm_show_values(ref, args):
    result = subprocess.run(["helm", "show", "values", ref, *args], capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"helm show values failed for {ref}: {result.stderr.strip()}")
    return result.stdout


def check(apps):
    problems = []
    for app in apps:
        source = chart_source(app)
        values = APPS / app / "values.yaml"
        if source is None or not values.exists():
            continue
        ref, args = source
        tree = yaml.safe_load(values.read_text()) or {}
        try:
            rendered = helm_template(app, ref, args, values)
            try:
                defaults = render_with(app, ref, args, without_tags(tree))
            except RuntimeError:
                chart_values = yaml.safe_load(helm_show_values(ref, args)) or {}
                defaults = render_with(app, ref, args, without_tags(tree, chart_values))
        except RuntimeError as error:
            problems.append(str(error))
            continue
        found = compare(defaults, rendered, values.read_text(), app)
        print(f"{app}: {'ok' if not found else f'{len(found)} override(s)'}")
        problems += found
    return problems


def changed(paths):
    apps = set()
    for path in paths:
        parts = path.strip().split("/")
        if len(parts) >= 4 and parts[:2] == ["kubernetes", "apps"] and parts[3] in ("values.yaml", "application.yaml"):
            apps.add(parts[2])
    return sorted(app for app in apps if chart_source(app))


def main(argv):
    if len(argv) < 2 or argv[1] not in ("check", "changed", "compare"):
        sys.exit(__doc__)
    if argv[1] == "changed":
        print("\n".join(changed(argv[2:] or sys.stdin.read().split())))
        return 0
    if argv[1] == "compare":
        defaults, rendered, values, app = argv[2:6]
        problems = compare(pathlib.Path(defaults).read_text(), pathlib.Path(rendered).read_text(),
                           pathlib.Path(values).read_text(), app)
    else:
        problems = check(argv[2:])
    for problem in problems:
        print(problem, file=sys.stderr)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
