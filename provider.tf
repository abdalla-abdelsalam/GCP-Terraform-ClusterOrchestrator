provider "google" {
  credentials = file("/home/mahdy/Downloads/abdallahmahdy-7f8fe1905045.json")
  project     = var.project-id
  region      = "us-central1"
}

