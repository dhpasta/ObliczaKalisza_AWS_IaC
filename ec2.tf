data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20260313"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"]
}


resource "aws_instance" "ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.public_subnet_a.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.default.id]
  key_name               = var.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = file("init.sh")

  depends_on = [
    aws_db_instance.db
  ]

  tags = {
    Name = var.app_name
  }
}

resource "aws_key_pair" "oblicza_key" {
  key_name   = var.key_name
  public_key = file(var.key_filename)
}

resource "aws_iam_role" "ec2" {
  name = "ec2_policies"

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

resource "aws_iam_policy" "ec2_describe_instance" {
  name = "ec2_describe_instance"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeInstances"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2.name
}

resource "aws_iam_role_policy_attachment" "ec2_sdk_iam" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2_describe_instance.arn
}

resource "null_resource" "wait_for_init" {
  provisioner "local-exec" {
    command = <<EOT
    echo "Waiting for init.sh to install application\n"
    for i in $(seq 1 100); do
      http_code=$(curl -s -o /dev/null -w "%%{http_code}" http://${aws_instance.ec2.public_ip})
      if [ "$http_code" = "200" ]; then
        echo "The app ObliczaKalisza i working correctly!"
        exit 0
      else
        echo "Waiting app to be ready..."
        sleep 10
      fi
    done
    echo "The app did not start in set time! Exiting..."
    exit 1
    EOT
  }
  depends_on = [aws_instance.ec2]
  triggers = {
    instance_public_ip = aws_instance.ec2.public_ip
  }
}

