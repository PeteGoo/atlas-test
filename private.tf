# Define the private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.main_vpc.id}"
  cidr_block              = "${cidrsubnet(var.cidr, 6, count.index + 3)}"
  availability_zone       = "${element(split(",", var.zones), count.index)}"
  map_public_ip_on_launch = false
  count                   = "${length(split(",", var.zones))}"

  tags = {
    Name        = "${var.environment}-private-subnet-${element(split(",", var.zones), count.index)}"
    Environment = "${var.environment}"
  }
}

# Define the private database cluster subnet
resource "aws_subnet" "private_db_subnet" {
  vpc_id                  = "${aws_vpc.main_vpc.id}"
  cidr_block              = "${cidrsubnet(var.cidr, 6, count.index + 6)}"
  availability_zone       = "${element(split(",", var.zones), count.index)}"
  map_public_ip_on_launch = false
  count                   = "${length(split(",", var.zones))}"

  tags = {
    Name        = "${var.environment}-private-db-subnet-${element(split(",", var.zones), count.index)}"
    Environment = "${var.environment}"
  }
}

# Create an elastic-ip for the NAT gateway
resource "aws_eip" "nat" {
  vpc = true

  #count = "${length(split(",", var.zones))}"
  count = "${var.multi_az_nat == "false" ? 1 : length(split(",", var.zones)) }"
}

# Create a NAT gateway to allow outbound traffic from the private subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.igw", "aws_eip.nat"]

  #count = "${length(split(",", var.zones))}"

  count = "${var.multi_az_nat == "false" ? 1 : length(split(",", var.zones)) }"
}

# Route table for Internal with NAT gateway
resource "aws_route_table" "private_routetable" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  tags {
    Name        = "Private Subnet RouteTable"
    Environment = "${var.environment}"
  }

  count = "${length(split(",", var.zones))}"
}

resource "aws_route" "private_nat_route" {
  route_table_id         = "${element(aws_route_table.private_routetable.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  depends_on             = ["aws_route_table.private_routetable"]
  count                  = "${length(split(",", var.zones))}"
}

resource "aws_route_table_association" "default_private_rta" {
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_routetable.*.id, count.index)}"
  count          = "${length(split(",", var.zones))}"
}
