set_account() {
	if [ "$1" = "shopkart" ]; then
		export ARM_CLIENT_ID="XXXX-XXXX-XXXX-XXXX-XXXXXXX"
		export ARM_CLIENT_SECRET="XXXXXXXXX.XXXXXX"
		export ARM_TENANT_ID="XXXX-XXXX-XXX-XX-XXXX"
		export ARM_SUBSCRIPTION_ID="XXXX-XXX-XX-XX-XXX"
		export TF_admin_group_object_id="XXXX-XXX-XX-XX-XXX"
		export AZ_ACCOUNT="testing@shopkart.io"
        export STATE_STORAGE_ACC_NAME="shopkart0infra0bucket"

	elif [ "$1" = "metabook" ]; then
		export ARM_CLIENT_ID="XX"
		export ARM_CLIENT_SECRET="XXXX"
		export ARM_TENANT_ID="XXXX-XXXX-XXX-XX-XXXX"
		export ARM_SUBSCRIPTION_ID="XXXX-XXX-XX-XX-XXX"
		export TF_admin_group_object_id="XXXX-XXX-XX-XX-XXX"
		export AZ_ACCOUNT="testing@metabook.com"
        export STATE_STORAGE_ACC_NAME="metabook0infra0bucket"
	else
	    echo "Unknown account number: $1"
	    return 1
	fi
	echo "Switched to account $1"
}

alias azu_shopkart='set_account shopkart'
alias azu_metabook='set_account metabook'