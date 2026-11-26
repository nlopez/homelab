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

# TODO
* touch `/etc/cloud/cloud-init.disabled` to workaround [cloud-init resetting hostname](https://askubuntu.com/a/1047659)