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

output "gce_name" {
  value = "${google_compute_instance.demo-gce.name}"
}

output "gce_zone" {
  value = "${google_compute_instance.demo-gce.zone}"
}

output "instance_template" {
  value = "${google_compute_instance_template.tf-mig-template.name}"
}

output "mig" {
  value = "${google_compute_instance_group_manager.webservers.name}"
}

//output "hc_fw_rule" {
//  value = "${google_compute_firewall.hc-fw.name}"
//}
//
//output "mig_fw_rule" {
//  value = "${google_compute_firewall.mig-fw.name}"
//}

output "hc_http" {
  value = "${google_compute_health_check.mig-hc-http.name}"
}

output "ilb_be" {
  value = "${google_compute_region_backend_service.ilb-backend-service.name}"
}

output "ilb_forward_rule" {
  value = "${google_compute_forwarding_rule.ilb-fw-rule.name}"
}

output "ilb_ip" {
  value = "${google_compute_forwarding_rule.ilb-fw-rule.ip_address}"
}