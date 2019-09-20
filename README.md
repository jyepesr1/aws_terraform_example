# Resources to be created for running EC2 instance inside a virtual private network

* VPC
* Subnet inside VPC
* Internet gateway associated with VPC
* Route Table inside VPC with a route that * directs internet-bound traffic to the internet gateway
* Route table association with our subnet to make it a public subnet
* Security group inside VPC
* Key pair used for SSH access
* EC2 instance inside our public subnet with an associated security group and a generated key pair
