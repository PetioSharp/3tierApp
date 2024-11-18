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

    # Update and upgrade the system
    sudo apt update -y
    sudo apt upgrade -y

    # Install Apache web server
    sudo apt install apache2 -y

    # Start Apache web server
    sudo systemctl start apache2
    sudo systemctl enable apache2

    # Create the custom index.html file
    sudo bash -c 'cat > /var/www/html/index.html <<EOL
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <title>A Basic HTML5 Template</title>
    </head>
    <body>
      <div>
        <h1>Welcome! Apache web server is running successfully.</h1>
        <h2>Achintha Bandaranaike</h2>
      </div>
    </body>
    </html>
    EOL'

    # Restart Apache to load new index.html
    sudo systemctl restart apache2
  EOF
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }
}
