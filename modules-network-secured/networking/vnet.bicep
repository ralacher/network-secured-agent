/*
Virtual Network Module
---------------------
This module deploys the core network infrastructure with security controls:

1. Address Space:
   - VNet CIDR: 172.16.0.0/16
   - Hub Subnet: 172.16.0.0/24 (private endpoints)
   - Agents Subnet: 172.16.101.0/24 (container apps)

2. Security Features:
   - Service endpoints
   - Network isolation
   - Subnet delegation
*/

@description('Azure region for the deployment')
param location string

@description('Tags to apply to resources')
param tags object = {}

@description('Unique suffix for resource names')
param suffix string

@description('The name of the virtual network')
param vnetName string = 'agent-vnet'

@description('The name of Agents Subnet')
param agentsSubnetName string = 'agent-subnet'

@description('The name of Hub subnet')
param hubSubnetName string = 'hub-subnet'

@description('Model/AI Resource deployment location')
param modelLocation string

// Virtual Network with segregated subnets
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: hubSubnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: agentsSubnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
          delegations: [
            {
              name: 'Microsoft.app/environments'
              properties: {
                serviceName: 'Microsoft.App/environments'
              }
            }
          ]
        }
      }
    ]
  }
}

// Output variables
output virtualNetworkName string = virtualNetwork.name
output virtualNetworkId string = virtualNetwork.id
output hubSubnetName string = hubSubnetName
output agentsSubnetName string = agentsSubnetName
output hubSubnetId string = '${virtualNetwork.id}/subnets/${hubSubnetName}'
output agentsSubnetId string = '${virtualNetwork.id}/subnets/${agentsSubnetName}'
