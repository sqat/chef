#
# Cookbook Name:: vmware
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

require 'socket'
require 'timeout'

def port_open?(host, port)
  begin
    Timeout::timeout(1) do
      begin
        s = TCPSocket.new(host, port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Exception
        return false
      end
    end
  rescue Timeout::Error
  end
  return false
end


def symbolize_keys(hash)
  hash.inject({}){|result, (key, value)|
    new_key = case key
              when String then key.to_sym
              else key
              end
    new_value = case value
                when Hash then symbolize_keys(value)
                else value
                end
    result[new_key] = new_value
    result
  }
end


config = symbolize_keys data_bag_item "tenant","config"
vms = data_bag_item "tenant", "vms"

if config[:options][:configure_vms_in_chef] == true

 config[:environments].each { |env|
   cenv = search(:environment, "name:#{env}")[0]
   if cenv.nil?   
      puts "Registering environment #{cenv} in chef"   	   
      c=Chef::Environment.new
      c.name env
      c.save
   end
   roles = vms[env].keys
   roles.each { |role|
     vm_list= vms[env][role]
     crole = search(:role,"name:#{role}")[0]
     if crole.nil?
	puts "Registering role #{crole} in chef"	     
	r = Chef::Role.new
        r.name role
        r.save	
     end
     vm_list.each { |vm|
	cnode = search(:node,"name:#{vm}")[0]     
	if cnode.nil?
	   puts "Registering  #{vm} in chef"		
	   n = Chef::Node.find_or_create vm
           run_list = Chef::RunList.new
           run_list << "role[#{role}]"
           n.run_list run_list
	   n.chef_environment env
           n.save	
	end
 	if config[:options][:register_vms_as_clients] == true
  	  cclient = search(:client, "name:#{vm}")[0]
	  if cclient.nil?
	   if port_open? vm, 22 
            message= "\e[32m Creating ssh connection to #{vm}.... to run chef-client \e[0m"		   
           else
            message= " \e[31m It seems #{vm} is throwing host not reachable or service. \e[0m"
	   end

	    bash "run-chef-client-#{vm}" do
             code <<-EOH
		echo "\n"	     
	        echo #{message}
	    	ssh -i #{config[:chef_ssh_credentials][:identity_key]} -o 'StrictHostKeyChecking no' #{config[:chef_ssh_credentials][:username]}@#{vm} sudo -i chef-client
	     EOH
#	     action :nothing
	    end
	 end
	end
     }
   }   
 }
end
