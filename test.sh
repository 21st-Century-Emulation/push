docker build -q -t push .
docker run --rm --name push -d -p 8080:8080 -e WRITE_MEMORY_API=http://localhost:8080/api/v1/debug/writeMemory push

sleep 5

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":245,"state":{"a":51,"b":1,"c":15,"d":5,"e":15,"h":10,"l":2,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":true},"programCounter":1,"stackPointer":1,"cycles":1,"interruptsEnabled":true}}' \
  http://localhost:8080/api/v1/execute`
EXPECTED='{"id":"abcd", "opcode":245,"state":{"a":51,"b":1,"c":15,"d":5,"e":15,"h":10,"l":2,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":true},"programCounter":1,"stackPointer":65534,"cycles":12,"interruptsEnabled":true}}'

docker kill push

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mPUSH Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mPUSH Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi