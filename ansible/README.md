# ansible_home
My first foray into [ansible](http://www.ansible.com/) for managing a handful of systems at home.

# Usage
```bash
direnv allow # or: nix develop
```

`ansible` and `ansible-lint` come from the root dev shell (`flake.nix`). Collections still need installing once:
```bash
ansible-galaxy collection install -r requirements.yaml
```

# CI

The `Ansible` workflow (`.github/workflows/ansible.yaml`) runs check mode nightly and keeps a
"Drift in Ansible" issue open while the hosts differ from the playbooks. A merge applies on its
own only when every changed file belongs to a role in `.github/scripts/ansible-merge-tags.py`'s
allowlist, and then only those roles' tags (today: `unattended_upgrades`). Any other change
waits for someone to run the workflow with **apply**, which applies every role. Add a role to
the allowlist only if its worst case can't cut a host off the network or lock out SSH, and give
it a tag in `site.yaml`.

# TODO
* touch `/etc/cloud/cloud-init.disabled` to workaround [cloud-init resetting hostname](https://askubuntu.com/a/1047659)