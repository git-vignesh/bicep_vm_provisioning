// main-rg.bicep: resource-group-scope deployment for all resources
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
// param createLogAnalytics bool  // removed: Log Analytics module deleted

// Log Analytics module removed — workspace creation/registration disabled

module networkNew './modules/networkNew.bicep' = if (NetworkType == 'new') {
  name: 'networkNew'
  params: {
    location: resourceGroup().location
    vnetName: vnetName
    subnetName: subnetName
    nsgName: nsgName
  }
}

module networkCheck './modules/networkCheck.bicep' = if (NetworkType == 'existing') {
  name: 'networkCheck'
  params: {
    vnetName: vnetName
    subnetName: subnetName
    nsgName: nsgName
  }
}

var derivedSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

module vm './vm.bicep' = {
  name: 'vmDeploy'
  params: {
    vmName: vmName
    location: resourceGroup().location
    adminUsername: adminUsername
    adminPassword: adminPassword
    subnetId: derivedSubnetId
    authentication: authentication
    sshPublicKey: sshPublicKey
    imageSource: imageSource
    tags: tags
    logAnalyticsName: logAnalyticsName
    patchMode: patchMode
  }
}
