#!/bin/ksh
##
##  script to create the commands to remove the detached plexes
##

rm -f *-rmplex.ksh

for FilePath in Inputs/*.plexes
do
  File=`echo $FilePath | awk -F\/ '{ print $2 }'`
  unset OuputFile
  echo
  echo "$File"

  ##  get relevant info from plexes file

  ServerName=`echo $File | awk -F\- '{ print $1 }'`
  DiskGroup=`echo $File | awk -F\- '{ print $2 }' | awk -F\. '{ print $1 }'`
  RMPlexFile="${ServerName}-rmplex.ksh"

  ##  put the bailout code into script files

  cat >> $RMPlexFile <<EOF
  WhereAmI=\`uname -n\`
  if [ "\${WhereAmI}" != "${ServerName}" ]
  then
    echo "WRONG SERVER - should be run on $ServerName"
    exit
  fi
  cd /var/tmp/SAN
EOF

##  for Plex in `cat $FilePath | awk ' $4 == "DISABLED" { print $2 }'`
  for Plex in `cat $FilePath | awk ' $4 == "ENABLED" { print $2 }'`
  do
    echo "  $Plex $DiskGroup"
    echo "vxedit -g $DiskGroup -rf rm $Plex" >> $RMPlexFile
  done  ##  for each plex

done  ##  for each plexes file
