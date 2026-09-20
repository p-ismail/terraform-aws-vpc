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
  availability_zone = local.avzns_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    #roboshop-dev-public-us-east-1a
    {
      Name = "${var.project}-${var.environment}-public- ${local.avzns_names[count.index]}"
    },
    var.public_subnet_tags
  )
  }

#creating private subnets
resource "aws_subnet" "private_subnets" {
  count = length(var.private_sunets_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_sunets_cidrs[count.index]
  availability_zone = local.avzns_names[count.index]

  tags = merge(
    local.common_tags,
    #roboshop-dev-private-us-east-1a
    {
      Name = "${var.project}-${var.environment}-private- ${local.avzns_names[count.index]}"
    },
    var.private_subnet_tags
  )
  }

#creating database subnets
resource "aws_subnet" "database_subnets" {
  count = length(var.database_sunets_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_sunets_cidrs[count.index]
  availability_zone = local.avzns_names[count.index]

  tags = merge(
    local.common_tags,
    #roboshop-dev-database-us-east-1a
    {
      Name = "${var.project}-${var.environment}-database- ${local.avzns_names[count.index]}"
    },
    var.database_subnet_tags
  )
  }


  resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

 
  tags =  merge(
    local.common_tags,
    #roboshop-dev-public
    {
      Name = "${var.project}-${var.environment}-public"
    },
    var.public_route_table_tags
  )
}

  resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

 
  tags =  merge(
    local.common_tags,
    #roboshop-dev-private
    {
      Name = "${var.project}-${var.environment}-private"
    },
    var.private_route_table_tags
  )
}

  resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

 
  tags =  merge(
    local.common_tags,
    #roboshop-dev-database
    {
      Name = "${var.project}-${var.environment}-database"
    },
    var.databse_route_table_tags
  )
}

