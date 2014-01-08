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

  exec {'install-mingw':
      command   => "set \"mingw=${mgw_path_base}\" ; ${mgw_get_path}\\bin\\mingw-get.exe install mingw32-base",
      provider  => powershell,
      before    => [Mingw::Dependency['msys'],Mingw::Dependency['gcc'],Mingw::Dependency['g++'],Mingw::Dependency['mingw32-make'],Mingw::Dependency['libtool']],
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
    require    => Mingw::Dependency['msys'],
    notify     => Reboot['after_run'],
  }

  mingw::dependency{ 'gcc':
    remote_url => undef,
    source     => undef,
    version    => undef,
  }

  mingw::dependency{ 'g++':
    remote_url => undef,
    source     => undef,
    version    => undef,
  }

  mingw::dependency{ 'mingw32-make':
    remote_url => undef,
    source     => undef,
    version    => undef,
  }

  mingw::dependency{ 'libtool':
    remote_url => undef,
    source     => undef,
    version    => undef,
  }

  reboot { 'after_run':
    apply      => finished,
  }
  $python_installdir  = 'C:\Python27'

  $distutils_cfg = "${python_installdir}\\Lib\\distutils\\distutils.cfg"

  file { $distutils_cfg:
    ensure     => file,
    source     => 'puppet:///modules/mingw/distutils.cfg',
    require    => Exec['install-mingw'],
  }

  $cygwinccompiler_py = "${python_installdir}\\Lib\\distutils\\cygwinccompiler.py"

  file { $cygwinccompiler_py:
    ensure     => file,
    source     => "puppet:///modules/mingw/cygwinccompiler.py",
    require    => Exec['install-mingw'],
  }
}
