#!/usr/bin/env ruby
require 'openssl'
require 'base64'
require 'cgi'
require 'open-uri'
require 'rubygems'
require 'json'
require 'AWS'

# Set up your variables
PINGDOM_EMAIL = "your@email.com"
PINGDOM_PWD = "secret"
AWS_ACCESS_KEY_ID = "ABCDEFGHIJK"
AWS_SECRET_ACCESS_KEY = "lotsarandomchars"
SECURITY_GROUP_NAME = "mygroup"
PORT_NUMBERS = [-1]
PROTOCOL = "icmp"
# ec2.us-east-1.amazonaws.com for us-east-1
# ec2.us-west-2.amazonaws.com for us-west-2
# ec2.us-west-1.amazonaws.com for us-west-1
# ec2.eu-west-1.amazonaws.com for eu-west-1
# ec2.ap-southeast-1.amazonaws.com for ap-southeast-1
# ec2.ap-northeast-1.amazonaws.com for ap-northeast-1
# ec2.sa-east-1.amazonaws.com for sa-east-1
SERVER = "us-east-1.ec2.amazonaws.com"
# End variables

# The following can be changed, but it's just generic info
# for the Pingdom API, so you should probably leave it as-is.
PINGDOM_API_KEY = "oibyjy1yu9qn4pdkdql9h5abuuwi96i2"
PINGDOM_SERVER = "https://api.pingdom.com"
PINGDOM_API_VERSION = "2.0"

url = "#{PINGDOM_SERVER}/api/#{PINGDOM_API_VERSION}/probes"

auth_hdr = Base64.encode64("#{PINGDOM_EMAIL}:#{PINGDOM_PWD}") 

headers = {"Authorization" => "Basic #{auth_hdr}", "App-Key" => PINGDOM_API_KEY}

begin
  response = open(url, headers).read
rescue Exception => e
  puts "Caught exception opening #{url}"
  puts e.message
  puts e.backtrace.inspect
  Process.exit
rescue OpenURI::HTTPError => http_e
  puts "Received HTTP Error opening #{url}"
  puts http_e.io.status[0].to_s
  Process.exit
end

resp_hash = JSON.parse(response)

ec2 = AWS::EC2::Base.new(:access_key_id => AWS_ACCESS_KEY_ID, :secret_access_key => AWS_SECRET_ACCESS_KEY, :server => SERVER)

resp_hash["probes"].each do |probe|
  PORT_NUMBERS.each do |port|
    begin
      puts "Adding #{probe["ip"]}:#{port}"
      ec2.authorize_security_group_ingress({
        :group_name => SECURITY_GROUP_NAME,
        :ip_protocol => PROTOCOL,
        :from_port => port,
        :to_port => port,
        :cidr_ip => "#{probe["ip"]}/32"
      })
    rescue AWS::InvalidPermissionDuplicate
      puts "Skipping #{probe["ip"]} since already present."
      next
    rescue Exception => e
      puts "Caught exception adding #{probe["ip"]}"
      puts "#{e.type}: #{e.message}"
      Process.exit
    end
  end
end

puts "Security groups added successfully."
