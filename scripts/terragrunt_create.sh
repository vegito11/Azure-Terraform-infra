usage() {
    cat <<EOF
Infrastructure deployment script for your Terragrunt structure:

Options:
    -e, --env     (Required) Environment name (e.g., staging, production)
    -r, --region  (Required) Region name (e.g., west-india, east-us)
    -m, --module  (Optional) Module name (e.g., networking, apps). Deploys all modules if omitted.
    -a, --all     (Optional) Create all modules under the specified region.
    -p, --plan    (Optional) Plan only. Do not apply.
    -h, --help    Show this help message.
EOF
    exit 1
}

# Initialize variables
ENV=""
REGION=""
MODULE=""
CREATE_ALL=false
PLAN_ONLY=false

# Parse input flags
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -e|--env) ENV="$2"; shift ;;
        -r|--region) REGION="$2"; shift ;;
        -m|--module) MODULE="$2"; shift ;;
        -a|--all) CREATE_ALL=true ;;
        -p|--plan) PLAN_ONLY=true ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
    shift
done

# Validate required parameters
if [[ -z "$ENV" || -z "$REGION" ]]; then
    echo "Error: Both environment (-e/--env) and region (-r/--region) are required."
    usage
fi

# Display inputs
cat <<EOF
Environment: ${ENV}
Region: ${REGION}
Module: ${MODULE:-"ALL"}
Create All: ${CREATE_ALL}
Plan Only: ${PLAN_ONLY}
EOF

# Define the base directory
BASE_DIR="$(pwd)/environments/$ENV/$REGION"

if [[ -n "$MODULE" ]]; then
    WORKING_DIR="$BASE_DIR/$MODULE"
else
    WORKING_DIR="$BASE_DIR"
fi

# Convert to Windows path if using Cygwin/Git bash
if [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
    WORKING_DIR=$(cygpath -w "$WORKING_DIR")
fi

# Check if the working directory exists
if [[ ! -d "$WORKING_DIR" ]]; then
    echo "Error: Path $WORKING_DIR does not exist."
    exit 1
fi

 # Validate the infrastructure
echo "=== Validating infrastructure in $WORKING_DIR ==="
# terragrunt run-all validate \
#     --terragrunt-working-dir "$WORKING_DIR" \
#     --terragrunt-include-external-dependencies \
#     --terragrunt-non-interactive

export TF_CLI_ARGS="-no-color"
export NO_COLOR="1"

# Plan or apply based on the PLAN_ONLY flag
if [[ "$PLAN_ONLY" == "true" ]]; then
    echo "=== Planning infrastructure changes in $WORKING_DIR ==="
    terragrunt run-all plan  \
        --terragrunt-working-dir "$WORKING_DIR" \
        --terragrunt-include-external-dependencies \
        --terragrunt-non-interactive -no-color
        
else
    if [[ "$CREATE_ALL" == "true" ]]; then
        echo "=== Applying all modules in $WORKING_DIR ==="
        terragrunt run-all -no-color  apply  \
            --terragrunt-working-dir "$WORKING_DIR" \
            --terragrunt-include-external-dependencies \
            --terragrunt-non-interactive
    else
        read -p "Are you sure you want to apply changes to $WORKING_DIR? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "=== Applying infrastructure changes in $WORKING_DIR ==="
            terragrunt run-all -no-color apply \
                --terragrunt-working-dir "$WORKING_DIR" \
                --terragrunt-include-external-dependencies \
                --terragrunt-non-interactive
        else
            echo "Aborted apply operation."
            exit 0
        fi
    fi
fi
