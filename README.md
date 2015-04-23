check_chef_stale
================

Alerting for stale nodes on Chef with Nagios/Icinga

## installation ##

1. copy plugin `check_chef_stale.rb` to `/usr/lib/nagios/plugins`
2. copy command definition and service template definition `check_chef_stale.cfg`  to `/etc/nagios/plugins`.
3. create check definition like this:
```
define service {
    use                     chef_stale
    host_name               localhost
}       
```

**NOTE**: the paths may vary, depending on your Nagios/Icinga installation.
