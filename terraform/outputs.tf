output "instance_public_ip" {
  value = aws_instance.splunk.public_ip
}

output "instance_id" {
  value = aws_instance.splunk.id
}
