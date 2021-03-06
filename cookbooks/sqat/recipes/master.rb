################## Set-up workspace #############################
puts "home---:#{node[:home]}"
template "#{node[:home]}/.bashrc" do
  owner "#{node[:system][:owner]}"
  user "#{node[:system][:owner]}"
  mode "0644"
  source "bashrc-jenkins.erb"
end

=begin
bash "-- source bashrc" do
  user "#{node[:system][:owner]}"  
  cwd "#{node[:home]}"
  code "source #{node[:home]}/.bashrc"
end
=end

execute "-- Runnning jenkins war file" do
  user "#{node[:system][:owner]}"  
  cwd "#{node[:home]}"
  command "nohup #{node[:home]}#{node[:binaries_sqat_folder]}#{node[:binaries_java]}/java -jar #{node[:home]}#{node[:binaries_sqat_folder]}/#{node[:binaries][:jenkins]}  &"
end

execute "-- copying wg jobs " do
  user "#{node[:system][:owner]}"  
  cwd "#{node[:home]}"
  command "cp -r #{node[:home]}#{node[:binaries_wg_jobs]}/* #{node[:home]}#{node[:binaries_jenkins_jobs]}/"
end
