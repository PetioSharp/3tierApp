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

# Load balancer - web tier
resource "aws_lb" "three-tier-web-aws-lb" {
  name                   = "three-tier-web-lb"
  internal               = false
  load_balancer_type     = "application" 

  security_groups = [aws_security_group.three-tier-alb-sg-1.id ]
  subnets         = [aws_subnet.three-tier-pub-sub-1.id, aws_subnet.three-tier-pub-sub-2.id]

  tags = merge(var.default_tags, {Environement = "three-tier-web-lb" })
}

# Load balancer - app tier
resource "aws_lb" "three-tier-app-aws-lb" {
  name                   = "three-tier-app-lb"
  internal               = true
  load_balancer_type     = "network"
  
  security_groups = [aws_security_group.three-tier-ec2-asg-sg-app.id]
  subnets         = [aws_subnet.three-tier-pvt-sub-3.id, aws_subnet.three-tier-pvt-sub-4.id]

  tags = merge(var.default_tags, {Environement = "three-tier-app-lb"}) 
}


# SG for the Load Balancer
resource "aws_security_group" "three-tier-alb-sg-1" {
  name        = "three-tier-alb-sg-1"
  description = "SG for Application Load Balancer"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP traffic from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "three-tier-alb-sg-1"
  }
}

# Load balancer target group -web tier
resource "aws_lb_target_group" "three-tier-web-lb-tg" {
  name            = "three-tier-web-lb-tg"
  port            = 80
  protocol        = "HTTP"
  vpc_id          = aws_vpc.three-tier-vpc.id 

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  
}

# Load balancer target group -app tier
resource "aws_lb_target_group" "three-tier-app-lb-tg" {
  name             = "three-tier-app-lb-tg"
  port             = 80
  protocol         = "TCP"
  vpc_id           = aws_vpc.three-tier-vpc.id 

  health_check {
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    
  }
  
}

# Load balancer listener -web tier
resource "aws_lb_listener" "three-tier-web-lb-listner" {
  load_balancer_arn     = aws_lb.three-tier-web-aws-lb.arn
  port                  =  80
  protocol              = "HTTP"
  default_action {
    type                = "forward"
    target_group_arn    =  aws_lb_target_group.three-tier-web-lb-tg.arn
  }  
  
}

# Load balancer listener -app tier
resource "aws_lb_listener" "three-tier-app-lb-listener" {
  load_balancer_arn       = aws_lb.three-tier-app-aws-lb.arn
  port                    = 80
  protocol                = "TCP"

  default_action {
    type                  = "forward"
    target_group_arn = aws_lb_target_group.three-tier-app-lb-tg.arn  
  } 
  
}

# IAM Role allow updating packages

resource "aws_iam_instance_profile" "three-tier-instance-profile" {
  name = "three-tier-instance-profile"
  role = aws_iam_role.three-tier-role.name
}

resource "aws_iam_role" "three-tier-role" {
  name = "three-tier-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "three-tier-policy" {
  name   = "three-tier-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ec2:Describe*", "s3:GetObject"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "three-tier-attach" {
  role       = aws_iam_role.three-tier-role.name
  policy_arn = aws_iam_policy.three-tier-policy.arn
}



# # Register the instances with the target group - web tier
# resource "aws_autoscaling_attachment" "three-tier-web-asattach" {
#   autoscaling_group_name = aws_autoscaling_group.three-tier-asg.name
#   target_group_arn       = aws_lb_target_group.three-tier-web-lb-tg.arn
# }