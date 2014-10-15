test-utilities
==============

A repository of utilities written to make testing CS assignments faster.

**Table of Contents**

- [ct.sh - Compile and test](#ctsh---compile-and-test)
  - [Usage](#usage)
    - [General usage](#general-usage)
    - [With command line arguments](#with-command-line-arguments)
- [tg.sh - Test suite generation](#tgsh---test-suite-generation)
  - [Usage](#usage-1)
    - [General usage](#general-usage-1)
    - [Specify the target directory](#specify-the-target-directory)
    - [Use a custom testfile](#use-a-custom-testfile)
    - [Use a custom test name prefix](#use-a-custom-test-name-prefix)
    - [Specify the suitefile name](#specify-the-suitefile-name)
  - [Attributions](#attributions)
    - [that other guy](#that-other-guy)

## ct.sh - Compile and test

This bash script takes a C++ file, compiles it, and runs it against an input file by standard input and outputs the result by standard output.

### Usage

#### General usage
```bash
$ ./ct.sh program.cc singletest.in
```

#### With command line arguments
```bash
$ ./ct.sh program.cc singletest.in "--option arg -a b"
```


## tg.sh - Test suite generation

This is a bash script for generating test suites from a testfile (default: `tests.txt`) containing alternating inputs and outputs separated by empty lines. The example testfile below is for a program that accepts an integer `n` and prints the first `n` terms of the Fibonacci sequence:

```
3

1 1 2

6

1 1 2 3 5 8

10

1 1 2 3 5 8 13 21 34 55

...
```

Any line that begins with `#` will be ignored by the generator. This allows you to include single-line comments:

```
# Powers of 2
4

1 1 2 3

8

1 1 2 3 5 8 13 21

# Powers of 3
9

1 1 2 3 5 8 13 21 34 55

...
```

tg.sh generates .in and .out files (default formats: `t[NUMBER].in`, `t[NUMBER].out`) and a suite file (default: `suite.txt`) containing the names of all the tests generated (e.g. `t1`, `t2`, `t3`, etc.).

The generated files are put in a target directory relative to the current directory (default: `tests`).

**WARNING:** The target directory is cleared on each run of this script, so make sure to specify a directory specifically for containing tests.

### Usage

#### General usage
```bash
$ ./tg.sh

# Reads testfile "test.txt" and generates .in and .out files in /current/directory/test
# Tests are listed in /current/directory/test/suite.txt
```

#### Specify the target directory
```bash
$ ./tg.sh --target mytests

# Generated files will be put in /current/directory/mytests instead
```

#### Use a custom testfile
```bash
# shortcut -t
$ ./tg.sh --testfile mytests.txt
```

#### Use a custom test name prefix
```bash
# shortcut -p
$ ./tg.sh --prefix q1t

# Tests will be named q1t0, q1t1, q1t2, etc.
```

#### Specify the suitefile name
```bash
# shortcut -s
$ ./tg.sh --suitefile suiteq1.txt

# Generated suitefile will named suiteq1.txt instead of suite.txt
```

#### Zip your test suite
```bash
$ ./tg.sh --zip a3q1a

# All generated test suite files will be zipped in file target/a3q1a.zip
# If no name is specified, the files will be zipped in target/tests.zip
```

### Attributions

#### that other guy

The code in tg.sh that reads the testfile and constructs an array using empty lines as delimiters borrows a portion of the code provided by [that other guy](http://stackoverflow.com/users/1899640/that-other-guy) in an answer to [this Stack Overflow question](http://stackoverflow.com/questions/18539369/split-text-file-into-array-based-on-an-empty-line-or-any-non-used-character).

