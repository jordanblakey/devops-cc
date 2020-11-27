provider "cloudflare" {
  version = "~> 2.0"
  token = "var.cloudflare_api_token"
}

# DNS Zone

# DNS A Record