# Terraform-Make

This build step provides a container with the build-essentials package
installed.  It is intended for running Make targets composed of shell commands,
such as targets that make modifications to a Dockerfile.

The entrypoint for this container is bash, so it is necessary to include the
whole make command.  For example:

    steps:
    - name: 'gcr.io/$PROJECT_ID/terraform-make
      args: ['remote']

To build it run the following:

    gcloud builds submit . --config=cloudbuild.yaml