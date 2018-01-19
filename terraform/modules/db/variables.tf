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

variable db_name {
  description = "Application name"
}

variable db_disk_image {
  description = "Disk image for reddit db"
}

variable mongo_rule_name {
  description = "Mongo allow rule name"
}

variable mongo_ip {
  description = "MongoDB IP"
  default     = "127.0.0.1"
}
