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
elsif cnodes.length == 0 and wnodes.length == 0
	puts "OK: All #{all_nodes.length} nodes checked in #{warning} hours"
	exit(OK_STATE)
else
	puts "UNKNOWN"
	exit(UNKNOWN_STATE)
end
