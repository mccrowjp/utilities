import time, sys

def print_no_nl(s):
	sys.stderr.write(str(s))
	sys.stderr.flush()
    
def line_erase():
	print_no_nl("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b")

def draw_progress(curr_x, max_x, start_time):
	curr_time = time.time()
	p = int(1000.0*curr_x/max_x)/10;
	n = int(p/5)
	es = -1
	
	if curr_x > max_x:
		curr_x = max_x
	
	if curr_x > 0:
	    if curr_x == max_x:
	        # total time taken
	        es = int(curr_time-start_time)
	    else:
	        # estimated time remaining
    		es = int((curr_time-start_time) * ((max_x-curr_x)/curr_x))

	es_str = ""
	if es > 0:
		if es > 7200:
			es_str = str(int(es/3600)) + "hr."
		elif es > 120:
			es_str = str(int(es/60)) + "min."
		else:
			es_str = str(int(es)) + "sec."
	
	line_erase()
	print_no_nl('[' + '*'*n + '.'*(20-n) + "] " + str(int(curr_x)) + '/' + str(int(max_x)) + " " + str(round(p,1)) + "% " + es_str + "      ")

def erase_progress():
	line_erase()
	print_no_nl(" " * 79)
	line_erase()
