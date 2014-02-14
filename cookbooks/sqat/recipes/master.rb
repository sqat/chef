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

execute "-- source bashrc" do
  user "#{node[:system][:owner]}"  
  cwd "#{node[:home]}"
  command "source .bashrc"
end

execute "-- Runnning jenkins war file" do
  user "#{node[:system][:owner]}"  
  cwd "#{node[:home]}"
  command "java -jar #{node[:home]}#{node[:binaries_sqat_folder]}/#{node[:binaries][:jenkins]}  &"
end
