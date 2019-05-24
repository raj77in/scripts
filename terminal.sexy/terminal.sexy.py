#!/usr/bin/python3

import os
# from pathlib import Path
import json
from pprint import pprint
import glob
import os

# Clone https://github.com/stayradiated/terminal.sexy
gitdir = '/tmp/terminal.sexy/dist/schemes'


def parse_json(infile):
    return json.loads(open(infile).read())


for infile in glob.glob(gitdir+'/**/*.json'):
    print(infile)
    d = parse_json(infile)
    # pprint(d)
    outfile = infile.split("/")[-1].replace(".json", ".xdefaults")
    print (outfile)

    ofptr = open("out/"+outfile, 'w')

    ofptr.writelines("*.foreground:\t"+d['foreground']+"\n")
    ofptr.writelines("URxvt.foreground:\t"+d['foreground']+"\n")
    ofptr.writelines("*.background:\t"+d['background']+"\n")
    ofptr.writelines("URxvt.background:\t"+d['background']+"\n")
    for i in range(7):
        col = d['color'][i]
        # print ("aka color"+str(i)+"\t"+col)
        ofptr.writelines("\n!! Color - "+str(i)+"\n")
        ofptr.writelines("*.color"+str(i)+":\t"+col+"\n")
        ofptr.writelines("*.color"+str(i+8)+":\t"+col+"\n")
        ofptr.writelines("URxvt.color"+str(i)+":\t"+col+"\n")
        ofptr.writelines("URxvt.color"+str(i+8)+":\t"+col+"\n")

    ofptr.close()
