[fortigates]
fgt ansible_host=${fgtpip} ansible_user=${fgt_username} ansible_network_os=fortios ansible_ssh_private_key_file=files/demokey.pem

[vms]
jumphost ansible_host=${fgtpip} ansible_user=${fgt_username} ansible_port=8022 ansible_ssh_private_key_file=files/demokey.pem

[vms:vars]
ansible_python_interpreter=/usr/bin/python3