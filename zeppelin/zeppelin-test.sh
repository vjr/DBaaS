#!/bin/sh

echo "VJR: Starting zeppelin from: [$ZEPPELIN_HOME]"

("$ZEPPELIN_HOME"/bin/zeppelin-daemon.sh status) &
zeppelinPID="$!"

echo "VJR: Waiting for subshell of: Starting zeppelin..."

#wait

echo "VJR: Done waiting for subshell of: Starting zeppelin..."

echo "VJR: Sleeping..."

sleep 1

echo "VJR: Done sleeping."

run_paragraph()
{
  echo "VJR: Start run paragraph $2 for notebook $1"
  zep_code=$(curl -o /dev/null -s -w %{http_code} -X POST http://localhost:8081/api/notebook/run/$1/$2)
  echo "VJR: End run paragraph $2 for notebook $1, zep_code=$zep_code, http_code=$http_code"
}

try_run_paragraph()
{

(
retry_count=5
sleep_time=1
zep_code=0

echo "VJR: Try run paragraph $2 for notebook $1"
run_paragraph $1 $2
echo "VJR: Done try run paragraph $2 for notebook $1"

while [ "$zep_code" != "200" ] && [ $retry_count -gt 0 ];
do
  ((retry_count--))
  echo "VJR: Sleep $sleep_time seconds before retry para $2 note $1"
  sleep $sleep_time
  echo "VJR: Done sleep $sleep_time seconds before retry para $2 note $1"
  ((sleep_time*=2))
  echo "VJR: Before retry para $2 note $1"
  run_paragraph $1 $2
  echo "VJR: After retry para $2 note $1"
done

if [ $retry_count -eq 0 ] && [ "$zep_code" != "200" ]; then
  echo "VJR: Setting error code for para $2 note $1"
  exit 1
  #resultCodes+="1"
#else
#  echo 0
  #resultCodes+="0"
fi
)
}

echo "VJR: Running paras..."

declare -a childPIDs

#(resultCodes+=$(try_run_paragraph 2EYUV26VR 20180530-101118_380906698)) &
(try_run_paragraph 2EYUV26VR 20180530-101118_380906698) &
childPIDs+=($!)

(try_run_paragraph 2EYUV26VR 20180530-101118_380906698) &
childPIDs+=($!)

echo "VJR: Before final wait"

wait "$zeppelinPID"

#wait

echo "VJR: After final wait, result count=${!childPIDs[@]}"

for i in "${!childPIDs[@]}"; do
  echo "VJR: Child PID $i: ${childPIDs[i]}"
  if ! wait "${childPIDs[i]}"; then
    echo "VJR: PHAIL!!!"
    #exit $?
    echo $?
  fi
done

#for i in "${!resultCodes[@]}"; do
#  resultCode="${resultCodes[i]}"
#  if [ "$resultCode" = "1" ]; then
#    echo "VJR: PHAIL!"
#    exit 1
#  fi
#done

echo "VJR: SUCCESS!"
