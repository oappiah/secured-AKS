[fortigates]
fgt ansible_host=${fgtpip} ansible_user=${fgt_username} ansible_network_os=fortios

[vms]
jumphost ansible_host=${fgtpip} ansible_user=${fgt_username} ansible_port=8022

[vms:vars]
ansible_python_interpreter=/usr/bin/python3