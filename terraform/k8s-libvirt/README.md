
## USAGE

```
$ ./ops
/terraform # cd k8s-libvirt/
/terraform/k8s-libvirt # terraform workspace select dev || terraform workspace new dev
/terraform/k8s-libvirt # terraform init
/terraform/k8s-libvirt # eval `ssh-agent`; ssh-add environment/dev.key
/terraform/k8s-libvirt # ./tfwrap.sh plan
/terraform/k8s-libvirt # ./tfwrap.sh apply
/terraform/k8s-libvirt # kubectl get pods --all-namespaces
/terraform/k8s-libvirt # virsh net-dhcp-leases k8s
/terraform/k8s-libvirt # ./master1.sh sudo -i
```

[//]: # ( vim:set ts=2 sw=2 et syn=markdown: )
