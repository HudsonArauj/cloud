output "db_host" {
    value = aws_db_instance.project_db.address
}
output "project_db" {
    value = aws_db_instance.project_db.id
}