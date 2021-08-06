provider "vsphere" {

  user      = "root"
  password  = "Golang@12"
  vsphere_server = "192.168.100.25"
  version = "1.15.0"

  # if you have a self-signed cert
  allow_unverified_ssl = true

}



data "vsphere_datacenter" "datacenter" {
    name = "dc1"
}


data "vsphere_host" "esxi1" {
  name = "192.168.100.25"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore1" {
    name          = "datastore1"
    datacenter_id = data.vsphere_datacenter.datacenter.id
}


data "vsphere_datastore" "datastore2" {
    name          = "datastore2"
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "rp" {}

data "vsphere_network" "networking" {
    name          = "VM Network"
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "centOS8" {
  count                      = 1
  name                       = "centOS8"
  resource_pool_id           = data.vsphere_resource_pool.rp.id
  datastore_id               = data.vsphere_datastore.datastore1.id
  force_power_off            = true
  shutdown_wait_timeout      = 1
  num_cpus                   = 1
  memory                     = 1024
  wait_for_guest_net_timeout = 0
  guest_id                   = "centos8_64Guest"
  nested_hv_enabled          = true
  network_interface {
    network_id   = data.vsphere_network.networking.id
    adapter_type = "vmxnet3"
  }
  cdrom {
    datastore_id = data.vsphere_datastore.datastore2.id
    path         = "ISOs/CentOS-8.4.2105-x86_64-boot.iso"
  }
  disk {
    size             = 10
    label            = "disk0.vmdk"
    eagerly_scrub    = false
    thin_provisioned = true
  }
}