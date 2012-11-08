# Passenger Module

This module is hacked up from the original puppetlabs-passenger module.

# Quick Start

You can use this module like so for Apache:

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