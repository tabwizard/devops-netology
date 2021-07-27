output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "region" {
  value = data.aws_region.current_region.name
}

output "endpoint" {
  value = data.aws_region.current_region.endpoint
}

output "private_ip" {
  value = aws_instance.wizard_http_server.private_ip
}

output "subnet_id" {
  value = aws_instance.wizard_http_server.subnet_id
}