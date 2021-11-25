
function vbox
  set -l options (fish_opt -s h -l help)
  argparse -i -n vbox $options -- $argv

  set -l cmd $argv[1]

  if set -q _flag_help
    __help $cmd
    return 0
  end

  switch $cmd
    case "import"
      __import_vm_exec $argv[2..] #$vmname $ovafile
    case "docker"
      __docker_vm_exec $argv[2..]
    case "start"
      __start_vm_exec $argv[2..]
    case "*"
      __invalid_command
  end
  return $status
end

function __help -a cmd
  if test -z "$cmd"
    __general_help
  else
    switch $cmd
      case "import"
        __import_vm_help
      case "docker"
        __docker_vm_help

      case "*"
        __invalid_command
    end
  end
end

function __invalid_command
  echo "invalid command" >&2
  __general_help
  return -1
end

function __general_help
    echo "Usage: vbox [OPTIONS] COMMAND [arg...]"
    echo "Commands"
    echo "  import" 
    echo "  docker" 
#    echo "  clone" 
    echo "  rm"
    echo "  start"
    echo "  stop"
    echo "  kill"
    echo "  ls"
    echo "  ps"
end

function __docker_vm_help
  echo "Usage: vbox docker [OPTIONS] [VM-NAME]"
  echo "Options:"
  echo "  -o, --ova     string    Virtual Box ova file path"
  echo "  --ssh-user    string    SSH User"
  echo "  -a, --attach  string    VM machine name"
end

function __docker_vm_exec
  echo "Usage: vbox docker [OPTIONS] [VM-NAME]"
  echo "Options:"
  echo "  -o, --ova     string    Virtual Box ova file path"
  echo "  --ssh-user    string    SSH User"
  echo "  -a, --attach  string    VM machine name"
end

function __start_vm_help
end

function __start_vm_exec
  VBoxManage startvm $argv --type headless
end

function __import_vm_help
  echo "Usage: vbox import [OPTIONS] [VM-NAME]"
  echo "Options:"
  echo "  -o, --ova     string    Virtual Box ova file path"
  echo "  -d, --docker  string    Create a docker machine"
  echo "  --ssh-user  string    Create a docker machine"
end

function __import_vm_exec
  set -l options (fish_opt -s o -l ova -r)
  argparse -n vbox_import $options -- $argv

  set -l ovafile $_flag_ova
  set -l vmname $argv[1]

  __import_vm_validate_params $vmname $ovafile
  or return
  
  echo "Importing virtual machine from $ovafile"

  VBoxManage import $ovafile --vsys 0 --vmname $vmname > /dev/null
  VBoxManage startvm $vmname --type headless
  set vmname "asterisk"

  echo "Waiting for VM "$vmname" to dhcp lease ..."
  set -l ipaddr (__fetch_ipaddr $vmname)

  echo "Waiting for openssh-server to start ..." $ipaddr
  __wait_openssh_to_start $ipaddr

  set -l hname (ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l root $ipaddr "hostname" 2> /dev/null)
  echo "Changing the hostname of VM($vmname) from $hname to $vmname ..."

  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l root $ipaddr "sed -i \"s/$hname/$vmname/g\" /etc/hosts; hostnamectl set-hostname $vmname" 2> /dev/null

  echo "Creating new ssh keys for $vmname ..."
  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l root $ipaddr "rm /etc/ssh/ssh_host_*; DEBIAN_FRONTEND=noninteractive dpkg-reconfigure openssh-server"

  echo "Adding new ssh keys to $HOME/.ssh/known_hosts ..."
  ssh-keyscan $ipaddr >> $HOME/.ssh/known_hosts 2> /dev/null

end

function __import_vm_validate_params -a vmname ovafile
  if test -z "$vmname"
    echo "virtual machine name is required !!!" >&2
    return -1
  end

  __is_vm_exist $vmname
  if test $status -eq 1
    echo "the virtual machine exists !!! name:$vmname" >&2
    return -1
  end

  if test -z "$ovafile"
    echo "ova file path is required !!!" >&2
    return -1
  end

  if not test -e "$ovafile"
    echo "ova file does not exist !!!" >&2
    return -1
  end
  
  return 0
end

function __is_vm_exist -a vmname
  set -l query (string replace -a '"' '' (VBoxManage list -s vms | grep $vmname | awk '{ print $1 }'))
  
  if test -z $query
    return 0
  end

  if test $query != $vmname
      return 0
  end

  return 1
end

function __wait_openssh_to_start -a ipaddr
  while true
    ssh-keyscan $ipaddr > /dev/null 2> /dev/null
    if test $status -eq 0
      break
    end
    sleep 1
  end
end

function __fetch_ipaddr -a vmname
  set -l macaddr (VBoxManage showvminfo $vmname | grep vboxnet0 | awk -F, '{ print $1 }' | awk '{ print $4 }')
  
  while true; 
    VBoxManage dhcpserver findlease --interface=vboxnet0 --mac-address=$macaddr > /dev/null 2> /dev/null
    if test $status -eq 0
      break
    end
    sleep 1
  end

  VBoxManage dhcpserver findlease --interface=vboxnet0 --mac-address=$macaddr | grep IP | awk '{ print $3 }'
end
