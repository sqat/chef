default[:home] = "/root"

default[:system][:user] = "sqat"
default[:system][:owner] = "sqat"
default[:system][:host] = "sqat-buildbox2"
default[:system][:email] = "your-email@domain.com"

default[:p4settings][:P4USER] = "sqat"
default[:p4settings][:P4PORT] = "op1-sfdeploy2.mah3.sfo2.snapfish.com:1666"
default[:p4settings][:P4CLIENT] = "sqat-buildbox2.tnt10-zone1.aus1"
default[:p4settings][:P4MERGE] = "/usr/bin/p4merge"


default[:ldap][:LDAP_USER] = "sqat"
default[:ldap][:LDAP_PASSWD] = "your-ldap-password"

default[:temp] = "/Temp"
default[:binaries_folder] = "/workarea/softwares"
default[:workspace] = "/snapfish"
default[:programs] = "/programs"
default[:ant_lib] = "/.ant/lib"
default[:branch] = "/integration"
default[:apps] = "/apps"
default[:apache_conf] = "/etc/apache2/apache2.conf"
default[:apache_ant] = "/apache-ant-1.9.0"
default[:apache_ivy] = "/apache-ivy-2.3.0"
default[:perforce] = "/perforce"

default[:binaries][:jdk1_6_0] = "jdk-6u43-linux-x64.bin"
default[:binaries][:apache_ant] = "apache-ant-1.9.0-bin.tar.gz"
default[:binaries][:apache_ivy] = "apache-ivy-2.3.0-bin.zip"
default[:binaries][:instantclient_basic] = "instantclient-basic-linux.x64-11.2.0.3.0.zip"
default[:binaries][:instantclient_sqlplus] = "instantclient-sqlplus-linux.x64-11.2.0.3.0.zip"
default[:binaries][:sfservice] = "sfservice_2.1.0-3_all.deb"
default[:binaries][:perforce] = "p4v.tgz"
