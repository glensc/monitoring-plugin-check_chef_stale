check_chef_stale
================

Alerting for stale nodes on Chef with Nagios/Icinga

## Installation ##

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

## Known Issues ##

```
chef/http/auth_credentials.rb:40:in `signature_headers': Cannot sign the request without a client name, check that :node_name is assigned (ArgumentError)
```

ensure `node_name` is defined in chef config. If you use [chef-client](https://github.com/chef-cookbooks/chef-client) cookbook, then it omits writing `node_name` to config if it's the default (`# Using default node name (fqdn)`). you can workaround this by creating `/etc/chef/client.d/nodename.rb`:

```ruby
# needed for check_chef_stale.rb
Chef::Config[:node_name] = 'nagios.fqdn.example.org'
```

----

```
[2016-02-03T13:49:00+02:00] WARN: Failed to read the private key /etc/chef/client.pem: #<Errno::EACCES: Permission denied - /etc/chef/client.pem>
```

ensure the files are accessible by user running the checks:
```sh
chmod a+r /etc/chef/client.d/nodename.rb
chown nagios /etc/chef/client.pem
```
