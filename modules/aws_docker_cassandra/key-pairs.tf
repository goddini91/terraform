resource "aws_key_pair" "deployer" {
  count      = "${var.create_cassandra ? 1 : 0 }"
  key_name   = "deploy"
  public_key = "ssh-rsa <key>/w== dima@dima.od.ua"
}
