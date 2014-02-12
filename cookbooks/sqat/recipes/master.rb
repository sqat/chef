#new reciepe
require 'socket'
host=Socket.gethostname
node.default["system"]["host"]=host
node.default["p4settings"]["P4CLIENT"]=host+".tnt26"
elements=host.split(/\-/)
workarea=elements[1]
puts "host: #{host},workarea: #{workarea}"


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
  command "nohup java -jar #{node[:home]}#{node[:binaries_sqat_folder]}/#{node[:binaries][:jenkins]}  > #{node[:binaries_root_folder]}/#{node[:binaries][:jenkinslog]}  2>&1 &"
end
