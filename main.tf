terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.96.0"  
    }
  }
}

provider "aws" {
  region = "us-east-1" 
}

#VPC and subnet creation
resource "aws_vpc" "dreVpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dreVpc.id
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.dreVpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index % 2)
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.dreVpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index % 2)

}

resource "aws_route_table" "publicRTB" {
  vpc_id = aws_vpc.dreVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table" "privateRTB" {
  vpc_id = aws_vpc.dreVpc.id
}


resource "aws_route_table_association" "publicRoutes" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.publicRTB.id
}
resource "aws_route_table_association" "privateRoutes" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.privateRTB.id
}
