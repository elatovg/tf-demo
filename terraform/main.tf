/*
Copyright 2019 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

///////////////////////////////////////////////////////////////////////////////////////
// This configuration will create an client gce VM, ILB, and Managed Instance Group
///////////////////////////////////////////////////////////////////////////////////////

resource "random_id" "gce" {
  byte_length = 4
  prefix      = "tf-compute-"
}

data "google_compute_zones" "available" {
  project = var.project
  region  = var.region
}

// Randomize the Zone Choice
resource "random_shuffle" "gz" {
  input        = data.google_compute_zones.available.names
  result_count = 1
}

locals {
  random_zone = random_shuffle.gz.result[0]
}

// Select Image to use for GCE and MIG
data "google_compute_image" "base_image" {
  family  = "debian-10"
  project = "debian-cloud"
}

resource "google_compute_network" "vpc_network" {
  name                    = "custom"
  project                 = var.project
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.region
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

// Create the GCE instance
resource "google_compute_instance" "demo-gce" {
  zone         = local.random_zone
  name         = random_id.gce.hex
  machine_type = "f1-micro"
  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.base_image.project}/${data.google_compute_image.base_image.family}"
      //     image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    // Include this section to give the VM an external ip address
    #  access_config = {}
  }
}

// Create Instance Template
resource "google_compute_instance_template" "tf-mig-template" {
  name_prefix  = "tf-mg-tmplt-"
  machine_type = var.mig-machine-type
  region       = var.region

  // Give minimal scopes to run as
  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

  // boot disk
  disk {
    source_image = "${data.google_compute_image.base_image.project}/${data.google_compute_image.base_image.family}"
    auto_delete  = true
    boot         = true
  }

  // Add metadata
  # metadata {
  #   startup-script-url = "${var.start-up-url}"
  # }

  tags = var.target_tags
  // Add internal IP
  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    // External IP
    # access_config = {}
  }

  // Recommended for doing updates with new Images for MIGs
  lifecycle {
    create_before_destroy = true
  }
}

// Create the MIG
resource "google_compute_instance_group_manager" "webservers" {
  name = "webservers-mig"
  version {
    instance_template = google_compute_instance_template.tf-mig-template.self_link
  }
  base_instance_name = "web"
  zone               = local.random_zone
  target_size        = "1"
}

// Add firewall rule to allow health checks
//resource "google_compute_firewall" "hc-fw" {
//  name    = "allow-health-check"
//  network = "${var.network}"
//
//  allow {
//    protocol = "tcp"
//    ports    = ["80"]
//  }
//
//  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
//  target_tags   = ["${var.target_tags}"]
//}

// Add firewall rule to allow other internal resources to reach it
//resource "google_compute_firewall" "mig-fw" {
//  name    = "allow-http"
//  network = "${var.network}"
//
//  allow {
//    protocol = "tcp"
//    ports    = ["80"]
//  }
//
//  source_ranges = ["10.128.0.0/9"]
//  target_tags   = ["${var.target_tags}"]
//}
//
// Add health check for the MIG
resource "google_compute_health_check" "mig-hc-http" {
  name    = "mig-http"
  project = var.project
  http_health_check {
    port = "80"
  }
}

// Add Regional Backend pointing to Instance Group Above
resource "google_compute_region_backend_service" "ilb-backend-service" {
  name                            = "ilb-be"
  protocol                        = "TCP"
  timeout_sec                     = 25
  connection_draining_timeout_sec = 10
  session_affinity                = "CLIENT_IP"
  region                          = var.region

  backend {
    group = google_compute_instance_group_manager.webservers.instance_group
  }

  health_checks = ["${google_compute_health_check.mig-hc-http.self_link}"]
}

// Add an internal Forwarding Rule to the backend service
resource "google_compute_forwarding_rule" "ilb-fw-rule" {
  name                  = "ilb-fw-rule"
  region                = var.region
  network               = google_compute_network.vpc_network.name
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.ilb-backend-service.self_link
  ip_protocol           = "TCP"
  ports                 = ["80"]
}

resource "google_project_service" "compute" {
  project            = var.project
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}
