# Create virtual network with Azure PowerShell
# Ref: https://timw.info/1bc

# create the resource group
New-AzResourceGroup -Name 'pluralsight' -Location EastUS

# create the virtual network
$vnet = @{
  Name              = 'ps-hub-vnet'
  ResourceGroupName = 'pluralsight'
  Location          = 'EastUS'
  AddressPrefix     = '172.17.0.0/16'
}
$virtualNetwork = New-AzVirtualNetwork @vnet

# add subnets
$subnet1 = @{
  Name           = 'workload'
  VirtualNetwork = $virtualNetwork
  AddressPrefix  = '172.17.1.0/24'
}
Add-AzVirtualNetworkSubnetConfig @subnet1

$subnet2 = @{
  Name           = 'AzureFirewallSubnet'
  VirtualNetwork = $virtualNetwork
  AddressPrefix  = '172.17.2.0/24'
}
Add-AzVirtualNetworkSubnetConfig @subnet2

$subnet3 = @{
  Name           = 'AzureBastionSubnet'
  VirtualNetwork = $virtualNetwork
  AddressPrefix  = '172.17.3.0/24'
}
Add-AzVirtualNetworkSubnetConfig @subnet3

# Associate subnets to VNet
$virtualNetwork | Set-AzVirtualNetwork