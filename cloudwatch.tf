resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/elastic-container-service"
  retention_in_days = 7

}