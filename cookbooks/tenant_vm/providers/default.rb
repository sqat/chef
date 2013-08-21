def init_config new_resource
    config = Hash.new
    config[:vim]=get_vim_connection new_resource.config[:vcenter]
    config[:vm] = Hash.new
    config[:vm][:resource_pool] = new_resource.config[:vcenter][:resource_pool]
    config[:vm][:datacenter] = new_resource.config[:vcenter][:dc]
    config[:vm][:hostname]=new_resource.name
    config[:vm][:template]=new_resource.template
    config[:vm][:datastore]=new_resource.datastore
    config[:vm][:environment]=new_resource.environment
    config[:vm][:fqdn]="#{new_resource.name}.#{new_resource.config[:tenant][:domain]}"
    config[:vm][:src_folder] = "/#{new_resource.config[:tenant][:name]}"
    config[:vm][:dest_folder] = "/#{new_resource.config[:tenant][:name]}/#{new_resource.environment}"
    config[:vm][:domain] = new_resource.config[:tenant][:domain]
    config[:vm][:cspec] = new_resource.config[:tenant][:spec]
    config[:options] = new_resource.config[:options]
    return config
end
action :start do
    config = init_config new_resource	
    config[:vm][:fqdn] = new_resource.name

    start_vm config	
    if config[:options][:try_vmware_tools_configuration] == true
       puts "Wait for vmware tools to be installed. sleeping for #{new_resource.timeout} seconds before stopping VM"
       sleep new_resource.timeout
       stop_vm config
       puts "vmare tools should have been installed now. sleeping for #{new_resource.timeout} seconds before starting VM"
       puts "After restarting VM, if everything goes well VM should have been configured with network configuration with ip address"
       sleep new_resource.timeout
       start_vm config
    end
end

action :create do 
    config = init_config new_resource	
    clone_vm config
end
