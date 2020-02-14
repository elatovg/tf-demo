# Deploy Sample Resources with Terraform on GCP

## Table of Contents
* [Prerequisites](#prerequisites)
  * [Install Cloud SDK](#install-cloud-sdk)
  * [Install Terraform](#install-terraform)
  * [Configure Authentication](#configure-authentication)
* [Deployment](#deployment)
  * [Deploying the demo](#deploying-the-demo)
  * [How does Terraform work?](#how-does-terraform-work)
* [Validation](#validation)
* [Teardown](#teardown)
* [Troubleshooting](#troubleshooting)


## Prerequisites

1. [Terraform >= 0.11.7](https://www.terraform.io/downloads.html)
2. [Google Cloud SDK version >= 204.0.0](https://cloud.google.com/sdk/docs/downloads-versioned-archives)

You can obtain a [free trial of GCP](https://cloud.google.com/free/) if you need one

#### Install Cloud SDK
The Google Cloud SDK is used to interact with your GCP resources.
[Installation instructions](https://cloud.google.com/sdk/downloads) for multiple platforms are available online.

#### Install Terraform

Terraform is used to automate the manipulation of cloud infrastructure. Its
[installation instructions](https://www.terraform.io/intro/getting-started/install.html) are also available online.

### Configure Authentication

The Terraform configuration will execute against your GCP environment and deploy GCP resources. The configuration will 
use your personal account to build out these resources.  To setup the  default account the configuration will use, run 
the following command to select the appropriate account:

```console
$ gcloud auth application-default login
```

## Deployment

### Deploying The Demo

The infrastructure can be deployed by executing:
```console
make create
```

This will:
1. Read your project & zone configuration to generate a couple config files:
  * `./terraform/terraform.tfvars` for Terraform variables
2. Run `terraform init` to prepare Terraform to create the infrastructure
3. Run `terraform apply` to actually create the infrastructure & Stackdriver alert policy

If you need to override any of the defaults in the Terraform variables file, simply replace the desired value(s) to 
the right of the equals sign(s). Be sure your replacement values are still double-quoted.

If no errors are displayed then after a few minutes you should see your Sample Resources in the  
[GCP Console](https://console.cloud.google.com/kubernetes).

### How does Terraform work?

Following the principles of [Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_Code) and 
[Immutable Infrastructure](https://www.oreilly.com/ideas/an-introduction-to-immutable-infrastructure), Terraform 
supports the writing of declarative descriptions of the desired state of infrastructure. When the descriptor is 
applied, Terraform uses GCP APIs to provision and update resources to match. Terraform compares the desired state 
with the current state so incremental changes can be made without deleting everything and starting over.  For instance, 
Terraform can build out GCP projects and compute instances, etc., even set up a Kubernetes Engine cluster and deploy 
applications to it. When requirements change, the descriptor can be updated and Terraform will adjust the cloud 
infrastructure accordingly.

This example will create a Managed Instances Group and put an Internal Load Balancer in front of it

## Validation

Run the following to confirm the resources have been deployed:

```console
make validate
```

## Teardown

When you are finished with this example, and you are ready to clean up the resources that were created so that you 
avoid accruing charges, you can run the following command to remove all resources :

```
$ make teardown
```

This command uses the `terraform destroy` command to remove the infrastructure. Terraform tracks the resources it 
creates so it is able to tear them all back down.

## Troubleshooting

** The install script fails with a `Permission denied` when running Terraform.**
The credentials that Terraform is using do not provide the
necessary permissions to create resources in the selected projects. Ensure
that the account listed in `gcloud config list` has necessary permissions to
create resources. If it does, regenerate the application default credentials
using `gcloud auth application-default login`.
