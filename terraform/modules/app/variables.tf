variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the pivate key used for ssh access"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable app_name {
  description = "Application name"
}

variable app_disk_image {
  description = "Disk image for reddit app"
}

variable puma_rule_name {
  description = "Puma allow rule name"
}

variable db_address {
  default = "127.0.0.1"
}
