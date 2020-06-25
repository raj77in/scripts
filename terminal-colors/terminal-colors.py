#!/usr/bin/python3

import os

# from pathlib import Path
import json
from pprint import pprint
import glob
import requests
import os
from bs4 import BeautifulSoup
import re

## apt install python3-pygit2
import pygit2


gitbase = "/tmp/terminal-colors/"
outdir = "/tmp/terminal-colors/out/"


extra_themes = (
    "https://web.archive.org/web/20090130061234/http://phraktured.net/terminal-colors/"
    ## https://github.com/mbadolato/iTerm2-Color-Schemes
)


def git_clone():
    gitdir = {
        "Gogh": "https://github.com/Mayccoll/Gogh/",
        "terminal.sexy": "https://github.com/stayradiated/terminal.sexy",
    }
    for repo in gitdir.keys():
        if os.path.exists(gitbase + repo):
            None
        else:
            pygit2.clone_repository(
                gitdir[repo],
                gitbase + repo,
                bare=False,
                repository=None,
                remote=None,
                checkout_branch=None,
                callbacks=None,
            )


gitpaths = {"terminal.sexy": "/dist/schemes", "Gogh": "themes"}


def mk_term_colors():
    html = requests.get(extra_themes)
    parsed_html = BeautifulSoup(html.text, "html.parser")
    vals = parsed_html.body.findAll(["img", "code"])
    for i in vals:
        print("-----------------------------")
        if "img" in i.name:
            print(i.attrs)
            print(i["title"])
            fname = i["title"].replace(" ", "_") + ".xdefaults"
            print(fname)
        if "code" in i.name:
            ofptr = open(outdir + "terminal-colors/" + fname, "w")
            ofptr.writelines(i)
            ofptr.close()


def parse_json(infile):
    return json.loads(open(infile).read())


def mk_terminal_sexy():

    print(gitbase + "/terminal.sexy/" + gitpaths["terminal.sexy"] + "/**/*.json")
    for infile in glob.glob(
        gitbase + "/terminal.sexy/" + gitpaths["terminal.sexy"] + "/**/*.json"
    ):
        if "index.json" in infile:
            continue
        print(infile)
        d = parse_json(infile)
        # pprint(d)
        outfile = infile.split("/")[-1].replace(".json", ".xdefaults")
        print(outfile)

        ofptr = open(outdir + "terminal.sexy/" + outfile, "w")

        ofptr.writelines("*foreground:\t" + d["foreground"] + "\n")
        # ofptr.writelines("URxvt.foreground:\t" + d["foreground"] + "\n")
        ofptr.writelines("*background:\t" + d["background"] + "\n")
        # ofptr.writelines("URxvt.tintColor:\t" + d["background"] + "\n")
        for i in range(7):
            col = d["color"][i]
            # print ("aka color"+str(i)+"\t"+col)
            ofptr.writelines("\n!! Color - " + str(i) + "\n")
            ofptr.writelines("*color" + str(i) + ":\t" + col + "\n")
            ofptr.writelines("*color" + str(i + 8) + ":\t" + col + "\n")
            # ofptr.writelines("URxvt.color" + str(i) + ":\t" + col + "\n")
            # ofptr.writelines("URxvt.color" + str(i + 8) + ":\t" + col + "\n")

        ofptr.writelines("\n! vim:ft=dosini\n")
        ofptr.close()


def mk_gogh():
    print(gitbase + "/Gogh/" + gitpaths["Gogh"] + "/*.sh")
    for infile in glob.glob(gitbase + "/Gogh/" + gitpaths["Gogh"] + "//*.sh"):
        print(infile)
        content = open(infile, "r").read()
        # print(content)

        match = re.findall(r".*COLOR.*=\"(.*)\"", content, re.MULTILINE)
        outfile = (os.path.basename(infile)).replace(".sh", ".xdefaults")
        ofptr = open(outdir + "gogh/" + outfile, "w")
        if len(match) > 15:
            print(match)
            for i in range(0, 16):
                if "FOREGROUND" in match[i - 1]:
                    match[i - 1] = match[16]
                ofptr.writelines("*color" + str(i) + ":\t" + match[i - 1] + "\n")
        ofptr.writelines("\n*foreground:\t" + match[1])
        ofptr.writelines("\n*background:\t" + match[5])
        ofptr.writelines("\n! vim:ft=dosini\n")
        ofptr.close()


def init():
    print("mkdir -p " + outdir + "terminal.sexy")
    os.system("mkdir -p " + outdir + "terminal.sexy/")
    print("mkdir -p " + outdir + "terminal-colors")
    os.system("mkdir -p " + outdir + "terminal-colors/")
    print("mkdir -p " + outdir + "gogh")
    os.system("mkdir -p " + outdir + "gogh/")


init()
git_clone()
mk_terminal_sexy()
mk_gogh()
mk_term_colors()
