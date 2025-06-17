variable "PROJECT_ID" {
  type = string
}

variable "REGION" {
    type = string
}

variable "machine_type" {
    type = string
    default = "e2-micro"
}

variable "total_min_node_count" {
  type = number
  default = 1
}

variable "total_max_node_count" {
  type = number
  default = 2  
}

variable "google_service_account_email" {
  type = string
}