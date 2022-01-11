#! /bin/bash

KUBERNETES_VERSION="v1.22.0"

###############################################################################
log()
{
   echo ***********************************************************************
   echo [`date`] - $1
}

###############################################################################
systemUpdate()
{
   log "System pkgs updating."
   sudo mkdir /etc/yum.repos.d/EPEL-SAVE
   sudo mv /etc/yum.repos.d/epel* /etc/yum.repos.d/EPEL-SAVE
   sudo yum update -y
   sudo yum install -y yum-utils net-tools curl
   sudo cat /vagrant/config/hosts >> /etc/hosts
   sudo systemctl stop sshd
   sudo sed -i 's|#  PasswordAuthentication|PasswordAutentication|g' /etc/ssh/ssh_config
   sudo sed -i 's|#  IdentityFile|IdentityFile|g' /etc/ssh/ssh_config
   sudo sed -i 's|#  Port|Port|g' /etc/ssh/ssh_config
   sudo systemctl start sshd
}

###############################################################################
systemSettings()
{
   log "Disabling swap permanently."
   sudo swapoff -a
   sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
   sudo free -h

   log "Enable transparent masquerading."
   modprobe br_netfilter
   firewall-cmd --add-masquerade --permanent
   firewall-cmd --reload
   
   log "Set bridged packets to traverse iptables rules"
   cat <<EOF sudo tee | /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
   sysctl --system

   log "Disable SELINUX permanently."
   sudo setenforce 0
   sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
}

###############################################################################
installDocker()
{
  log "Removing podman (default now on centos)"
  sudo dnf remove podman
  sudo dnf remove containers-common-1.2.2-10.module_el8.4.0+830+8027e1c4.x86_64

  log "Installing docker-ce"
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo dnf install docker-ce -y

  log "Creating centos user."
  sudo useradd -p $(openssl passwd -crypt centos) centos
  
  log "Adding centos user as part o docker and sudo groups"
  sudo usermod -aG docker centos
  sudo usermod -aG wheel  centos
  sudo mkdir /home/centos/.ssh
  sudo cp /vagrant/config/id_rsa.pub /home/centos/.ssh/authorized_keys
  sudo chmod 700 /home/centos/.ssh/authorized_keys
  sudo chown -R centos.centos /home/centos/.ssh

  log "Apply recomanded kubernetes configuration"
  sudo mkdir /etc/docker
  cat <<EOF | sudo tee /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "100m"
    },
    "storage-driver": "overlay2"
}
EOF

  log "Enable Docker."
  sudo systemctl enable docker
  sudo systemctl daemon-reload
  sudo systemctl restart docker
  sudo systemctl status docker

  log "Verify docker HelloWorld"
  sudo docker run hello-world
}

###############################################################################
installAnsible()
{
   sudo yum -y install centos-release-ansible-29.noarch
   sudo yum -y install ansible
}

###############################################################################

systemUpdate
systemSettings
installDocker
installAnsible
