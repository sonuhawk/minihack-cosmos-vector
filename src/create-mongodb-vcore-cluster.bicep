@description('Azure Cosmos DB MongoDB vCore cluster name')
@maxLength(40)
param clusterName string = '' //= 'lab-${uniqueString(resourceGroup().id)}'

@description('Location for the cluster.')
param dblocation string = ''

@description('Username for admin user')
param adminUsername string = ''

@description('Public IP address to allow access to the cluster')
param publicIp string = '0.0.0.0'
param publicIpRuleName string = 'labMachineIPAccessRule'

@secure()
@description('Password for admin user')
//@minLength(8)
@maxLength(128)
param adminPassword string = ''

resource cluster 'Microsoft.DocumentDB/mongoClusters@2024-03-01-preview' = {
  name: clusterName
  location: dblocation
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    nodeGroupSpecs: [
      {
        kind: 'Shard'
        nodeCount: 1
        sku: 'M10'
        diskSizeGB: 32
        enableHa: false
      }
    ]
  }
}

resource firewallRules 'Microsoft.DocumentDB/mongoClusters/firewallRules@2023-03-01-preview' = {
  parent: cluster
  name: 'AllowAllAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource firewallRules_local_access 'Microsoft.DocumentDB/mongoClusters/firewallRules@2023-03-01-preview' = {
  parent: cluster
  name: publicIpRuleName
  properties: {
    startIpAddress: publicIp
    endIpAddress: publicIp
  }
}
