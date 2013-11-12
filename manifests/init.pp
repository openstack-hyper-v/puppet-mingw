# === Class: mingw
#
# === Authors
# 
#
class mingw {

  Package { provider => chocolatey }
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
  package {'mingw':
    ensure => installed,
  }
 # package {'git':
 #  ensure => installed,
 # }


  $mingw_path = 'C:\MinGW\bin'  

  windows_path { $mingw_path:
    ensure => present,
    require => Package['mingw'],
  }

  
  
 $git_path = 'C:\Program Files\Git\cmd'
 
 # windows_path { $git_path:
 #   ensure  => present,
 #   require => Package['git'],
 # }

 $python_installdir  = 'C:\Python27'

  windows_path { $python_installdir:
    ensure  => present,
    require => Package[$python_package],
  }

  windows_path { "${python_installdir}\\Scripts":
    ensure  => present,
    require => Package[$python_package],
  }
  



#  file {"${::temp}\\MinGW.zip":
#    ensure => file,
#    source => "puppet:///extra_files/MinGW/MinGW.zip"
#  }

#  extract_file {'MinGW':
#    $file => "${::temp}\\MinGW.zip",
#    $destination => C:\\"
#  }


  $distutils_cfg = 'C:\\Python27\\Lib\\distutils\\distutils.cfg'

  file { $distutils_cfg:
    ensure  => file,  
    source => 'puppet:///modules/mingw/distutils.cfg',
    require => Package['pip','mingw'],
  }

  $cygwincompiler_py = 'C:\\Python27\\Lib\\distutils\\cygwinccompiler.py'

  file { $cygwinccompiler_py:
    ensure  => file,  
    source => 'puppet:///modules/mingw/cygwincompiler.py',
    require => Package['pip','mingw'],
  }

}
