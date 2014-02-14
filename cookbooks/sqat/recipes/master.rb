################## Set-up workspace #############################
puts "home---:#{node[:home]}"
template "#{node[:home]}/.bashrc" do
  owner "#{node[:system][:owner]}"
  user "#{node[:system][:owner]}"
  mode "0644"
  source "bashrc-jenkins.erb"
end

=begin
execute "-- source bashrc" do
  user "#{node[:system][:owner]}"  
  cwd "#{node[:home]}"
  command "source #{node[:home]}/.bashrc"
end
=end

bash "-- source bashrc" do
  code "source #{node[:home]}/.bashrc"
end

execute "-- Runnning jenkins war file" do
  user "#{node[:system][:owner]}"  
  cwd "#{node[:home]}"
  command "java -jar #{node[:home]}#{node[:binaries_sqat_folder]}/#{node[:binaries][:jenkins]}  &"
end
