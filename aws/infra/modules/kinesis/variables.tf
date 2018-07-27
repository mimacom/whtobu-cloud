variable "name" {}
variable "environment" {}
variable "shard_count" {
  type = "string"
  default = "1"
}
variable "retention_period" {
  type = "string"
  default = "48"
}