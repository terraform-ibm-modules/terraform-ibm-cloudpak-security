# Test CP4S Module

## 1. Set up access to IBM Cloud

If running this module from your local terminal, you need to set the credentials to access IBM Cloud. You can will also need to set the IC_API_KEY the steps are

1. Make sure you’re logged into cloud.ibm.com and within the correct account.
2. Go to [https://cloud.ibm.com/iam/apikeys](https://cloud.ibm.com/iam/apikeys) and click on Create an IBM API key
3. Provide a name and description.
4. export the key as IC_API_KEY

``` bash
export IC_API_KEY=<given_secret> # pragma: allowlist secret
```

You can define the IBM Cloud credentials in the IBM provider block but it is recommended to pass them in as environment variables.

## 2. Test

### Using Terraform client

Follow these instructions to test the Terraform Module manually

Create the file `test.auto.tfvars` with the following input variables, these values are fake examples:

```hcl
    source          = "./.."

    // ROKS cluster parameters:
    cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
    region = var.region
    resource_group_name = var.resource_group_name
    cluster_name_id = var.cluster_name_id

    // Entitled Registry parameters:
    entitled_registry_key        = var.entitled_registry_key
    entitled_registry_user_email = var.entitled_registry_user_email

    admin_user = var.admin_user
```

These parameters are:

| Name                         | Description                                            | Type   | Default        | Required |
|------------------------------|--------------------------------------------------------|--------|----------------|----------|
| cluster_config_path          | Path leading to the cluster details                    | string | ./.kube/config | yes      |
| region                       | Region that the cluster is located in                  | string | us-east        | yes      |
| entitled_registry_key        | Entitlement key from IBM products library, see below   | string | n/a            | yes      |
| entitled_registry_user_email | Emailed address related to entitlement key             | string | n/a            | yes      |
| admin_user                   | The admin user name of LDAP to be configured with CP4S | String | n/a            | yes      |

Get the entitlement key from the [products services container library](https://myibm.ibm.com/products-services/containerlibrary). Optionally you can store the key in a file and use the `file()` function to get the file content/key

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

One of the Test Scenarios is to verify the YAML files rendered to install IAF, these files are generated in the directory `rendered_files`. Go to this directory to validate that they are generated correctly.

## 3. Cleanup

 execute: `terraform destroy`.

There are some directories and files you will want to delete on your local machine.  These files contain metadata and private keys to your cluster. `rm -rf test.auto.tfvars terraform.tfstate* .terraform .kube rendered_files` as well as delete the `cp4s_cli_install` and `ibm-cp-security`
