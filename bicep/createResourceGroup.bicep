// createResourceGroup.bicep
targetScope = 'subscription'

@allowed([
  'new'
  'existing'
])
param resourceGroupType string
param resourceGroupName string
param location string = 'uaenorth'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (resourceGroupType == 'new') {
  name: resourceGroupName
  location: location
}

resource existingResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (resourceGroupType == 'existing') {
  name: resourceGroupName
}

output resourceGroupName string = resourceGroupType == 'new' ? resourceGroup.name : existingResourceGroup.name
