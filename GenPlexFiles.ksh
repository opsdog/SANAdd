#!/bin/ksh
##
##  script to read the Inputs/server-vxprint-ht.diskgroup files and
##  create the raw server-diskgroup.plex and server-diskgroup.olddm
##  files
##

##  remove old runs

rm -f Inputs/*.olddm Inputs/*.plexes

for FilePath in Inputs/*-vxprint-ht.*
do
  echo $FilePath

  File=`echo $FilePath | awk -F\/ '{ print $2 }'`
  # echo "  $File"

  ##  get relevant info from vxprint file

  ServerName=`echo $File | awk -F\- '{ print $1 }'`
  DiskGroup=`echo $File | awk -F\. '{ print $2 }'`

  # echo "  $ServerName"
  # echo "  $DiskGroup"

  grep \^pl\  $FilePath > Inputs/${ServerName}-${DiskGroup}.plexes
  grep \^dm\  $FilePath > Inputs/${ServerName}-${DiskGroup}.olddm

done
