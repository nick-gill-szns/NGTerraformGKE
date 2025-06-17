variable "PROJECT_ID" {
  type = string
}

variable "REGION" {
    type = string
}

variable "github_access_token" {
    type = string
    description = "Secret Access Token"
}

variable "app_installation_id" {
    type = number
    default = 71615909
}

variable "google_service_account_email" {
    type = string
}