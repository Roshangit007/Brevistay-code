# network.tf

# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/20"

   tags = {
    Name = "${var.env}-vpc"
  }
}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "private" {
  count             = var.priv-count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = "${var.env}-private-subnet"
  }
}

  

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "public" {
  count                   = var.pub-count
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, var.pub-count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-public-subnet"
  }
}
 

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

   tags = {
    Name = "${var.env}-IGW"
  }
}

/*# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
} */

# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "eip" {
  //count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "Nat-GW" {
  //count         = var.az_count
  //subnet_id     = element(aws_subnet.public.*.id, count.index)
 //allocation_id = element(aws_eip.gw.*.id, count.index)
    subnet_id     = aws_subnet.public[0].id
    allocation_id = aws_eip.eip.id

    tags = {
    Name = "${var.env}-NGW"
  }
}

# Route the public subnet traffic through the IGW
resource "aws_route_table" "public" {
  count  = var.pub-count
  vpc_id = aws_vpc.main.id
  #route_table_id         = aws_vpc.main.main_route_table_id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    "Name" = "${var.env}-RoutePublic-${count.index}"
  }
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
/*resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
  }
    tags = {
    Name = "brevistay-prod-route-private"
  }
} */

# Explicitly associate the newly created route tables to the public subnets (so they don't default to the main route table)
resource "aws_route_table_association" "public" {
  count          = var.pub-count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}


# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = var.priv-count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Nat-GW.id
  }

  tags = {
    "Name" = "${var.env}-RoutePrivate-${count.index}"
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = var.priv-count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

/*
# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
} */

