#!/usr/bin/env python
#
# fastq_demultiplex_F4N8I_qc version: 0.1 (4/12/2017)
# Check undetermined indexes for demultiplex paired FASTQ files, by forward read 4N + 8 index bases
#
import sys, re, os, getopt
import happyfile

dict_index_count = {}
dict_is_index = {}
count_total = 0
count_index = 0

def xprint_err(s):
    sys.stderr.write(str(s) + '\n')

def xprint_out(s):
    sys.stdout.write(str(s) + '\n')

        
def read_index_file(index_file):
    global dict_is_index

    in_handle = happyfile.hopen_or_else(index_file)
    xprint_err("reading file: " + index_file)

    while 1:
        line = in_handle.readline()
        if not line:
            break
        line = line.rstrip()
        cols = line.split('\t')
        dict_is_index[cols[0]] = True
        xprint_err("found: " + cols[0])

def read_fastq(fastq_file):
    global dict_index_count
    global count_total
    global count_index

    in_handle = happyfile.hopen_or_else(fastq_file)
    xprint_err("reading file: " + fastq_file)

    rnum = 1
    while 1:
        line = in_handle.readline()
        if not line:
            break
        line = line.rstrip()
        if rnum == 2:
            idx = line[4:12]
            dict_index_count[idx] = dict_index_count.get(idx, 0) + 1
            count_total += 1
            if dict_is_index.get(idx, False):
            	count_index += 1
        rnum += 1
        if rnum > 4:
            rnum = 1

def print_results():
	global dict_is_index
	global dict_index_count
	global count_total
	global count_index

	xprint_out("Indexes:")
	for idx in sorted(dict_is_index, key=dict_index_count.get(0), reverse=True):
		xprint_out(idx + '\t' + str(dict_index_count.get(idx, 0)))

	xprint_out('\n' + "Top 20 undetermined indexes:")
	count_not_index = 0
	for idx in sorted(dict_index_count, key=dict_index_count.get, reverse=True):
		if not dict_is_index.get(idx, False):
			if count_not_index < 20:
				xprint_out(str(idx) + "\t" + str(dict_index_count.get(idx, 0)))
			count_not_index += 1
		
	xprint_out('\n' + "Total sequences: " + str(count_total))
	xprint_out("Indexed sequences: " + str(count_index))

###

def main(argv):
    if len(argv) > 1:
        read_index_file(argv[1])
        for file in argv[2:]:
            read_fastq(file)
        print_results()
        
    else:
        xprint_err("Usage: " + os.path.basename(argv[0]) + " [index file] [fastq file(s)...]")

if __name__ == "__main__":
    main(sys.argv)
