Vagrant.configure(2) do |config|
    common = <<-SHELL
    # voir si dans etc/hosts on a une machine qui s'appelle deploykub si on l'a pas on la rajoute avec cet ip 192.168.6.120
    if ! grep -q deploykub /etc/hosts; then  sudo echo "192.168.6.120     deploykub" >> /etc/hosts ;fi
    if ! grep -q node01 /etc/hosts; then  sudo echo "192.168.6.121     node01" >> /etc/hosts ;fi
    if ! grep -q node02 /etc/hosts; then  sudo echo "192.168.6.122     node02" >> /etc/hosts ;fi
    if ! grep -q node03 /etc/hosts; then  sudo echo "192.168.6.123     node03" >> /etc/hosts ;fi
    if ! grep -q node04 /etc/hosts; then  sudo echo "192.168.6.124     node04" >> /etc/hosts ;fi
    if ! grep -q node05 /etc/hosts; then  sudo echo "192.168.6.125     node05" >> /etc/hosts ;fi
    SHELL
    
  
      config.vm.box = "generic/centos8"
      config.vm.box_url = "generic/centos8"
  
      config.vm.define "deploykub" do |control|
          control.vm.hostname = "deploykub"
          control.vm.network "private_network", ip: "192.168.6.120"
          control.vm.box_download_insecure = true
          control.vm.provider "virtualbox" do |v|
              v.customize [ "modifyvm", :id, "--cpus", "1" ]
              v.customize [ "modifyvm", :id, "--memory", "512" ]
              v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
              v.customize ["modifyvm", :id, "--name", "deploykub"]
          end
          control.vm.provision "shell", path: "scripts/common.sh"
      end
      config.vm.define "node01" do |node1|
          node1.vm.hostname = "node01"
          node1.vm.network "private_network", ip: "192.168.6.121"
          node1.vm.box_download_insecure = true
          node1.vm.provider "virtualbox" do |v|
              v.customize [ "modifyvm", :id, "--cpus", "2" ]
              v.customize [ "modifyvm", :id, "--memory", "2048" ]
              v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
              v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
              v.customize ["modifyvm", :id, "--name", "node01"]
          end
          node1.vm.provision "shell", path: "scripts/common.sh"
      end
      config.vm.define "node02" do |node2|
          node2.vm.hostname = "node02"
          node2.vm.network "private_network", ip: "192.168.6.122"
          node2.vm.box_download_insecure = true
          node2.vm.provider "virtualbox" do |v|
              v.customize [ "modifyvm", :id, "--cpus", "2" ]
              v.customize [ "modifyvm", :id, "--memory", "2048" ]
              v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
              v.customize ["modifyvm", :id, "--name", "node02"]
          end
          node2.vm.provision "shell", path: "scripts/common.sh"
      end
      config.vm.define "node03" do |node3|
          node3.vm.hostname = "node03"
          node3.vm.network "private_network", ip: "192.168.6.123"
          node3.vm.box_download_insecure = true
          node3.vm.provider "virtualbox" do |v|
              v.customize [ "modifyvm", :id, "--cpus", "2" ]
              v.customize [ "modifyvm", :id, "--memory", "2048" ]
              v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
              v.customize ["modifyvm", :id, "--name", "node03"]
          end
          node3.vm.provision "shell", path: "scripts/common.sh"
      end
      config.vm.define "node04" do |node4|
          node4.vm.hostname = "node04"
          node4.vm.network "private_network", ip: "192.168.6.124"
          node4.vm.box_download_insecure = true
          node4.vm.provider "virtualbox" do |v|
              v.customize [ "modifyvm", :id, "--cpus", "1" ]
              v.customize [ "modifyvm", :id, "--memory", "2048" ]
              v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
              v.customize ["modifyvm", :id, "--name", "node04"]
          end
          node4.vm.provision "shell", path: "scripts/common.sh"
      end
      config.vm.define "node05" do |node5|
          node5.vm.hostname = "node05"
          node5.vm.network "private_network", ip: "192.168.6.125"
          node5.vm.box_download_insecure = true
          node5.vm.provider "virtualbox" do |v|
              v.customize [ "modifyvm", :id, "--cpus", "1" ]
              v.customize [ "modifyvm", :id, "--memory", "2048" ]
              v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
              v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
              v.customize ["modifyvm", :id, "--name", "node05"]
          end
          node5.vm.provision "shell", path: "scripts/common.sh"
      end
  
  end
  
  