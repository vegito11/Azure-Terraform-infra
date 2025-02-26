# Azure-Terraform-infra

1. [Configure Azure CLI and creds for Terraform](./docs/01.1-Azure-Cred.md)

2. Create the required resources in Azure for storing Terraform state

    ```bash
    ARM_TENANT_ID="XXXXXXXX"
    MGMT_RG_NAME="management"
    LOCATION="westindia"
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
    scripts/terragrunt_create.sh --env staging --region westindia --module resource-group --plan
    
    # Add sed if getting special characters in output
    scripts/terragrunt_create.sh --env staging --region westindia --module resource-group --plan | sed -r 's/\x1b\[[0-9;]*m//g'
    
    scripts/terragrunt_create.sh --env staging --region westindia --module networking --plan
    ```

------------------------------------------------

## Infra explanation 




## Reference

1. [Backend: Azure](https://developer.hashicorp.com/terraform/language/backend/azurerm)

2. [Azure Region CodeNames](https://azuretracks.com/2021/04/current-azure-region-names-reference/)