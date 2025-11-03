param vmName string
param location string
param adminUsername string
@secure()
param adminPassword string
param subnetId string
@allowed([
  'Credential'
  'SSH'
])
param authentication string = 'Credential'
param sshPublicKey string = ''
param imageSource string = 'Windows Server 2022 Datacenter'
param tags object = {}
param logAnalyticsName string = 'mylogspace'
param patchMode string = ''

@description('Log Analytics workspace id to register this VM with (resourceId)')
param logAnalyticsWorkspaceId string = 'fcb6faa9-cb48-4f5d-853a-32cc7b9ce289'
@secure()
@description('Primary shared key for the Log Analytics workspace')
param logAnalyticsWorkspaceKey string = '6V7c4SIs46RSMV0lLUMMkQzr5pRUoBYt/tf0La9D/I97o4XMXAVg+PXVQqYThyw93Nvmz4npMkCSpeKWwNlD7Q=='

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

var isWindows = contains(toLower(imageSource), 'windows')

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    osProfile: isWindows ? {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    } : {
      computerName: vmName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: authentication == 'SSH'
        ssh: authentication == 'SSH' ? {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        } : null
      }
    }
    storageProfile: {
      imageReference: isWindows ? {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      } : {
        publisher: 'RedHat'
        offer: 'RHEL'
        sku: '8'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// Placeholder for configuring patch mode and Log Analytics. These actions often require
// additional resources (Log Analytics workspace, Update Management / Automanage configuration).
// For now we emit outputs so automation or a follow-up module can configure them.

output vmId string = vm.id
output patchModeConfigured string = patchMode
output logAnalyticsTarget string = logAnalyticsName

// Install Log Analytics agent on the VM if workspace info is provided
var installLA = logAnalyticsWorkspaceId != '' && logAnalyticsWorkspaceKey != ''

resource laExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = if (installLA) {
  name: 'OmsAgent'
  parent: vm
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: isWindows ? 'MicrosoftMonitoringAgent' : 'OmsAgentForLinux'
    typeHandlerVersion: '1.0'
    settings: {
      workspaceId: logAnalyticsWorkspaceId
    }
    protectedSettings: {
      workspaceKey: logAnalyticsWorkspaceKey
    }
  }
}

// Output indicating whether the Log Analytics extension was deployed, and the name of the extension resource
output logAnalyticsExtensionStatus string = installLA ? 'Log Analytics agent extension deployed with resource name: ${laExtension.name}' : 'Log Analytics agent extension not deployed'

// Optional: Also output the workspace ID for confirmation
output logAnalyticsWorkspaceIdOutput string = installLA ? logAnalyticsWorkspaceId : 'No workspace ID provided'
