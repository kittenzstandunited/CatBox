#!/bin/bash
main()
{
date=$(date +'%m%d%Y_%H%M')
read -p "RHOST: " rhost
#mkdir ~/$rhost
echo
read -p "Rate [Default 2000]: " rate
rate=${rate:-2000}
echo
read -p "TCP Port Range [Default All]: " tcpports
tcpports=${tcpports:-1-65535}
echo
read -p "Do you want to scan UDP ports[N/Y]?: " udpanswer
echo
_logic_udpanswer
_logic_masscan
_logic_smbclient
}

_masscan()
{
  masscan=$(masscan -p$tcpports --rate=$rate $rhost -oG ~/$rhost/masscan$date.txt --wait 0 -e tun0| sed -n 's/.* port \([^ ]*\).*/\1/p' | cut -f1 -d"/" | tr '\n' ',')
}
_masscan_udp()
{
  masscan=$(masscan -p$tcpports,U:$udpports --rate=$rate $rhost --wait 5 -e tun0| sed -n 's/.* port \([^ ]*\).*/\1/p' | cut -f1 -d"/" | tr '\n' ',')
}
_nmap()
{
  nmap=$(nmap -p$masscan -sV -sC $rhost)
}
_nmap_udp()
{
  nmap=$(nmap -p$masscan_udp -sV -sC $rhost)
}
_nikto()
{
  nikto=$(nikto -host $rhost)
}
_nikto_8080()
{
  nikto=$(nikto -host $rhost -p 8080)
}
_gobuster()
{
  gobuster=$(gobuster dir -u http://$rhost -t 30)
}
_gobuster_8080()
{
  gobuster=$(gobuster dir -u http://$rhost:8080 -t 30)
}
_smbclient()
{
  smbclient=$(smbclient -L $rhost)
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
  if [[ $masscan == "80,"* || $masscan == *",80" || $masscan == "80" ]];then
  _nikto
  _gobuster
  elif [[ $masscan == "8080,"* || $masscan == *",8080" || $masscam == "8080" ]];then
  _nikto_8080
  _gobuster_8080
  fi
}
_logic_smbclient()
{
  if [[ $masc == "445,"* || $masc == *",445" || $masc == "445" ]];then
  _smbclient
  fi
}

main


