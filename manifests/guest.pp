# @summary Defines a guest VM
#
# @param image sets the system image to use to bootstrap the guest
# @param disks sets the LVs to create for the guest
# @param vm_name sets the name of the VM
define kvm::guest (
  String $image,
  Hash[String, Hash] $disks,
  String $vm_name = $title,
) {
  $disks.each | String $name, Hash $options | {
    disks::lv { "guest-${vm_name}-${name}":
      * => $options,
    }
  }

  $image_path = "${kvm::image_path}/${image}"
  $root_device = "/dev/${disks['root']['vg']}/guest-${vm_name}-root"

  exec { "/usr/bin/qemu-img convert -O raw --target-is-zero '${image_path}' '${root_device}'":
    onlyif  => "/usr/bin/file -sLb '${root_device}' | grep '^data$'",
    require => Disks::Lv["guest-${vm_name}-root"],
  }
}
