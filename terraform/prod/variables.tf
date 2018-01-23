variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable app_disk_image {
  description = "Disk image for reddit app"
}

variable db_disk_image {
  description = "Disk image for reddit db"
}

variable app_name {
  description = "Application name"
}

variable puma_rule_name {
  description = "Puma allow rule name"
}

variable db_name {
  description = "Application name"
}

variable mongo_rule_name {
  description = "Mongo allow rule name"
}
