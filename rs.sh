#!/bin/bash

TESTDIR='tests'
SUITEFILE='suite.txt'
PROGRAM='program'

# OPTIONS
while test $# -gt 0; do
  case "$1" in
    -s|--suitefile)
      shift
      if test $# -gt 0; then
        SUITEFILE=$1
        echo $SUITEFILE
      else
        echo "no suitefile specified"
        exit 1
      fi
      shift
      ;;
    -d|--dir)
      shift
      if test $# -gt 0; then
        TESTDIR=$1
        echo $TESTDIR
      else
        echo "no test directory specified"
        exit 1
      fi
      shift
      ;;
    *)
      echo $1
      PROGRAM=$1
      shift
      ;;
  esac
done

cd ${TESTDIR}
cp ../${PROGRAM} .

lines=$(wc -l < ${SUITEFILE})
fails=0

# clear error.log file
if [[ -r errors.log ]]; then
  rm errors.log
fi

for (( line=1; line<=$lines; line++ )); do
  testfile=$(head -$line ${SUITEFILE} | tail -1)

  if [ ! -r ${testfile}.in ]; then
    echo "Missing or unreadable file ${testfile}.in" >&2
    exit 1
  elif [ ! -r ${testfile}.out ]; then
    echo "Missing or unreadable file ${testfile}.out" >&2
    exit 1
  fi

  tempname=$(mktemp /tmp/${testfile}.XXXXXX)

  ./${PROGRAM} < ${testfile}.in > ${tempname}

  if diff ${testfile}.out ${tempname} >> /dev/null; then
    :
  else
    echo -e "Test failed: ${testfile}\nInput:\n$(cat ${testfile}.in)\n\nExpected:\n$(cat ${testfile}.out)\n\nActual:\n$(cat ${tempname})\n\n"
    ((fails++))
    touch errors.log
    echo -e "FAILED: ${testfile}" >> errors.log
    diff ${testfile}.out ${tempname} >> errors.log
    echo >> errors.log
  fi

  rm ${tempname}
done

rm ${PROGRAM}
cd ..

if [ $fails -gt 0 ]; then
  echo "${fails} tests failed (${TESTDIR}/error.log)"
fi
