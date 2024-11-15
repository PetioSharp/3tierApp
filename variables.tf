variable "aws_region" {
    type = string
  }

variable "aws_profile" {
  type = string
}

variable "default_tags" {
  type = map(string)
}

# Define the VPC CIDR block
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Define CIDR blocks for public subnets
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/28", "10.0.1.16/28"]
}

# Define CIDR blocks for private subnets
variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  default     = ["10.0.2.0/28", "10.0.2.16/28", "10.0.2.32/28", "10.0.2.48/28"]
}

# Define availability zones
variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  default     = ["eu-west-1a", "eu-west-1b"]
}

# Define AMI ID
variable "image_id" {
  description = "The AMI ID for the EC2 instances in the ASG"
  type        = string
  default     = "ami-0d64bb532e0502c46"  
}

# Define EC2 instance type
variable "instance_type" {
  description = "The instance type for the EC2 instance in ASG"
  type        = string
  default     = "t2.micro"
}