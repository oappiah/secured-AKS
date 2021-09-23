
Content-Type: multipart/mixed; boundary="===============0086047718136476635=="
MIME-Version: 1.0

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system admin
    edit "${fgt_username}"
        set ssh-public-key1 "${trimspace(ssh_public_key)}" 
    next
end
config system api-user
    edit autouser
      set comments "API user for automatic setup"
      set api-key "${auto_password}"
      set accprofile "super_admin_readonly"
    end
config system sdn-connector
	edit "AzureSDN"
		set type azure
        set update-interval 30
	end
end
config system global
    set admintimeout 480
    set admin-port 8080
    set timezone 26
end
config router static
    edit 1
        set gateway 172.27.40.1
        set device "port1"
        next
    edit 2
        set dst 172.27.40.0 255.255.252.0
        set gateway 172.27.40.65
        set device "port2"
        next
    end
config firewall address
    edit "K8SNetwork"
        set subnet "172.27.41.0/24"
    next
    edit "JumpNetwork"
        set subnet "172.27.42.0/24"
    next
end
config firewall vip
    edit "JumpVip"
        set extip "0.0.0.0"
        set mappedip "172.27.42.4"
        set extintf "port1"
        set portforward enable
        set extport 8022
        set mappedport 22
    next
end
config firewall policy
    edit 40
        set name "Outbound"
        set srcintf "port2"
        set dstintf "port1"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set logtraffic all
        set logtraffic-start enable
        set nat enable
    next
    edit 41
        set name "InboundJump"
        set srcintf "port1"
        set dstintf "port2"
        set srcaddr "all"
        set dstaddr "JumpVip"
        set action accept
        set schedule "always"
        set service "SSH"
        set logtraffic all
        set logtraffic-start enable
    next
end
%{ if fgt_license_file != "" }
--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="${fgt_license_file}"

${file(fgt_license_file)}

%{ endif }
--===============0086047718136476635==--