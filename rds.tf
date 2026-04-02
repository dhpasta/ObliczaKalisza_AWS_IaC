resource "aws_db_instance" "oblicza" {
  allocated_storage    = 20
  db_name              = "data"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t4g.micro"
  username             = "admin"
  password             = random_password.db_password.result
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  db_subnet_group_name   = aws_db_subnet_group.private_db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]

  iam_database_authentication_enabled = true
}

resource "random_password" "db_password" {
  length  = 20
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "aws_secretsmanager_secret" "rds_cred" {
  name                    = "rds-pwd"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rds_cred_version" {
  secret_id = aws_secretsmanager_secret.rds_cred.id
  secret_string = jsonencode({
    db_hostname = aws_db_instance.oblicza.address
    db_port     = aws_db_instance.oblicza.port
    db_username = aws_db_instance.oblicza.username
    db_password = random_password.db_password.result
    db_name     = aws_db_instance.oblicza.db_name
  })
}

resource "aws_db_subnet_group" "private_db_subnet" {
  name       = "mysql-rds-private-subnet-group"
  subnet_ids = ["${aws_subnet.private_subnet_a.id}", "${aws_subnet.private_subnet_b.id}"]
}

resource "aws_security_group" "rds_security_group" {
  name       = "stage-rds-security-group"
  vpc_id     = aws_vpc.this.id
  depends_on = [aws_vpc.this]
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  security_group_id = aws_security_group.rds_security_group.id

  cidr_ipv4   = "10.0.0.0/8"
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}


# resource "aws_iam_role_policy" "get_rds_passwd" {
#   name = "get_rds_passwd"
#   role = aws_iam_role.ec2_rds_connection.id

#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "secretsmanager:GetResourcePolicy",
#           "secretsmanager:GetSecretValue",
#           "secretsmanager:DescribeSecret",
#           "secretsmanager:ListSecretVersionIds"
#         ],
#         "Resource" : [
#           "${aws_secretsmanager_secret.rds_cred.arn}"
#         ]
#       }
#     ]
#   })
# }

resource "aws_iam_policy" "get_rds_passwd" {
  name = "get_rds_passwd"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Resource" : [
          "${aws_secretsmanager_secret.rds_cred.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ec2_rds_connection" {
  name = "ec2_rds_connection"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_iam" {
  role       = aws_iam_role.ec2_rds_connection.name
  policy_arn = aws_iam_policy.get_rds_passwd.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-rds-access-profile"
  role = aws_iam_role.ec2_rds_connection.name
}
