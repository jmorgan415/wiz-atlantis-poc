# AWS Info
provider "google" {
  region      = var.config[terraform.workspace].region
  project     = var.config[terraform.workspace].project
  credentials = "/gcp.json"
}

# Create bucket
resource "google_storage_bucket" "demo" {
  name                        = var.config[terraform.workspace].bucket_name
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}
