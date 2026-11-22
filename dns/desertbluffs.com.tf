locals {
  desertbluffs_com_records = {
    "a-unifi"                                           = { name = "unifi", type = "A", content = "67.207.87.138" }
    "aaaa-unifi"                                        = { name = "unifi", type = "AAAA", content = "2604:a880:400:d1:0:4:8533:d001" }
    "caa-apex-issue-letsencrypt"                        = { name = "@", type = "CAA", data = { flags = 0, tag = "issue", value = "letsencrypt.org" } }
    "caa-apex-issue-pki"                                = { name = "@", type = "CAA", data = { flags = 0, tag = "issue", value = "pki.goog" } }
    "caa-apex-issuewild-letsencrypt"                    = { name = "@", type = "CAA", data = { flags = 0, tag = "issuewild", value = "letsencrypt.org" } }
    "caa-apex-issuewild-pki"                            = { name = "@", type = "CAA", data = { flags = 0, tag = "issuewild", value = "pki.goog" } }
    "caa-apex-iodef-mailto"                             = { name = "@", type = "CAA", data = { flags = 128, tag = "iodef", value = "mailto:sslabuse@desertbluffs.com" } }
    "cname-ec25ukpzz6h4nddab3jyevcnzmmmbrgm._domainkey" = { name = "ec25ukpzz6h4nddab3jyevcnzmmmbrgm._domainkey", type = "CNAME", content = "ec25ukpzz6h4nddab3jyevcnzmmmbrgm.dkim.amazonses.com" }
    "cname-gc4caluqqezmfk6xanwpdpw5eytglrkn._domainkey" = { name = "gc4caluqqezmfk6xanwpdpw5eytglrkn._domainkey", type = "CNAME", content = "gc4caluqqezmfk6xanwpdpw5eytglrkn.dkim.amazonses.com" }
    "cname-ptusb247sybmwk4i32j5lmagtmtqq7qi._domainkey" = { name = "ptusb247sybmwk4i32j5lmagtmtqq7qi._domainkey", type = "CNAME", content = "ptusb247sybmwk4i32j5lmagtmtqq7qi.dkim.amazonses.com" }
    "cname-zb14086362"                                  = { name = "zb14086362", type = "CNAME", content = "zmverify.zoho.com" }
    "mx-apex-mx"                                        = { name = "@", type = "MX", content = "mx.zoho.com", priority = 10 }
    "mx-apex-mx2"                                       = { name = "@", type = "MX", content = "mx2.zoho.com", priority = 20 }
    "mx-apex-mx3"                                       = { name = "@", type = "MX", content = "mx3.zoho.com", priority = 50 }
    "mx-ses"                                            = { name = "ses", type = "MX", content = "feedback-smtp.us-east-1.amazonses.com", priority = 10 }
    "txt-wildcard"                                      = { name = "*", type = "TXT", content = "v=spf1 -all" }
    "txt-apex-google"                                   = { name = "@", type = "TXT", content = "google-site-verification=NNYObey8Yje_tBPGc8bIsGlU5ii5KAePBJvDVGO2S9M" }
    "txt-apex-spf"                                      = { name = "@", type = "TXT", content = "v=spf1 mx include:zoho.com include:ses.desertbluffs.com ~all" }
    "txt-_amazonses"                                    = { name = "_amazonses", type = "TXT", content = "nOSqNz6GuHWUV/GdUWiXEWRTTRMK/ibv6afYRtn5WtU=" }
    "txt-_dmarc"                                        = { name = "_dmarc", type = "TXT", content = "v=DMARC1; p=reject; pct=100; rua=mailto:itadso9z@ag.us.dmarcian.com" }
    "txt-ses"                                           = { name = "ses", type = "TXT", content = "v=spf1 include:amazonses.com ~all" }
    "txt-zoho._domainkey"                               = { name = "zoho._domainkey", type = "TXT", content = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCIqHMhuUXI0KCxNVfkJpHSKVKqFFGi5zB2xmnvsz6tkKNSUHpDLUg2PXy3xkSep9V0XKMjD8zWSRcjFUCj/JB0d3WGdJ7RblrKDpMqkj4M8dWJPCkCrLFLw2ET6D2eCx0W/zrW1foAP/HcXv10QYiE5iOh+dUNHTyLFTHJzzVnoQIDAQAB" }
  }
}
