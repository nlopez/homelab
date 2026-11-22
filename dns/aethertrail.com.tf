locals {
  aethertrail_com_records = {
    "cname-protonmail._domainkey"  = { name = "protonmail._domainkey", type = "CNAME", content = "protonmail._domainkey.d37mwtwdoeonibgpu5jnsfnzrjnqm5p4ifgp2plkf5r4wkgmkrlha.domains.proton.ch" }
    "cname-protonmail2._domainkey" = { name = "protonmail2._domainkey", type = "CNAME", content = "protonmail2._domainkey.d37mwtwdoeonibgpu5jnsfnzrjnqm5p4ifgp2plkf5r4wkgmkrlha.domains.proton.ch" }
    "cname-protonmail3._domainkey" = { name = "protonmail3._domainkey", type = "CNAME", content = "protonmail3._domainkey.d37mwtwdoeonibgpu5jnsfnzrjnqm5p4ifgp2plkf5r4wkgmkrlha.domains.proton.ch" }
    "mx-apex-mail"                 = { name = "@", type = "MX", content = "mail.protonmail.ch", priority = 10 }
    "mx-apex-mailsec"              = { name = "@", type = "MX", content = "mailsec.protonmail.ch", priority = 20 }
    "txt-wildcard"                 = { name = "*", type = "TXT", content = "v=spf1 -all" }
    "txt-apex-google"              = { name = "@", type = "TXT", content = "google-site-verification=dvq0zeVnXreX-ORHQopNOs_c7T3fqdl5LAATDoL6miU" }
    "txt-apex-protonmail"          = { name = "@", type = "TXT", content = "protonmail-verification=f1ab807d903a45b94591fa70864d795a030e118c" }
    "txt-apex-spf"                 = { name = "@", type = "TXT", content = "v=spf1 include:_spf.protonmail.ch mx ~all" }
    "txt-_dmarc"                   = { name = "_dmarc", type = "TXT", content = "v=DMARC1; p=quarantine; rua=mailto:itadso9z@ag.us.dmarcian.com" }
  }
}
