### GENERAL
variable "app_name" {
  type = string
}

### ATLAS
variable "mongodbatlas_public_key" {
  type = string
}
variable "mongodbatlas_private_key" {
  type = string
}
variable "atlas_user_password" {
  type = string
}

variable "atlas_project_id" {
  type = string
}

### GCP
variable "gcp_machine_type" {
  type = string
}

### CloudFlare
variable "cloudflare_api_token" {
  type = string
}

variable "cloudflare_email" {
  type = string
}

variable "domain" {
  type = string
}