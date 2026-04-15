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

