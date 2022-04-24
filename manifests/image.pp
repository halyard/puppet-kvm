# @summary Downloads a VM base image
#
# @param url sets the source URL for the image
# @param checksum sets the checksum for the image
# @param image_name sets the name of the image
# @param base_dir sets the parent directory for images
define kvm::image (
  String $url,
  String $checksum,
  String $image_name = $title,
  String $base_dir = $kvm::image_path,
) {
  file { "${base_dir}/${image_name}":
    ensure         => file,
    source         => $url,
    checksum_value => $checksum,
    mode           => '0644',
    owner          => 'root',
    group          => 'root',
  }
}
