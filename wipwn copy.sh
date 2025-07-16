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

# Detect Termux environment
if [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=true
    echo -e "${YELLOW}Termux environment detected${NC}"
else
    IS_TERMUX=false
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check if we have root/sudo/tsu
check_root() {
    # Skip root check for Termux, as we'll use tsu when needed
    if [ "$IS_TERMUX" = true ]; then
        # Check if tsu/sudo is available
        if command_exists tsu; then
            echo -e "${GREEN}[+] Termux with tsu detected${NC}"
        elif command_exists sudo; then
            echo -e "${GREEN}[+] Termux with sudo detected${NC}"
        else
            echo -e "${RED}[!] Neither tsu nor sudo found. Install with: pkg install tsu -y${NC}"
            echo -e "${RED}[!] Root access is required for WIPWN to work properly${NC}"
            echo -e "${YELLOW}[*] Continuing anyway, but expect errors...${NC}"
            sleep 3
        fi
    else
        # Traditional root check for non-Termux environments
        if [ "$(id -u)" -ne 0 ]; then
            echo -e "${RED}[!] This script must be run as root${NC}"
            exit 1
        fi
    fi
}

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

# Function to execute commands with the appropriate sudo/tsu
run_command() {
    if [ "$IS_TERMUX" = true ]; then
        if command_exists tsu; then
            tsu -c "$1"
        elif command_exists sudo; then
            sudo $1
        else
            # Try without sudo/tsu as a last resort
            echo -e "${YELLOW}[!] Running without root privileges, may fail${NC}"
            $1
        fi
    else
        # Standard Linux environment
        sudo $1
    fi
}

# Function to verify wireless interface
verify_interface() {
    echo -e "${CYAN}[*] Checking interface ${INTERFACE}...${NC}"
    
    # Variable to track if we found a valid interface
    local interface_found=false
    
    # First try with ip command
    if command_exists ip; then
        # Check if interface exists
        if ! ip link show "$INTERFACE" &>/dev/null; then
            echo -e "${RED}[!] Interface $INTERFACE does not exist${NC}"
            
            # List available interfaces
            echo -e "${CYAN}Available interfaces:${NC}"
            ip link | grep -E '^[0-9]+:' | cut -d' ' -f2 | sed 's/://g'
            
            # Ask for new interface
            echo -n -e "${GREEN}Enter correct interface name: ${NC}"
            read new_interface
            
            if [ -n "$new_interface" ]; then
                INTERFACE=$new_interface
                echo -e "${BLUE}[+] Interface set to: $INTERFACE${NC}"
                # Verify the new interface again
                if ip link show "$INTERFACE" &>/dev/null; then
                    interface_found=true
                else
                    echo -e "${RED}[!] New interface $INTERFACE still not found${NC}"
                fi
            else
                echo -e "${RED}[!] No interface provided, using default: $INTERFACE${NC}"
            fi
        else
            echo -e "${GREEN}[+] Interface $INTERFACE exists${NC}"
            interface_found=true
        fi
    # Try alternative methods if ip command not available
    elif command_exists ifconfig; then
        if ! ifconfig "$INTERFACE" &>/dev/null; then
            echo -e "${RED}[!] Interface $INTERFACE does not exist${NC}"
            echo -e "${CYAN}Available interfaces:${NC}"
            ifconfig | grep -E '^[a-zA-Z0-9]+:' | cut -d':' -f1
            
            echo -n -e "${GREEN}Enter correct interface name: ${NC}"
            read new_interface
            
            if [ -n "$new_interface" ]; then
                INTERFACE=$new_interface
                echo -e "${BLUE}[+] Interface set to: $INTERFACE${NC}"
                # Verify the new interface again
                if ifconfig "$INTERFACE" &>/dev/null; then
                    interface_found=true
                else
                    echo -e "${RED}[!] New interface $INTERFACE still not found${NC}"
                fi
            else
                echo -e "${RED}[!] No interface provided, using default: $INTERFACE${NC}"
            fi
        else
            echo -e "${GREEN}[+] Interface $INTERFACE exists${NC}"
            interface_found=true
        fi
    # For Termux, try different methods
    elif [ "$IS_TERMUX" = true ]; then
        echo -e "${YELLOW}[!] Standard network commands not found. Using Termux-specific checks${NC}"
        if [ -d "/sys/class/net/$INTERFACE" ]; then
            echo -e "${GREEN}[+] Interface $INTERFACE exists${NC}"
            interface_found=true
        else
            echo -e "${RED}[!] Interface $INTERFACE does not exist${NC}"
            echo -e "${CYAN}Available interfaces:${NC}"
            ls /sys/class/net/
            
            echo -n -e "${GREEN}Enter correct interface name: ${NC}"
            read new_interface
            
            if [ -n "$new_interface" ]; then
                INTERFACE=$new_interface
                echo -e "${BLUE}[+] Interface set to: $INTERFACE${NC}"
                # Verify the new interface again
                if [ -d "/sys/class/net/$INTERFACE" ]; then
                    interface_found=true
                else
                    echo -e "${RED}[!] New interface $INTERFACE still not found${NC}"
                fi
            else
                echo -e "${RED}[!] No interface provided, using default: $INTERFACE${NC}"
            fi
        fi
    else
        # Fallback to checking /sys/class/net directly
        if [ -d "/sys/class/net/$INTERFACE" ]; then
            echo -e "${GREEN}[+] Interface $INTERFACE exists${NC}"
            interface_found=true
        else
            echo -e "${RED}[!] Interface $INTERFACE does not exist${NC}"
            echo -e "${CYAN}Available interfaces:${NC}"
            ls /sys/class/net/ 2>/dev/null || echo -e "${RED}[!] Could not list interfaces${NC}"
            
            echo -n -e "${GREEN}Enter correct interface name: ${NC}"
            read new_interface
            
            if [ -n "$new_interface" ]; then
                INTERFACE=$new_interface
                echo -e "${BLUE}[+] Interface set to: $INTERFACE${NC}"
                # Verify the new interface again
                if [ -d "/sys/class/net/$INTERFACE" ]; then
                    interface_found=true
                else
                    echo -e "${RED}[!] New interface $INTERFACE still not found${NC}"
                fi
            else
                echo -e "${RED}[!] No interface provided, using default: $INTERFACE${NC}"
            fi
        fi
    fi
    
    # If no valid interface was found, return failure
    if [ "$interface_found" != true ]; then
        echo -e "${RED}[!] Error: Could not find valid wireless interface${NC}"
        echo -e "${YELLOW}[*] Please make sure your WiFi adapter is properly connected${NC}"
        echo -e "${YELLOW}[*] If using Termux, ensure WiFi permissions are granted${NC}"
        return 1
    fi
    
    # Try to enable monitor mode (might fail if not supported)
    echo -e "${YELLOW}[*] Attempting to verify $INTERFACE capability...${NC}"
    
    # Try to bring interface up if it's down
    run_command "ip link set $INTERFACE up 2>/dev/null"
    sleep 1
    
    return 0
}

# Function to select wireless interface
select_interface() {
    echo -e "${CYAN}[*] Available interfaces:${NC}"
    
    # Use an array to store found interfaces
    declare -a found_interfaces
    
    # Try multiple methods to list interfaces
    if command_exists iw && iw dev | grep -q Interface; then
        # Get wireless interfaces using iw
        echo -e "${CYAN}[+] Wireless interfaces (iw):${NC}"
        while read -r interface; do
            found_interfaces+=("$interface")
            echo -e "  ${GREEN}→ $interface${NC}"
        done < <(iw dev | grep Interface | awk '{print $2}')
    fi
    
    if command_exists iwconfig; then
        # Get wireless interfaces using iwconfig
        echo -e "${CYAN}[+] Wireless interfaces (iwconfig):${NC}"
        while read -r interface; do
            # Only add if not already in array
            if [[ ! " ${found_interfaces[@]} " =~ " ${interface} " ]]; then
                found_interfaces+=("$interface")
                echo -e "  ${GREEN}→ $interface${NC}"
            fi
        done < <(iwconfig 2>/dev/null | grep -v "no wireless extensions" | grep -E '^[a-zA-Z0-9]+' | cut -d' ' -f1)
    fi
    
    # Show all interfaces as fallback
    echo -e "${CYAN}[+] All network interfaces:${NC}"
    if command_exists ip; then
        ip -br link show | awk '{print $1}' | while read -r interface; do
            # Only add if not already in array
            if [[ ! " ${found_interfaces[@]} " =~ " ${interface} " ]]; then
                found_interfaces+=("$interface")
                echo -e "  ${YELLOW}→ $interface${NC}"
            fi
        done
    elif [ -d "/sys/class/net/" ]; then
        for interface in /sys/class/net/*; do
            interface=$(basename "$interface")
            # Only add if not already in array
            if [[ ! " ${found_interfaces[@]} " =~ " ${interface} " ]]; then
                found_interfaces+=("$interface")
                echo -e "  ${YELLOW}→ $interface${NC}"
            fi
        done
    elif command_exists ifconfig; then
        ifconfig -a | grep -E '^[a-zA-Z0-9]+:' | cut -d':' -f1 | while read -r interface; do
            # Only add if not already in array
            if [[ ! " ${found_interfaces[@]} " =~ " ${interface} " ]]; then
                found_interfaces+=("$interface")
                echo -e "  ${YELLOW}→ $interface${NC}"
            fi
        done
    fi
    
    # Special check for Termux
    if [ "$IS_TERMUX" = true ]; then
        echo -e "${CYAN}[+] Termux may require additional setup for wireless interfaces${NC}"
        echo -e "${YELLOW}[*] Make sure you have granted WiFi permissions to Termux${NC}"
        if [ -e "/dev/wlan0" ]; then
            echo -e "${GREEN}[+] Found /dev/wlan0 device${NC}"
        fi
    fi
    
    echo
    echo -e "${YELLOW}Current interface: $INTERFACE${NC}"
    echo -n -e "${GREEN}Enter interface name (leave blank to keep current): ${NC}"
    read new_interface
    if [ ! -z "$new_interface" ]; then
        INTERFACE=$new_interface
        echo -e "${BLUE}[+] Interface set to: $INTERFACE${NC}"
    fi
    
    # Verify the selected interface
    if ! verify_interface; then
        echo -e "${RED}[!] Failed to verify interface. Please try again.${NC}"
        echo -e "${YELLOW}[*] Press Enter to continue...${NC}"
        read
    fi
}

# Function to scan networks
scan_networks() {
    echo -e "${CYAN}[*] Scanning for networks with WPS...${NC}"
    echo -e "${YELLOW}[!] This might take some time...${NC}"
    
    # Verify interface first
    if ! verify_interface; then
        echo -e "${RED}[!] Error: can not find device wifi${NC}"
        echo -e "${YELLOW}[*] Please select a valid wireless interface first (Option 1)${NC}"
        echo -e "${YELLOW}[*] Press Enter to continue...${NC}"
        read
        return 1
    fi
    
    run_command "python $CURRENT_DIR/main.py -i $INTERFACE -s"
    echo -e "${GREEN}[+] Scan complete${NC}"
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to auto-attack all networks
auto_attack() {
    echo -e "${CYAN}[*] Starting automatic attack on all networks...${NC}"
    
    # Verify interface first
    if ! verify_interface; then
        echo -e "${RED}[!] Error: can not find device wifi${NC}"
        echo -e "${YELLOW}[*] Please select a valid wireless interface first (Option 1)${NC}"
        echo -e "${YELLOW}[*] Press Enter to continue...${NC}"
        read
        return 1
    fi
    
    # Check if the interface appears to be wireless
    local is_wireless=false
    
    # Try with iw command first
    if command_exists iw; then
        if iw dev "$INTERFACE" info &>/dev/null; then
            is_wireless=true
        fi
    # Try with iwconfig if iw is not available
    elif command_exists iwconfig; then
        if iwconfig "$INTERFACE" 2>&1 | grep -v "no wireless extensions" &>/dev/null; then
            is_wireless=true
        fi
    # For Termux or systems without iw/iwconfig, check if it looks like a WiFi interface
    elif [ -d "/sys/class/net/$INTERFACE/wireless" ] || [ -d "/sys/class/net/$INTERFACE/phy80211" ]; then
        is_wireless=true
    # Last resort: check if name starts with typical wireless prefixes
    elif [[ "$INTERFACE" == wlan* ]] || [[ "$INTERFACE" == wlp* ]] || [[ "$INTERFACE" == wlx* ]]; then
        is_wireless=true
    fi
    
    if [ "$is_wireless" != true ]; then
        echo -e "${YELLOW}[!] Warning: $INTERFACE might not be a wireless interface${NC}"
        echo -n -e "${GREEN}Continue anyway? (y/n): ${NC}"
        read confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    echo -e "${YELLOW}[*] Using interface: $INTERFACE${NC}"
    echo -e "${YELLOW}[*] Make sure your device supports monitor mode${NC}"
    
    run_command "python $CURRENT_DIR/main.py -i $INTERFACE -K"
}

# Function to attack specific BSSID
attack_specific() {
    echo -n -e "${GREEN}Enter target BSSID (MAC address): ${NC}"
    read BSSID
    if [ ! -z "$BSSID" ]; then
        echo -e "${CYAN}[*] Starting attack on $BSSID...${NC}"
        
        # Verify interface first
        if ! verify_interface; then
            echo -e "${RED}[!] Error: can not find device wifi${NC}"
            echo -e "${YELLOW}[*] Please select a valid wireless interface first (Option 1)${NC}"
            echo -e "${YELLOW}[*] Press Enter to continue...${NC}"
            read
            return 1
        fi
        
        # Validate BSSID format (basic validation)
        if [[ ! $BSSID =~ ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$ ]]; then
            echo -e "${YELLOW}[!] Warning: BSSID format looks unusual. Standard format: XX:XX:XX:XX:XX:XX${NC}"
            echo -n -e "${GREEN}Continue anyway? (y/n): ${NC}"
            read confirm
            if [[ ! $confirm =~ ^[Yy]$ ]]; then
                return
            fi
        fi
        
        run_command "python $CURRENT_DIR/main.py -i $INTERFACE -b $BSSID -K"
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
    
    # Verify interface first
    if ! verify_interface; then
        echo -e "${RED}[!] Error: can not find device wifi${NC}"
        echo -e "${YELLOW}[*] Please select a valid wireless interface first (Option 1)${NC}"
        echo -e "${YELLOW}[*] Press Enter to continue...${NC}"
        read
        return 1
    fi
    
    echo -n -e "${GREEN}Enter PIN prefix (e.g. 1234, leave blank for full bruteforce): ${NC}"
    read PIN_PREFIX
    
    if [ ! -z "$PIN_PREFIX" ]; then
        # Basic validation for PIN prefix
        if [[ ! $PIN_PREFIX =~ ^[0-9]+$ ]]; then
            echo -e "${RED}[!] PIN prefix must contain only numbers${NC}"
            return
        fi
        
        echo -e "${CYAN}[*] Starting PIN bruteforce on $BSSID with prefix $PIN_PREFIX...${NC}"
        run_command "python $CURRENT_DIR/main.py -i $INTERFACE -b $BSSID -B -p $PIN_PREFIX"
    else
        echo -e "${CYAN}[*] Starting full PIN bruteforce on $BSSID...${NC}"
        run_command "python $CURRENT_DIR/main.py -i $INTERFACE -b $BSSID -B"
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