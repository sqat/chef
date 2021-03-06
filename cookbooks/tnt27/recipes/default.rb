#new reciepe
require 'socket'
host=Socket.gethostname
node.default["system"]["host"]=host
node.default["p4settings"]["P4CLIENT"]=host+".tnt27"
elements=host.split(/\-/)
workarea=elements[1]
puts "host: #{host},workarea: #{workarea}"

directory "#{node[:home]}#{node[:programs]}" do
  owner "#{node[:system][:owner]}"
  mode "0775"
  recursive true
  action :create
end

=begin
execute "-- Installing JDK" do
  user "#{node[:system][:owner]}"  
  cwd "#{node[:home]}#{node[:programs]}"
  command "#{node[:home]}#{node[:binaries_sqat_folder]}/#{node[:binaries][:jdk1_7_0]} && date > #{node[:home]}/.jdk_installed"
  not_if { ::File.exists?("#{node[:home]}/.jdk_installed")}
end
=end

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

################## Set-up workspace  #############################
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

=begin
bash "-- source bashrc" do
  user "#{node[:system][:owner]}"
  cwd "#{node[:home]}"
  code "source #{node[:home]}/.bashrc"
end
=end

############## set up p4client ###################################

if workarea.eql?("snapfish")
  puts "picking snapfish_p4client"

  template "#{node[:workspace]}/p4client.txt" do
  owner "#{node[:system][:owner]}"
  user "#{node[:system][:owner]}"
  mode "0644"
  source "snapfish_p4client.erb"
  variables(
    :P4CLIENT => node[:p4settings][:P4CLIENT],
    :WORKSPACE => "#{node[:workspace]}",
    :P4USER => node[:p4settings][:P4USER],
    :HOST => "#{node[:system][:host]}",
  )
end
elsif workarea.eql?("walmart") 
  puts "picking walmart_p4client"

  template "#{node[:workspace]}/p4client.txt" do
  owner "#{node[:system][:owner]}"
  user "#{node[:system][:owner]}"
  mode "0644"
  source "walmart_p4client.erb"
  variables(
    :P4CLIENT => node[:p4settings][:P4CLIENT],
    :WORKSPACE => "#{node[:workspace]}",
    :P4USER => node[:p4settings][:P4USER],
    :HOST => "#{node[:system][:host]}",
  )
end  
elsif workarea.eql?("walgreens") 
  puts "picking walgreens_p4client"

  template "#{node[:workspace]}/p4client.txt" do
  owner "#{node[:system][:owner]}"
  user "#{node[:system][:owner]}"
  mode "0644"
  source "walgreens_p4client.erb"
  variables(
    :P4CLIENT => node[:p4settings][:P4CLIENT],
    :WORKSPACE => "#{node[:workspace]}",
    :P4USER => node[:p4settings][:P4USER],
    :HOST => "#{node[:system][:host]}",
  )
end 
elsif workarea.eql?("grid")
  puts "picking grid_p4client"

  template "#{node[:workspace]}/p4client.txt" do
  owner "#{node[:system][:owner]}"
  user "#{node[:system][:owner]}"
  mode "0644"
  source "grid_p4client.erb"
  variables(
    :P4CLIENT => node[:p4settings][:P4CLIENT],
    :WORKSPACE => "#{node[:workspace]}",
    :P4USER => node[:p4settings][:P4USER],
    :HOST => "#{node[:system][:host]}",
  )
end

else
  puts "No p4client template taken" 
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
  rescue => e
   puts e
  end

 end
end

script "copy p4 ticket" do
interpreter "bash"
code <<-EOH
 cp /root/.p4tickets /home/sqat/.p4tickets
EOH
end

if workarea.eql?("grid")
execute "-- Runnning server" do
  user "#{node[:system][:owner]}"
  cwd "#{node[:workspace]}#{node[:seleniumserver]}"
  command "nohup #{node[:home]}#{node[:binaries_sqat_folder]}#{node[:binaries_java]}/java -jar #{node[:workspace]}#{node[:seleniumserver]}/selenium-server-standalone-2.x.jar -role hub  -timeout 7200 -browserTimeout 7200 -WARN -ERROR 2>&1 &"
end
end
