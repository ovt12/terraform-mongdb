provider "aws" {
  region="us-east-1"
}

# create our vpc
resource "aws_vpc" "olivertaylor-application-deployment" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "olivertaylor-application-deployment-vpc"
  }
}

resource "aws_internet_gateway" "olivertaylor-ig" {
  vpc_id = "${aws_vpc.olivertaylor-application-deployment.id}"

  tags = {
    Name = "olivertaylor-ig"
  }
}

resource "aws_route_table" "olivertaylor-rt" {
    vpc_id = "${aws_vpc.olivertaylor-application-deployment.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.olivertaylor-ig.id}"
    }
}

resource "aws_key_pair" "deployer" {
    key_name = "olivertaylor-awskey"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCCUIDKvvF1DQJJLbCEw1EAv98rSMUavXRJ/XK8pt9wCmSON3j9j8zI+spCEL0I52ktoiOtkqqiPioj2s/FVEG0dzQJW3yDVdc7nK62iar8MYWjH2+Y/kQRWWjgvQA0sINTridH1RV7/ddrkajQGhg8e5Sp0hqSfsm1NBnb6Agt5DUayJZZbw5/7I/AxNjTGb2kmsvCWWA2/ZuNyacMbZwDxr7Mil4sN3ojSXW7D4Fl4Ktjo4sl86+0ZNmLEOp7H20MZKCijW+xa4r4wcugUVcCuApeI0M42aRX0IAzXYwqUfWhgOgam5K3FcSwk2Xv3lRlrKnvLwt+6K8CV+t7nuXr"

}


module "db-tier" {
  name = "olivertaylor-database"
  source = "./modules/db-teir"
  vpc_id = "${aws_vpc.olivertaylor-application-deployment.id}"
  route_table_id = "${aws_vpc.olivertaylor-application-deployment.main_route_table_id}"
  cidr_block = "10.1.1.0/24"
  user_data=templatefile("./scripts/db_user_data.sh", {})
  ami_id = "ami-0a6bcbc3dec6aeb5a"
  map_public_ip_on_launch = false

  ingress = [{
    from_port = 27017
    to_port = 27017
    protocol = "tcp"
    cidr_blocks = "${module.application-tier.subnet_cidr_block}"
  }]


}

module "application-tier" {
  name="olivertaylor-app"
  source = "./modules/application-teir"
  vpc_id = "${aws_vpc.olivertaylor-application-deployment.id}"
  route_table_id = "${aws_route_table.olivertaylor-rt.id}"
  cidr_block = "10.1.0.0/24"
  user_data=templatefile("./scripts/app_user_data.sh", {mongodb_ip=module.db-tier.private_ip})
  ami_id = "ami-0aadcd8576538f786"
  map_public_ip_on_launch = true

  ingress = [{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = "0.0.0.0/0"
  }, {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = "149.36.18.119/32"
  },{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = "3.129.210.142/32"
    
}]
}


