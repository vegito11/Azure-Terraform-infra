# Azure-Terraform-infra

1. [Configure Azure CLI and creds for Terraform](./docs/01.1-Azure-Cred.md)

2. Create the required resources in Azure for storing Terraform state

    ```bash
    ARM_TENANT_ID="XXXXXXXX"
    MGMT_RG_NAME="management"
    LOCATION="centralindia"
    STATE_STORAGE_ACC_NAME="omkar0infra0bucket"
    STATE_CONTAINER_NAME="terraform-state-$ARM_TENANT_ID"

    # 1. Create Resource Group
    az group create --name $MGMT_RG_NAME --location $LOCATION

    # 2. Create Storage Account
    az storage account create --name $STATE_STORAGE_ACC_NAME --resource-group $MGMT_RG_NAME --location $LOCATION --sku Standard_LRS --kind StorageV2

    # 3. Create Storage Container
    az storage container create --name $STATE_CONTAINER_NAME --account-name $STATE_STORAGE_ACC_NAME
    ```

    ```bash
    # 1. Delete Storage Container
    az storage container delete --name $STATE_CONTAINER_NAME --account-name $STATE_STORAGE_ACC_NAME

    # 2. Delete Storage Account
    az storage account delete --name $STATE_STORAGE_ACC_NAME --resource-group $MGMT_RG_NAME --yes

    # 3. Delete Resource Group
    az group delete  --name $MGMT_RG_NAME
    ```

2. [**`terragrunt_create`** script explanation](./docs/01.2-Terragrunt-run-script-expl.md)
    
    ```bash
    $ scripts/terragrunt_create.sh --env staging --region centralindia --module resource-group --plan
    # Run init as well as plan
    $ scripts/terragrunt_create.sh --env staging --region centralindia --module resource-group --plan --init
    
    # Add sed if getting special characters in output
    $ scripts/terragrunt_create.sh --env staging --region centralindia --module resource-group --plan | sed -r 's/\x1b\[[0-9;]*m//g'
    
    $ scripts/terragrunt_create.sh --env staging --region centralindia --module networking --plan

    # This will apply with automatically yes confirmation
    $ scripts/terragrunt_create.sh --env staging --region centralindia --module networking -a  | sed -r 's/\x1b\[[0-9;]*m//g'

    # Destroy all modules
    $ scripts/terragrunt_create.sh --env staging --region centralindia --all

    ```

------------------------------------------------

## Create K8s Infra

```bash
az aks get-credentials --resource-group staging --name "staging-aks" --admin
az aks get-credentials --resource-group staging --name "staging-aks"
```

## Reference

1. [Backend: Azure](https://developer.hashicorp.com/terraform/language/backend/azurerm)

2. [Azure Region CodeNames](https://azuretracks.com/2021/04/current-azure-region-names-reference/)

3. **Terraform Code Ref**

    1. [terraform-azurerm-avm-ptn-aks-production](https://github.com/Azure/terraform-azurerm-avm-ptn-aks-production/blob/main/main.tf)

    2. [Official AKS terraform module](https://github.com/Azure/terraform-azurerm-aks/blob/main/examples/startup/main.tf)

4. [Microsoft AKS Doc - Authentication](https://learn.microsoft.com/en-us/azure/aks/enable-authentication-microsoft-entra-id#disable-local-accounts)

5. [Sizes for virtual machines in Azure](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview?tabs=breakdownseries%2Cgeneralsizelist%2Ccomputesizelist%2Cmemorysizelist%2Cstoragesizelist%2Cgpusizelist%2Cfpgasizelist%2Chpcsizelist)
   
   [virtual machine size restrictions AKS](https://learn.microsoft.com/en-us/azure/aks/quotas-skus-regions#supported-vm-sizes)

   [Azure Machine Selector](https://azure.microsoft.com/en-us/pricing/calculator/)