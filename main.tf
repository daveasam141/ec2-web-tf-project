data "aws_ami" "rhel9" {
  most_recent = true
  owners      = ["309956199498"] // Red Hat's Account ID
  filter {
    name   = "name"
    values = ["RHEL-9.*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "web-server" {
  ami                         = data.aws_ami.rhel9.id
  instance_type               = "t2.micro"
  user_data                   = file("./files/web-server.sh")
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet.id
  ###vpc_security_group_ids      = ["aws_security_group.sg_web.name"] ### set of string required use brackets
  key_name = aws_key_pair.test-key.key_name

  tags = {
    Name        = "web-instance"
    Environment = "Development"
    Owner       = "Dave"
  }
}

resource "aws_ebs_volume" "web-vol" {
  availability_zone = "us-east-2a"
  size              = 20
}

resource "aws_volume_attachment" "ebs_web" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.web-vol.id
  instance_id = aws_instance.web-server.id
}

resource "aws_key_pair" "test-key" {  #### Change public key
  key_name   = "mac-key"
  public_key = "example key"
}
