#new reciepe
require 'socket'
host=Socket.gethostname
node.default["system"]["host"]=host
node.default["p4settings"]["P4CLIENT"]=host+".tnt26"
elements=host.split(/\-/)
workarea=elements[1]
puts "host: #{host},workarea: #{workarea}"

directory "#{node[:home]}#{node[:programs]}" do
  owner "#{node[:system][:owner]}"
  mode "0775"
  recursive true
  action :create
end

execute "-- Installing JDK" do
  user "#{node[:system][:owner]}"  
  cwd "#{node[:home]}#{node[:programs]}"
  command "#{node[:home]}#{node[:binaries_sqat_folder]}/#{node[:binaries][:jdk1_7_0]} && date > #{node[:home]}/.jdk_installed"
  not_if { ::File.exists?("#{node[:home]}/.jdk_installed")}
end

################## Set-up workspace #############################
puts "home---:#{node[:home]}"
template "#{node[:home]}/.bashrc" do
  owner "#{node[:system][:owner]}"
  user "#{node[:system][:owner]}"
  mode "0644"
  source "bashrc.erb"
  variables(
    :P4CLIENT => node[:p4settings][:P4CLIENT]
  )
end

execute "-- Runnning jenkins war file" do
  user "#{node[:system][:owner]}"  
  cwd "#{node[:home]}"
  command "java -jar #{node[:home]}#{node[:binaries_sqat_folder]}/#{node[:binaries][:jenkins]}"
end
