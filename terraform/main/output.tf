output "vpc_id" {
  value = data.aws_vpc.default.id
}




output "public_ip" {
  value = aws_instance.ws1.public_ip
} 