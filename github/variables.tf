variable "webhook_secret" {
  type      = string
  sensitive = true
}

# The repository is public. With a false default, an apply without
# -var public=true would make it private again and delete the main ruleset.
variable "public" {
  type        = bool
  default     = true
  description = "Make the repository public and turn on the settings that need it (ruleset, secret scanning)."
}

variable "rulesets" {
  type        = bool
  default     = false
  description = "Create the main ruleset on a private repository. Needs a plan that offers rulesets there (GitHub Pro or higher)."
}
