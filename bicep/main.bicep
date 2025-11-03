targetScope = 'subscription'

@allowed([
  'new'
  'existing'
])
param resourceGroupType string
param resourceGroupName string
// param resourceGroupLocation string
param vmName string = 'modularVM'
param adminUsername string = 'azureadmin'
@secure()
param adminPassword string

@allowed([
  'new'
  'existing'
])
param NetworkType string = 'existing'

param vnetName string = 'vnet-uaenorth-1'
param subnetName string = 'snet-uaenorth-1'
param nsgName string = 'myvmtest-nsg'

@allowed([
  'Credential'
  'SSH'
])
param authentication string = 'Credential'
param sshPublicKey string = ''
param imageSource string = 'Windows Server 2022 Datacenter'
param tags object = {}
param logAnalyticsName string = ''
param patchMode string = ''
param location string 



// Create the resource group if needed
module rg './createResourceGroup.bicep' = {
  name: 'resourceGroup'
  params: {
    location: location
    resourceGroupType: resourceGroupType
    resourceGroupName: resourceGroupName
    // resourceGroupLocation: resourceGroupLocation
  }
}

// Deploy all resources into the resource group using a nested resource-group-scoped module
module rgResources './main-rg.bicep' = {
  name: 'rgResources'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    vmName: vmName
    adminUsername: adminUsername
    adminPassword: adminPassword
    NetworkType: NetworkType
    vnetName: vnetName
    subnetName: subnetName
    nsgName: nsgName
    authentication: authentication
    sshPublicKey: sshPublicKey
    imageSource: imageSource
    tags: tags
    logAnalyticsName: logAnalyticsName
    patchMode: patchMode
  }
  dependsOn: [ rg ]
}
