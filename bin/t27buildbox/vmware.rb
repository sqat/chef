require 'trollop'
require 'rbvmomi'
require 'rbvmomi/trollop'

VIM = RbVmomi::VIM
CMDS = %w(on off reset suspend destroy)

class VmWare
  @opts
	@cmd
	@vm_name
	@vm_folder
	@vm
	
	def initialize
		
	end
		
	def usage
		@opts = Trollop.options do
		  banner <<-EOS
Perform VM power operations.

Usage:
	power.rb [options] cmd VM FOLDER

Commands: #{CMDS * ' '}

VIM connection options:
	EOS

	rbvmomi_connection_opts

	text <<-EOS

VM location options:
	EOS

	rbvmomi_datacenter_opt

	text <<-EOS

Other options:
  EOS

		  stop_on CMDS
		end	
	end
	
	def readArguments
		usage
		
		@cmd = ARGV[0] or Trollop.die("no command given")
		@vm_name = ARGV[1] or Trollop.die("no VM name given")
		@vm_folder = ARGV[2] or Trollop.die("no folder name given")
		Trollop.die("must specify vcenter host") unless @opts[:host]
		{:cmd => @cmd, :vm_name => @vm_name, :vm_folder => @vm_folder}
	end
	
	def findVm
		readArguments
		
		puts "\n\nConnecting to vcenter : #{@opts[:host]} ...\n"
		vim = VIM.connect @opts

		dc = vim.serviceInstance.find_datacenter(@opts[:datacenter]) or abort "datacenter #{@opts[:datacenter]} not found"
		puts "#{@opts[:datacenter]}->#{dc}"

		folders = @vm_folder.split("/")

		parentFolder = dc.vmFolder 
		for f in folders
		parentFolder = parentFolder.childEntity.grep(RbVmomi::VIM::Folder).find { |x| x.name == f } or fail "Folder #{f} not found"
		puts "#{f}->#{parentFolder}"
		end
   
		@vm = parentFolder.childEntity.grep(RbVmomi::VIM::VirtualMachine).find { |x| x.name == @vm_name} or fail "vm #{@vm_name} not found"
		puts "#{@vm_name}->#{@vm}"
		
	end
	
	def runCommand
		findVm
		
		cmd = @cmd
		vm = @vm
		
		case cmd
		when 'on'
		  puts "\nTurning vm on ...\n"
		  vm.PowerOnVM_Task.wait_for_completion
		when 'off'
		  puts "\nTurning vm off ...\n"
		  vm.PowerOffVM_Task.wait_for_completion
		when 'reset'
		  puts "\nResetting vm  ...\n"
		  vm.ResetVM_Task.wait_for_completion
		when 'suspend'
		  puts "\nSuspending vm ...\n"
		  vm.SuspendVM_Task.wait_for_completion
		when 'destroy'
		  puts "\nDeleting vm ...\n"
		  vm.Destroy_Task.wait_for_completion
		else
		  abort "\ninvalid command\n"
		end
	end
	
end



VmWare.new.runCommand





#example : ruby vmware.rb --host vcenter1.op-zone1.aus1 --user gatadi --password passord --insecure --datacenter MP1 off devbox1.tnt13-zone1.aus1 tenant13/test
 
