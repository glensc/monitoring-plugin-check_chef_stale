#!/usr/bin/ruby
# Based on: http://www.nclouds.com/alerting-for-stale-nodes-on-chef-with-nagios/
#
# Rewritten by Elan Ruusamäe <glen@pld-linux.org>
# https://github.com/glensc/nagios-plugin-check_chef_stale

require 'optparse'
require 'chef/client'

# Setup some defaults
# Hours to be alerted upon
critical = 12
warning = 2
# Solr search query to make
query = "ohai_time:*"

OptionParser.new do |opts|
	opts.banner = "Usage: check_chef_stale.rb [options]"

	opts.on("-w", "--warning N", "Set warning treshold in hours. Default: #{warning}h") do |v|
		warning = v.to_i
	end
	opts.on("-c", "--critical N", "Set critical treshold in hours. Default: #{critical}h") do |v|
		critical = v.to_i
	end
	opts.on("-q", "--query QUERY", "Append query to Chef-SOLR search") do |v|
		query = "#{query} #{v}"
	end
end.parse!

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

Chef::Config.from_file(File.expand_path("/etc/chef/client.rb"))

Chef::Search::Query.new.search('node', query) do |node|
	all_nodes << node
end

now = Time.now.to_i
all_nodes.each do |node|
	hours = (now - node['ohai_time'].to_i)/3600
	if hours >= critical
		cnodes << node
	elsif hours >= warning
		wnodes << node
	end
end

def report_fail_nodes(nodes, hours)
	if nodes.length == 1
		node = nodes[0]
		time = Time.at(node['ohai_time']).strftime('%Y-%m-%d %H:%M:%S %z')
		res = "#{node} did not check in for #{hours.to_s} hours (#{time})"
	else
		res = "#{nodes.length.to_s} nodes did not check in for #{hours.to_s} hours: "
		res += nodes.map { |n| n.name }.sort.join(', ')
	end
	res
end

def report_ok_nodes(nodes, hours)
	if nodes.length == 1
		node = nodes[0]
		time = Time.at(node['ohai_time']).strftime('%Y-%m-%d %H:%M:%S %z')
		"#{node} checked in #{hours} hours (#{time})"
	else
		"All #{nodes.length} nodes checked in #{hours} hours"
	end
end

if all_nodes.length == 0
	puts "CRITICAL: No nodes match criteria"
	exit(CRITICAL_STATE)
elsif cnodes.length > 0
	puts "CRITICAL: " + report_fail_nodes(cnodes, critical)
	exit(CRITICAL_STATE)
elsif wnodes.length > 0
	puts "WARNING: " + report_fail_nodes(wnodes, warning)
	exit(WARNING_STATE)
elsif cnodes.length == 0 and wnodes.length == 0
	puts "OK: "+ report_ok_nodes(all_nodes, warning)
	exit(OK_STATE)
else
	puts "UNKNOWN"
	exit(UNKNOWN_STATE)
end
