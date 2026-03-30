data "aws_ami" "ubuntu"{
    most_recent = true
   
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20260313"] 
    }

    filter {
        name = "architecture"
        values = ["x86_64"] 
    }

    owners = ["099720109477"]
}

resource "aws_instance" "oblicza" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_subnet_a.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.default.id]
  key_name = "oblicza-key"

  tags = {
    Name = "oblicza"
  }
}

resource "aws_key_pair" "oblicza-key" {
  key_name   = "oblicza-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}
