#!/usr/bin/env python
#
## happyfile - File open read/write functions, with automatic support for Gzip or BZip2 compression
## Created by: John McCrow (Feb. 25, 2016)
#
# 1. Basic hopen and hopen_write are happy, and thus do not complain by way of IOError exceptions.
#    Instead they return None, in case of file not found or permission issues.
#    Otherwise they return a valid file handle.
#
# 2. _any functions will attempt to open a base filename with added extensions of any compression method
#
# 3. _or_else functions will report a nice message to stderr upon failure to open, rather than raise exception
#
# 4. _write functions open file handles for writing, and can write compressed files directly
#

import bz2, gzip, sys, re

class hCompression:
    none = 0
    gzip = 1
    gz = 1
    bzip2 = 2
    bz2 = 2

def xprint(s):
    sys.stderr.write(str(s) + '\n')
        
def hopen(infile):
    f = None
    try:
        if re.search('\.bz2$', infile):
            f = bz2.open(infile, 'rt')
        elif re.search('\.gz$', infile):
            f = gzip.open(infile, 'rt')
        else:
            f = open(infile)
    except IOError:
        return None
    return f

def hopen_any(basefile):
    for ext in '', '.gz', '.bz2':
        f = hopen(basefile + ext)
        if f:
            return f
    return None

def hopen_or_else(infile):
    f = hopen(infile)
    if f:
        return f
    else:
        xprint("Unable to open file: " + infile)
        sys.exit(2)

def hopen_or_else_any(basefile):
    f = hopen_any(basefile)
    if f:
        return f
    else:
        xprint("Unable to open file: " + basefile)
        sys.exit(2)

def hopen_write(outfile, compression=hCompression.none, level=9):
    f = None
    if not level in range(1, 10):  # compression level must be integer 1-9
        level = 9
    try:
        if compression == hCompression.bzip2:
            if not re.search('\.bz2$', outfile):
                outfile += '.bz2'
            f = bz2.BZ2File(outfile, 'w', level)
        elif compression == hCompression.gzip:
            if not re.search('\.gz$', outfile):
                outfile += '.gz'
            f = gzip.GzipFile(outfile, 'w', level)
        else:
            f = open(outfile, 'w')
    except IOError:
        return None
    return f

def hopen_write_or_else(outfile, compression=hCompression.none, level=9):
    f = hopen_write(outfile, compression, level)
    if f:
        return f
    else:
        xprint("Unable to write to file: " + outfile)
        sys.exit(2)
