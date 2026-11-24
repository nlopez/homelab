# Passwords and authenticators are set by each user, not here, so they stay
# out of the state.
resource "authentik_user" "nlopez" {
  username = "nlopez"
  name     = "Nick Lopez"
  email    = "nlopez@pm.me"
}
