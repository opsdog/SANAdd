#!/bin/ksh
##
##  script to create the adddisk commands
##
##  assumes input files with names SERVER"-"DISKGROUP".disks"
##  which contains:
##    line 1:  name of disk group
##    line 2:  name of first volume and number (assumes each volume ascends)
##    line 3-: CTD of the new disk and "m" for add as mirror or "n" for new volume
##

rm -f *-adddisk.ksh
rm -f *-backout.ksh
rm -f *-mirror.ksh
rm -f *-newvol.ksh
rm -f *-brkmir.ksh

for FilePath in Inputs/*.disks
do
  File=`echo $FilePath | awk -F\/ '{ print $2 }'`
  unset OuputFile
  echo
  echo "$File"

  ##  get relevant info from disks file

  ServerName=`echo $File | awk -F\+ '{ print $1 }'`
  AddDiskFile="${ServerName}-adddisk.ksh"
  MirrorFile="${ServerName}-mirror.ksh"
  NewVolFile="${ServerName}-newvol.ksh"
  BreakMirrorFile="${ServerName}-brkmir.ksh"
  BackoutFile="${ServerName}-backout.ksh"

  ##  put the bailout code into script files

  cat >> $AddDiskFile <<EOF
  WhereAmI=\`uname -n\`
  if [ "\${WhereAmI}" != "${ServerName}" ]
  then
    echo "WRONG SERVER - should be run on $ServerName"
    exit
  fi
  cd /var/tmp/SAN
EOF

  cat >> $MirrorFile <<EOF
  WhereAmI=\`uname -n\`
  if [ "\${WhereAmI}" != "${ServerName}" ]
  then
    echo "WRONG SERVER - should be run on $ServerName"
    exit
  fi
  cd /var/tmp/SAN
EOF

  cat >> $NewVolFile <<EOF
  WhereAmI=\`uname -n\`
  if [ "\${WhereAmI}" != "${ServerName}" ]
  then
    echo "WRONG SERVER - should be run on $ServerName"
    exit
  fi
  cd /var/tmp/SAN
EOF



  cat >> $BreakMirrorFile <<EOF
  WhereAmI=\`uname -n\`
  if [ "\${WhereAmI}" != "${ServerName}" ]
  then
    echo "WRONG SERVER - should be run on $ServerName"
    exit
  fi
  cd /var/tmp/SAN
EOF

  cat >> $BackoutFile <<EOF
  WhereAmI=\`uname -n\`
  if [ "\${WhereAmI}" != "${ServerName}" ]
  then
    echo "WRONG SERVER - should be run on $ServerName"
    exit
  fi
  cd /var/tmp/SAN
EOF



  ##  open the input file

  exec 4<$FilePath

  ##  get the disk group and volume info

  read -u4 DiskGroup DMNumber Tag
  read -u4 VolumeName VolNumber

  ##  echo
  echo "  $ServerName"
  echo "  $DiskGroup ($DMNumber)"
  echo "  $AddDiskFile"
  echo 
  ##  echo "If not correct - bail now..."
  ##  sleep 5

  ##  process each disk

  while read -u4 CTD Action
  do
    echo "  $CTD (${Action}) (${DMNumber}) (${VolNumber})"

    DMNumberF=`printf %03d $DMNumber`
    VolNumberF=`printf %03d $VolNumber`

    echo "vxdisk settag $CTD $Tag" >> $AddDiskFile
    echo "vxdg -g $DiskGroup adddisk ${DiskGroup}${DMNumberF}=${CTD}" >> $AddDiskFile

    if [ "${Action}" = "m" ]
    then
      echo "vxassist -f -g ${DiskGroup} -b mirror ${VolumeName}${VolNumberF} ${DiskGroup}${DMNumberF}" >> $MirrorFile
      echo "vxplex -g ${DiskGroup} dis ${VolumeName}${VolNumberF}-01" >> $BreakMirrorFile
      echo "vxplex -g ${DiskGroup} dis ${VolumeName}${DMNumberF}-01" >> $BackoutFile
      VolNumber=`expr $VolNumber + 1`
    fi

    if [ "${Action}" = "n" ]
    then
      echo "vxassist -g ${DiskGroup} make ${VolumeName}${VolNumberF} SIZE ${DiskGroup}${DMNumberF}" >> $NewVolFile
      echo "vxedit -g ${DiskGroup} set user=oracle group=dba ${VolumeName}${VolNumberF}" >> $NewVolFile
      VolNumber=`expr $VolNumber + 1`
    fi

    DMNumber=`expr $DMNumber + 1`
  done  ##  while reading file
  exec 4<&-

done  ##  for each File
