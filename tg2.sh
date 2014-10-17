#!/bin/bash

# tg.sh -- test suite generation script
# This is a bash script for generating test suites from a testfile (default: tests.txt) containing blocks separated by empty lines and containing mixed lines of input and outputs, where outputs are represented by lines beginning with a single right angle bracket `>`.
# This script generates .in and .out files (default formats: t[NUMBER].in | t[NUMBER].out) and a suite file (default: suite.txt) containing the names of all the tests generated (e.g. t1, t2, t3, etc.).
# The generated files are put in a target directory relative to the current directory (default: tests)
# WARNING: The target directory is cleared on each run of this script, so make sure to specify a directory specifically for containing tests.

# OPTIONS:
# [-p|--prefix=PATTERN] sets the test file name prefixes (e.g. "./tg.sh -p mytest" will generate tests called "mytest1.in", "mytest2.in", etc. and "mytest1.out", "mytest2.out", etc.)
# [-t|--testfile=NAME] sets the name of the test, where the tests will be listed (default: "tests.txt")
# [-s|--suitefile=NAME] sets the name of the suitefile, which lists the name of the tests generated and which will be used by the submission tester (default: "suite.txt")
# [--target=TARGET] sets the relative target directory, where the tests and suitefile will be stored
# [--zip{=ZIPFILE}] zips all generated test suite files in target/tests.zip; the name of the zip file can be specified

# DEFAULTS
TESTDIR='tests'
PATTERN='t'
TESTFILE='tests.txt'
SUITEFILE='suite.txt'
AUXFILE='aux.txt'
AUXPATTERN='x'
ZIP=0
ZIPNAME='tests.zip'

# OPTIONS
while test $# -gt 0; do
  case "$1" in
    -p|--prefix)
      shift
      if test $# -gt 0; then
        PATTERN=$1
      else
        echo "no test prefix specified"
        exit 1
      fi
      shift
      ;;
    -t|--testfile)
      shift
      if test $# -gt 0; then
        TESTFILE=$1
      else
        echo "no testfile specified"
        exit 1
      fi
      shift
      ;;
    -s|--suitefile)
      shift
      if test $# -gt 0; then
        SUITEFILE=$1
      else
        echo "no suitefile specified"
        exit 1
      fi
      shift
      ;;
    -a|--auxfile)
      shift
      if test $# -gt 0; then
        AUXFILE=$1
      else
        echo "no auxfile specified"
        exit 1
      fi
      shift
      ;;
    --target)
      shift
      if test $# -gt 0; then
        TESTDIR=$1
      else
        echo "no target specified"
        exit 1
      fi
      shift
      ;;
    --zip)
      shift
      if test $# -gt 0; then
        ZIPNAME=$1
      fi
      ZIP=1
      shift
      ;;
    *)
      break
      ;;
  esac
done

# READ IN TESTFILE
# This section borrows code from the answer to the Stack Overflow question here: http://stackoverflow.com/questions/18539369/split-text-file-into-array-based-on-an-empty-line-or-any-non-used-character
block=0 # index of the current block
s=1 # if (s == 1), then we are in the first line of a block (inputs)
t=1 # if (t == 1), then we are in the first line of a block (outputs)
blocktype=0 # if (blocktype == 0), we are currently adding to an input file; otherwise add to an output file

declare -a inputs
declare -a outputs

TESTSKEY=$RANDOM

# Before processing testfile, remove all lines beginning with '#'
# There can be spaces before '#'
sed '/^ *#/ d' < ${TESTFILE} > /tmp/tmp-$TESTSKEY.txt

