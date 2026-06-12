# ── INFRASTRUCTURE VARIABLES ──────────────────────────────────────────────────

variable "private_key_path" {
  description = "Path to the SSH private key file for bastion host access"
  type        = string
}

variable "my_ip" {
  description = "Admin IP address for SSH access to bastion host (format: x.x.x.x/32)"
  type        = string
}

# ── DATABASE VARIABLES ────────────────────────────────────────────────────────

variable "db_password" {
  description = "RDS PostgreSQL master password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "Database password must be at least 8 characters."
  }
}

# ── APPLICATION SECRETS ───────────────────────────────────────────────────────

variable "groq_api_key" {
  description = "Groq API key for LLM coaching feedback and Whisper transcription"
  type        = string
  sensitive   = true
}

variable "google_client_id" {
  description = "Google OAuth 2.0 client ID for social login"
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth 2.0 client secret for social login"
  type        = string
  sensitive   = true
}

variable "session_secret" {
  description = "Secret key for signing session cookies — must be random and long"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.session_secret) >= 32
    error_message = "Session secret must be at least 32 characters for security."
  }
}
