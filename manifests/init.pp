# @summary Configure KVM hosting
#
# @param image_path sets the base directory for image storage
# @param images sets the OS images to use for bootstrapping VMs
# @param guests sets guest VM information for management
class kvm (
  String $image_path,
  Hash[String, Hash] $images = [],
  Hash[String, Hash] $guests = {},
) {
  package { 'qemu-headless': }

  $images.each | String $name, Hash $options | {
    file { "${image_path}/${name}":
      ensure   => file,
      source   => $options['url'],
      checksum => $options['checksum'],
      mode     => '0644',
      owner    => 'root',
      group    => 'root',
    }
  }

  $guests.each | String $name, Hash $options | {
  }
}
