#!/bin/bash

# tg.sh -- test suite generation script
# This is a bash script for generating test suites from a testfile containing alternating inputs and outputs separated by empty lines.
# This script generates .in and .out files (default formats: t[NUMBER].in | t[NUMBER].out) and a suite file (default: suite.txt) containing the names of all the tests generated (e.g. t1, t2, t3, etc.).
# The generated files are put in a target directory relative to the current directory (default: tests)
# WARNING: The target directory is cleared on each run of this script, so make sure to specify a directory specifically for containing tests.

# OPTIONS:
# [-p|--prefix=PATTERN] sets the test file name prefixes (e.g. "./tg.sh -p mytest" will generate tests called "mytest1.in", "mytest2.in", etc. and "mytest1.out", "mytest2.out", etc.)
# [-t|--testfile=NAME] sets the name of the test, where the tests will be listed (default: "tests.txt")
# [-s|--suitefile=NAME] sets the name of the suitefile, which lists the name of the tests generated and which will be used by the submission tester (default: "suite.txt")
# [--target=TARGET] sets the relative target directory, where the tests and suitefile will be stored

# DEFAULTS
TESTDIR='tests'
PATTERN='t'
TESTFILE='tests.txt'
SUITEFILE='suite.txt'

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
        SUITENAME=$1
      else
        echo "no suitefile specified"
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
    *)
      break
      ;;
  esac
done

# READ IN TESTFILE
i=0
s=1
declare -a tests

while read -r line; do
  # If we find an empty line, then we increase the counter (i), 
  # set the flag (s) to one, and skip to the next line
  [[ $line == "" ]] && ((i++)) && s=1 && continue

  # If the flag (s) is zero, then we are not in a new line of the block
  # so we set the value of the array to be the previous value concatenated
  # with the current line
  [[ $s == 0 ]] && tests[$i]="${tests[$i]}"$'\n'"$line" || { 
    # Otherwise we are in the first line of the block, so we set the value
    # of the array to the current line, and then we reset the flag (s) to zero 
    tests[$i]="$line"
    s=0; 
  }
done < ${TESTFILE}

# CLEAR TARGET DIRECTORY
if [ ! -d "$TESTDIR" ]; then
  mkdir "$TESTDIR"
else
  rm -rfv "${TESTDIR}/*"
fi

# GENERATE TESTS
count=0
for i in "${!tests[@]}"; do
  if ! (($i % 2)); then
    echo "Test $((i / 2)):" # Output for verifying test generation
    echo ${tests[$i]} > "${TESTDIR}/${PATTERN}$(( $i / 2 )).in" # Generate .in file
    echo "${PATTERN}$(( $i / 2 ))" >> "${TESTDIR}/${SUITEFILE}" # Record test in suitefile
    cat "${TESTDIR}/${PATTERN}$(( $i / 2 )).in" # Print the test input
  else
    echo ${tests[$i]} > "${TESTDIR}/${PATTERN}$((($i - 1) / 2)).out" # Generate the .out file
    ((count++))
    cat "${TESTDIR}/${PATTERN}$((($i - 1) / 2)).out" # Print the test output
    echo
  fi
done

[ "$count" == 1 ] && printf "1 test generated" || printf "$count tests generated"
echo " in directory '$TESTDIR' (suitefile: $SUITEFILE)."
