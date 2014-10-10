#!/bin/bash

# ct.sh -- compile and test script
# This bash script takes a C++ file, compiles it, and runs it against an input file and outputs the result in the terminal.

# ${1} : name of C++ file (e.g. 'program.cc', 'program.cpp')
# ${2} : name of input file (assuming the names of your input files end with '.in')
# ${3} : string of command-line arguments to pass to the program

PROGNAME="$( cut -d '.' -f 1 <<< ${1} )" # so we can specify the name of the g++ output file
TESTNAME="$( cut -d '.' -f 1 <<< ${2} )" # in case you included the '.in' suffix

g++ -o ${PROGNAME}.out ${1}

if [ -f ${TESTNAME}.in ]; then
  ./${PROGNAME}.out "${3}" < ${TESTNAME}.in
fi
