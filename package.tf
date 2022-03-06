# Lambda package path
variable "output_path" {
  default     = "lambda.zip"
  description = "Name of the lambda output zip file"
}

# Prepare lambda package
resource "null_resource" "prepare_lambda_catalog" {
  provisioner "local-exec" {
    command = "mkdir -p ./lambda"
  }
  provisioner "local-exec" {
    command = "pip install --target ./lambda -r ./requirements.txt"
  }
  provisioner "local-exec" {
    command = "cp -r ./src/logic.py ./lambda/"
  }
  provisioner "local-exec" {
    command = "cp -r ./src/ndvi_evalscript.js ./lambda/"
  }
  provisioner "local-exec" {
    command = "cp -r ./src/sh_stat.py ./lambda/"
  }
}

# Create lambda package
data archive_file "lambda" {
  type        = "zip"
  source_dir  = "lambda"
  output_path = var.output_path
  depends_on  = [
      null_resource.prepare_lambda_catalog,
    ]
}