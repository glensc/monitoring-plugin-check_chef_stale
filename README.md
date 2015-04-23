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

## setting up chef ##

You need additionally to configure `~/.chef/knife.rb` for user that runs the plugin (usually `nagios`):

```ruby
log_level                :debug
log_location             STDOUT
node_name                'glen'
client_key               'glen.pem'
validation_client_name   'glen'
validation_key           '~/.chef/glen.pem'
chef_server_url          'https://chef-server'
```

Consult [knife configure](https://docs.chef.io/knife_configure.html) manual for details.
