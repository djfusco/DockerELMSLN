#!/bin/bash
# this script assumes ELMSLN code base is on the server and that the server
# has the correct packages in place to start working. Now we need to run
# some things against mysql because root is completely wide open. Part
# of the handsfree mindset is that, effectively, no one knows root for
# mysql and instead, a high credential elmslndbo is created

# now we can start into the actual ELMS stuff
cd $HOME
# @todo pipe in values
cat <<EOF | bash /usr/local/bin/elmsln-preinstall.sh

$1
$2
$3
$4
$5
$6
$7
$8
$9
${10}
elmslndbo
$dbopass
${11}
${12}
EOF

# copy and paste this
cd $HOME
source .bashrc
# replace YOU with your username and root with whatever group you want
# to own the system. If not sure leave the second value as root though
# admin is common as well.
chown -R root:root /var/www/elmsln
# setup user as admin
bash /usr/local/bin/elmsln-admin-user.sh

# give them a roadmap for mapping to this until proving a real domain
cd /var/www/elmsln/core/dslmcode/stacks
stacklist=( $(find . -maxdepth 1 -type d | sed 's/\///' | sed 's/\.//') )
domain=$5
datadomain=$6
prefix=$7
ip=$(hostname -I)
# if this is our default dev box domain name then kick this into the hosts file
# so that it works when they do it on their own machine
if [[ $domain = 'elmsln.dev' ||  $domain = 'elmsln.local' ]]; then
  elmslnwarn "ELMSLN Development settings detected, we will author your server's /etc/hosts file for you"
  echo "# ELMSLN development" >> /etc/hosts
  for stack in "${stacklist[@]}"
  do
    echo "${ip}  ${stack}.${domain}" >> /etc/hosts
  done
  echo "" >> /etc/hosts
  # loop again on webservices domains
  for stack in "${stacklist[@]}"
  do
    echo "${ip}  ${prefix}${stack}.${datadomain}" >> /etc/hosts
  done
fi
  # systems restart differently
  if [[ $1 == '1' ]]; then
    /etc/init.d/httpd restart
    /etc/init.d/php-fpm restart
    /etc/init.d/mysqld restart
  elif [ $1 == '2' ]; then
    service apache2 restart
    service php5-fpm restart
    service php7.0-fpm restart
  else
    service httpd restart
    service mysqld restart
    service php-fpm restart
  fi

# install system and off we go
bash /usr/local/bin/elmsln-install.sh
elmslnecho "If you are developing with this and don't have a valid domain yet you can copy the following into your local machine's /etc/hosts file:"
elmslnecho "# ELMSLN development"
# loop through and write each of these here
for stack in "${stacklist[@]}"
do
  elmslnecho "${ip}      ${stack}.${domain}"
done
elmslnecho ""
# loop again on webservices domains
for stack in "${stacklist[@]}"
do
  elmslnecho "${ip}      ${prefix}${stack}.${datadomain}"
done
