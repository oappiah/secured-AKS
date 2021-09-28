---
- hosts: jumphost
  tasks:   
  - name: Get Fortinet_SSL_CA from fortigate
    uri:
      url: "https://${fgtpip}/api/v2/monitor/system/certificate/download/Fortinet_CA_SSL?scope=vdom&type=local-ca&vdom=root"
      dest: /tmp/fgt.crt
      headers:
        Authorization: "Bearer ${auto_password}"
      validate_certs: no
    register: SSLCA
    delegate_to: 127.0.0.1

  - name: Copy cert to jumphost
    become: yes
    copy:
      src: "{{SSLCA.path}}"
      dest: /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt

  - name: Update ca store
    become: yes
    shell: "update-ca-certificates --fresh"

  #TODO: Replace when I figure out how to the VMSS name in terraform...
  - name: Get VMSS name
    shell: az vmss list --resource-group ${crg} --query '[].name' -o tsv
    register: vmss_name
    delegate_to: 127.0.0.1
  
  - name: Update ca store on AKS nodes
    shell: > 
      az vmss extension set 
      --resource-group ${crg}
      --vmss-name "{{vmss_name.stdout }}"
      --version 2.0 
      --publisher Microsoft.Azure.Extensions 
      --name CustomScript 
      --protected-settings '{"commandToExecute": "echo {{FGTCA}} | base64 -d > /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt ; update-ca-certificates --fresh; service docker restart "}'
    delegate_to: 127.0.0.1
    vars:
      FGTCA: "{{ lookup('file', SSLCA.path) | b64encode }}"
  - name: Install pip packages
    pip:
      name:
      - kubernetes
      - openshift


  - name: Deploy the voteapp 
    k8s:
      state: present
      definition: "{{ lookup('file', 'voting-app.yaml') }}"
      wait: yes