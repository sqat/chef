require 'rbvmomi.rb'
def get_vim_connection config
    conn_opts = {
     :host => config[:host],
     :path => config[:path],
     :port => config[:port],
     :user => config[:user],
     :password => config[:password],
     :insecure => config[:insecure]
   }
   vim = RbVmomi::VIM.connect conn_opts
   config[:vim] = vim
   return vim
end

def find_folder config,folderName
    dcname = config[:vm][:datacenter]
    dc = config[:vim].serviceInstance.find_datacenter(dcname) or abort "datacenter not found"
    baseEntity = dc.vmFolder
    entityArray = folderName.split('/')
    entityArray.each do |entityArrItem|
     if entityArrItem != ''
       baseEntity = baseEntity.childEntity.grep(RbVmomi::VIM::Folder).find { |f| f.name == entityArrItem } or
       abort "no such folder #{folderName} while looking for #{entityArrItem}"
     end
    end
    baseEntity
end

def find_all_in_folder folder, type
    if folder.instance_of?(RbVmomi::VIM::ClusterComputeResource)
       folder = folder.resourcePool
    end
    if folder.instance_of?(RbVmomi::VIM::ResourcePool)
       folder.resourcePool.grep(type)
    elsif folder.instance_of?(RbVmomi::VIM::Folder)
       folder.childEntity.grep(type)
    else
       puts "Unknown type #{folder.class}, not enumerating"
       nil
    end
end

def find_in_folder folder, type, name
    folder.childEntity.grep(type).find { |o| o.name == name }
end

def find_pool poolName,config
    dcname = config[:vm][:datacenter]
    dc = config[:vim].serviceInstance.find_datacenter(dcname) or abort "datacenter not found"
    baseEntity = dc.hostFolder
    entityArray = poolName.split('/')
    entityArray.each do |entityArrItem|
    if entityArrItem != ''
       if baseEntity.is_a? RbVmomi::VIM::Folder
   	 baseEntity = baseEntity.childEntity.find { |f| f.name == entityArrItem } or  abort "no such pool #{poolName} while looking for #{entityArrItem}"
       elsif baseEntity.is_a? RbVmomi::VIM::ClusterComputeResource
 	 baseEntity = baseEntity.resourcePool.resourcePool.find { |f| f.name == entityArrItem } or abort "no such pool #{poolName} while looking for #{entityArrItem}"
       elsif baseEntity.is_a? RbVmomi::VIM::ResourcePool
     	 baseEntity = baseEntity.resourcePool.find { |f| f.name == entityArrItem } or abort "no such pool #{poolName} while looking for #{entityArrItem}"
       else
	 abort "Unexpected Object type encountered #{baseEntity.type} while finding resourcePool"
       end
      end
    end
    baseEntity = baseEntity.resourcePool if not baseEntity.is_a?(RbVmomi::VIM::ResourcePool) and baseEntity.respond_to?(:resourcePool)
    baseEntity
end

def find_customization name, config
    csm = config[:vim].serviceContent.customizationSpecManager
    csm.GetCustomizationSpec(:name => name)
end
def find_datastore dsName,config
    dcname = config[:vm][:datacenter]
    dc = config[:vim].serviceInstance.find_datacenter(dcname) or abort "datacenter not found"
    baseEntity = dc.datastore
    baseEntity.find { |f| f.info.name == dsName } or abort "no such datastore #{dsName}"
end
def start_vm(config)
 vim = config[:vim]
 folder=find_folder(config, config[:vm][:dest_folder]);
 vm = find_in_folder(folder, RbVmomi::VIM::VirtualMachine, config[:vm][:fqdn]) or abort " #{config[:vm][:fqdn]} vm not found "
 if vm.runtime.powerState == 'poweredOn' 
    puts "#{config[:vm][:fqdn]} already powered on"
    return
 end
 puts "Powering on #{config[:vm][:fqdn]}..."
 begin 
    vm.PowerOnVM_Task.wait_for_completion
 rescue Exception => e
      puts "Unable to power on vm: #{config[:vm][:fqdn]}"	    
      puts "Got Exception message\n #{e.message}"
      puts "This exception may / may not be a critical error. Check error events in vcenter console to resolve your errors manually if required"
      puts "Do you want to continue powering on other virtual machines... y(yes)/n(no)?"
      yn = gets.chomp
      if yn == "y" || yn == "yes"
        puts e.message 
      else
	raise e
      end
  end
