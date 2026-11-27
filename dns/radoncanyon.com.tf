locals {
  radoncanyon_com_records = {
    "mx-apex"                 = { name = "@", type = "MX", content = ".", priority = 0 }
    "txt-wildcard"            = { name = "*", type = "TXT", content = "v=spf1 -all" }
    "txt-wildcard._domainkey" = { name = "*._domainkey", type = "TXT", content = "v=DKIM1; p=" }
    "txt-apex"                = { name = "@", type = "TXT", content = "google-site-verification=ZnkGcjiK9_Od1OOq6ZxMFzoS3Q7ZatXb8W_aH89g5mY" }
    "txt-_dmarc"              = { name = "_dmarc", type = "TXT", content = "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; fo=1; rua=mailto:itadso9z@ag.us.dmarcian.com" }

    # Site infrastructure. The addresses are private; the gateways' Unbound
    # allows private answers for this domain (private_domains in gateway/unbound.tf).
    "a-gw.lga1"        = { name = "gw.lga1", type = "A", content = "192.168.222.1" }
    "aaaa-gw.lga1"     = { name = "gw.lga1", type = "AAAA", content = "fd54:571b:560a:2::1" }
    "a-knode1.lga1"    = { name = "knode1.lga1", type = "A", content = "192.168.222.143" }
    "aaaa-knode1.lga1" = { name = "knode1.lga1", type = "AAAA", content = "fd54:571b:560a:2::143" }
    "a-knode2.lga1"    = { name = "knode2.lga1", type = "A", content = "192.168.222.144" }
    "aaaa-knode2.lga1" = { name = "knode2.lga1", type = "AAAA", content = "fd54:571b:560a:2::144" }
    "a-nas1.lga1"      = { name = "nas1.lga1", type = "A", content = "192.168.222.149" }
    "aaaa-nas1.lga1"   = { name = "nas1.lga1", type = "AAAA", content = "fd54:571b:560a:2:ec4:7aff:fe33:59ee" }
    "a-nas2.lga1"      = { name = "nas2.lga1", type = "A", content = "192.168.222.114" }
    "aaaa-nas2.lga1"   = { name = "nas2.lga1", type = "AAAA", content = "fd54:571b:560a:2:225:90ff:fe9b:4ae2" }
    "a-odroid.lga1"    = { name = "odroid.lga1", type = "A", content = "192.168.222.2" }
    "aaaa-odroid.lga1" = { name = "odroid.lga1", type = "AAAA", content = "fd54:571b:560a:2::2" }
    "a-gw.lga2"        = { name = "gw.lga2", type = "A", content = "192.168.239.254" }
    "aaaa-gw.lga2"     = { name = "gw.lga2", type = "AAAA", content = "fd72:ce7b:d4a9:9511::254" }
    "a-odroid.lga2"    = { name = "odroid.lga2", type = "A", content = "192.168.239.2" }
    "aaaa-odroid.lga2" = { name = "odroid.lga2", type = "AAAA", content = "fd72:ce7b:d4a9:9511::2" }
  }
}
