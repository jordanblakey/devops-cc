provider "cloudflare" {
  version = "~> 2.0"
  api_token = var.cloudflare_api_token
  email = var.cloudflare_email
}

# DNS Zone
data "cloudflare_zones" "cf_zones" {
  count = 1
  filter {
    name = var.domain
  }
}


# DNS A Record
resource "cloudflare_record" "dns_record" {
  zone_id = data.cloudflare_zones.cf_zones[0].id
  name = "storybooks${terraform.workspace == "prod" ? "" : "-${terraform.workspace}" }"
  value = google_compute_address.ip_address.address
  type = "A"
  proxied = true
}