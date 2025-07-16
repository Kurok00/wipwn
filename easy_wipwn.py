#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
WIPWN Easy Menu Interface
A user-friendly wrapper for WIPWN that enhances usability
without modifying the core functionality.
"""

import os
import sys
import subprocess
import re
from colors import *  # Import colors from the existing colors.py

# Global settings
INTERFACE = "wlan0"
BSSID = ""
PIN_PREFIX = ""
TEMP_SCAN_FILE = "scan_results.tmp"

def clear_screen():
    """Clear the terminal screen."""
    os.system('cls' if os.name == 'nt' else 'clear')

def show_banner():
    """Display the WIPWN banner."""
    clear_screen()
    print(f"{blue}██╗    ██╗██╗██████╗ ██╗    ██╗███╗   ██╗")
    print(f"██║    ██║██║██╔══██╗██║    ██║████╗  ██║")
    print(f"██║ █╗ ██║██║██████╔╝██║ █╗ ██║██╔██╗ ██║")
    print(f"██║███╗██║██║██╔═══╝ ██║███╗██║██║╚██╗██║")
    print(f"╚███╔███╔╝██║██║     ╚███╔███╔╝██║ ╚████║")
    print(f" ╚══╝╚══╝ ╚═╝╚═╝      ╚══╝╚══╝ ╚═╝  ╚═══╝{reset}")
    print(f"{green}=== WiFi Pentesting Framework ===={reset}")
    print(f"{yellow}Enhanced Python Menu Interface{reset}\n")

def check_root():
    """Check if the script is running as root."""
    if os.name != 'nt' and os.geteuid() != 0:
        print(f"{red}[!] This script must be run as root{reset}")
        sys.exit(1)

def get_wireless_interfaces():
    """Get a list of wireless interfaces."""
    interfaces = []
    
    try:
        if os.name == 'nt':  # Windows
            output = subprocess.check_output("netsh interface show interface", shell=True).decode('utf-8')
            for line in output.split('\n'):
                if "Wireless" in line:
                    match = re.search(r'(\w+)\s*$', line)
                    if match:
                        interfaces.append(match.group(1))
        else:  # Linux
            output = subprocess.check_output("iw dev | grep Interface", shell=True).decode('utf-8')
            for line in output.split('\n'):
                if line.strip():
                    match = re.search(r'Interface\s+(\w+)', line)
                    if match:
                        interfaces.append(match.group(1))
    except subprocess.CalledProcessError:
        pass
        
    return interfaces

def select_interface():
    """Select a wireless interface."""
    global INTERFACE
    
    print(f"{cyan}[*] Available wireless interfaces:{reset}")
    interfaces = get_wireless_interfaces()
    
    if not interfaces:
        print(f"{red}[!] No wireless interfaces found{reset}")
        return
        
    for i, iface in enumerate(interfaces, 1):
        print(f"{i}. {iface}")
        
    print(f"{yellow}Current interface: {INTERFACE}{reset}")
    choice = input(f"{green}Select interface (number or name, press Enter to keep current): {reset}")
    
    if choice.strip():
        try:
            if choice.isdigit() and 1 <= int(choice) <= len(interfaces):
                INTERFACE = interfaces[int(choice) - 1]
            elif choice in interfaces:
                INTERFACE = choice
        except (ValueError, IndexError):
            print(f"{red}[!] Invalid selection{reset}")
            return
            
    print(f"{blue}[+] Interface set to: {INTERFACE}{reset}")
    input("Press Enter to continue...")

def run_command(command):
    """Run a command and return output."""
    try:
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, 
                                  universal_newlines=True)
        
        # Print output in real-time
        while True:
            output = process.stdout.readline()
            if output == '' and process.poll() is not None:
                break
            if output:
                print(output.strip())
                
        return process.poll()
    except subprocess.CalledProcessError as e:
        print(f"{red}[!] Error executing command: {e}{reset}")
        return -1
    except KeyboardInterrupt:
        print(f"\n{yellow}[*] Operation cancelled by user{reset}")
        return -1

def scan_networks():
    """Scan for networks with WPS."""
    print(f"{cyan}[*] Scanning for networks with WPS...{reset}")
    print(f"{yellow}[!] This might take some time...{reset}")
    
    command = f"sudo python main.py -i {INTERFACE} -s"
    run_command(command)
    
    print(f"{green}[+] Scan complete{reset}")
    input("Press Enter to continue...")

def auto_attack():
    """Auto-attack all networks."""
    print(f"{cyan}[*] Starting automatic attack on all networks...{reset}")
    
    command = f"sudo python main.py -i {INTERFACE} -K"
    run_command(command)
    
    input("Press Enter to continue...")

def attack_specific():
    """Attack a specific BSSID."""
    global BSSID
    
    new_bssid = input(f"{green}Enter target BSSID (MAC address, format XX:XX:XX:XX:XX:XX): {reset}")
    if not new_bssid.strip():
        print(f"{red}[!] BSSID cannot be empty{reset}")
        input("Press Enter to continue...")
        return
        
    BSSID = new_bssid
    print(f"{cyan}[*] Starting attack on {BSSID}...{reset}")
    
    command = f"sudo python main.py -i {INTERFACE} -b {BSSID} -K"
    run_command(command)
    
    input("Press Enter to continue...")

def pin_bruteforce():
    """Perform PIN bruteforce attack."""
    global BSSID, PIN_PREFIX
    
    new_bssid = input(f"{green}Enter target BSSID (MAC address, current: {BSSID}): {reset}")
    if new_bssid.strip():
        BSSID = new_bssid
    
    if not BSSID:
        print(f"{red}[!] BSSID cannot be empty{reset}")
        input("Press Enter to continue...")
        return
        
    new_pin = input(f"{green}Enter PIN prefix (e.g. 1234, leave blank for full bruteforce): {reset}")
    PIN_PREFIX = new_pin
    
    if PIN_PREFIX:
        print(f"{cyan}[*] Starting PIN bruteforce on {BSSID} with prefix {PIN_PREFIX}...{reset}")
        command = f"sudo python main.py -i {INTERFACE} -b {BSSID} -B -p {PIN_PREFIX}"
    else:
        print(f"{cyan}[*] Starting full PIN bruteforce on {BSSID}...{reset}")
        command = f"sudo python main.py -i {INTERFACE} -b {BSSID} -B"
        
    run_command(command)
    
    input("Press Enter to continue...")

def show_help():
    """Show help information."""
    command = "sudo python main.py --help"
    run_command(command)
    input("Press Enter to continue...")

def advanced_options():
    """Advanced options menu."""
    while True:
        show_banner()
        print(f"{cyan}=== Advanced Options ==={reset}")
        print(f"{blue}1.{reset} Custom command execution")
        print(f"{blue}2.{reset} View saved credentials")
        print(f"{blue}3.{reset} Check vulnerable router database")
        print(f"{red}0.{reset} Back to main menu")
        
        choice = input(f"{green}Select an option: {reset}")
        
        if choice == "1":
            cmd = input(f"{green}Enter custom WIPWN command (e.g. -i wlan0 -b XX:XX:XX:XX:XX:XX -K): {reset}")
            run_command(f"sudo python main.py {cmd}")
            input("Press Enter to continue...")
        elif choice == "2":
            print(f"{cyan}[*] Saved credentials (if any):{reset}")
            try:
                with open("config.txt", "r") as f:
                    content = f.read()
                    if content.strip():
                        print(content)
                    else:
                        print(f"{yellow}No saved credentials found{reset}")
            except FileNotFoundError:
                print(f"{red}Config file not found{reset}")
            input("Press Enter to continue...")
        elif choice == "3":
            print(f"{cyan}[*] Vulnerable router models:{reset}")
            try:
                with open("vulnwsc.txt", "r") as f:
                    for line in f:
                        print(f"- {line.strip()}")
            except FileNotFoundError:
                print(f"{red}Vulnerable router database not found{reset}")
            input("Press Enter to continue...")
        elif choice == "0":
            break
        else:
            print(f"{red}Invalid option{reset}")
            input("Press Enter to continue...")

def main_menu():
    """Display the main menu and handle user input."""
    while True:
        show_banner()
        print(f"{cyan}=== Current Settings ==={reset}")
        print(f"{yellow}Interface: {green}{INTERFACE}{reset}")
        if BSSID:
            print(f"{yellow}Target BSSID: {green}{BSSID}{reset}")
        if PIN_PREFIX:
            print(f"{yellow}PIN Prefix: {green}{PIN_PREFIX}{reset}")
        print()
        
        print(f"{cyan}=== WIPWN Menu ==={reset}")
        print(f"{blue}1.{reset} Select wireless interface")
        print(f"{blue}2.{reset} Scan for WPS networks")
        print(f"{blue}3.{reset} Auto-attack all networks (Pixie Dust)")
        print(f"{blue}4.{reset} Attack specific BSSID (Pixie Dust)")
        print(f"{blue}5.{reset} PIN bruteforce attack")
        print(f"{blue}6.{reset} Show help / command options")
        print(f"{blue}7.{reset} Advanced options")
        print(f"{red}0.{reset} Exit")
        
        choice = input(f"{green}Select an option: {reset}")
        
        if choice == "1":
            select_interface()
        elif choice == "2":
            scan_networks()
        elif choice == "3":
            auto_attack()
        elif choice == "4":
            attack_specific()
        elif choice == "5":
            pin_bruteforce()
        elif choice == "6":
            show_help()
        elif choice == "7":
            advanced_options()
        elif choice == "0":
            print(f"{red}Exiting...{reset}")
            sys.exit(0)
        else:
            print(f"{red}Invalid option{reset}")
            input("Press Enter to continue...")

if __name__ == "__main__":
    try:
        check_root()
        main_menu()
    except KeyboardInterrupt:
        print(f"\n{red}Program interrupted by user. Exiting...{reset}")
        sys.exit(0)
