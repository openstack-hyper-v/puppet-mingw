# === Class: mingw
#
# === Authors
#
#
class mingw (
  $mgw_get_version = $mingw::params::mgw_get_version,
  $mgw_get_path    = $mingw::params::mgw_get_path,
  $mgw_path_base   = $mingw::params::mgw_path_base,
) inherits mingw::params {

  file {"${mgw_get_path}":
     ensure      => "directory",
  }

  windows_common::remote_file{"mingw-get":
    source       => "http://downloads.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-${mgw_get_version}-${mgw_get_build}/mingw-get-${mgw_get_version}-mingw32-${mgw_get_build}-bin.zip",
    destination  => "${mgw_get_path}\\mingw-get.zip",
    before       => Windows_7zip::Extract_file['mingw-get'],
    require      => File["${mgw_get_path}"],
  }

  windows_7zip::extract_file{'mingw-get':
    file         => "${mgw_get_path}\\mingw-get.zip",
    destination  => $mgw_get_path,
    before       => Exec['install-mingw'],
    subscribe    => Windows_common::Remote_file["mingw-get"],
  }

  $python_package = 'python.x86'

  package {
    $python_package:
      ensure     => installed,
      provider   => 'chocolatey';
    'easy.install':
      ensure     => installed,
      provider   => 'chocolatey';
  }

  windows_common::remote_file{"get_pip_installer":
    source       => "https://raw.github.com/pypa/pip/master/contrib/get-pip.py",
    destination  => "C:\\get-pip.py",
  }

  exec {
    'install_pip':
      command   => 'python "C:\\get-pip.py"',
      require   => [Package[$python_package,'easy.install'], Windows_common::Remote_file['get_pip_installer']],
      provider  => powershell;
    'install-mingw':
      command   => "set \"mingw=${mgw_path_base}\" ; ${mgw_get_path}\\bin\\mingw-get.exe install mingw32-base",
      provider  => powershell,
      before    => Mingw::Dependency['msys'],
  }

  mingw::dependency{ 'msys':
    remote_url => undef,
    source     => undef,
    version    => undef,
  }

  $mingw_path = "${mgw_get_path}\\bin"

  windows_path { $mingw_path:
    ensure     => present,
    require    => Exec['install-mingw'],
    before     => Mingw::Dependency['msys'],
    notify     => Reboot['after_run'],
  }

  $msys_path = "${mgw_get_path}\\msys\\1.0\\bin"

  windows_path { $msys_path:
    ensure     => present,
    require    =>  Mingw::Dependency['msys'],
    notify     => Reboot['after_run'],
  }

  reboot { 'after_run':
    apply      => finished,
  }

  $python_installdir  = 'C:\Python27'

  windows_path { $python_installdir:
    ensure     => present,
    require    => Package[$python_package],
    notify     => Reboot['after_run'],
  }

  windows_path { "${python_installdir}\\Scripts":
    ensure     => present,
    require    => Package[$python_package],
    notify     => Reboot['after_run'],
  }

  $distutils_cfg = "${python_installdir}\\Lib\\distutils\\distutils.cfg"

  file { $distutils_cfg:
    ensure     => file,
    source     => 'puppet:///modules/mingw/distutils.cfg',
    require    => Exec['install_pip','install-mingw'],
  }

  $cygwinccompiler_py = "${python_installdir}\\Lib\\distutils\\cygwinccompiler.py"

  file { $cygwinccompiler_py:
    ensure     => file,
    source     => "puppet:///modules/mingw/cygwinccompiler.py",
    require    => Exec['install_pip','install-mingw'],
  }
}

