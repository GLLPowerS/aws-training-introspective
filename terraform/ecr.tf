resource "aws_ecr_repository" "product" {
  name = "product-service"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Project = "introspect"
  }
}

resource "aws_ecr_repository" "order" {
  name = "order-service"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Project = "introspect"
  }
}
