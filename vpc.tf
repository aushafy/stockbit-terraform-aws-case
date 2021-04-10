// This file was made by Muhammad Aushafy Setyawan for DevOps test case

resource "aws_vpc" "devops_vpc" {
  cidr_block = "10.0.0.0/16"

   tags = {
    Name = "devops_vpc"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.devops_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "private_subnet"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.devops_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_natgw.id
  subnet_id     = aws_subnet.public_subnet.id
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "nat_gw"
  }
}

resource "aws_eip" "eip_natgw" {
  vpc = true

  tags = {
    Name = "eip_natgw"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
      Name = "igw"
  }
}

// Route Table Section both Public and Private Subnet
resource "aws_route_table" "public_to_igw" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_to_igw"
  }
}

resource "aws_route_table" "private_to_natgw" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private_to_natgw"
  }
}

// Route Table Subnet Association both Private and Public
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_to_igw.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_to_natgw.id
}