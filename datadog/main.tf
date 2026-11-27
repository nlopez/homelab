terraform {
  required_version = ">= 1.7"

  backend "s3" {
    bucket       = "homelab-tofu-state-546422192262"
    key          = "datadog/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 4.0"
    }
  }
}

# Reads DD_API_KEY and DD_APP_KEY from the environment.
provider "datadog" {}

# The worker is deployed by the datadog app, so the location id comes from the
# runner config in the datadog-keys secret rather than from a resource here.
variable "synthetics_location_id" {
  type    = string
  default = "pl:k8s-home-f3f578aff4bf51e5b30953259fcd87ce"
}
