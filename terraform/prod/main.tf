provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "app" {
  source           = "../modules/app"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  db_address       = "${module.db.db_internal_ip}"
  zone             = "${var.zone}"
  app_disk_image   = "${var.app_disk_image}"
  app_name         = "${var.app_name}"
  puma_rule_name   = "${var.puma_rule_name}"
}

module "db" {
  source           = "../modules/db"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  zone             = "${var.zone}"
  db_disk_image    = "${var.db_disk_image}"
  db_name          = "${var.db_name}"
  mongo_rule_name  = "${var.mongo_rule_name}"
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["46.188.72.15/32"]
}
