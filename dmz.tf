# Define the public subnets
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.main_vpc.id}"
  cidr_block              = "${cidrsubnet(var.cidr, 6, count.index + 10)}"
  availability_zone       = "${element(split(",", var.zones), count.index)}"
  map_public_ip_on_launch = true
  count                   = "${length(split(",", var.zones))}"

  tags = {
    Name        = "${var.environment}-public-subnet-${element(split(",", var.zones), count.index)}"
    Environment = "${var.environment}"
  }
}

# Route table for DMZ  
resource "aws_route_table" "public_routetable" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  tags {
    Name        = "Public Subnet RouteTable"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "dmz_igw_route" {
  route_table_id         = "${aws_route_table.public_routetable.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  depends_on             = ["aws_route_table.public_routetable"]
}

resource "aws_route_table_association" "default_public_rta" {
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_routetable.id}"
  count          = "${length(split(",", var.zones))}"
}

output "public_route_table" {
  value = "${aws_route_table.public_routetable.id}"
}

output "public_subnets" {
  value = ["${aws_subnet.public_subnet.*.id}"]
}
