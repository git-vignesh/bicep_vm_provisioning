# Replace these variables
$workspaceName = "mylogspace"
$resourceGroup = "pocrg"

# Get the workspace key
az monitor log-analytics workspace get-shared-keys --resource-group $resourceGroup --workspace-name $workspaceName --query primarySharedKey -o tsv
