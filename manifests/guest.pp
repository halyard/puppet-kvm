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
  $disks::lvs.each | String $name, Hash $options | {
    disks::lv { "guest-${vm_name}-${name}":
      * => $options,
    }
  }

  exec { "/usr/bin/qemu-img convert -O raw '${kvm::image_path}/${image}' '/dev/${vg}/guest-${vm_name}-root'":
    onlyif  => "/usr/bin/file -sLb '/dev/${vg}/${lvname}' | grep '^data$'",
    require => Disks::Lv["guest-${vm_name}-root"],
  }
}
