terraform {
  backend "gcs" {
    bucket  = "vaticle-web-prod-terraform-state"
    prefix  = "terraform/consul"
  }
}

provider "google" {
  project = "vaticle-web-prod"
  region  = "europe-west2"
  zone    = "europe-west2-b"
}

resource "google_compute_firewall" "consul_api_firewall" {
  name    = "consul-api-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8300"]
  }

  target_tags = ["consul"]
}

resource "google_compute_address" "consul_static_ip" {
  name = "consul-static-ip"
}

resource "google_compute_disk" "consul_additional" {
  name  = "consul-additional"
  type  = "pd-ssd"
}

resource "google_compute_instance" "consul" {
  name                      = "consul"
  machine_type              = "n1-standard-2"

  boot_disk {
    initialize_params {
      image = "vaticle-web-prod/consul-1591ddda0e08f7d26a1351ced111695732327ce0"
    }
    device_name = "boot"
  }

  attached_disk {
    source = google_compute_disk.consul_additional.name
    device_name = "consul-additional"
  }

  service_account {
    email = "grabl-prod@vaticle-web-prod.iam.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.consul_static_ip.address
    }
  }

  tags = ["consul"]

  metadata_startup_script = file("${path.module}/startup/startup-consul.sh")
}
