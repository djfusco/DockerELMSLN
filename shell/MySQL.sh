#!/bin/bash
# this script assumes ELMSLN code base is on the server and that the server
# has the correct packages in place to start working. Now we need to run
# some things against mysql because root is completely wide open. Part
# of the handsfree mindset is that, effectively, no one knows root for
# mysql and instead, a high credential elmslndbo is created

# used for random password generation
COUNTER=0
char=(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V X W Y Z)
max=${#char[*]}
# generate a random 30 digit password
pass=''
for i in `seq 1 30`
do
  let "rand=$RANDOM % 62"
  pass="${pass}${char[$rand]}"
done

# make mysql secure so no one knows the password except this script
mysql -e "UPDATE mysql.user SET Password = PASSWORD('$pass') WHERE User = 'root'"
# Kill the anonymous users
mysql -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
mysql -e "DROP USER ''@'$(hostname)'"
# Kill off the demo database
mysql -e "DROP DATABASE test"
# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"
# generate a password for the elmslndbo account
dbopass=''
for i in `seq 1 30`
do
  let "rand=$RANDOM % 62"
  dbopass="${pass}${char[$rand]}"
done
# now make an elmslndbo
cat <<EOF | mysql -u root --password=$pass
CREATE USER 'elmslndbo'@'localhost' IDENTIFIED BY '$dbopass';
GRANT ALL PRIVILEGES ON *.* TO 'elmslndbo'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
exit
EOF
