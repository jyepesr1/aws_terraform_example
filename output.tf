output "vpc_id" {
  value = "${aws_vpc.vpc_1.id}"
}
output "public_subnets" {
  value = ["${aws_subnet.subnets.*.id[0]}"]
}
output "public_route_table_ids" {
  value = ["${aws_route_table.rtb_public.id}"]
}
output "public_instance_ip" {
  value = ["${aws_instance.example.public_ip}"]
}
output "public_instance_hostname" {
  value = ["${aws_instance.example.public_dns}"]
}