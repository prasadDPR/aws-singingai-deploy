variable "private_key_path" {
  description = "Path to the SSH private key file"
}

variable "db_password" {
  description = "RDS master password"
  sensitive   = true
}

variable "my_ip" {
  description = "Your IP address for SSH access (format: x.x.x.x/32)"
}

variable "groq_api_key" {
  description = "Groq API key for LLM feedback"
  sensitive   = true
}

variable "google_client_id" {
  description = "Google OAuth client ID"
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth client secret"
  sensitive   = true
}

variable "session_secret" {
  description = "Session secret for cookie signing"
  sensitive   = true
}