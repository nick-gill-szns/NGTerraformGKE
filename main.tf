provider "google" {
  project = var.PROJECT_ID
  region  = var.REGION
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "my-context"
}

#Accounts - normally separate from CI/CD / separate process
resource "google_service_account" "default" {
  account_id   = "gke-service-account-id"
  display_name = "gke Service Account"
}

resource "google_project_iam_member" "storage_admin_member" {
  project = var.PROJECT_ID
    for_each = toset([
    "roles/storage.admin",
    "roles/artifactregistry.writer",
    "roles/logging.logWriter",
    "roles/container.admin",
  ])
  role    = each.key
  member  = "serviceAccount:${google_service_account.default.email}"
}

module "gke" {
  source                       = "./kub"
  PROJECT_ID                   = var.PROJECT_ID
  REGION                       = var.REGION
  google_service_account_email = google_service_account.default.email
}

module "cloudbuild" {
  source                       = "./build"
  PROJECT_ID                   = var.PROJECT_ID
  REGION                       = var.REGION
  github_access_token          = var.github_access_token
  google_service_account_email = google_service_account.default.email
}