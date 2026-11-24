# Makes a push to main refresh the Argo CD Applications instead of waiting for
# the poller. argocd-server verifies the signature with the same secret.
resource "github_repository_webhook" "argocd" {
  repository = github_repository.homelab.name
  events     = ["push"]

  configuration {
    url          = "https://flopie.desertbluffs.com/api/webhook"
    content_type = "json"
    secret       = var.webhook_secret
    insecure_ssl = "0"
  }
}
