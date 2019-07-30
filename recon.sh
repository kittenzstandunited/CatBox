#!/bin/bash
main()
{
date=$(date +'%m%d%Y_%H%M')
read -p "RHOST: " rhost
mkdir ~/$rhost
echo
read -p "Rate [Default 2000]: " rate
rate=${rate:-2000}
echo
read -p "TCP Port Range [Default All]: " tcpports
tcpports=${tcpports:-1-65535}
echo
read -p "Do you want to scan UDP ports[N/Y]?: " udpanswer
echo
read -p "What interface do you want to listen on?:" massint
echo
_logic_udpanswer
_logic_masscan
_logic_smbclient
}

_masscan()
{
  masscan=$(masscan -p$tcpports --rate=$rate $rhost --wait 5 -e $massint| sed -n 's/.* port \([^ ]*\).*/\1/p' | cut -f1 -d"/" | tr '\n' ',' | tee ~/$rhost/masscan$date.txt)
}
_masscan_udp()
{
  masscan=$(masscan -p$tcpports,U:$udpports --rate=$rate $rhost --wait 5 -e $massint| sed -n 's/.* port \([^ ]*\).*/\1/p' | cut -f1 -d"/" | tr '\n' ','| tee ~/$rhost/masscan$date.txt)
}
_nmap()
{
  nmap=$(nmap -oN ~/$rhost/nmap$date.txt -p$masscan -sV -sC $rhost)
}
_nmap_udp()
{
  nmap=$(nmap -oN ~/$rhost/nmap$date.txt -p$masscan -sV -sC $rhost)
}
_nikto()
{
  nikto=$(nikto -output ~/$rhost/nikto$date.txt -host $rhost)
}
_nikto_8080()
{
  nikto=$(nikto -output ~/$rhost/nikto$date.txt -host $rhost -p 8080)
}
_gobuster()
{
  gobuster=$(gobuster dir -u http://$rhost -o ~/$rhost/gobuster$date.txt -w /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt -t 30)
}
_gobuster_8080()
{
  gobuster=$(gobuster dir -u http://$rhost:8080 -w /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt -o ~/$rhost/gobuster$date.txt -t 30)
}
_smbclient()
{
  smbclient=$(smbclient -L $rhost | tee ~/$rhost/gobuster$date.txt)
}


_logic_udpanswer()
{
  shopt -s nocasematch
  if [[ $udpanswer == "y" ]];then
  read -p "UDP Port Range [Default All]: " udpports
  udpports=${udpports:-1-65535}
  _masscan_udp
  _nmap_udp
  elif [[ $udpanswer == "n" ]]; then
  _masscan
  _nmap
  fi
}
_logic_masscan()
{
  if [[ $masscan == "80,"* || $masscan == *",80" || $masscan == "80" || $masscan == *",80,"* ]];then
  _gobuster
  _nikto
  elif [[ $masscan == "8080,"* || $masscan == *",8080" || $masscan == "8080" || $masscan == *"80,"* ]];then
  _gobuster_8080
  _nikto_8080
  fi
}
_logic_smbclient()
{
  if [[ $masscan == "445,"* || $masscan == *",445" || $masscan == "445" || $masscan == *",445,"* ]];then
  _smbclient
  fi
}

main


