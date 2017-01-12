#!/bin/ksh
##
##  script to create the commands to remove the detached plexes
##

rm -f *-rmdisk.ksh

for FilePath in Inputs/*.olddm
do
  File=`echo $FilePath | awk -F\/ '{ print $2 }'`
  unset OuputFile
  echo
  echo "$File"

  ##  get relevant info from disks file

  ServerName=`echo $File | awk -F\- '{ print $1 }'`
  DiskGroup=`echo $File | awk -F\- '{ print $2 }' | awk -F\. '{ print $1 }'`
  RMDMFile="${ServerName}-rmdisk.ksh"

  ##  put the bailout code into script files

  cat >> $RMDMFile <<EOF
  WhereAmI=\`uname -n\`
  if [ "\${WhereAmI}" != "${ServerName}" ]
  then
    echo "WRONG SERVER - should be run on $ServerName"
    exit
  fi
  cd /var/tmp/SAN
EOF

  exec 4<$FilePath
  while read -u4 type DiskMedia DiskCTD junk
  do
    echo "  $DiskMedia $DiskGroup"
    echo "vxdisk reclaim $DiskCTD" >> $RMDMFile
    echo "vxdg -g $DiskGroup rmdisk $DiskMedia" >> $RMDMFile
  done  ##  for each dm
  exec 4<&-

done  ##  for each olddm file
