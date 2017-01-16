resource "aws_instance" "atlas-test-windows-instance" {
  ami           = "ami-bdb618dd"
  instance_type = "t2.micro"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
  monitoring    = "true"

  #ebs_optimized           = "true"
  associate_public_ip_address = "true"
  disable_api_termination     = "false"
}
