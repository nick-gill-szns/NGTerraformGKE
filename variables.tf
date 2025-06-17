variable "PROJECT_ID" {
  type = string
}

variable "REGION" {
  type = string
}

variable "env" {
  type        = string
  description = "the environment where the clusters exist (dev, prod)"
  ephemeral   = true
}

variable "deletion_protection" {
  type        = bool
  description = "True if terraform is not allowed to delete compute"
  default     = false
}

variable "github_access_token" {
  type        = string
  description = "Secret Access Token"
}