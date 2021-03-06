# == Class: colorprompt
#
# This module adds colors to your bash prompt.
#
# === Parameters
#
# [*ensure*]
#   Ensure if present or absent.
#   Type: string
#   Default: present
#
# [*path*]
#   Path to colorprompt.sh file
#   Type: string
#   Default: /etc/profile.d/colorprompt.sh
#
# [*default_usercolor*]
#   Sets the color for all users. Spesific user colors can be overrided by 'custom_usercolors'. Defaults to 'cyan'.
#   Type: string or array
#   Default: 'cyan'
#
# [*custom_usercolors*]
#   Sets the color for spesific users.
#   Type: hash
#   Default: { 'root' => 'magenta' }
#
# [*server_color*]
#   Ensure if present or absent.
#   Type: string or array
#   Default: undef
#
# [*env_name*]
#   Ensure if present or absent.
#   Type: string
#   Default: undef
#
# [*env_color*]
#   Ensure if present or absent.
#   Type: string or array
#   Default: undef
#
# [*prompt*]
#   Sets the final $PS1 variable. Use ${env}, ${userColor} and ${serverColor}
#   Type: string
#   Default:
#   '${env}[${userColor}\u\[\e[0m\]@${serverColor}\h\[\e[0m\] \w]\\$ ' on RedHat
#   '${env}[${userColor}\u\[\e[0m\]@${serverColor}\h\[\e[0m\] \W]\\$ ' on Debian
#
# [*modify_skel*]
#   Comments out PS1 variables in /etc/skel/.bashrc on Debian distributions
#   Type: boolean
#   Default: true on Debian, false on RedHat
#
# [*modify_root*]
#   Comments out PS1 variables in /root/.bashrc on Debian distributions
#   Type: boolean
#   Default: true on Debian, false on RedHat
#
# === Examples
#
#  class { 'colorprompt':
#     ensure            => present,
#     env_name          => 'PROD',
#     env_color         => ['white', 'bg_red'],
#     server_color      => 'red',
#     default_usercolor => 'cyan',
#     custom_usercolors => {
#       'root' => 'magenta',
#     },
#  }
#
# === Original Authors
#
# Gjermund Jensvoll <gjerjens@gmail.com>
#
# === Maintainer
#
# Denver Mcanally <denver.mcanally@gmail.com>
#
# === Copyright
#
# Copyright 2014-2015 Gjermund Jensvoll
#
class colorprompt (
  Enum[present,absent] $ensure   = present,
  Stdlib::Absolutepath $path     = '/etc/profile.d/colorprompt.sh',
  String $default_usercolor      = 'cyan',
  Hash $custom_usercolors        = { 'root' => 'magenta' },
  Optional[String] $server_color = undef,
  Optional[String] $env_name     = undef,
  Optional[String] $env_color    = undef,
  String $prompt                 = $::colorprompt::params::prompt,
  Boolean $modify_skel           = false,
  Boolean $modify_root           = false,
) inherits ::colorprompt::params {

  file { $path:
    ensure  => $ensure,
    path    => $path,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('colorprompt/colorprompt.erb'),
  }

  if $modify_skel {
    exec { 'modify_skel':
      command     => 'sed -i \'/^if \[ "\$color_prompt" = yes \]; then/,/fi/s/^/#/\' /etc/skel/.bashrc',
      path        => '/bin:/usr/bin:/sbin:/usr/sbin',
      refreshonly => true,
      subscribe   => File[$path],
    }
  }

  if $modify_root {
    exec { 'modify_root':
      command     => 'sed -i \'/^if \[ "\$color_prompt" = yes \]; then/,/fi/s/^/#/\' /root/.bashrc',
      path        => '/bin:/usr/bin:/sbin:/usr/sbin',
      refreshonly => true,
      subscribe   => File[$path],
    }
  }

}
