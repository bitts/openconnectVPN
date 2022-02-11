#!/bin/bash

# This script connects the computer to a vpn server using openconnect without pain

prog_name=$(basename $0)

# CHANGE YOUR_VPN_SERVER_DOMAIN to the VPN server you know like example.com
domain=vpn.domain.com

function help {
        echo "Usage: $prog_name [-c server] [-d]"
        echo
        echo "Options"
        echo "    -c, --connect <subdomain>  Connect to the specified VPN server (subdomain.domain)"
        echo "    -d, --disconnect           Disconnect the running VPN"
        echo "    -s, --status               Status Connect to VPN"
        echo
}

function connect {
        server=$domain
        echo "Connecting to $server..."
        sudo openconnect -v -b $server < ~/Documentos/vpnmakers.txt
}

function disconnect {
        echo "Disconnecting..."
        sudo pkill -SIGINT openconnect

        # Remove default gateway route rule when there is already a PPTP connection
        # Uncomment line below if your computer is connected to internet through a PPTP connection
        ip r | grep ppp0 && ip r | grep default | head -n1 | xargs sudo ip r del
}

function status {
        # ---- Define colors
        RED='\033[91m'
        GREEN='\033[92m'
        NC='\033[0m'
        
        [ $(which tmux) ] || echo "Need to install tmux..." && sudo apt install tmux
        
        echo "Checked Status..."
        result=`ps -ax | grep -c '[o]penconnect'`
        if [ $result -ne 0 ]; then
                echo -e "Status (openconnect): ${GREEN}Running${NC}. Connected to $(tmux list-sessions | grep VPN | awk {'print $1'} | tr ':' ' ' )"
        else
                echo -e "Status (openconnect): ${RED}Not running${NC}."
        fi
}
 
subcommand=$1
case $subcommand in
        "-s" | "-status")
        status
        ;;
        "" | "-h" | "--help")
        help
        ;;
        "-c" | "--connect")
        shift
        connect $@
        ;;
        "-d" | "--disconnect")
        disconnect
        ;;
        *)
        echo "Error: '$subcommand' is not a known command." >&2
        echo "       Run '$prog_name --help' for a list of known commands." >&2
        exit 1
        ;;
esac
 
