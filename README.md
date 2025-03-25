# Azure-Terraform-infra

1. [Configure Azure CLI and creds for Terraform](./docs/01.1-Azure-Cred.md)

2. Create the required resources in Azure for storing Terraform state

    > **NOTE :** You can the [bash_aliases](./scripts/bash_aliases.sh) script to set variables

    ```bash
    ARM_TENANT_ID="XXXXXXXX"
    MGMT_RG_NAME="management"
    LOCATION="centralindia"
    STATE_STORAGE_ACC_NAME="shopkart0infra0bucket"
    STATE_CONTAINER_NAME="terraform-state-$ARM_TENANT_ID"

    # 1. Create Resource Group🟩
    az group create --name $MGMT_RG_NAME --location $LOCATION
 
    # 2. Create Storage Account  🟢
    az storage account create --name $STATE_STORAGE_ACC_NAME --resource-group $MGMT_RG_NAME --location $LOCATION --sku Standard_LRS --kind StorageV2
     
     ## Run below command if error - Code: SubscriptionNotFound ⭐
     # az provider register -n Microsoft.Storage --subscription $ARM_SUBSCRIPTION_ID

    # 3. Create Storage Container 🔰
    az storage container create --name $STATE_CONTAINER_NAME --account-name $STATE_STORAGE_ACC_NAME
    ```

    ```bash
    # 1. Delete Storage Container 🔴
    az storage container delete --name $STATE_CONTAINER_NAME --account-name $STATE_STORAGE_ACC_NAME

    # 2. Delete Storage Account 🔴
    az storage account delete --name $STATE_STORAGE_ACC_NAME --resource-group $MGMT_RG_NAME --yes

    # 3. Delete Resource Group 🔴
    az group delete  --name $MGMT_RG_NAME
    ```

2. [**`terragrunt_create`** script explanation](./docs/01.2-Terragrunt-run-script-expl.md)
    
    ```bash
    $ scripts/terragrunt_create.sh --env staging --region centralindia --module resource-group --plan
    
    # Migrate state or Reconfigure 🗃️
    scripts/terragrunt_create.sh --env staging --region centralindia --module resource-group --init-only -reconfigure

    # Run init as well as plan 🚧
    $ scripts/terragrunt_create.sh --env staging --region centralindia --module resource-group --plan --init
    
    # Add sed if getting special characters in output 🎨
    $ scripts/terragrunt_create.sh --env staging --region centralindia --module resource-group --plan | sed -r 's/\x1b\[[0-9;]*m//g'

    # This will apply with automatically yes confirmation 🎯
    $ scripts/terragrunt_create.sh --env staging --region centralindia --module networking -a  | sed -r 's/\x1b\[[0-9;]*m//g'

    # Destroy all modules 🔴
    $ scripts/terragrunt_create.sh --env staging --region centralindia --all

    ```

------------------------------------------------

## Create Azure Resource

1. [Resource Group](modules/resource-group/main.tf)
  
   ```bash
   scripts/terragrunt_create.sh --env staging --region centralindia --module resource-group --plan | sed -r 's/\x1b\[[0-9;]*m//g'
   ```
2. [Storage](modules/storage/main.tf)
   
   ```bash
   scripts/terragrunt_create.sh --env staging --region centralindia --module storage | sed -r 's/\x1b\[[0-9;]*m//g'
   ```

2. [Networking](environments/_env/vnet.hcl)
   
   ```bash
   # Or run terragrunt command without script
   WORKING_DIR="$(pwd)/environments/staging/centralindia/networking"
   WORKING_DIR=$(cygpath -w "$WORKING_DIR")

   terragrunt init --reconfigure --terragrunt-working-dir "$WORKING_DIR"

   export TF_company_name="something"
   terragrunt apply --terragrunt-working-dir "$WORKING_DIR"
   ```

2. [AKS Cluster](environments/_env/aks.hcl)

   ```bash
   scripts/terragrunt_create.sh --env staging --region centralindia --module aks | sed -r 's/\x1b\[[0-9;]*m//g'
   ```

2. [Pod Workload Identity](environments/_env/identity.hcl)

   ```bash
   scripts/terragrunt_create.sh --env staging --region centralindia --module access-control -p | sed -r 's/\x1b\[[0-9;]*m//g'
   ```

1. Get the output

   ```bash
   export TG_NON_INTERACTIVE="true"
   export TERRAGRUNT_NON_INTERACTIVE="true"
   
   # Use this for windows cygwin
   WORKING_DIR_WIN="$(cygpath -w "$(pwd)/environments/staging/centralindia")" # Use this for Windows
   terragrunt output --terragrunt-working-dir "${WORKING_DIR_WIN}\networking"
   terragrunt run-all output --terragrunt-working-dir "${WORKING_DIR_WIN}\access-control"
   terragrunt output --terragrunt-working-dir "${WORKING_DIR_WIN}\storage"
   
   # Use this for linux
   WORKING_DIR="$(pwd)/environments/staging/centralindia"
   terragrunt output --terragrunt-working-dir "${WORKING_DIR}/networking"
   terragrunt run-all output --terragrunt-working-dir "${WORKING_DIR}/access-control"
   terragrunt run-all output --terragrunt-working-dir "${WORKING_DIR}/storage"
   ```

## Push Images to ACR

```bash
ACR_REPO_NAME="vegitoapp"
az login
az acr login --name $ACR_REPO_NAME
docker push $ACR_REPO_NAME.azurecr.io/az-sample-app:v2
```

## Create K8s Infra

```bash
az aks get-credentials --resource-group staging --name "staging-aks" --admin
az aks get-credentials --resource-group staging --name "staging-aks"
```


```bash
cd manifests
helm upgrade -i flaskapp  ./azureflaskapp  -f secret-values.yaml
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

6. [Deploy and configure workload identity on an Azure Kubernetes Service (AKS) cluster](https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster)

    - [Use Microsoft Entra Workload ID with Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview?tabs=dotnet)
    - [Migrate from pod managed-identity to workload identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-migrate-from-pod-identity)