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
vms = data_bag_item "tenant", "vms"
config[:environments].each { |env|
 if vms[env].nil?
    vms[env] = Hash.new
 end    
 config[:volumes].each { |volume|
    vm_list=data_bag_item "tenant",env
    unless vm_list["nodes"][volume].nil? 
      vm_list["nodes"][volume].each { |host| 
         template = config[:tenant][:template]
         name = host
	  
	 if defined? host.template 
	   template = host.template
	 end
	 	 
	 if host.is_a? Hash 
   	   name = host["name"]
	 end
	 role = name

	 unless vm_list["prefix"].nil?
	    name = "#{vm_list["prefix"]}-#{name}"
	 end

	 if vms[role].nil?
	    vms[env][role]=[]
	 end

	 if volume == "rotate"
	    capacity=host["capacity"]
	    capacity.times do |i|
	      vol = config[:volumes][i%2]
	      cclient = search(:client,"name:#{name}-#{i+1}.#{config[:tenant][:domain]}")[0]
	      if cclient.nil?
	         vms[env][role] << "#{name}-#{i+1}.#{config[:tenant][:domain]}"
      	         tenant_vm "#{name}-#{i+1}" do
                  config config
                  environment env
                  template template
                  datastore config[:tenant][:datastores][vol.to_sym]
                  action :create
#		  notifies :start, "tenant_vm[start-#{name}-#{i+1}.#{config[:tenant][:domain]}]"
                 end
	      else
#		 puts "Skipping this VM creation, as client already exists in chef: #{name}-#{i+1}.#{config[:tenant][:domain]}"
	      end
	    end    
	 else

	    cclient = search(:client,"name:#{name}.#{config[:tenant][:domain]}")[0]
	     if cclient.nil?
	        vms[env][role] << "#{name}.#{config[:tenant][:domain]}"
     	        tenant_vm name do
                 config config
                 environment env
                 template template
                 datastore config[:tenant][:datastores][volume.to_sym]
                 action :create
#		 notifies :start, "tenant_vm[start-#{name}.#{config[:tenant][:domain]}]"
                end
	    else
#		 puts "Skipping this VM creation, as client already exists in chef: #{name}.#{config[:tenant][:domain]}"
	    end
	 end 
	vms[env][role].uniq!
      }
    end
  }
}
vms.save
