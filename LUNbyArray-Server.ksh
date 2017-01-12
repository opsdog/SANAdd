#!/bin/ksh
##
##  script to show the LUNs (ID and CTD) by array for the server
##  given on the command line
##

##  check arg

if [ -z "$1" ]
then
  echo "usage:  `basename $0` servername"
  exit
fi

SANMapDir=/Volumes/External300/DBProgs/FSRServers/Inputs-SANmap
ServerName=$1

##
##  find the latest SAN map for server and gunzip it
##

SANMap=`ls -l ${SANMapDir}/${ServerName}_SAN2_* 2>/dev/null | tail -1 | awk '{ print $NF }'`
## echo $SANMap
gunzip -f $SANMap 2>/dev/null
SANMap=`ls -l ${SANMapDir}/${ServerName}_SAN2_* 2>/dev/null | tail -1 | awk '{ print $NF }'`
echo $SANMap

##
##  find distinct array numbers
##  find LUNs by array
##

ArrayNumsHEX=`cat $SANMap | awk -F\, '{ print $2 }' | sort -u`

for ArrayNumHEX in $ArrayNumsHEX
do
  ArrayNumDEC=`echo "ibase=16; $ArrayNumHEX" | bc`
  echo "Array $ArrayNumDEC (${ArrayNumHEX})"

  for LUNid in `cat $SANMap | awk -F\, ' $2 == arrayhex { print $3 }' arrayhex=$ArrayNumHEX | sort`
  do
    ## echo "  LUNID $LUNid"
    CTDS=`cat $SANMap | awk -F\, ' $2 == arrayhex && $3 == lunid { print $1 }' arrayhex=$ArrayNumHEX lunid=$LUNid`
    ## echo "    CTDS $CTDS"
    echo "${CTDS},${ArrayNumDEC},${LUNid}"
  done

done



