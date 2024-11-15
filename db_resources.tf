# RDS DB

resource "aws_db_subnet_group" "three-tier-db-sub-grp" {
    name             = "three-tier-db-sub-grp"
    subnet_ids = ["${aws_subnet.three-tier-pvt-sub-3.id}","${aws_subnet.three-tier-pvt-sub-4.id}"]
}

    resource "aws_db_instance" "three-tier-db" {
    allocated_storage           = 20
    storage_type                = "gp3"
    engine                      = "mysql"
    engine_version              = "8.0.39"
    instance_class              = "db.t3.micro"
    identifier                  = "three-tier-db"
    username                    = "admin"
    password                    = "pppppdb12345"
    parameter_group_name        = "default.mysql8.0"
    db_subnet_group_name        = aws_db_subnet_group.three-tier-db-sub-grp.name
    vpc_security_group_ids      = ["${aws_security_group.three-tier-db-sg.id}"]
    multi_az                    = true
    skip_final_snapshot         = true
    publicly_accessible          = false

    lifecycle {
        prevent_destroy = false
        ignore_changes  = all
  }
}

# SG for the RDS DB instance

resource "aws_security_group" "three-tier-db-sg" {
  name        = "three-tier-db-sg"
  description = "Security group for RDS database instance"
  vpc_id      = aws_vpc.three-tier-vpc.id  # Ensure this VPC exists

  # Allow traffic from the application instances on port 3306 (or the relevant port for your database)
  ingress {
    from_port   = 3306                      
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.three-tier-ec2-asg-sg-app.id]  # Allow from App SG
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "three-tier-db-sg"
  }
}
