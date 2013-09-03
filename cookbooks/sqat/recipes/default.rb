require 'socket'
node.default["system"]["host"]=Socket.gethostname
node.default["p4settings"]["P4CLIENT"]=Socket.gethostname+".tnt10"

directory "#{node[:home]}#{node[:programs]}" do
  owner "#{node[:system][:owner]}"
  mode "0775"
  recursive true
  action :create
end

execute "-- Installing JDK" do
  user "#{node[:system][:owner]}"  
  cwd "#{node[:home]}#{node[:programs]}"
  command "#{node[:home]}#{node[:binaries_folder]}/#{node[:binaries][:jdk1_6_0]} && date > #{node[:home]}/.jdk_installed"
  not_if { ::File.exists?("#{node[:home]}/.jdk_installed")}
end

################## Set-up Perforce  #############################
directory "#{node[:home]}#{node[:programs]}" do
  owner "#{node[:system][:owner]}"
  mode "0775"
  recursive true
  action :create
end

directory "#{node[:home]}#{node[:programs]}#{node[:perforce]}" do
  owner "#{node[:system][:owner]}"
  mode "0775"
  recursive true
  action :create
end

directory "#{node[:home]}#{node[:programs]}#{node[:perforce]}/bin" do
  owner "#{node[:system][:owner]}"
  mode "0775"
  recursive true
  action :create
end


cookbook_file "#{node[:home]}#{node[:programs]}#{node[:perforce]}/bin/p4" do
  owner "#{node[:system][:owner]}"
  user "#{node[:system][:owner]}"
  mode "0755"
  source "p4"
end

directory "#{node[:workspace]}" do
  owner "#{node[:system][:owner]}"
  mode "0775"
  recursive true
  action :create
end

template "#{node[:workspace]}/p4client.txt" do
  owner "#{node[:system][:owner]}"
  user "#{node[:system][:owner]}"
  mode "0644"
  source "p4client.erb"
  variables(
    :P4CLIENT => node[:p4settings][:P4CLIENT],
    :WORKSPACE => "#{node[:workspace]}",
    :P4USER => node[:p4settings][:P4USER],
    :HOST => "#{node[:system][:host]}"
  )
end

################## Set-up workspace  #############################
template "#{node[:home]}/.bashrc" do
  owner "#{node[:system][:owner]}"
  user "#{node[:system][:owner]}"
  mode "0644"
  source "bashrc.erb"
  variables(
    :P4CLIENT => node[:p4settings][:P4CLIENT]
  )
end

ruby_block "p4login" do
 block do
  require "P4"
  p4 = P4.new
  p4.port="#{node[:p4settings][:P4PORT]}"
  p4.user="#{node[:p4settings][:P4USER]}"
  password=''
  File.open("#{node[:home]}/.p4passwd").each{|line| password << line}
  p4.password = password
  p4.connect
  p4.run_login
  text=''
  File.open("#{node[:workspace]}/p4client.txt").each { |line| text << line }
  p4.input=text
  p4.run_client("-i")
  p4.client="#{node[:p4settings][:P4CLIENT]}"
  begin
   p4.run_sync
  rescue
   puts "Files up to date"
  end

 end
end

script "copy p4 ticket" do
interpreter "bash"
code <<-EOH
 cp /root/.p4tickets /home/tenant10/.p4tickets
EOH
end
