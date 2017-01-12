#!/bin/ksh
##
##  read the *.disks files and create the vxdisksetup commands
##
##  assumes input files with names SERVER"-"DISKGROUP".disks"
##  which contains:
##    line 1:  name-of-disk-group" "next-number-of-DM
##    line 2:  name of first volume and number (assumes each volume ascends)
##    line 3-: CTD of the new disk and "m" for add as mirror or "n" for new volume
##

rm -f *-init-sliced.ksh
rm -f *-init-CDS.ksh
rm -f *-label.ksh

for FilePath in Inputs/*.disks
do
  File=`echo $FilePath | awk -F\/ '{ print $2 }'`
  unset OuputFile
  echo "$File"

  ##  get relevant info from disks file

  ServerName=`echo $File | awk -F\+ '{ print $1 }'`
  DiskGroup=`echo $File | awk -F\+ '{ print $2 }' | awk -F\. '{ print $1 }'`
  OutputFileSliced="${ServerName}-init-sliced.ksh"
  OutputFileCDS="${ServerName}-init-CDS.ksh"
  OutputFileLabel="${ServerName}-label.ksh"

  echo "  $ServerName"
  echo "  $DiskGroup"
  echo "  $OutputFileSliced"
  echo "  $OutputFileCDS"

  ##  put the bailout code into OutputFile

  cat >> $OutputFileSliced <<EOF
  WhereAmI=\`uname -n\`
  if [ "\${WhereAmI}" != "${ServerName}" ]
  then
    echo "WRONG SERVER - should be run on $ServerName"
    exit
  fi
  cd /var/tmp
EOF

  cat >> $OutputFileCDS <<EOF
  WhereAmI=\`uname -n\`
  if [ "\${WhereAmI}" != "${ServerName}" ]
  then
    echo "WRONG SERVER - should be run on $ServerName"
    exit
  fi
  cd /var/tmp
EOF

  cat >> $OutputFileLabel <<EOF
  WhereAmI=\`uname -n\`
  if [ "\${WhereAmI}" != "${ServerName}" ]
  then
    echo "WRONG SERVER - should be run on $ServerName"
    exit
  fi
  cd /var/tmp
EOF

  ##
  ##  create the label format input file
  ##

  cat > label.fmt <<EOF
label
y

EOF

  ##
  ##  process the file
  ##

  exec 4<$FilePath

  ##  discard the disk group name and volume info

  read -u4 Discard
  read -u4 Discard

  ##  process each disk

  NOHUP=1
  while read -u4 CTD Action
  do
    echo "  $CTD (${Action})"

    echo "format $CTD < /var/tmp/label.fmt" >> $OutputFileLabel

    if [ "${NOHUP}" = "1" ]
    then
      NOHUP=0
      echo "nohup /etc/vx/bin/vxdisksetup -i $CTD format=sliced &" >> $OutputFileSliced
      echo "nohup /usr/sbin/vxdisk init $CTD format=cdsdisk &" >> $OutputFileCDS
    else
      NOHUP=1
      echo "/etc/vx/bin/vxdisksetup -i $CTD format=sliced" >> $OutputFileSliced
      echo "/usr/sbin/vxdisk init $CTD format=cdsdisk" >> $OutputFileCDS
    fi
  done
  exec 4<&-

  echo "echo ; echo ; echo \"  -- finite --\"" >> $OutputFileSliced
  echo "echo ; echo ; echo \"  -- finite --\"" >> $OutputFileCDS

done
