locals {
  # The tailnet view of the site infrastructure: tailscale addresses instead of
  # the LAN and cluster addresses that radoncanyon.com answers with.
  nulogorsk_com_records = {
    "a-gw-lga1"                    = { name = "gw.lga1", type = "A", content = "100.83.144.88" }
    "a-gw-lga2"                    = { name = "gw.lga2", type = "A", content = "100.86.37.97" }
    "a-nas1-lga1"                  = { name = "nas1.lga1", type = "A", content = "100.92.205.106" }
    "a-nas2-lga1"                  = { name = "nas2.lga1", type = "A", content = "100.73.101.17" }
    "a-odroid-lga1"                = { name = "odroid.lga1", type = "A", content = "100.127.60.59" }
    "a-odroid-lga2"                = { name = "odroid.lga2", type = "A", content = "100.110.65.2" }
    "cname-dns-lga1"               = { name = "dns.lga1", type = "CNAME", content = "odroid.lga1.nulogorsk.com" }
    "cname-dns-lga2"               = { name = "dns.lga2", type = "CNAME", content = "odroid.lga2.nulogorsk.com" }
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
