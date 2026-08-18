output "Window_public_ip" {
  description = "public ip of window server for access via RDP"
  value       = aws_instance.window-server.public_ip

}

output "Window_private_ip" {
  description = "Private ip of Window server "
  value       = aws_instance.window-server.private_ip
}

output "Linux_private_ip" {
  description = "Private IP of application server"
  value       = aws_instance.linux-server.private_ip

}
output "rds_endpoint" {
  description = "RDS mysql endpoint"
  value       = aws_db_instance.mysql.endpoint
}

output "windows_jump_server_id" {
  description = "Instance id of Win server "
  value       = aws_instance.window-server.id
}

output "eips_value" {
  description = "Elastic ip address of NAT gateway"
  value       = aws_eip.eip-nat.public_ip
}