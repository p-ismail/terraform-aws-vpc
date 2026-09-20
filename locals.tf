locals {
  common_tags = {
    Project = var.project
    Environment = var.environment
    Terraform = true
  }

  vpc_final_tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}"
    },
    var.vpc_tags
  )

  igw_final_tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}"
    },
    var.vpc_tags
  )

  avzns_names = slice(data.aws_availability_zones.available.names, 0, 2)

# here we will get us-east-1a and us-east-1b from the data.tf
}