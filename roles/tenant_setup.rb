name  "tenant_setup"
description  "automate vm creation using tenant vm cookbook"
run_list "recipe[tenant_vm::default]","recipe[tenant_vm::start]","recipe[tenant_vm::configure]"

