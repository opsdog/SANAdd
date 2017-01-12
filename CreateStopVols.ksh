#!/bin/ksh
##
##  script to create the commands to remove the detached plexes
##

rm -f *-stopvols.ksh
rm -f *-rmvols.ksh

for FilePath in Inputs/*.vols
do
  File=`echo $FilePath | awk -F\/ '{ print $2 }'`
  unset OuputFile
  echo
  echo "$File"

  ##  get relevant info from plexes file

  ServerName=`echo $File | awk -F\- '{ print $1 }'`
  DiskGroup=`echo $File | awk -F\- '{ print $2 }' | awk -F\. '{ print $1 }'`
  StopVolFile="${ServerName}-stopvols.ksh"
  RMVolFile="${ServerName}-rmvols.ksh"

  ##  put the bailout code into script files

  cat >> $RMVolFile <<EOF
  WhereAmI=\`uname -n\`
  if [ "\${WhereAmI}" != "${ServerName}" ]
  then
    echo "WRONG SERVER - should be run on $ServerName"
    exit
  fi
  cd /var/tmp/SAN
EOF

  cat >> $StopVolFile <<EOF
  WhereAmI=\`uname -n\`
  if [ "\${WhereAmI}" != "${ServerName}" ]
  then
    echo "WRONG SERVER - should be run on $ServerName"
    exit
  fi
  cd /var/tmp/SAN
EOF

  for Volume in `cat $FilePath | awk ' $4 == "ENABLED" { print $2 }'`
  do
    echo "  $Volume $DiskGroup"
    echo "vxvol -g $DiskGroup stop $Volume" >> $StopVolFile
    echo "vxassist -g $DiskGroup remove volume $Volume" >> $RMVolFile
  done  ##  for each plex

done  ##  for each plexes file
