#!/bin/bash

waitTime=10
VMNAME="$1"
if [$VMNAME == ""]; then
  VMNAME="$(vboxmanage list vms |grep -e ""| sed -e 's/"//g' -e 's/ .*//')"
fi
VMNAME_C="\e[36m$VMNAME\e[0m"
PROTOCODE="ssh"
HOST_IP="$(vboxmanage showvminfo $VMNAME | grep -e "name = $PROTOCODE" | sed -e 's/.*host ip = \(.*\)\, host port.*/\1/')"
HOST_PORT="$(vboxmanage showvminfo $VMNAME | grep -e "name = $PROTOCODE" | sed -e 's/.*host port = \(.*\)\, guest ip.*/\1/')"

check_status (){
  INFO_State="$(vboxmanage showvminfo $VMNAME | grep -e "State:" | tr -s ' ' | sed -e 's/.*State: \(.*\)\ (since.*/\1/')"
  case "$INFO_State" in
    "powered off")  COLOUR=31m ;; #Red
    "running")      COLOUR=32m ;; #Greed
    *)              COLOUR=33m ;; #Yellow
  esac
  echo -e "Status    = \e[$COLOUR$INFO_State\e[0m "
}

main_menu(){
clear
echo  ------------------------------------
echo  "  KIC VM SSH AUTO LOGIN SYSTEM "
echo  ------------------------------------
echo -e "VM Name   = $VMNAME_C"
echo    "Protocode = $PROTOCODE"
echo    "Host IP   = $HOST_IP"
echo    "Host Port = $HOST_PORT"
check_status
echo  ------------------------------------
echo    "  [1] linux"
echo    "  [2] sql"
if [ "$INFO_State" != "powered off" ]; then
  echo -e "  [q] turn off $VMNAME_C";
fi
echo  ------------------------------------
wait_for_input
}

ssh_login (){
  if [ "$INFO_State" != "running" ]; then
    expect -c "
      spawn VBoxManage startvm $VMNAME --type headless;
      expect {
        \"Waiting\" { exp_continue; }
        \"successfully\" { puts \"Expecting $waitTime seconds to boot\"; } }
    ";
    for (( i=0 ; i<$waitTime ; i++ )); do
      sleep 1; echo -ne ".";
    done;
    echo "";
  fi
  expect -c "
    set timeout 20;
    puts \"Waiting for $PROTOCODE connection... Expecting 15 seconds.\";
    spawn $PROTOCODE $USER@$HOST_IP -p$HOST_PORT;
    expect {
      \"assword:\" { send \"$PASSWORD\r\"; interact; } }
  "
  main_menu;
}

wait_for_input(){
read Input
case "$Input" in
  1)
    USER="linux";
    PASSWORD="penguin";
    ssh_login;;
  2)
    USER="sql";
    PASSWORD="sql";
    ssh_login;;

  "q")
    if [ "$INFO_State" != "powered off" ]; then
      echo -e "You are going to push the \e[1;31;42mAcpi Power Button\e[0m of $VMNAME_C";
      echo -e "\e[5;36m Are you sure ? (Y/N) (Default=No) \e[0m";
      read ConfirmInput;
      case "$ConfirmInput" in
        "q" | "yes"| "Yes" | "Y" | "y")
          VBoxManage controlvm $VMNAME acpipowerbutton;
          echo "Waiting for $VMNAME_C to shutdown. Expecting $waitTime seconds";
          for (( i=0 ; i<$waitTime ; i++ )); do
            sleep 1; echo -ne ".";
          done;;
        *) ;;
      esac
    else check_status; sleep 1;
    fi
    main_menu ;;
  "r")
    check_status;
    main_menu ;;
  *) ;;
esac
}

main_menu;
echo -e "\n~~~~~~~~~~~~~~~~~~~~ END ~~~~~~~~~~~~~~~~~~~~\n"
sleep 1;
exit 1;