end

def stop_vm(config)
 vim = config[:vim]
 folder=find_folder(config,config[:vm][:dest_folder]);
 vm = find_in_folder(folder, RbVmomi::VIM::VirtualMachine, config[:vm][:fqdn])
 if vm.runtime.powerState == 'poweredOff' 
    puts "#{config[:vm][:fqdn]} already powered off"
    return
 end
 puts "Powering off #{config[:vm][:fqdn]}..."
 begin 
    vm.PowerOffVM_Task.wait_for_completion
 rescue Exception => e
      puts "Unable to power off vm: #{config[:vm][:fqdn]}" 	    
      puts "Got Exception message\n #{e.message}"
      puts "This exception may / may not be a critical error. Check error events in vcenter console to resolve your errors manually if required"
      puts "Do you want to continue powering on other virtual machines... y(yes)/n(no)?"
      yn = gets.chomp
      if yn == "y" || yn == "yes"
        puts e.message 
      else
	raise e
      end
  end
end

def reboot_vm(config)
 vim = config[:vim]
 folder=find_folder(config,config[:vm][:dest_folder]);
 vm = find_in_folder(folder, RbVmomi::VIM::VirtualMachine, config[:vm][:fqdn])
 puts "Rebooting request #{config[:vm][:fqdn]}..."
 vm.RebootGuest
end

def build_clone_spec(config)
    rspec = RbVmomi::VIM.VirtualMachineRelocateSpec(:pool => find_pool(config[:vm][:resource_pool],config))
    rspec.datastore = find_datastore config[:vm][:datastore],config
    clone_spec = RbVmomi::VIM.VirtualMachineCloneSpec(:location => rspec,:powerOn => false,:template => false)
    csi = find_customization(config[:vm][:cspec], config)
    cust_spec = csi.spec
    ident = RbVmomi::VIM.CustomizationLinuxPrep
    ident.hostName = RbVmomi::VIM.CustomizationFixedName
    ident.hostName.name = config[:vm][:hostname]
    ident.domain= config[:vm][:domain]
    cust_spec.identity = ident
    clone_spec.customization = cust_spec
    clone_spec
end

def clone_vm(config)
    $stdout.sync = true
    
    vim = config[:vim]  
    folder=find_folder(config,config[:vm][:dest_folder]);
    vm = find_in_folder(folder, RbVmomi::VIM::VirtualMachine, config[:vm][:fqdn])
    unless vm.nil?  
       puts "#{config[:vm][:fqdn]} already exists in #{config[:vm][:dest_folder]}"
       return
    end

    dcname = config[:vm][:datacenter]
    dc = vim.serviceInstance.find_datacenter(dcname) or abort "datacenter not found"
    src_folder = find_folder(config,config[:vm][:src_folder]) || dc.vmFolder
    src_vm = find_in_folder(src_folder, RbVmomi::VIM::VirtualMachine, config[:vm][:template]) or abort "VM/Template not found"
    clone_spec = build_clone_spec(config)

    cust_folder = config[:vm][:dest_folder] || config[:vm][:src_folder]
    dest_folder = cust_folder.nil? ? src_vm.vmFolder : find_folder(config,cust_folder)
    begin
    task = src_vm.CloneVM_Task(:folder => dest_folder, :name => config[:vm][:fqdn], :spec => clone_spec)
    puts "Cloning template #{config[:vm][:template]} to new VM #{config[:vm][:fqdn]} in #{config[:vm][:dest_folder]}"
    if config[:options][:clone_in_background] != true
       task.wait_for_completion
    end
    puts "Finished creating virtual machine #{config[:vm][:fqdn]}"
    rescue Exception => e
      puts "Unable to clone vm: #{config[:vm][:fqdn]}" 	    
      puts "Got Exception message:\n #{e.message}"
      puts "This exception may / may not be a critical error. Check error events in vcenter console to resolve your errors manually if required"
      puts "Do you want to continue cloning other virtual machines ... y(yes)/n(no)?"
      yn = gets.chomp
      if yn == "y" || yn == "yes"
        puts e.message 
      else
	raise e
      end
    end
end

