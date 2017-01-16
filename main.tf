/**
 * Creates a new vpc
 * stack.
 *
 * Usage:
 *
 *    module "main_vpc" {
 *      source      = "<relative path>"
 *      fqdn        = "playpen"
 *      environment = "playpen"
 *      vpc_id      = "sdsdfsd"
 *      subnet1_id  = "adfgsfg"
 *      subnet2_id  = "sdfgsdf"
 *    }
 *
 */

variable "cidr" {
  description = "the CIDR range for the cluster subnets"
  default     = "10.240.0.0/16"
}

variable "environment" {
  description = "the name of your environment, e.g. \"playpen\""
  default     = "atlas"
}

variable "zones" {
  description = "a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both internal_subnets and external_subnets have to be defined as well"
  default     = "us-west-2a, us-west-2b, us-west-2c"
}

variable "multi_az_nat" {
  description = "Boolean to define if the environment has for Multi availability zone Nat gateway or a single Nat gateway across availability zones. MultiAZ when equals true"
  default     = "false"
}

output "vpc_id" {
  value = "${aws_vpc.main_vpc.id}"
}

output "igw_id" {
  value = "${aws_internet_gateway.igw.id}"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  tags = {
    Name = "${var.environment}-igw"
  }
}
