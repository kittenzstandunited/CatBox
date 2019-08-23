#!/usr/bin/python3
from subprocess import check_output
import datetime

def main():
    grab_input()
    now = datetime.datetime.now()
    ports = masscan(rhost,tports,rate).rstrip()
    g_worldlist = "/usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt"
    date = now.strftime("%y_%m_%d_%H_%M")
    nmap(ports,rhost,date)
    nikto(rhost)

def masscan(a,b,c):
    masscan = check_output(["masscan "+a+" -p "+b+" --rate "+c+" --wait 0  | awk \'{print $4}\' | cut -f1 -d\"/\""],shell=True).decode("utf-8")
    return masscan

def nmap(a,b,c):
    nmap = check_output(["nmap -oN ~/namp_"+a+"_"c+".txt -sC -T5 -p "+a+" "+b+""],shell=True).decode("utf-8")
    print(nmap)

def nikto(a):
    nikto = check_output(["nikto -output -host "+a+""],shell=True).decode("utf-8")

#def gobuster(a)
#    gobuster = (["gobuster dir -u http://$rhost -o ~/$rhost/gobuster$date.txt -w"])


def grab_input():
    global rhost
    global tports
    global rate
    rhost = input("IP to Scan: ")
    tports = input(("Which TCP ports do you want to scan?: ") or 1-65535)
    rate = input(("What rate do you want to run Masscan?: ") or 50)

main()