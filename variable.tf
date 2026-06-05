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