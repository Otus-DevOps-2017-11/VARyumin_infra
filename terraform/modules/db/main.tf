data "template_file" "mongod-config" {
  template = "${file("${path.module}/files/mongod.conf.tpl")}"

  vars {
    mongo_ip = "0.0.0.0"
  }
}

resource "google_compute_instance" "db" {
  name         = "${var.db_name}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-db"]

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    sshKeys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file("${var.private_key_path}")}"
  }

  provisioner "file" {
    content     = "${data.template_file.mongod-config.rendered}"
    destination = "/tmp/mongod.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/mongod.conf /etc/mongod.conf",
      "sudo systemctl restart mongod",
    ]
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "${var.mongo_rule_name}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  # правило применимо к инстансам с тегом ...
  target_tags = ["reddit-db"]

  #  порт будет доступен только для инстансов с тегом ...
  source_tags = ["reddit-app"]
}
