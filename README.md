# Secured AKS "terraformed"

[Remake of Secure-AKS-refarch](https://github.com/fortinet-solutions-cse/secured-AKS-refarch)

Tested terraform version: v1.0.3

## Steps

Before you run this:

* (`az login` to the correct subscription before you begin)

* Edit 90-vars.tf to pick options and then create terraform.tfvars with username and password

```bash
username = "mydemouser"
password = "D0ntUseThisPassword"
```

1) Run `terraform` (`init` , `plan` , `apply` ...)
2) Output will show you how to copy the files to jumphost
3) Output will show how to login to the jumphost
4) (jumphost#) copy the kubeconfig demo to ~/.kube/config
5) kubectl apply -f vote-app.yaml to launch the vote application on AKS
6) Configure the VIP...  [original instructions](https://github.com/fortinet-solutions-cse/secured-AKS-refarch/blob/main/docs/Hands_on_demos.md) minus the inspection for now.

### TODO

* Some real docs on how to use this, current state of this README is more tracking what needs to be done

* Bigger network for 3-5 Autoscale AKS
* More variables , less hardcoded IP's
* Replace outputs with a summary.tpl

* Add BYOL option
* Port2 Interface config differs from orignal script (Does it matter?)
* UDR on the Jumpsubnet needs adjustment(?)

* Automated way to get certs + Install CA cert on AKS for SSL inspection
* Configure and restrict outbound traffic with full inspection.

#### Known issues

* AKS creation taking forever can be a provsioning quota issue and/or the fortios template breaking and ending up with no config making AKS nodes unable to reach any network. Also note that `terraform destroy` after this kind of issue tends to get suck and deleting the resource group(s) manually might work faster.
