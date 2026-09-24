resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = local.vpc_final_tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # here vpc ID associate with the internet gateway

  tags = local.igw_final_tags
}

#creating public subnets
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets_cidrs[count.index]
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
  count = length(var.private_subnets_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnets_cidrs[count.index]
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
  count = length(var.database_subnets_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnets_cidrs[count.index]
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


#  here we are giving the internet access to the public subnets through internet gateway
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

# we are creating the elastic ip to assign to the NAT Gateway
resource "aws_eip" "nat" {
  domain                    = "vpc"

  tags =  merge(
    local.common_tags,
    #roboshop-dev-nat
    {
      Name = "${var.project}-${var.environment}-nat"
    },
    var.eip_tags
  )
  
}

#creating the NAT Gateway

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnets[0].id
  #creating nat gateway in public subnet in only one zone us-east-1

  tags = merge(
    local.common_tags,
    #roboshop-dev
    {
      Name = "${var.project}-${var.environment}"
    },
    var.nat_gateway_tags
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main] #Nat Gateway is depending on the IG 
}


#here providing internet access to the both private and database subnets through NAT Gateway
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

#associating the route tables with the subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets_cidrs)
  subnet_id      = aws_subnet.public.id[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets_cidrs)
  subnet_id      = aws_subnet.private.id[count.index]
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnets_cidrs)
  subnet_id      = aws_subnet.database.id[count.index]
  route_table_id = aws_route_table.database.id
}





