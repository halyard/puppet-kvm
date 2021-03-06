# @summary Defines a guest VM
#
# @param image sets the system image to use to bootstrap the guest
# @param disks sets the LVs to create for the guest
# @param ram sets the memory given to the VM
# @param cores sets the CPU core count given to the VM
# @param vm_name sets the name of the VM
# @param bridge sets the bridge interface to use for networking
define kvm::guest (
  String $image,
  Hash[String, Hash] $disks,
  Integer $ram = 1024,
  Integer $cores = 1,
  String $vm_name = $title,
  Optional[String] $bridge = undef,
) {
  $disks.each | String $name, Hash $options | {
    disks::lv { "guest-${vm_name}-${name}":
      * => $options,
    }
  }

  $image_path = "${kvm::image_path}/${image}"
  $root_device = "/dev/${disks['root']['vg']}/guest-${vm_name}-root"
  $vnc_path = "${kvm::console_path}/vnc/${vm_name}.sock"
  $serial_path = "${kvm::console_path}/serial/${vm_name}.sock"
  $monitor_path = "${kvm::console_path}/monitor/${vm_name}.sock"
  $mac_address_seed = fqdn_rand(4294967295, "macaddress-${vm_name}", true)

  exec { "Create root for ${root_device}":
    command => "/usr/bin/qemu-img convert -O raw -n '${image_path}' '${root_device}'",
    onlyif  => "/usr/bin/file -sLb '${root_device}' | grep '^data$'",
    require => Disks::Lv["guest-${vm_name}-root"],
  }

  -> file { "/etc/kvm/${vm_name}":
    ensure  => file,
    content => template('kvm/guest.conf.erb'),
    require => File['/etc/qemu/bridge.conf'],
  }

  ~> service { "kvm@${vm_name}":
    ensure => running,
    enable => true,
  }
}
