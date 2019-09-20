provider "aws" {
  region = "${var.region}"
}

# Create new VPC
resource "aws_vpc" "vpc_1" {
  cidr_block = "${var.vpc_cidr}"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
      Name = "vpc_1"
      Environment = "${var.environment_tag}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc_1.id}"

  tags = {
    Name = "igw"
    Environment = "${var.environment_tag}"
  }
}

# Create multiple subnets using count and list variables
resource "aws_subnet" "subnets" {
  count      = "${length(data.aws_availability_zones.avail_zones.names)}"
  vpc_id     = "${aws_vpc.vpc_1.id}"
  cidr_block = "${element(var.subnet_cidr, count.index)}"
  availability_zone = "${element(data.aws_availability_zones.avail_zones.names, count.index)}"
  map_public_ip_on_launch = "${count.index == 0}" # Instances launched into the first subnet should be assigned a public IP address

  tags = {
    Name = "subnet_${count.index+1}"
    Environment = "${var.environment_tag}"
  }
}

# Route table needs to be added which uses internet gateway to access the internet.
resource "aws_route_table" "rtb_public" {
  vpc_id = "${aws_vpc.vpc_1.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "rtb_public"
    Environment = "${var.environment_tag}"
  }
}

# Once route table is created, we need to associate it with the subnet to make our subnet public.
resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = "${aws_subnet.subnets.*.id[0]}"
  route_table_id = "${aws_route_table.rtb_public.id}"
}

resource "aws_security_group" "sg_ssh" {
  name = "allow_ssh"
  description = "Allow incoming ssh connections from my current IP"
  vpc_id = "${aws_vpc.vpc_1.id}"

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }
 
  /* NOTE on Egress rules: By default, AWS creates an ALLOW ALL egress rule when
    creating a new Security Group inside of a VPC. When creating a new Security 
    Group inside a VPC, Terraform will remove this default rule, and require you 
    specifically re-create it if you desire that rule. We feel this leads to fewer 
    surprises in terms of controlling your egress rules. If you desire this rule 
    to be in place, you can use this egress block
  */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
    Environment = "${var.environment_tag}"
  }
}

# Create a key pair which we are going to use to SSH on our EC2
resource "aws_key_pair" "ec2key" {
  key_name = "PSL_computer_key"
  public_key = "${file(var.public_key_path)}"
}

# Create new ec2 instance of t2.micro type
resource "aws_instance" "example" {
  ami = "${var.instance_ami}" # ubuntu AMI (free tier)
	instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.subnets.*.id[0]}"
  vpc_security_group_ids = ["${aws_security_group.sg_ssh.id}"]
  key_name = "${aws_key_pair.ec2key.key_name}"

  tags = {
    Name = "example"
    Environment = "${var.environment_tag}"
  }
}