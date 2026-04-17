## AWS infrastructure for hosting ObliczaKalisza app build with Terraform
*only for demonstration purposes*

Application [repository](#https://github.com/dhpasta/ObliczaKalisza)

### Features:
- **variables** - parameters necessary for configuration can be loaded as variables, paths for aws credentials and key pair are omitted in this repository,
- **VPC** - defined network for services communication and remote connection with EC2 instance,
- **EC2** - Ubuntu based AWS instance with local key pair loaded for communication over SSH. Simple script `init.sh` is provided for initial configuration and app installation from repository,
- **IAM** - IAM role for EC2 is created with policies allowing secret manager and instance data access,
- **RDS** - MySQL database is created, authentication credentials are stored in secret manager and initial schema is loaded by `init.sh`,
- **output** - necessary data for connection with instance and database are exported.

### Usage:
- in `terraform.tfvars` change `aws_region` and `instance_type` for prefered. Change other values if needed,
- create `local.auto.tfvars` file and assign values to `credentials_files` and `key_filename`, according to variables description,
- `init` and `apply` Terraform configuration,
- wait until EC2 is initialized and `init.sh` is executed completely, Terraform will check for instance to be accessible,
- access running application by visiting outputted `ec2_public_ip`.

### init.sh
Bash script provided on EC2 launch:
- installs MySQL client for database manual inspections,
- installs and enables Docker for app activation,
- clones app repository,
- configures app files and builds up containers with application.

---
Provided under the terms of the [Apache License](LICENSE).
