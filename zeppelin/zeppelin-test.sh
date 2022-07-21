#!/bin/sh

echo "VJR: Starting zeppelin..."

("$(ZEPPELIN_HOME)/bin/zeppelin-daemon.sh start") &

echo "VJR: Waiting for subshell of: Starting zeppelin..."

wait

echo "VJR: Done waiting for subshell of: Starting zeppelin..."

echo "VJR: Sleeping..."

sleep 5

echo "VJR: Done sleeping."

run_paragraph()
{
  echo "VJR: Start run paragraph $2 for notebook $1"
  zep_code=$(curl -o /dev/null -s -w {%http_code} -X POST http://localhost:8081/api/notebook/run/$1/$2)
  echo "VJR: End run paragraph $2 for notebook $1, zep_code=$zep_code, http_code=$http_code"
}

result_code=0

try_run_paragraph()
{

(
retry_count=5
sleep_time=1
zep_code=0

echo "VJR: Try run paragraph $2 for notebook $1"
run_paragraph $1 $2
echo "VJR: Done try run paragraph $2 for notebook $1"

while [ zep_code -ne 200 && retry_count -gt 0 ];
do
  ((retry_count--))
  echo "VJR: Sleep $sleep_time seconds before retry para $2 note $1"
  sleep sleep_time
  echo "VJR: Done sleep $sleep_time seconds before retry para $2 note $1"
  ((sleep_time*=2))
  echo "VJR: Before retry para $2 note $1"
  run_paragraph {{ $1 }} {{ $2 }}
  echo "VJR: After retry para $2 note $1"
done

if [ retry_count -eq 0 && zep_code -ne 200 ]
  echo "VJR: Setting error code for para $2 note $1"
  result_code=1
fi
) &

}

echo "VJR: Before final wait"

wait

echo "VJR: After final wait"

if [ result_code -ne 0 ]
  echo "VJR: PHAIL!"
  exit 1
fi

echo "VJR: SUCCESS!"
