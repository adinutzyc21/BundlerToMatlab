#!/usr/bin/python

import sys,getopt

# First, split the bundle.out file (found in the Bundler directory at
# /bundle) into two separate files. Name the first half camfile.txt and the
# second half ptsfile0.txt. Then run this python code on the ptsfile0.txt to make it
# importable into matlab:

args=sys.argv
if len(args)==1:
	process='.'
else:
	process=str(args[1])

ptsf0 = open(process+'/ptsfile0.txt','r')
ptsf = open(process+'/ptsfile.txt','w')

my_file = []
with ptsf0 as fi:
    for i, row in enumerate(fi):
        if (i + 1) % 3 > 0:
            my_file.append(row)
        else:
            my_file.append(' '.join(row.split(" ")[1:2]) + ', ')
            my_file.append(' '.join(row.split(" ")[3:5]) + '\n')                  
    ptsf.write("".join(my_file))

ptsf.close()
ptsf0.close()


#If I recall correctly, this is throwing out a fair amount of the data. 
#Like, it's just grabbing the first XYZ set for each line that has a bunch of XYZ sets. 
#That was enough for getting camera locations, but I just want to be sure you know that I'm throwing all that out.
