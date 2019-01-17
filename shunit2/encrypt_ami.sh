#!/usr/bin/env bash

script_under_test=$(basename $0)

aws() {
  echo "${FUNCNAME[0]} $*" >> commands_log
  case "${FUNCNAME[0]} $*" in
  'aws sts get-caller-identity --query Account --output text') echo 111111111111 ;;
  'aws ec2 describe-images --image-id ami-0114e9d25da9ed405 --query Images[].OwnerId --output text') echo 111111111111 ;;
  'aws ec2 copy-image --name ami-0114e9d25da9ed405 --source-image-id encrypted-alex --source-region ap-southeast-2 --encrypted --query ImageId --output text') echo ami-023d5e57238507bdf ;;
  'aws ec2 describe-images --image-id ami-023d5e57238507bdf --query Images[].State --output text')
    count=$(<count)
    case $count in
      [123])
        echo pending
        ;;
      4)
        echo available
        ;;
    esac
    (( count++ ))
    echo $count > count
    ;;
  *)
    echo "No responses for: aws $*"
    ;;
  esac
}

sleep() {
  echo "${FUNCNAME[0]} $*" >> commands_log
}

tearDown() {
  rm -f count commands_log expected_log
}

testUsage() {
  assertTrue "unexpected output when testing script usage function" ". $script_under_test -h | grep -qi usage"
}

testScript() {
  echo 1 > count
  . $script_under_test 'ami-0114e9d25da9ed405' 'encrypted-alex' 'windows' 'xxx' > /dev/null

  cat > expected_log <<EOF
aws sts get-caller-identity --query Account --output text
aws ec2 describe-images --image-id ami-0114e9d25da9ed405 --query Images[].OwnerId --output text
aws ec2 copy-image --name ami-0114e9d25da9ed405 --source-image-id encrypted-alex --source-region ap-southeast-2 --encrypted --query ImageId --output text
aws ec2 describe-images --image-id ami-023d5e57238507bdf --query Images[].State --output text
sleep 10
aws ec2 describe-images --image-id ami-023d5e57238507bdf --query Images[].State --output text
sleep 10
aws ec2 describe-images --image-id ami-023d5e57238507bdf --query Images[].State --output text
sleep 10
aws ec2 describe-images --image-id ami-023d5e57238507bdf --query Images[].State --output text
EOF

  assertEquals "unexpected sequence of commands issued" \
    "" "$(diff -wu expected_log commands_log)"
}

. shunit2
