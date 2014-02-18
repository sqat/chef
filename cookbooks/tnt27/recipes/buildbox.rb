
execute "-- creating .chef folder " do
  user "#{node[:system][:owner]}"
  cwd "#{node[:home]}"
  command "mkdir #{node[:home]}/#{node[:build_chef]}"
end

execute "-- copying files " do
  user "#{node[:system][:owner]}"
  cwd "#{node[:home]}/#{node[:build_chef]}"
  command "cp -a #{node[:home]}#{node[:build_bin]}/knife.rb #{node[:home]}#{node[:build_bin]}/vmware.sh #{node[:home]}#{node[:build_bin]}/vmware.rb #{node[:home]}/#{node[:build_chef]}/"
end
