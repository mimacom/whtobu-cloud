resource "aws_kinesis_stream" "stream" {
  name                = "${var.name}"
  shard_count         = "${var.shard_count}"
  retention_period    = "${var.retention_period}"

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags {
    Environment = "${var.environment}"
  }
}