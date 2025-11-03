param vnetName string
param subnetName string
param nsgName string

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

// If any of the above doesn't exist, deployment will fail with a clear message.
output vnetId string = existingVnet.id
output subnetId string = existingSubnet.id
output nsgId string = existingNsg.id
