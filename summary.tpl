##############################################################################################################
#
# Secured-AKS is now deployed
# 
#
# The FortiGate VM can be reached on the HA management public IP on port HTTPS/443 and SSH/22.
# Jumpbox can be reach on the public IP on port SSH/8022
#
# Deployment location: ${location}
# Username: ${username}
#
# GUI Management FortiGate : https://${fgtpip}/
# SSH Management FortiGate : ssh ${username}@${fgtpip} -i files/demokey.pem 
# SSH Jumpbox              : ssh ${username}@${fgtpip} -p8022 -i files/demokey.pem 
#
##############################################################################################################

To execute the post-configuration:  'ansible-playbook -i files/inventory files/post.yaml'

After running the post-config it will take about a minute for the dynamic address to update and you can access
the voteapp on http://${fgtpip}:8080/ , so meanwhile login to the GUI (or CLI) and update the Virtual Server "VoteApp"
with the "dynVoteApp" by removing and adding it back again.

##############################################################################################################