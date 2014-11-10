#!/usr/bin/knife exec
# vim:ft=ruby
#
# Based on: http://www.nclouds.com/alerting-for-stale-nodes-on-chef-with-nagios/
# Rewritten by Elan Ruusamäe <glen@delfi.ee> to use knife exec
# Date: 2014-11-10

# Define hours to be alerted upon and chef client.rb path so the script can execute knife status command
critical = 12
warning = 2

OK_STATE = 0
WARNING_STATE = 1
CRITICAL_STATE = 2
UNKNOWN_STATE = 3

if warning > critical || warning < 0
	puts "Warning: warning should be less than critical and bigger than zero"
	exit(WARNING_STATE)
end

all_nodes = []
cnodes = []
wnodes = []

search('node', "ohai_time:*") do |node|
	all_nodes << node
end

all_nodes.each do |node|
	hours = (Time.now.to_i - node['ohai_time'].to_i)/3600
	if hours >= critical
		cnodes << node.name
	elsif hours >= warning
		wnodes << node.name
	end
end

if cnodes.length > 0
	puts "CRITICAL: " + cnodes.length.to_s + " nodes did not check in for " + critical.to_s + " hours: " + cnodes.join(', ')
	exit(CRITICAL_STATE)
elsif wnodes.length > 0
	puts "WARNING: " + wnodes.length.to_s + " nodes did not check in for " + warning.to_s + " hours: " + wnodes.join(', ')
	exit(WARNING_STATE)
elsif cnodes.length == 0 and wnodes.join(',') == 0
	puts "OK: All nodes are ok!"
	exit(OK_STATE)
else
	puts "UNKNOWN"
	exit(UNKNOWN_STATE)
end
