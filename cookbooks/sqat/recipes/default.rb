
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

################## Set-up Perforce  #############################
cookbook_file "#{node[:home]}#{node[:programs]}#{node[:perforce]}/bin/p4" do
  owner "#{node[:system][:owner]}"
  mode "0755"
  source "p4"
end

template "#{node[:home]}#{node[:workspace]}/p4client" do
  owner "#{node[:system][:owner]}"
  mode "0644"
  source "p4client.erb"
  variables(
    :P4CLIENT => node[:p4settings][:P4CLIENT],
    :WORKSPACE => "#{node[:home]}#{node[:workspace]}",
    :P4USER => node[:p4settings][:P4USER],
    :HOST => "#{node[:system][:host]}"
  )
end

################## Set-up workspace  #############################
directory "#{node[:home]}#{node[:workspace]}" do
  owner "#{node[:system][:owner]}"
  mode "0775"
  recursive true
  action :create
end

template "#{node[:home]}/.bashrc" do
  owner "#{node[:system][:owner]}"
  mode "0644"
  source "bashrc.erb"
  variables(
    :P4CLIENT => node[:p4settings][:P4CLIENT]
  )
end



