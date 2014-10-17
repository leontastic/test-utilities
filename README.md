test-utilities
==============

A repository of utilities written to make testing CS assignments faster.

**Table of Contents**

- [ct.sh - Compile and test](#ctsh---compile-and-test)
  - [Usage](#usage)
    - [General usage](#general-usage)
    - [With command line arguments](#with-command-line-arguments)
- [tg.sh - Test suite generation](#tgsh---test-suite-generation)
  - [The testfile](#the-testfile)
    - [Comments](#comments)
    - [Empty lines](#empty-lines)
  - [The suitefile](#the-suitefile)
  - [Generated tests](#generated-tests)
  - [Usage](#usage-1)
    - [General usage](#general-usage-1)
    - [Specify the target directory](#specify-the-target-directory)
    - [Use a custom testfile](#use-a-custom-testfile)
    - [Use a custom test name prefix](#use-a-custom-test-name-prefix)
    - [Specify the suitefile name](#specify-the-suitefile-name)
    - [Zip your test suite](#zip-your-test-suite)
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

This is a bash script for generating test suites from a testfile (default: `tests.txt`) containing alternating inputs and outputs separated by empty lines.

### The testfile

The testfile (default: `tests.txt`) should be located in the same directory as `tg.sh`. It consists of blocks of text separated by exactly one newline. Each block represents a test file to generate, alternating between input and output files; the first block corresponds to `t0.in`, the second corresponds to `t0.out`, the third corresponds to `t1.in`, etc. Your testfile should contain an even number of blocks, or else the last test will be missing an .out file.

The example testfile below is for a program that reads input integers `n` and prints the first `n` terms of the Fibonacci sequence:

```
3
6

1 1 2
1 1 2 3 5 8

10
9
8

1 1 2 3 5 8 13 21 34 55
1 1 2 3 5 8 13 21 34
1 1 2 3 5 8 13 21

...
```

#### Comments

Any line that begins with `#` will be ignored by the generator. This allows you to include **single-line** comments:

```
# Powers of 2 - t0.in
2
4
8

# t0.out
1 1
1 1 2 3
1 1 2 3 5 8 13 21

# Powers of 3 - t1.in
3
9

# t1.out
1 1 2
1 1 2 3 5 8 13 21 34 55

...
```

#### Empty lines

Empty lines between blocks in the testfile tells `tg.sh` to generate a new file. If you want to insert an empty line in the middle of a block, any line that contains exactly one backslash followed by one tilde `\~` will tell the script to insert an empty line at that position in the generated test file. It is safe to put `\~` at the beginning or end of any block.

### The suitefile

`tg.sh` generates tests consisting of one `.in` and one `.out` file. The name of each test (e.g. `t0`, `t1`, `t2`) is recorded in a suitefile that is generated in the target directory.

By default, the suitefile is named `suite.txt`. You can change this by setting the `--suitefile` flag.

### Generated tests

Each block in the testfile is used to generate an input `.in` or output `.out` file. The files are generated in a target directory inside the current directory. By default, this directory is called `tests`. You can specify another (relative) target directory by setting the `--target` flag.

The default format for the generated files is `t[NUMBER].in` and `t[NUMBER].out`. You can change the prefix (e.g. `q2t[NUMBER].in`) of the generated files by setting the `--prefix` flag.

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

**WARNING:** The target directory is cleared on each run, so make sure to specify a directory meant specifically for containing tests.

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

The code in `tg.sh` that reads the testfile and constructs an array using empty lines as delimiters borrows a portion of the code provided by [that other guy](http://stackoverflow.com/users/1899640/that-other-guy) in an answer to [this Stack Overflow question](http://stackoverflow.com/questions/18539369/split-text-file-into-array-based-on-an-empty-line-or-any-non-used-character).

