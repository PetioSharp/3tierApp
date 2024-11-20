# Create an EC2 Auto Scaling Group - web
resource "aws_autoscaling_group" "three-tier-asg" {
  name                 = "three-tier-web-asg"
  launch_template {
    id      = aws_launch_template.three-tier-web-template.id
    version = "$Latest"
  } 
  vpc_zone_identifier  =  [aws_subnet.three-tier-pvt-sub-1.id, aws_subnet.three-tier-pvt-sub-2.id]
  min_size             = 2
  max_size             = 3
  desired_capacity     = 2    

  target_group_arns = [aws_lb_target_group.three-tier-web-lb-tg.arn]

  tag {
    key                 = "Name"
    value               = "three-tier-web-instance"
    propagate_at_launch = true
  }

}

# Create a SG for Web
resource "aws_security_group" "three-tier-ec2-asg-sg" {
  name                 =  "three-tier-ec2-asg-sg-web-unique"
  description          =  "Security group for EC2 Auto Scaling Group"
  vpc_id               =   aws_vpc.three-tier-vpc.id 

  ingress {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = [aws_security_group.bastion-sg.id] 
      self             = false
    }
  ingress {
    from_port          = 80
    to_port            = 80
    protocol           = "tcp"
    cidr_blocks        = ["0.0.0.0/0"]
    ipv6_cidr_blocks   = []
    prefix_list_ids    = []
    self               = false
  }

  egress {
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"] 
  }
  egress {
    from_port          = 0
    to_port            = 0
    protocol           = "-1"
    cidr_blocks        = ["0.0.0.0/0"]
    ipv6_cidr_blocks   = []
    prefix_list_ids    = []
    self               = false

  }
  
}
  
# Create a launch configuration for the EC2 instances
resource "aws_launch_template" "three-tier-web-template" {
  name_prefix          = "three-tier-web-lconfig"
  image_id             = var.image_id
  instance_type        = var.instance_type
  key_name             = "my-ec2-key-pair"
  
  network_interfaces {
    security_groups    = [aws_security_group.three-tier-ec2-asg-sg.id] 
    associate_public_ip_address = false
  }
  
 user_data = base64encode(<<-EOF
#!/bin/bash
# Update system packages
sudo apt update -y
sudo apt upgrade -y

# Install Apache
sudo apt install -y apache2

# Start Apache service
sudo systemctl start apache2

# Enable Apache to start on boot
sudo systemctl enable apache2

# Create a custom index.html file
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to Apache on Ubuntu</title>
</head>
<body>
    <h1>Welcome to your Apache Server!</h1>
    <p>This server is launched via an Auto Scaling Group in AWS.</p>
</body>
</html>
  EOF
  )
  iam_instance_profile {
    name = aws_iam_instance_profile.three-tier-instance-profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }
}
