# @summary Configure KVM hosting
#
# @param image_path sets the base directory for image storage
# @param console_path sets the location for QEMU/serial sockets
# @param images sets the OS images to use for bootstrapping VMs
# @param guests sets guest VM information for management
class kvm (
  String $image_path,
  String $console_path = '/var/lib/kvm',
  Hash[String, Hash] $images = [],
  Hash[String, Hash] $guests = {},
) {
  package { [
      'qemu-base',
      'socat',
  ]: }

  file { [$console_path, "${console_path}/vnc", "${console_path}/serial",  "${console_path}/monitor"]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  $images.each | String $name, Hash $options | {
    kvm::image { $name:
      * => $options,
    }
  }

  $guests.each | String $name, Hash $options | {
    kvm::guest { $name:
      * => $options,
    }
  }

  file { '/etc/qemu':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/qemu/bridge.conf':
    ensure  => file,
    content => template('kvm/bridge.conf.erb'),
  }

  file { '/etc/kvm':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/systemd/system/kvm@.service':
    ensure => file,
    source => 'puppet:///modules/kvm/kvm@.service',
  }
}
