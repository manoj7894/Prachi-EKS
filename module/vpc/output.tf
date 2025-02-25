output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id_value_1" {
  value = aws_subnet.private_1.id
}

output "private_subnet_id_value_2" {
  value = aws_subnet.private_2.id
}
