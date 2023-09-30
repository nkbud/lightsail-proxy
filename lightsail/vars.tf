#
# inputs
#

variable "prod" {
  default     = null
  description = <<-EOT
    Options:
    - blue
    - green
    - (null)
    EOT
}

variable "dev" {
  default     = null
  description = <<-EOT
    Options:
    - blue
    - green
    - (null)
    EOT
}

variable "dns_domain" {}
variable "dns_record" {}

variable "letsencrypt_cert_is_ready" {
  description = "See oioio-dev/lambda-certbot. You must already have certs in s3 for you domain."
  default = false
}

variable "falconx_api_key" {
  sensitive = true
}
variable "falconx_passphrase" {
  sensitive = true
}
variable "falconx_secret_key" {
  sensitive = true
}

variable "new_relic_license_key" {
  sensitive = true
}
variable "new_relic_api_key" {
  sensitive = true
}
variable "new_relic_account_id" {
  sensitive = true
}
