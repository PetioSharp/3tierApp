# Create an EC2 Auto Scaling Group - app
resource "aws_autoscaling_group" "three-tier-app-asg" {
  name                = "three-tier-app-asg"
  vpc_zone_identifier = [aws_subnet.three-tier-pvt-sub-1.id, aws_subnet.three-tier-pvt-sub-2.id]
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2
  launch_configuration = aws_launch_configuration.three-tier-app-lconfig.id

}

# Create a SG for App
resource "aws_security_group" "three-tier-ec2-asg-sg-app" {
  name                = "three-tier-ec2-asg-sg-app" 
  description         = "SG for EC2 instances in the App Auto Scaling Group"
  vpc_id              = aws_vpc.three-tier-vpc.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   tags = {
    Name = "three-tier-db-sg"
  }
}

# Create a launch configuration for the EC2 instances
resource "aws_launch_configuration" "three-tier-app-lconfig"                                           {
  name_prefix         = "three-tier-app-lconfig" 
  image_id            = var.image_id
  instance_type       = var.instance_type
  key_name            = "three-tier-app-asg-kp"
  security_groups     = [aws_security_group.three-tier-ec2-asg-sg-app.id]
  user_data           = <<-EOF
                        #!/bin/bash

                        sudo yum install mysql -y

                        EOF
  associate_public_ip_address = false
  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }

}
