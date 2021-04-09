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