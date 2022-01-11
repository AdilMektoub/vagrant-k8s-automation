#! /bin/bash

MASTER_IP="192.168.56.10"
NODENAME=$(hostname -s)
POD_CIDR="10.10.0.0/16"

log()
{
   echo [`date`] - $1
}

initialseMaster()
{
   log "Configure kubeadm"
   sudo kubeadm config images pull

   log "Open the necessary ports used by Kubernetes." 
   sudo firewall-cmd --zone=public --permanent --add-port={6443,2379,2380,10250,10251,10252}/tcp

   log "Allow docker access from another workers nodes"
   sudo firewall-cmd --zone=public --permanent --add-rich-rule 'rule family=ipv4 source address=192.168.56.11/24 accept'
   sudo firewall-cmd --zone=public --permanent --add-rich-rule 'rule family=ipv4 source address=192.168.56.12/24 accept'

   log "Allow access to the host’s localhost from the docker container."   
   sudo firewall-cmd --zone=public --permanent --add-rich-rule 'rule family=ipv4 source address=172.17.0.0/16 accept'
   sudo firewall-cmd --reload


   log "Master node initialization"
   sudo kubeadm init --apiserver-advertise-address=$MASTER_IP --pod-network-cidr=$POD_CIDR 

   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config

   sudo mkdir -p ~vagrant/.kube
   sudo cp -i /etc/kubernetes/admin.conf ~vagrant/.kube/config
   sudo chown vagrant:vagrant ~vagrant/.kube/config

   sudo mkdir -p ~centos/.kube
   sudo cp -i /etc/kubernetes/admin.conf ~centos/.kube/config
   sudo chown centos:centos ~centos/.kube/config

   log "Save kubeconfig"
   sudo cp -i /etc/kubernetes/admin.conf /vagrant/config/kube-config
   log "Save join script"
   mkdir -p /vagrant/config
   kubeadm token create --print-join-command > /vagrant/config/join-cluster.sh
   chmod +x /vagrant/config/join-cluster.sh
}

installIngressController()
{

   log "Install Calico Network Plugin."
   curl --insecure -OL https://docs.projectcalico.org/manifests/calico.yaml
   sed -i s'|apiVersion: policy/v1beta1|apiVersion: policy/v1|' calico.yaml
   kubectl apply -f calico.yaml

   log "Force ingress controller POD to run on the Master node."
   # add a label on the master node 
   kubectl label node $NODENAME run-ingress-controller=true
   # Verify the node have the new label
   kubectl get node --show-labels | grep master
   # Patch ingress deployment
   cat <<EOF | tee /tmp/node-selector-patch.yaml
spec:
  template:
    spec:
      nodeSelector:
        run-ingress-controller: "true"
EOF

  kubectl -n kube-system patch deployment/calico-kube-controllers --patch "$(cat /tmp/node-selector-patch.yaml)"
}


installMetricsServer()
{
   log "Install Metrics Server"
   curl -OL --insecure https://raw.githubusercontent.com/scriptcamp/kubeadm-scripts/main/manifests/metrics-server.yaml
   kubectl apply -f metrics-server.yaml
}

installDashboard()
{
   log "Install Kubernetes Dashboard"
   curl -OL --insecure https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml
   kubectl apply -f recommended.yaml

   log "Force dashboard POD to run on the Master node."
   # add a label on the master node
   kubectl label node $NODENAME run-dashboard=true
   # Verify the node have the new label
   kubectl get node --show-labels | grep master
   # Patch dashboard deployment
   cat <<EOF | tee /tmp/node-selector-patch.yaml
spec:
  template:
    spec:
      nodeSelector:
        run-dashboard: "true"
EOF

  kubectl -n kubernetes-dashboard  patch  deployment/kubernetes-dashboard --patch "$(cat /tmp/node-selector-patch.yaml)"
  kubectl -n kubernetes-dashboard  patch  deployment/dashboard-metrics-scraper --patch "$(cat /tmp/node-selector-patch.yaml)"
  kubectl -n kubernetes-dashboard  get service kubernetes-dashboard -o yaml > /vagrant/kubernetes-dashboard-np.yaml
  sed -i 's|targetPort: 8443|targetPort: 8443\n    nodePort: 30002|' /tmp/kubernetes-dashboard-np.yaml
  sed -i 's|type: ClusterIP|type: NodePort|'  /tmp/kubernetes-dashboard-np.yaml
  kubectl -n kubernetes-dashboard  delete service kubernetes-dashboard
  cat /tmp/kubernetes-dashboard-np.yaml  | kubectl apply -f -

   log "Create Dashboard User"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
}

cp -i /etc/kubernetes/admin.conf /vagrant/configs/config

initialseMaster
installIngressController
installMetricsServer
installDashboard
