resource "aws_network_interface" "eth0_k8s_nfs" {
  subnet_id   = aws_subnet.k8s_subnet_public1_eu_west_1a.id
#  private_ips = ["172.16.10.100"]
   security_groups = [ aws_security_group.k8s-nfs-sg.id ]

  tags = {
    Project = "K8s"
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "k8s_nfs" {
    ami                   = "ami-0786326ba4d12342a"
    instance_type         = "t3.micro"
    #security_groups = [ aws_security_group.k8s-nfs-sg.id ]
#   count = 3 //the number of servers to create. To delete an instance, enter 0 or use the "terraform destroy" command.
#    vpc_security_group_ids = [ aws_security_group.k8s-nfs-sg.id ]
#    user_data = file("nfs.sh")
#    key_name = "ssh"
network_interface {
    network_interface_id = aws_network_interface.eth0_k8s_nfs.id
    device_index         = 0
}
lifecycle {
#  privent_destroy = true //can not destroy resource
  create_before_destroy = true //  create a new instance and then remove old
}
    tags = {
      Name = "k8s-nfs"
      OS = "RHEL8"
      Project = "k8s"
    }
}

resource "aws_eip" "static_ip" {
  instance=aws_instance.k8s_nfs.id
}