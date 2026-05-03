output "vpc_id"          { value = aws_vpc.sentinel.id }
output "private_subnets" { value = aws_subnet.private[*].id }
output "security_group"  { value = aws_security_group.sentinel_sg.id }
