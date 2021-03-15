output "hive_hdfs_datanode_dns" {
  value = [aws_instance.ec2_instance_hive_hdfs_datanode.*.public_dns]
}

output "hive_hdfs_namenode_dns" {
  value = [aws_instance.ec2_instance_hive_hdfs_namenode.*.public_dns]
}

output "hive_server_dns" {
  value = [aws_instance.ec2_instance_hive_server.*.public_dns]
}

output "hive_metastore_dns" {
  value = [aws_instance.ec2_instance_hive_metastore.*.public_dns]
}

output "hive_rdbms_dns" {
  value = [aws_instance.ec2_instance_hive_rdbms.*.public_dns]
}