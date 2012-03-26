# pingdom-ec2-security

A simple script for grabbing the most current list of Pingdom probe servers and adding them to a specified EC2 security group.

## Install

Requires the JSON and amazon-ec2 gems:

	sudo gem install json
	sudo gem install amazon-ec2
	
## Configuration

Configure the following environment variables at the top of the script:

*	PINGDOM_EMAIL (the e-mail account associated with your Pingdom account)
*	PINGDOM_PWD (the password for your Pingdom account)
*	AWS\_ACCESS\_KEY\_ID (your Amazon Web Services Access Key)
*	AWS\_SECRET\_ACCESS\_KEY (your Amazon Web Services Secret Key)
*	SECURITY\_GROUP\_NAME (the AWS security group you wish to add the pingdom servers to)
*	PORT\_NUMBERS (an array of ports that you wish to give Pingdom probes access to. eg [80,443,8080])
*	PROTOCOL (can be one of "tcp", "icmp", or "udp")
*	SERVER (the Amazon EC2 endpoint for the region you wish to target)

To enable just ping monitoring, set PORT\_NUMBERS to [-1] and PROTOCOL to "icmp"

## Usage

Just run it.

	./add-pingdom.rb
	
## Copyright

Copyright (c) 2011 Alex Kremer. See LICENSE.txt for further details.
