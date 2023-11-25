variable "application_name" {}
variable "public_subnets" {}
variable "vpc_id" {}
variable "ami_id" {
    default = "ami-0fc5d935ebf8bc3bc"
}
variable "db_host" {}
variable "profile_name" {}
variable "private_subnet_a_id" {}
variable "private_subnet_b_id" {}
variable "project_db" {}
variable "public_subnet_a_id" {}