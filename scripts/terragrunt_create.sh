usage() {
    cat <<EOF
Infrastructure deployment script for your Terragrunt structure:

Options:
    -e, --env     (Required) Environment name (e.g., staging, production)
    -r, --region  (Required) Region name (e.g., centralindia, east-us)
    -m, --module  (Optional) Module name (e.g., networking, apps). Operates on all modules if omitted.
    -a, --all     (Optional) Apply all modules under the specified region.
    -p, --plan    (Optional) Plan only. Do not apply.
    -d, --destroy (Optional) Destroy the infrastructure.
    --init        (Optional) Run terragrunt init before other operations.
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
DESTROY=false
RUN_INIT=false
INIT_ONLY=false

# Parse input flags
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -e|--env) ENV="$2"; shift ;;
        -r|--region) REGION="$2"; shift ;;
        -m|--module) MODULE="$2"; shift ;;
        -a|--all) CREATE_ALL=true ;;
        -p|--plan) PLAN_ONLY=true ;;
        -d|--destroy) DESTROY=true ;;
        --init) RUN_INIT=true ;;
        --init-only) RUN_INIT=true; INIT_ONLY=true ;; 
        -h|--help) usage ;;
        *) EXTRA_ARGS+=("$1") ;;  # Collect additional arguments
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
Destroy: ${DESTROY}
Run Init: ${RUN_INIT}
Run INIT_ONLY: ${INIT_ONLY}
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

# Run terragrunt init if --init flag is set
if [[ "$RUN_INIT" == "true" ]]; then
    echo "=== Initializing infrastructure in $WORKING_DIR ==="
    terragrunt init \
        --terragrunt-working-dir "$WORKING_DIR" \
        --terragrunt-non-interactive "${EXTRA_ARGS[@]}"
    
    # Exit immediately if --init-only flag is set
    if [[ "$INIT_ONLY" == "true" ]]; then
        echo "=== Init completed. Exiting as --init-only was specified. ==="
        exit 0
    fi        
fi

# Handle destroy operation
if [[ "$DESTROY" == "true" ]]; then
    echo "=== Destroying infrastructure in $WORKING_DIR ==="
    read -p "Are you sure you want to destroy the infrastructure in $WORKING_DIR? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        terragrunt run-all destroy \
            --terragrunt-working-dir "$WORKING_DIR" \
            --terragrunt-non-interactive "${EXTRA_ARGS[@]}"
            # -terragrunt-exclude-external-dependencies
            # --no-destroy-dependencies-check \
            # --disable-dependent-modules \
            # --terragrunt-include-external-dependencies \
    else
        echo "Aborted destroy operation."
        exit 0
    fi
elif [[ "$PLAN_ONLY" == "true" ]]; then
    echo "=== Planning infrastructure changes in $WORKING_DIR ==="
    terragrunt run-all plan \
        --terragrunt-working-dir "$WORKING_DIR" \
        --terragrunt-non-interactive "${EXTRA_ARGS[@]}"
        # --terragrunt-include-external-dependencies \
else
    if [[ "$CREATE_ALL" == "true" ]]; then
        echo "=== Applying all modules in $WORKING_DIR ==="
        terragrunt run-all apply \
            --terragrunt-working-dir "$WORKING_DIR" \
            --terragrunt-non-interactive "${EXTRA_ARGS[@]}"
            # --terragrunt-include-external-dependencies \
    else
        read -p "Are you sure you want to apply changes to $WORKING_DIR? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "=== Applying infrastructure changes in $WORKING_DIR ==="
            terragrunt run-all apply \
                --terragrunt-working-dir "$WORKING_DIR" \
                --terragrunt-non-interactive "${EXTRA_ARGS[@]}"
                # --terragrunt-include-external-dependencies \
        else
            echo "Aborted apply operation."
            exit 0
        fi
    fi
fi
