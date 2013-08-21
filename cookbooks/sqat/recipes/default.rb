
directory "#{node[:home]}#{node[:programs]}" do
  owner "#{node[:system][:owner]}"
  mode "0775"
  recursive true
  action :create
end

execute "-- Installing JDK" do
  user "tenant10"
  cwd "#{node[:home]}#{node[:programs]}"
  command "#{node[:home]}#{node[:binaries_folder]}/#{node[:binaries][:jdk1_6_0]} && date > #{node[:home]}/.jdk_installed"
  not_if { ::File.exists?("#{node[:home]}/.jdk_installed")}
end
