
resource "local_sensitive_file" "startup" {
  filename = "${path.module}/out/startup.sh"
  content = templatefile(
    "${path.module}/tpl/startup.sh.tftpl",
    local.startup_vars
  )
}

resource "local_sensitive_file" "nginx" {
  filename = "${path.module}/out/nginx.conf"
  content = templatefile(
    "${path.module}/tpl/nginx.conf.tftpl",
    local.nginx_vars
  )
}

resource "local_sensitive_file" "compose" {
  filename = "${path.module}/out/compose.yml"
  content = templatefile(
    "${path.module}/tpl/compose.yml.tftpl",
    local.compose_vars
  )
}

locals {
  user_dir = "/home/ubuntu"

  newrelic_vars = {
    newrelic_license_key = var.newrelic_license_key
    newrelic_api_key = var.newrelic_api_key
    newrelic_account_id = var.newrelic_account_id
  }
  nginx_vars = merge(local.newrelic_vars, {
    app_port                         = 1000
    server_name                      = var.dns_fqdn
    path_to_certificate_in_container = "/etc/certificate.pem"
    path_to_private_key_in_container = "/etc/private_key.pem"
    path_to_app_zip_on_host          = "${local.user_dir}/app.zip"
    path_to_app_dir_on_host          = "${local.user_dir}/app"
    path_to_compose_on_host          = "${local.user_dir}/compose.yml"
    path_to_newrelic_on_host         = "${local.user_dir}/newrelic.yml"
  })

  compose_vars = merge(local.nginx_vars, {
    deploy_version = var.app_version
    path_to_nginx_on_host       = "${local.user_dir}/nginx.conf"
    path_to_certificate_on_host = "${local.user_dir}/certificate.pem"
    path_to_private_key_on_host = "${local.user_dir}/private_key.pem"
  })

  startup_vars = merge(local.compose_vars, {
    user_dir = local.user_dir

    aws_region            = var.aws_region
    aws_access_key_id     = var.iam_access_key
    aws_secret_access_key = var.iam_secret_key
    # aws cli

    bucket_name                = var.bucket_name
    app_object_key             = aws_s3_object.app.key
    compose_object_key         = aws_s3_object.compose.key
    nginx_object_key           = aws_s3_object.nginx.key
    ssl_certificate_object_key = var.letsencrypt_cert_is_ready ? "${var.dns_fqdn}/fullchain.pem" : aws_s3_object.ssl_cert.key
    ssl_private_key_object_key = var.letsencrypt_cert_is_ready ? "${var.dns_fqdn}/privkey.pem" : aws_s3_object.ssl_cert.key
    # s3
  })
}