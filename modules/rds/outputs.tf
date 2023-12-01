output "db_host" {
    value = aws_db_instance.project_db.address
}
output "project_db_endpoint" {
    value = aws_db_instance.project_db.endpoint
}
output "project_db" {
    value = aws_db_instance.project_db.endpoint
}