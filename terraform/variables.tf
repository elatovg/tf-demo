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

/*
Required Variables
These must be provided at runtime.
*/

variable "region" {
  description = "The region in which to create Demo"
  type        = "string"
}

variable "project" {
  description = "The name of the project in which to create the demo."
  type        = "string"
}

variable "mig-machine-type" {
  description = "Machine type to use for the instance template"
  type        = "string"
  default     = "f1-micro"
}

# variable "start-up-url" {
#   description = "Specify startup script for the instance"
#   type        = "string"
#   default     = "gs://your_storage_bucket/startup.sh"
# }

# variable "network" {
#   description = "VPC to use for the demo"
#   type        = "string"
#   default     = "default"
# }

variable "target_tags" {
  description = "Network Tags to add to Instance Template"
  type        = "list"
  default     = ["ilb-web"]
}
