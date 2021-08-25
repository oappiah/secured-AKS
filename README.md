# Secured AKS "terraformed"

[Remake of Secure-AKS-refarch](https://github.com/fortinet-solutions-cse/secured-AKS-refarch)

Tested terraform version: v1.0.3

## Steps

Before you run this:

* (`az login` to the correct subscription before you begin)

* Edit 90-vars.tf to pick options
* Create terraform.tfvars with username and password (example below)

```bash
username = "mydemouser"
password = "D0ntUseThisPassword"
```

1) Run `terraform` (`init` , `plan` , `apply` ...)
2) Output will show you how to run the ansible playbook created
3) Configure the VIP...  [original instructions](https://github.com/fortinet-solutions-cse/secured-AKS-refarch/blob/main/docs/Hands_on_demos.md)

### TODO

* Move away from cloud-init to Ansible post?
* Some real docs on how to use this, current state of this README is more tracking what needs to be done
* Requirements (other then Terraform and Ansible version) needs to be documented.

* More variables , less hardcoded IP's.
* Replace outputs with a summary text.

* Add BYOL license option
* Port2 Interface config differs from orignal script (Does it matter?)
* UDR on the Jumpsubnet needs adjustment(?)

* Configure and restrict outbound traffic with full inspection.

* See comments in [post.tpl](post.tpl)

#### Known issues

* AKS creation taking forever can be a provsioning quota issue and/or the fortios template breaking and ending up with no config making AKS nodes unable to reach any network. Also note that `terraform destroy` after this kind of issue tends to get suck and deleting the resource group(s) manually might work faster.

* Permission for the AKS cluster LB can take some time, if you are quick with deploying the voteapp you might see this `Warning  SyncLoadBalancerFailed  3m3s (x3 over 3m18s)   service-controller  Error syncing load balancer: failed to ensure load balancer: Retriable: false, RetryAfter: 0s, HTTPStatusCode: 403, RawError: Retriable: false, RetryAfter: 0s, HTTPStatusCode: 403, RawError: {"error":{"code":"AuthorizationFailed","message":"The client '..........` .

* Cloud-init gets stuck in apt(?!)
