resource "aws_security_group" "hive_hdfs_datanode" {
  name        = "HDFS Datanode Security Group"
  description = "HDFS Datanode Security Group"  # see https://www.stefaanlippens.net/hadoop-3-default-ports.html
  ingress {
    description = "ssh"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dfs.datanode.address"
    protocol = "tcp"
    from_port = 9866
    to_port = 9866
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dfs.datanode.http.address"
    protocol = "tcp"
    from_port = 9864
    to_port = 9864
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dfs.datanode.ipc.address"
    protocol = "tcp"
    from_port = 9867
    to_port = 9867
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dfs.federation.router.admin-address"
    protocol = "tcp"
    from_port = 8111
    to_port = 8111
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dfs.federation.router.http-address"
    protocol = "tcp"
    from_port = 50071
    to_port = 50071
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dfs.federation.router.rpc-address"
    protocol = "tcp"
    from_port = 8888
    to_port = 8888
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dfs.journalnode.http-address"
    protocol = "tcp"
    from_port = 8480
    to_port = 8480
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dfs.journalnode.rpc-address"
    protocol = "tcp"
    from_port = 8485
    to_port = 8485
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dfs.namenode.backup.address"
    protocol = "tcp"
    from_port = 50100
    to_port = 50100
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dfs.namenode.backup.http-address"
    protocol = "tcp"
    from_port = 50105
    to_port = 50105
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dfs.namenode.http-address"
    protocol = "tcp"
    from_port = 9870
    to_port = 9870
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dfs.namenode.secondary.http-address"
    protocol = "tcp"
    from_port = 9868
    to_port = 9868
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dfs.provided.aliasmap.inmemory.dnrpc-address"
    protocol = "tcp"
    from_port = 50200
    to_port = 50200
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "hadoop.registry.zk.quorum"
    protocol = "tcp"
    from_port = 2181
    to_port = 2181
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "mapreduce.jobhistory.address"
    protocol = "tcp"
    from_port = 10020
    to_port = 10020
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "mapreduce.jobhistory.admin.address"
    protocol = "tcp"
    from_port = 10033
    to_port = 10033
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "mapreduce.jobhistory.webapp.address"
    protocol = "tcp"
    from_port = 19888
    to_port = 19888
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.nodemanager.amrmproxy.address"
    protocol = "tcp"
    from_port = 8049
    to_port = 8049
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.nodemanager.collector-service.address"
    protocol = "tcp"
    from_port = 8048
    to_port = 8048
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.nodemanager.localizer.address"
    protocol = "tcp"
    from_port = 8040
    to_port = 8040
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.nodemanager.webapp.address"
    protocol = "tcp"
    from_port = 8042
    to_port = 8042
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.resourcemanager.address"
    protocol = "tcp"
    from_port = 8032
    to_port = 8032
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.resourcemanager.admin.address"
    protocol = "tcp"
    from_port = 8033
    to_port = 8033
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.resourcemanager.resource-tracker.address"
    protocol = "tcp"
    from_port = 8031
    to_port = 8031
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.resourcemanager.scheduler.address"
    protocol = "tcp"
    from_port = 8030
    to_port = 8030
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.resourcemanager.webapp.address"
    protocol = "tcp"
    from_port = 8088
    to_port = 8088
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "xxx"
    protocol = "tcp"
    from_port = 8089
    to_port = 8089
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.sharedcache.admin.address"
    protocol = "tcp"
    from_port = 8047
    to_port = 8047
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.sharedcache.client-server.address"
    protocol = "tcp"
    from_port = 8045
    to_port = 8045
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.sharedcache.uploader.server.address"
    protocol = "tcp"
    from_port = 8046
    to_port = 8046
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.sharedcache.webapp.address"
    protocol = "tcp"
    from_port = 8788
    to_port = 8788
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.timeline-service.address"
    protocol = "tcp"
    from_port = 10200
    to_port = 10200
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "yarn.timeline-service.webapp.address"
    protocol = "tcp"
    from_port = 8188
    to_port = 8188
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "namenode server port"  #  https://www.edureka.co/community/463/what-is-the-default-namenode-port-hdfs-it-8020-or-9000-or-50070
    protocol = "tcp"
    from_port = 8020
    to_port = 8020
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "namenode web UI port"  #  https://www.edureka.co/community/463/what-is-the-default-namenode-port-hdfs-it-8020-or-9000-or-50070
    protocol = "tcp"
    from_port = 50070
    to_port = 50070
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "namenode heartbeat"
    protocol = "tcp"
    from_port = 9000
    to_port = 9000
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow ping"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "tcp wide open below 53"
    from_port = 0
    to_port = 52
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "tcp wide open above 53"
    from_port = 54
    to_port = 65353
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "DNS UDP on 53"
    from_port = 53
    to_port = 53
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "HDFS Datanode Security Group"
  }
}