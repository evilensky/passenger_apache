# Passenger Module

This module is hacked up from the original puppetlabs-passenger module.

# Quick Start

You can use this module like so for Apache: (depends on puppetlabs-apache).

    include apache
    include passenger_apache
    
    apache::vhost { 'fromthepage.northwestern.edu':
       priority        => '10',
       port            => '80',
       docroot         => '/var/www/fromthepage/',
       passenger       => true,
    }

Nginx support (with NUL-specific RPM dependencies) is coming soon!®

#Links
See: https://github.com/evilensky/nginx-passenger-1.2.2-3.0.13-2.el6.src

And because my puppetlabs-apache module is so hopelessly behind the current master, this is a change to Puppetlabs-apache/manifest/vhost.pp

  define apache::vhost(
    $port,
    $docroot,
    $passenger          = false,
    $configure_firewall = false,
    $ssl                = $apache::params::ssl,
    #$template           = $apache::params::template,
    $priority           = $apache::params::priority,
    $servername         = $apache::params::servername,
    $serveraliases      = $apache::params::serveraliases,
    $auth               = $apache::params::auth,
    $redirect_ssl       = $apache::params::redirect_ssl,
    $options            = $apache::params::options,
    $apache_name        = $apache::params::apache_name,
    $vhost_name         = $apache::params::vhost_name,

  ) {

  include apache

  if $passenger == true {
    $template = $apache::params::template_passenger.
  } else {
    $template = $apache::params::template
  }