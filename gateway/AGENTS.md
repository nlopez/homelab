# Gateway: agent notes

Read the root [AGENTS.md](../AGENTS.md) and this directory's [README.md](README.md) first. The
gateways route every site's traffic; a bad apply can cut off the network the CI runner reaches them
through.

## What the PR plan can't see

- **WireGuard.** The plan user (`ci_pr_user` in `users.tf`) has no WireGuard privilege, so the PR plan
  excludes every `opnsense_wireguard_*` resource (`plan-args` in `.github/workflows/gateway.yaml`).
  A change to them is first planned by the apply on `main`. Don't change WireGuard resources in a
  PR an agent merges: say what you intend and leave it for a human.
- **The dns-webhook passwords** are `ignore_changes`, and the PR plan passes placeholders for them.
- **GUI-only settings** (see "Not managed here" in the README) never show in a plan.

## Rules for changes here

- Keep each PR to one gateway and one kind of resource where you can. Firewall rules, NAT, and
  routes interact; a small diff is easier to check against intent.
- A plan that replaces a filter rule, VLAN, virtual IP, route, or user is a destroy, and `ci-ok`
  waits for a human (root AGENTS.md). Many provider fields force replacement; read the plan's
  `# forces replacement` lines.
- The CI user gets a new API page privilege only through `users.tf`. If a PR plan fails with a 403,
  the plan user lacks the page: add the privilege in its own PR first.
- The provider has quirks that show as permanent diffs (README, "Provider limitations"). A diff you
  didn't cause on a resource listed there is probably that, not drift.
