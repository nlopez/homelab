# AWS: agent notes

Read the root [AGENTS.md](../AGENTS.md) first.

## Stacks

- `state-bucket/`: the OpenTofu state bucket, Identity Center access, and every CI OIDC role
  (`iam.tf`). Its own workflow plans and applies it. An apply here can lock CI out of AWS; the
  workflow comment says how to recover. Leave changes to trust policies to a human.
- `ses/`: the SES domain identity for `desertbluffs.com`.
- `<app>-smtp/`: one IAM user per app that sends mail, through `modules/ses-smtp-user`. All of them
  plan and apply in one matrix in `.github/workflows/aws.yaml`.

## Adding an SMTP user for an app

It takes two PRs, because the CI roles can only read and write the state prefixes `iam.tf` lists:

1. In `state-bucket/iam.tf`, add `<app>-smtp` to the apply role's state prefixes and IAM user ARNs
   (next to the existing `*-smtp` entries) and to `plan_state_prefixes.aws`. Merge it and wait for
   the State bucket apply.
2. Copy an existing `<app>-smtp/` directory, change the backend `key`, the module's `name` and
   `from_addresses`, and add the directory to the matrix in `aws.yaml`. Its plan should show only
   the new user, its access key, and its policy.

The SMTP password is a sensitive output of the stack. Nothing copies it into 1Password for the app;
say in the PR that a human has to.
