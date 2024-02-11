vm_id = 200
vm_name = "master-node"
vm_description = "Template for cluster master node"
vm_cores = 4
vm_memory = 16384
disk_size = "60G"
ssh_timeout = "100m"

provisioning = [
  
  # containerd

  "sudo apt install -y containerd",
  "sudo mkdir /etc/containerd",
  "sudo touch /etc/containerd/config.toml",
  "sudo chmod 666 /etc/containerd/config.toml",
  "sudo containerd config default > /etc/containerd/config.toml",
  "sudo sed -i '/SystemdCgroup = false/c\\SystemdCgroup = true' /etc/containerd/config.toml",

  # system misc

  "sudo touch /etc/modules-load.d/k8s.conf",
  "sudo chmod 666 /etc/modules-load.d/k8s.conf",
  "sudo echo 'br_netfilter' > /etc/modules-load.d/k8s.conf",
  "sudo swapoff -a",
  "sudo sed -i '/swap/c\\' /etc/fstab",
  "sudo sed -i '/net.ipv4.ip_forward/c\\net.ipv4.ip_forward=1' /etc/sysctl.conf", 

  # k8s

  "sudo sudo apt-get install -y apt-transport-https ca-certificates curl",
  "sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
  "sudo echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
  "sudo apt update",
  "sudo apt install -y kubeadm",
  "sudo apt install -y kubelet",
  "sudo apt install -y kubectl",

  # haproxy
  
  "sudo apt install -y haproxy",
  "sudo apt install -y keepalived",
]

