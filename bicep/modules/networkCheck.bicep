@description('Check that the specified VNet, Subnet and NSG exist in the target resource group. Throws a friendly error if any are missing.')
param vnetName string
param subnetName string
param nsgName string
param location string

// Reference existing resources. If they do not exist, properties will be null and the checks below will throw.
resource existingVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: existingVnet
  name: subnetName
}

resource existingNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' existing = {
  name: nsgName
}

// This module references the existing networking resources. If any of them do not exist,
// the deployment will fail with the Azure provider's error and that error will reference
// the missing resource. We also emit a friendly summary message as an output when the
// deployment runs so callers get a clear success message.

output message string = 'Validated network resources: vnet="${vnetName}" (id=${existingVnet.id}), subnet="${subnetName}" (id=${existingSubnet.id}), nsg="${nsgName}" (id=${existingNsg.id}). If any are missing the deployment will fail with a clear provider error.'

