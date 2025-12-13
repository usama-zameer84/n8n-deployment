variable "billing_account_id" {
  description = "The alphanumeric ID of the billing account this project belongs to."
  type        = string
}

variable "project_name" {
  description = "The name of the project to create."
  type        = string
  default     = "n8n-automation"
}

variable "tunnel_token" {
  description = "Your Cloudflare Tunnel Token"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Your domain name for n8n (e.g., n8n.example.com)"
  type        = string
}

variable "timezone" {
  description = "Timezone for n8n (e.g., Europe/Berlin, America/New_York)"
  type        = string
  default     = "UTC"
}

variable "postgres_password" {
  description = "Password for the PostgreSQL database"
  type        = string
  sensitive   = true
  default     = "n8n_secure_password"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}