@description('Location where all resources will be created.')
param location string = resourceGroup().location

@description('Name of the Virtual Wan.')
param wanname string = 'SampleVirtualWan'

@allowed([
  'Standard'
  'Basic'
])
@description('Sku of the Virtual Wan.')
param wansku string = 'Standard'

@description('Name of the Virtual Hub. A virtual hub is created inside a virtual wan.')
param hubname string = 'SampleVirtualHub'

@description('Name of the Vpn Gateway. A vpn gateway is created inside a virtual hub.')
param vpngatewayname string = 'SampleVpnGateway'

@description('Name of the vpnsite. A vpnsite represents the on-premise vpn device. A public ip address is mandatory for a vpn site creation.')
param vpnsitename string = 'SampleVpnSite'

@description('Name of the vpnconnection. A vpn connection is established between a vpnsite and a vpn gateway.')
param connectionName string = 'SampleVpnsiteVpnGwConnection'

@description('A list of static routes corresponding to the vpn site. These are configured on the vpn gateway.')
param vpnsiteAddressspaceList array = []

@description('The public IP address of a vpn site.')
param vpnsitePublicIPAddress string

@description('The bgp asn number of a vpnsite.')
param vpnsiteBgpAsn int

@description('The bgp peer IP address of a vpnsite.')
param vpnsiteBgpPeeringAddress string

@description('The hub address prefix. This address prefix will be used as the address prefix for the hub vnet')
param addressPrefix string = '192.168.0.0/24'

@allowed([
  'true'
  'false'
])
@description('This needs to be set to true if BGP needs to enabled on the vpn connection.')
param enableBgp string = 'false'

resource wanname_resource 'Microsoft.Network/virtualWans@2020-05-01' = {
  name: wanname
  location: location
  properties: {
    type: wansku
  }
}

resource hubname_resource 'Microsoft.Network/virtualHubs@2020-05-01' = {
  name: hubname
  location: location
  properties: {
    addressPrefix: addressPrefix
    virtualWan: {
      id: wanname_resource.id
    }
  }
}

resource vpnsitename_resource 'Microsoft.Network/vpnSites@2020-05-01' = {
  name: vpnsitename
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vpnsiteAddressspaceList
    }
    bgpProperties: {
      asn: vpnsiteBgpAsn
      bgpPeeringAddress: vpnsiteBgpPeeringAddress
      peerWeight: 0
    }
    deviceProperties: {
      linkSpeedInMbps: 0
    }
    ipAddress: vpnsitePublicIPAddress
    virtualWan: {
      id: wanname_resource.id
    }
  }
}

resource vpngatewayname_resource 'Microsoft.Network/vpnGateways@2020-05-01' = {
  name: vpngatewayname
  location: location
  properties: {
    connections: [
      {
        name: connectionName
        properties: {
          connectionBandwidth: 10
          enableBgp: enableBgp
          remoteVpnSite: {
            id: vpnsitename_resource.id
          }
        }
      }
    ]
    virtualHub: {
      id: hubname_resource.id
    }
    bgpSettings: {
      asn: 65515
    }
  }
}
