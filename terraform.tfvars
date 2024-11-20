# VPC CIDR block
vpc_cidr_block = "10.1.0.0/16"

# CIDR blocks for public subnets
public_subnet_cidrs = [
  "10.1.1.0/28",  # Public Subnet 1
  "10.1.1.16/28"  # Public Subnet 2
]

# CIDR blocks for private subnets
private_subnet_cidrs = [
  "10.1.2.0/28",  # Private Subnet 1
  "10.1.2.16/28", # Private Subnet 2
  "10.1.2.32/28", # Private Subnet 3
  "10.1.2.48/28"  # Private Subnet 4
]

# Availability zones
availability_zones = ["eu-west-1a", "eu-west-1b"]

# Tags
default_tags = {
  Project     = "Three-Tier-App"
  Environment = "Production"
  Owner       = "DevOps Team"
}

# AMI's
image_id = "ami-0d64bb532e0502c46"