while read -r line; do

  # If we find an empty line, then we increment the block index
  # Set the flag (s) to 1, then skip to the next line
  if [[ $line == "" ]]; then
    ((block++))
    s=1
    t=1
    continue
  fi

  # If the current line begins with '>', switch to outputs; otherwise switch to inputs
  # There can be no spaces before or after '>'
  if [[ $line == \>* ]]; then
    # If line begins with '>', remove the first character
    line="${line#?}"
    blocktype=1
  else
    blocktype=0
  fi

  # Handle inputs
  if (( blocktype == 0 )); then

    if [ $s == 0 ]; then
      # If the line is exactly "\~" and we're inside a block then insert an empty line into the current test
      if [ "$line" == "\~" ]; then
        inputs[$block]="${inputs[$block]}"$'\n'
      else
        inputs[$block]="${inputs[$block]}"$'\n'"$line"
      fi

    else
      # If the first line of a block is "\~", we skip processing empty lines since the next line will add a newline for us
      if [ "$line" != "\~" ]; then
        inputs[$block]="$line"
      fi
      s=0
    fi

  # Handle outputs
  else

    if [ $t == 0 ]; then
      # If the line is exactly "\~" and we're inside a block then insert an empty line into the current test
      if [ "$line" == "\~" ]; then
        outputs[$block]="${outputs[$block]}"$'\n'
      else
        outputs[$block]="${outputs[$block]}"$'\n'"$line"
      fi
    else
      # If the first line of a block is "\~", we skip processing empty lines since the next line will add a newline for us
      if [ "$line" != "\~" ]; then
        outputs[$block]="$line"
      fi
      t=0
    fi

  fi
done < /tmp/tmp-$TESTSKEY.txt

rm /tmp/tmp-$TESTSKEY.txt

# READ IN AUXFILE
auxblock=0 # index of the current block
x=1 # if (s == 1), then we are in the first line of a block (inputs)

declare -a aux

if [ -e ${AUXFILE} ]; then

  AUXKEY=$RANDOM

  sed '/^ *#/ d' < ${AUXFILE} > /tmp/tmp-$AUXKEY.txt

  while read -r line; do

    # If we find an empty line, then we increment the block index
    # Set the flag (s) to 1, then skip to the next line
    if [[ $line == "" ]]; then
      ((auxblock++))
      x=1
      continue
    fi

    # Handle auxiliary files
    if [ $x == 0 ]; then
      # If the line is exactly "\~" and we're inside a block then insert an empty line into the current test
      if [ "$line" == "\~" ]; then
        aux[$auxblock]="${aux[$auxblock]}"$'\n'
      else
        aux[$auxblock]="${aux[$auxblock]}"$'\n'"$line"
      fi
    else
      # If the first line of a block is "\~", we skip processing empty lines since the next line will add a newline for us
      if [ "$line" != "\~" ]; then
        aux[$auxblock]="$line"
      fi
      x=0
    fi

  done < /tmp/tmp-$AUXKEY.txt

  rm /tmp/tmp-$AUXKEY.txt

fi

# CLEAR TARGET DIRECTORY
if [ ! -d "$TESTDIR" ]; then
  mkdir "$TESTDIR"
else
  printf "Clearing files in target directory... "
  rm "${TESTDIR}"/*
  echo "Target directory cleared."
  echo
fi

# GENERATE TESTS
count=0
for i in "${!outputs[@]}"; do
  echo "Test ${i} input:"
  echo "${inputs[$i]}" > "${TESTDIR}/${PATTERN}${i}.in" # Generate .in file
  echo "${PATTERN}${i}" >> "${TESTDIR}/${SUITEFILE}" # Record test in suitefile
  cat "${TESTDIR}/${PATTERN}${i}.in" # Print the test input
  echo
  echo "Test ${i} output:" # Output for verifying test generation
  echo "${outputs[$i]}" > "${TESTDIR}/${PATTERN}${i}.out" # Generate the .out file
  cat "${TESTDIR}/${PATTERN}${i}.out" # Print the test output
  echo
  ((count++))
done

auxcount=0
if [ -e ${AUXFILE} ]; then
  for i in "${!aux[@]}"; do
    echo "Auxiliary file ${i}:"
    echo "${aux[$i]}" > "${TESTDIR}/${AUXPATTERN}${i}.txt" # Generate .in file
    cat "${TESTDIR}/${AUXPATTERN}${i}.txt" # Print the test input
    echo
    ((auxcount++))
  done
fi

if [ $ZIP == 1 ]; then
  echo "Zipping files in ${TESTDIR}/${ZIPNAME}..."
  cd ${TESTDIR} && zip ${ZIPNAME} * && cd .. && echo "Successfully zipped files." || echo "File zipping failed."
  echo
fi

[ "$count" == 1 ] && printf "1 test" || printf "$count tests"
if [ "$auxcount" == 1 ]; then
  [ "$auxcount" == 1 ] && printf " and 1 auxiliary file" || printf " and $auxcount auxiliary files"
fi
printf " generated"
echo " in directory '$TESTDIR' (suitefile: $SUITEFILE)."
