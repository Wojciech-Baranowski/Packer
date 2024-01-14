vm_id = 200
vm_name = "master-node"
vm_description = "Template for cluster master node"
vm_cores = 4
vm_memory = 16384
disk_size = "60G"
ssh_timeout = "100m"

provisioning = [
  "sudo apt install -y containerd",
  "sudo mkdir /etc/containerd",
  "sudo touch /etc/containerd/config.toml",
  "sudo chmod 666 /etc/containerd/config.toml",
  "sudo containerd config default > /etc/containerd/config.toml",
  "sudo sed -i 's/systemd_cgroup = false/systemd_cgroup = true/g' /etc/containerd/config.toml",
  "sudo touch /etc/modules-load.d/k8s.conf",
  "sudo chmod 666 /etc/modules-load.d/k8s.conf",
  "sudo echo 'br_netfilter' > /etc/modules-load.d/k8s.conf",
]
