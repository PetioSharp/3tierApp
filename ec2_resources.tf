# Create an EC2 Auto Scaling Group - app
resource "aws_autoscaling_group" "three-tier-app-asg" {
  name                = "three-tier-app-asg"
  launch_template {
    id = aws_launch_template.three-tier-app-template.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.three-tier-pvt-sub-1.id, aws_subnet.three-tier-pvt-sub-2.id]
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2
  

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
resource "aws_launch_template" "three-tier-app-template"                                           {
  name_prefix         = "three-tier-app-template" 
  image_id            = var.image_id
  instance_type       = var.instance_type
  key_name            = "my-ec2-key-pair"

  network_interfaces {
    security_groups     = [aws_security_group.three-tier-ec2-asg-sg-app.id]
    associate_public_ip_address = true
  }
  
  user_data = base64encode(<<-EOF
  #!/bin/bash
  sudo yum install mysql -y
  EOF
  )
 

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }
  lifecycle {
    prevent_destroy = false
    ignore_changes  = all
  }

}
