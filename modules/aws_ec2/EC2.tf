#################
# EC2 Instances #
# Test          #
#################
resource "aws_instance" "test" {
  count                       = "${var.create_ec2 && var.number_of_instances > 0 ? var.number_of_instances : 0 }"
  ami                         = "${var.aws_ami}"
  instance_type               = "${var.aws_instance_type}"
  associate_public_ip_address = "true"

  subnet_id = "${var.aws_subnet}"

  key_name   = "${aws_key_pair.admin.key_name}"
  monitoring = "${var.ec2_monitoring}"

  #  vpc_security_group_ids = ["${var.aws_security_groups}"]

  vpc_security_group_ids = [
    "${var.aws_security_groups}",
    "${aws_security_group.security_group.*.id}",
  ]
  associate_public_ip_address = "true"
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "12"
    delete_on_termination = true
  }

  #    lifecycle {
  #	create_before_destroy = true
  #    }

  user_data = "${var.user_data}"
  tags {
    Name = "Bastion Instance"
  }
  connection {
    user        = "ec2-user"
    private_key = "${file("${path.module}/files/deployer.pem")}"
  }
  provisioner "file" {
    source      = "${path.module}/files"
    destination = "/home/ec2-user/"
  }
  provisioner "remote-exec" {
    inline = [
      "eval $(ssh-agent -s)",
      "chmod 400 ~/files/deployer.pem",
      "ssh-add ~/files/deployer.pem",
    ]
  }
}

resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  public_key = "ssh-rsa <key>/w== dima@dima.od.ua"
}
