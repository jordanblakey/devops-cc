provider "mongodbatlas" {
  public_key  = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
  version     = "~> 0.7"
}

# Cluster

# DB User

# IP Whitelist