resource "google_artifact_registry_repository" "my-repo" {
  location      = var.REGION
  repository_id = "my-repository"
  description   = "docker repository"
  format        = "DOCKER"
}


resource "google_secret_manager_secret" "github-token-secret" {
  secret_id = "github-token-secret"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "github-token-secret-version" {
  secret = google_secret_manager_secret.github-token-secret.id
  secret_data = var.github_access_token
}

data "google_iam_policy" "p4sa-secretAccessor" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    #TODO Make ID a Var
    members = ["serviceAccount:service-539035393972@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
  }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  secret_id = google_secret_manager_secret.github-token-secret.secret_id
  policy_data = data.google_iam_policy.p4sa-secretAccessor.policy_data
}

resource "google_cloudbuildv2_connection" "my-connection" {
  location = var.REGION
  name = "tf-test-connection"
  github_config {
    #TODO Make ID a var
    app_installation_id = 71615909

    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github-token-secret-version.id
    }
  }
}

resource "google_cloudbuildv2_repository" "my-repository" {
  location = var.REGION
  name = "GKE-Terraform-DummyProject"
  parent_connection = google_cloudbuildv2_connection.my-connection.name
  remote_uri = "https://github.com/nick-gill-szns/GKE-Terraform-DummyProject.git"
}

resource "google_cloudbuild_trigger" "build-trigger" {
  description = "Trigger for building and pushing Docker images"
  location = var.REGION
  service_account = "projects/${var.PROJECT_ID}/serviceAccounts/${var.google_service_account_email}"
  repository_event_config {
      repository = google_cloudbuildv2_repository.my-repository.id
      push {
        branch = "staging"
      }
    }
  build {
    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "us-east1-docker.pkg.dev/${var.PROJECT_ID}/my-repository/myimage", "."]
    }
  }
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}