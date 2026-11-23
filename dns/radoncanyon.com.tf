locals {
  # The physical view of the site infrastructure: LAN and cluster addresses.
  # The tailnet view of the same names lives in nulogorsk.com.
  radoncanyon_com_records = {
    "a-dns-lga1"              = { name = "dns.lga1", type = "A", content = "192.168.222.2" }
    "a-dns-lga2"              = { name = "dns.lga2", type = "A", content = "192.168.239.2" }
    "a-gw-lga1"               = { name = "gw.lga1", type = "A", content = "192.168.222.1" }
    "a-gw-lga2"               = { name = "gw.lga2", type = "A", content = "192.168.239.254" }
    "a-knode1-lga1"           = { name = "knode1.lga1", type = "A", content = "192.168.222.143" }
    "a-knode2-lga1"           = { name = "knode2.lga1", type = "A", content = "192.168.222.144" }
    "a-nas1-lga1"             = { name = "nas1.lga1", type = "A", content = "192.168.222.149" }
    "a-nas2-lga1"             = { name = "nas2.lga1", type = "A", content = "192.168.222.114" }
    "a-odroid-lga1"           = { name = "odroid.lga1", type = "A", content = "192.168.222.2" }
    "a-odroid-lga2"           = { name = "odroid.lga2", type = "A", content = "192.168.239.2" }
    "mx-apex"                 = { name = "@", type = "MX", content = ".", priority = 0 }
    "txt-wildcard"            = { name = "*", type = "TXT", content = "v=spf1 -all" }
    "txt-wildcard._domainkey" = { name = "*._domainkey", type = "TXT", content = "v=DKIM1; p=" }
    "txt-apex"                = { name = "@", type = "TXT", content = "google-site-verification=ZnkGcjiK9_Od1OOq6ZxMFzoS3Q7ZatXb8W_aH89g5mY" }
    "txt-_dmarc"              = { name = "_dmarc", type = "TXT", content = "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; fo=1; rua=mailto:itadso9z@ag.us.dmarcian.com" }
  }
}
