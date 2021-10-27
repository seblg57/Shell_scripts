#! /bin/sh
##############################

scripts=/usr/local/bin
trap "echo 'Control-C cannot be used' ; sleep 1 ; clear ; continue " 1 2 3

#=========================================================================
usage()
{
cat << EOU

Usage:   mysmit [-h]

  -h    usage

  mysmit - AIX specific command regrouped in a menu
EOU

  exit
}
shortcuts()
{
cat << EOU

Shortcuts for mysmit:

  user          user management
  fs            filesystem menu

EOU

  exit
}
#=========================================================================
resetpwd()
{
if [ $# -ge 1 ] ; then
  usage
fi

lsuser -a unsuccessful_login_count $1
echo "Resetting unsuccessful login count of $1"
chsec -f /etc/security/lastlog -a "unsuccessful_login_count=0" -s $1
if [ $? -eq 0 ]
then
   echo "$1 resetted"
   lsuser -a unsuccessful_login_count $1
fi
}

#-------------------------------------------------------------------------
user_unlock()
{
 echo "Enter user name (you will have to fix the password):"
     read name
     if [ "$name" != "" ]
     then
        chuser -a unsuccessful_login_count=0 $name
        passwd $name
     else
        echo empty name
        read dummy
     fi
}

#=========================================================================
menu_user()
{
while true
do
clear
cat << "EOT"
-------------------------------------
        MENU OF CHOICES
-------------------------------------

a )  show the usernames only
b )  show the usernames and ID
c )  reset passwd
d )  unlock account

r )  return to previous menu
q )  QUIT (Leave this menu program)

Please type a choiceletter (from the above choices) then press the RETURN key

EOT

read answer
clear
case "$answer" in
[aA]*) echo "please wait ..." ;lsuser ALL |awk '{ print $1} ';;
[bB]*) lsuser ALL |awk '{ print $1 $3} ';;
[cC]*) echo "user name :"
     read name
     if [ "$name" != "" ]
     then
        resetpwd $name
     else
        echo empty name
        read dummy
     fi ;;
[dD]*) user_unlock;;
[Rr]*) menu_main  ;;
[Qq]*)  echo "Quitting the menu program" ; exit 0 ;;
*)      echo "Please choose an option which is displayed on the menu" ;;
esac
echo ""
echo "PRESS RETURN FOR THE MENU"
read dummy
done
}

#=========================================================================
#=========================================================================
menu_fs()
{
while true
do
clear
cat << "EOT"
-------------------------------------
        MENU OF CHOICES
-------------------------------------

a )  Change fs size

r )  return to previous menu
q )  QUIT (Leave this menu program)

Please type a choiceletter (from the above choices) then press the RETURN key

EOT

read answer
clear
case "$answer" in
[Aa]*)  echo "change a file system size "
        echo "filesystem name absolute path:"
        read fs
        if [ "$fs" = "" ]
        then
                echo "Listing $HOME"
                echo ""
                ls $HOME
        fi
        echo "Size followed by M or G for megabyte and gigabyte:"
        read size
        chfs -a size=$size $fs
       ;;
[Rr]*) menu_main  ;;
[Qq]*)  echo "Quitting the menu program" ; exit 0 ;;
*)      echo "Please choose an option which is displayed on the menu" ;;
esac
echo ""
echo "PRESS RETURN FOR THE MENU"
read dummy
done
}


menu_main()
{
RET=menu_main
while true
do
clear
cat << "EOT"
-------------------------------------
        MAIN MENU
-------------------------------------

a )  menu user
b )  menu filesystem

q )  QUIT (Leave this menu program)

Please type a choiceletter (from the above choices) then press the RETURN key

EOT

read answer
clear
case "$answer" in
[Aa]*) menu_user ;;
[Bb]*) menu_fs ;;
[Qq]*)  echo "Quitting the menu program" ; exit 0 ;;
*)      echo "Please choose an option which is displayed on the menu" ;;
esac
echo ""
echo "PRESS RETURN FOR THE MENU"
read dummy
done
}

#gestion des parametres
while getopts h os
do case "$o" in
    h)      usage;;
    s)      shortcuts;;
    esac
done

echo $1

# common
[ $# -ge 2 ] && usage
[ $# -eq 0 ] && menu_main

# shortcuts
[ "$1" == "user" ] && menu_user
[ "$1" == "fs" ] && menu_fs

echo "option menu not found type mysmit"