#!/bin/bash

#test  scheduled job

DIR=$(cd `dirname $0` && pwd)
source $DIR/include.sh

###
# setup: create a new job
###

# job exec
args="echo hello there"

project=$2
if [ "" == "$2" ] ; then
    project="test"
fi

#escape the string for xml
xmlargs=$($XMLSTARLET esc "$args")
xmlproj=$($XMLSTARLET esc "$project")
xmlhost=$($XMLSTARLET esc $(hostname))

#determine h:m:s to run, 10 seconds from now
NDATES=$(date '+%s')
NDATES=$(( $NDATES + 10 ))
osname=$(uname)
if [ "Darwin" = "$osname" ] ; then
  NDATE=$(env TZ=GMT date -r "$NDATES" '+%Y %m %d %H %M %S')
else
  NDATE=$(env TZ=GMT date -u --date="@$NDATES" '+%Y %m %d %H %M %S')
fi
NY=$(echo $NDATE | cut -f 1 -d ' ')
NMO=$(echo $NDATE | cut -f 2 -d ' ')
ND=$(echo $NDATE | cut -f 3 -d ' ')
NH=$(echo $NDATE | cut -f 4 -d ' ')
NM=$(echo $NDATE | cut -f 5 -d ' ')
NS=$(echo $NDATE | cut -f 6 -d ' ')

#produce job.xml content corresponding to the dispatch request
cat > $DIR/temp.out <<END
<joblist>
   <job>
      <name>scheduled job</name>
      <group>api-test/job-run-scheduled</group>
      <uuid>api-test-job-run-scheduled</uuid>
      <description></description>
      <loglevel>INFO</loglevel>
      <context>
          <project>$xmlproj</project>
      </context>
      <dispatch>
        <threadcount>1</threadcount>
        <keepgoing>true</keepgoing>
      </dispatch>
      <schedule>
        <time hour='$NH' seconds='$NS' minute='$NM' />
        <month month='$NMO'  day='$ND' />
        <year year='$NY' />
      </schedule>
      <timeZone>GMT</timeZone>

      <sequence>
        <command>
        <exec>$xmlargs</exec>
        </command>
      </sequence>
   </job>
</joblist>

END

jobid=$(uploadJob "$DIR/temp.out" "$project"  1 )
if [ 0 != $? ] ; then
  errorMsg "failed job upload"
  exit 2
fi

###
# Get list of successful execs for this job before the job succeeds
###

runurl="${APIURL}/job/$jobid/executions"

params="status=succeeded"

# get listing
docurl ${runurl}?${params} > $DIR/curl.out
if [ 0 != $? ] ; then
    errorMsg "ERROR: failed query request"
    exit 2
fi

$SHELL $SRC_DIR/api-test-success.sh $DIR/curl.out || exit 2

#result will contain list of failed and succeeded jobs, in this
#case there should only be 1 failed or 1 succeeded since we submit only 1

succount=$(xmlsel "//executions/@count" $DIR/curl.out)

###
# Wait for schedule to pass and test success
###

echo "TEST: scheduled job run should succeed (sleep 20 sec)"

#check if job has another success after 20 secs
sleep 20

runurl="${APIURL}/job/$jobid/executions"

params="status=succeeded"

# get listing
docurl ${runurl}?${params} > $DIR/curl.out
if [ 0 != $? ] ; then
    errorMsg "ERROR: failed query request"
    exit 2
fi

$SHELL $SRC_DIR/api-test-success.sh $DIR/curl.out || exit 2

#result will contain list of failed and succeeded jobs, in this
#case there should only be 1 failed or 1 succeeded since we submit only 1

succount2=$(xmlsel "//executions/@count" $DIR/curl.out)

####
# Verify the Count of executions
####
testval=$(( $succount + 1 ))
if [ "$testval" == "$succount2" -a "$succount" != "" -a "$succount2" != "" ] ; then
    echo "OK"
else
    errorMsg "FAIL: expected scheduled job execution to succeed. (expected: ${testval}, actual: ${succount2})"
    exit 2
fi


rm $DIR/curl.out

