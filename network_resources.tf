# VPC
resource "aws_vpc" "three-tier-vpc" {
  cidr_block = var.vpc_cidr_block
  tags       = merge(var.default_tags, { Name = "three-tier-vpc" })
}

# Public Subnets
resource "aws_subnet" "three-tier-pub-sub-1" {
  vpc_id                  = aws_vpc.three-tier-vpc.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = merge(var.default_tags, { Name = "three-tier-pub-sub-1" })
}

resource "aws_subnet" "three-tier-pub-sub-2" {
  vpc_id                  = aws_vpc.three-tier-vpc.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = merge(var.default_tags, { Name = "three-tier-pub-sub-2" })
}

# Private Subnets
resource "aws_subnet" "three-tier-pvt-sub-1" {
  vpc_id                  = aws_vpc.three-tier-vpc.id
  cidr_block              = var.private_subnet_cidrs[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = merge(var.default_tags, { Name = "three-tier-pvt-sub-1" })
}

resource "aws_subnet" "three-tier-pvt-sub-2" {
  vpc_id                  = aws_vpc.three-tier-vpc.id
  cidr_block              = var.private_subnet_cidrs[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = merge(var.default_tags, { Name = "three-tier-pvt-sub-2" })
}

resource "aws_subnet" "three-tier-pvt-sub-3" {
  vpc_id                  = aws_vpc.three-tier-vpc.id
  cidr_block              = var.private_subnet_cidrs[2]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = merge(var.default_tags, { Name = "three-tier-pvt-sub-3" })
}

resource "aws_subnet" "three-tier-pvt-sub-4" {
  vpc_id                  = aws_vpc.three-tier-vpc.id
  cidr_block              = var.private_subnet_cidrs[3]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = merge(var.default_tags, { Name = "three-tier-pvt-sub-4" })
}

# Route Tables
resource "aws_route_table" "three-tier-web-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.three-tier-igw.id
  }

  tags = merge(var.default_tags, { Name = "three-tier-web-rt" })
}

resource "aws_route_table" "three-tier-app-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.three-tier-natgw-01.id
  }

  tags = merge(var.default_tags, { Name = "three-tier-app-rt" })
}

# Route Table Associations
resource "aws_route_table_association" "three-tier-rt-as-1" {
  subnet_id      = aws_subnet.three-tier-pub-sub-1.id
  route_table_id = aws_route_table.three-tier-web-rt.id
}

resource "aws_route_table_association" "three-tier-rt-as-2" {
  subnet_id      = aws_subnet.three-tier-pub-sub-2.id
  route_table_id = aws_route_table.three-tier-web-rt.id
}

resource "aws_route_table_association" "three-tier-rt-as-3" {
  subnet_id      = aws_subnet.three-tier-pvt-sub-1.id
  route_table_id = aws_route_table.three-tier-app-rt.id
}

resource "aws_route_table_association" "three-tier-rt-as-4" {
  subnet_id      = aws_subnet.three-tier-pvt-sub-2.id
  route_table_id = aws_route_table.three-tier-app-rt.id
}

resource "aws_route_table_association" "three-tier-rt-as-5" {
  subnet_id      = aws_subnet.three-tier-pvt-sub-3.id
  route_table_id = aws_route_table.three-tier-app-rt.id
}

resource "aws_route_table_association" "three-tier-rt-as-6" {
  subnet_id      = aws_subnet.three-tier-pvt-sub-4.id
  route_table_id = aws_route_table.three-tier-app-rt.id
}

# Create an Elastic IP address for the NAT Gateway
resource "aws_eip" "three-tier-nat-eip" {
  
  tags = {
    Name = "three-tier-nat-eip"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "three-tier-igw" {
  vpc_id = aws_vpc.three-tier-vpc.id

  tags = merge(var.default_tags, { Name = "three-tier-igw" })
}

# NAT Gateway
resource "aws_nat_gateway" "three-tier-natgw-01" {
  allocation_id = aws_eip.three-tier-nat-eip.id
  subnet_id     = aws_subnet.three-tier-pub-sub-1.id
  depends_on    = [aws_internet_gateway.three-tier-igw]

  tags = merge(var.default_tags, { Name = "three-tier-natgw-01" })
}
