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

  
  windows_common::remote_file{"mingw-get":
    source      => "http://downloads.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-${mgw_get_version}/mingw-get-${mgw_get_version}-bin.zip",
    destination => "${mgw_get_path}\\mingw-get.zip",
  }
  
  windows_7zip::extract_file{'':
    file        => "${mgw_get_path}\\mingw-get.zip",
    destination => $mgw_get_path,
  }

#  Package { provider => chocolatey }
#
#  package {'python.x86':
#    ensure => installed,
# }
#  package {'easyinstall':
#    ensure => installed,
#  }
#  package {'pip':
#    ensure => installed,
#  }
#  package {'mingw':
#    ensure => installed,
#  }
#  package {'git':
#   ensure => installed,
#  }

  $python_package = 'python.x86'
  
  package {
    $python_package: 
      ensure => installed,
      provider => chocolatey;
    'easy.install':
      ensure => installed,
      provider => chocolatey;
  }
  exec { 
    'get_pip_installer':
      provider  => powershell,
      unless    => '[IO.File]::Exists("$env:temp\get-pip.py")',
      command   => '(New-Object Net.WebClient).DownloadFile("https://raw.github.com/pypa/pip/master/contrib/get-pip.py", "$env:temp\get-pip.py")';
    'install_pip':
      command   => 'cmd.exe /c python %temp%\get-pip.py',
      require   => [Package[$python_package,'easy.install'], Exec['get_pip_installer']];
    'install-mingw':
      command   => "cmd.exe /c set \"mingw=${mgw_path_base}\" ; ${mgw_get_path}\\bin\\mingw-get.exe install mingw32-base",
  }
  
  
  $mingw_path = "${mgw_path_base}\bin"  

  windows_path { $mingw_path:
    ensure => present,
    require => Exec['install-mingw'],
  }
  
#  $git_path = 'C:\Program Files\Git\cmd'
# 
#  windows_path { $git_path:
#    ensure  => present,
#    require => Package['git'],
#  }

  $python_installdir  = 'C:\Python27'

  windows_path { $python_installdir:
    ensure  => present,
    require => Package[$python_package],
  }

  windows_path { "${python_installdir}\\Scripts":
    ensure  => present,
    require => Package[$python_package],
  }

  $distutils_cfg = "${python_installdir}\\Lib\\distutils\\distutils.cfg"

  file { $distutils_cfg:
    ensure  => file,  
    source => 'puppet:///modules/mingw/distutils.cfg',
    require => Exec['install_pip','install-mingw'],
  }

  $cygwincompiler_py = "${python_installdir}\\Lib\\distutils\\cygwinccompiler.py"

  file { $cygwinccompiler_py:
    ensure  => file,  
    source => 'puppet:///modules/mingw/cygwincompiler.py',
    require => Exec['install_pip','install-mingw'],
  }

}
