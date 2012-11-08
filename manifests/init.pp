# Class: passenger
#
# This class installs Passenger (mod_rails) on your system.
# http://www.modrails.com
#
# Parameters:
#   [*passenger_version*]
#     The Version of Passenger to be installed
#
#   [*gem_path*]
#     The path to rubygems on your system
#
#   [*gem_binary_path*]
#     Path to Rubygems binaries on your system
#
#   [*mod_passenger_location*]
#     Path to Passenger's mod_passenger.so file
#
#   [*passenger_provider*]
#     The package provider to use for the system
#
#   [*passenger_package*]
#     The name of the Passenger package
#   
#   [*nginx_helper_location*]
#     Path to the nginx helper location
#
# Usage (!RedHat):
#
#  class { 'passenger':
#    passenger_version      => '3.0.13',
#    passenger_ruby         => '/usr/bin/ruby'
#    gem_path               => '/var/lib/gems/1.8/gems',
#    gem_binary_pcent-demo1.library.northwestern.eduath        => '/var/lib/gems/1.8/bin',
#    mod_passenger_location => '/var/lib/gems/1.8/gems/passenger-3.0.9/ext/apache2/mod_passenger.so',
#    nginx_helper_location  => '/var/lib/gems/1.8/gems/passenger-3.0.9/ext/apache2/mod_passenger.so',
#    passenger_provider     => 'gem',
#    passenger_package      => 'passenger',
#  }
#
#
# Requires:
#   - apache
#   - apache::dev
# or
#   - nginx_passenger
#
class passenger_apache (
  $passenger_version      = $passenger_apache::params::passenger_version,
  $passenger_ruby         = $passenger_apache::params::passenger_ruby,
  $gem_path               = $passenger_apache::params::gem_path,
  $gem_binary_path        = $passenger_apache::params::gem_binary_path,
  $nginx_helper_location  = $passenger_apache::params::nginx_helper_location,
  $mod_passenger_location = $passenger_apache::params::mod_passenger_location,
  $passenger_provider     = $passenger_apache::params::passenger_provider,
  $passenger_package      = $passenger_apache::params::passenger_package,
  $passenger_webserver    = $passenger_apache::params::passenger_webserver,
) inherits passenger_apache::params {


  case $::osfamily {
    'debian': {
      package { [$passenger::params::libruby, 'libcurl4-openssl-dev']:
        ensure => present,
        before => Exec['compile-passenger'],
      }

      file { '/etc/apache2/mods-available/passenger.load':
        ensure  => present,
        content => template('passenger/passenger-load.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644',
      }

      file { '/etc/apache2/mods-available/passenger.conf':
        ensure  => present,
        content => template('passenger/passenger-enabled.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644',
      }

      file { '/etc/apache2/mods-enabled/passenger.load':
        ensure  => 'link',
        target  => '/etc/apache2/mods-available/passenger.load',
        owner   => '0',
        group   => '0',
        mode    => '0777',
        require => File['/etc/apache2/mods-available/passenger.load'],
      }

      file { '/etc/apache2/mods-enabled/passenger.conf':
        ensure  => 'link',
        target  => '/etc/apache2/mods-available/passenger.conf',
        owner   => '0',
        group   => '0',
        mode    => '0777',
        require => File['/etc/apache2/mods-available/passenger.conf'],
      }
    }
    'redhat': {
      package { ['libcurl-devel', 'rubygems', 'ruby-devel', 'make', 'gcc', 'gcc-c++', 'zlib-devel', 'openssl-devel', 'httpd-devel',]:
        ensure => present,
        before => Package['passenger'],
      }
      
      file { '/etc/httpd/conf.d/passenger.conf':
        ensure    => present,
        owner     => 'root',
        group     => 'root',
        content   => template('passenger_apache/passenger-conf.erb'),
        require   => Exec['compile-passenger'],
      }

    }
    default:{
      fail("Operating system ${::operatingsystem} is not supported with the Passenger module")
    }
  }

  package {'passenger':
    name     => $passenger_package,
    ensure   => $passenger_version,
    provider => $passenger_provider,
    before  => Exec['compile-passenger'],
  }
     
      exec {'compile-passenger':
        path      => [ $gem_binary_path, '/usr/bin', '/bin', '/usr/local/bin', '/usr/sbin'],
        logoutput => on_failure,
        cwd       => "/usr/lib/ruby/gems/1.8/gems/passenger-$passenger_version/",
        creates   => $mod_passenger_location,
        require   => Package['passenger'],
        notify    => Service['httpd'],
        command   => 'passenger-install-apache2-module -a',
      }
}

