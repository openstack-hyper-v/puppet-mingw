# === Define: mingw::dependency
#
#  >
#
# === Parameters
#
# [*name*]
# [*version*]
# [*source*]
# [*url*]
# [*type*]
#
# == Examples
#
#  windows_python::dependency { 'M2Crypto':
#    name => 'Python 2.7 M2Crypto-0.21.1'
#    remote_url      => 'http://chandlerproject.org/pub/Projects/MeTooCrypto/M2Crypto-0.21.1.win32-py2.7.msi'
#    soure      => "${::temp}\\M2Crypto-0.21.1.win32-py2.7.msi"
#  }
#
#  windows_python::dependency { 'Python 2.7 M2Crypto-0.21.1':
#    remote_url      => 'http://chandlerproject.org/pub/Projects/MeTooCrypto/M2Crypto-0.21.1.win32-py2.7.msi'
#    source      => "${::temp}\\M2Crypto-0.21.1.win32-py2.7.msi"
#  }
#
#  windows_python::dependency { 'Python 2.7 M2Crypto-0.21.1':
#    source      => "G:\\Software\\Python\\M2Crypto-0.21.1.win32-py2.7.msi"
#  }
#
# == Authors
#
define mingw::dependency (
  $remote_url = undef,
  $source     = undef,
  $version    = latest,
){
if $source == undef {
  if $remote_url == undef {
    if $version != latest {
      $source_real = "${name}==${version}"
    } else {
      $source_real = $name
    }
  } else {
    $source_real = "${::temp}\\${title}.${::type}"
    windows_common::remote_file{ $source_real:
      source      => $remote_url,
      destination => $source_real,
      before      => Exec["mingw-get-dependency-${name}"],
    }
  }
}
  exec { "mingw-get-dependency-${name}":
    command  => "& mingw-get install '${source_real}'",
    provider => powershell,
  }
}
