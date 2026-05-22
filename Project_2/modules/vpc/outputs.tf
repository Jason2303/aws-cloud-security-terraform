output "vpc-id" {
    description = "vpc ID"
    value = aws_vpc.my_vpc.id
}

output "private-id" {
    description = "private subnet ID"
    value = aws_subnet.private.id
}

output "public-id" {
    description = "public subnet ID"
    value = aws_subnet.public.id
}

output "public-id_2" {
    description = "public subnet ID"
    value = aws_subnet.public_2.id
}