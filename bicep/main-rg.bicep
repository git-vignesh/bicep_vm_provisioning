param vmName string
param adminUsername string
@secure()
param adminPassword string
param NetworkType string
param vnetName string
param subnetName string
param nsgName string
param authentication string
param sshPublicKey string
param imageSource string
param tags object
param logAnalyticsName string
param patchMode string
param location string = resourceGroup().location

module networkNew './modules/networkNew.bicep' = if (NetworkType == 'new') {
  name: 'networkNew'
  params: {
    location: location
    vnetName: vnetName
    subnetName: subnetName
    nsgName: nsgName
  }
}

module networkCheck './modules/networkCheck.bicep' = if (NetworkType == 'existing') {
  name: 'networkCheck'
  params: {
    location: location
    vnetName: vnetName
    subnetName: subnetName
    nsgName: nsgName
  }
}

// Use the subnet ID output from networkNew if creating new, else derive
var subnetId = NetworkType == 'new' ? networkNew.outputs.subnetId : resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

module vm './vm.bicep' = {
  name: 'vmDeploy'
  dependsOn: (NetworkType == 'new') ? [networkNew] : []
  params: {
    vmName: vmName
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    subnetId: subnetId
    authentication: authentication
    sshPublicKey: sshPublicKey
    imageSource: imageSource
    tags: tags
    logAnalyticsName: logAnalyticsName
    patchMode: patchMode
  }
}
