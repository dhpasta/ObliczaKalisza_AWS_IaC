resource "aws_db_instance" "db" {
  allocated_storage    = 20
  db_name              = var.db_name
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t4g.micro"
  username             = var.db_username
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
  name                    = "rds_pwd"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rds_cred_version" {
  secret_id = aws_secretsmanager_secret.rds_cred.id
  secret_string = jsonencode({
    db_hostname = aws_db_instance.db.address
    db_port     = aws_db_instance.db.port
    db_username = aws_db_instance.db.username
    db_password = random_password.db_password.result
    db_name     = aws_db_instance.db.db_name
  })
}

resource "aws_db_subnet_group" "private_db_subnet" {
  name       = "mysql_rds_private_subnet_group"
  subnet_ids = ["${aws_subnet.private_subnet_a.id}", "${aws_subnet.private_subnet_b.id}"]
}

resource "aws_security_group" "rds_security_group" {
  name       = "rds_security_group"
  vpc_id     = aws_vpc.this.id
  depends_on = [aws_vpc.this]
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  security_group_id = aws_security_group.rds_security_group.id

  cidr_ipv4   = "10.0.0.0/8"
  from_port   = aws_db_instance.db.port
  ip_protocol = "tcp"
  to_port     = aws_db_instance.db.port
}

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

resource "aws_iam_role_policy_attachment" "ec2_rds_iam" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.get_rds_passwd.arn
}

