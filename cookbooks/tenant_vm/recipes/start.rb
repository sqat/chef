#
# Cookbook Name:: vmware
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

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
if config[:options][:power_on_vms] == true 
vms = data_bag_item "tenant", "vms"
config[:environments].each { |env|
   roles = vms[env].keys
   roles.each { |role|
     vm_list= vms[env][role]
     vm_list.each { |vm|
	cnode = search(:client,"name:#{vm}")[0]
        if cnode.nil?        
      	  tenant_vm vm do
                 config config
		 environment env
		 timeout 30
                 action :start
#		 notifies :run,"bash[run-chef-client-#{vm}]"
	  end
	end
     }
   }   
}

end
