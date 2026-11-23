locals {
  nulogorsk_com_records = {
    "cname-protonmail._domainkey"  = { name = "protonmail._domainkey", type = "CNAME", content = "protonmail.domainkey.dtq25ze44gqbgofgt2yteu67cedbavwyaszrouvla23bp3c2ltjuq.domains.proton.ch" }
    "cname-protonmail2._domainkey" = { name = "protonmail2._domainkey", type = "CNAME", content = "protonmail2.domainkey.dtq25ze44gqbgofgt2yteu67cedbavwyaszrouvla23bp3c2ltjuq.domains.proton.ch" }
    "cname-protonmail3._domainkey" = { name = "protonmail3._domainkey", type = "CNAME", content = "protonmail3.domainkey.dtq25ze44gqbgofgt2yteu67cedbavwyaszrouvla23bp3c2ltjuq.domains.proton.ch" }
    "mx-apex-mail"                 = { name = "@", type = "MX", content = "mail.protonmail.ch", priority = 10 }
    "mx-apex-mailsec"              = { name = "@", type = "MX", content = "mailsec.protonmail.ch", priority = 20 }
    "txt-wildcard"                 = { name = "*", type = "TXT", content = "v=spf1 -all" }
    "txt-apex-google"              = { name = "@", type = "TXT", content = "google-site-verification=5812hCoCmKwaI_0BOxwDLgllxUt0Z1zF8xMVGpnJSJ4" }
    "txt-apex-protonmail"          = { name = "@", type = "TXT", content = "protonmail-verification=95474329be7c5db7b13b98a1a7cf2a302dea3f57" }
    "txt-apex-spf"                 = { name = "@", type = "TXT", content = "v=spf1 include:_spf.protonmail.ch mx ~all" }
    "txt-_dmarc"                   = { name = "_dmarc", type = "TXT", content = "v=DMARC1; p=quarantine; rua=mailto:itadso9z@ag.us.dmarcian.com" }
  }
}
