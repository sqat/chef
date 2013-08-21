file "/cygdrive/c/Temp/helloworld.txt" do
  owner "gatadi"  
  action :create
  content "Hello, Implementor!"
end

script "install_dropbox" do
  not_if {File.exists?('/cygdrive/c/Temp/helloworld.txt')}
  interpreter "bash"
  user "gatadi"
  code <<-EOH
     cat "vijay gatadi" > /cygdrive/c/Temp/helloworld.txt
  EOH
end


