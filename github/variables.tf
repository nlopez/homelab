variable "webhook_secret" {
  type      = string
  sensitive = true
}

variable "public" {
  type        = bool
  default     = false
  description = "Make the repository public and turn on the settings that need it (ruleset, secret scanning)."
}

variable "rulesets" {
  type        = bool
  default     = false
  description = "Create the main ruleset on a private repository. Needs a plan that offers rulesets there (GitHub Pro or higher)."
}
