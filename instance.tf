resource "aws_instance" "marjo_test-windows-domainjoined-instance" {
  ami           = "ami-bdb618dd"
  instance_type = "t2.micro"
  subnet_id     = "${element(aws_vpc.main_vpc.public_subnets, 0)}"
  monitoring    = "true"

  #ebs_optimized           = "true"
  associate_public_ip_address = "true"
  disable_api_termination     = "false"
}
