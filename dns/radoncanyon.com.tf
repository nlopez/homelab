locals {
  radoncanyon_com_records = {
    "mx-apex"                 = { name = "@", type = "MX", content = ".", priority = 0 }
    "txt-wildcard"            = { name = "*", type = "TXT", content = "v=spf1 -all" }
    "txt-wildcard._domainkey" = { name = "*._domainkey", type = "TXT", content = "v=DKIM1; p=" }
    "txt-apex"                = { name = "@", type = "TXT", content = "google-site-verification=ZnkGcjiK9_Od1OOq6ZxMFzoS3Q7ZatXb8W_aH89g5mY" }
    "txt-_dmarc"              = { name = "_dmarc", type = "TXT", content = "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; fo=1; rua=mailto:itadso9z@ag.us.dmarcian.com" }
  }
}
