resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = local.vpc_final_tags
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id # here vpc ID associate with the internet gateway

  tags = local.igw_final_tags
}

#creating public subnets
resource "aws_subnet" "public_subnets" {
  count = length(var.public_sunets_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_sunets_cidrs[count.index]

  tags = {
    Name = "Main"
  }
}

