#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
WIPWN - Giao Diện Menu Đơn Giản
Một wrapper thân thiện với người dùng cho WIPWN,
nâng cao khả năng sử dụng mà không thay đổi chức năng cốt lõi.
"""

import os
import sys
import subprocess
import re
from colors import *  # Import colors từ file colors.py có sẵn

# Cài đặt chung
INTERFACE = "wlan0"
BSSID = ""
PIN_PREFIX = ""
TEMP_SCAN_FILE = "scan_results.tmp"

def clear_screen():
    """Xóa màn hình terminal."""
    os.system('cls' if os.name == 'nt' else 'clear')

def show_banner():
    """Hiển thị banner WIPWN."""
    clear_screen()
    print(f"{blue}██╗    ██╗██╗██████╗ ██╗    ██╗███╗   ██╗")
    print(f"██║    ██║██║██╔══██╗██║    ██║████╗  ██║")
    print(f"██║ █╗ ██║██║██████╔╝██║ █╗ ██║██╔██╗ ██║")
    print(f"██║███╗██║██║██╔═══╝ ██║███╗██║██║╚██╗██║")
    print(f"╚███╔███╔╝██║██║     ╚███╔███╔╝██║ ╚████║")
    print(f" ╚══╝╚══╝ ╚═╝╚═╝      ╚══╝╚══╝ ╚═╝  ╚═══╝{reset}")
    print(f"{green}=== Tool Kiểm Tra Bảo Mật WiFi ===={reset}")
    print(f"{yellow}Giao Diện Python Nâng Cao{reset}\n")

def check_root():
    """Kiểm tra xem script có đang chạy với quyền root không."""
    if os.name != 'nt' and os.geteuid() != 0:
        print(f"{red}[!] Script này phải được chạy với quyền root{reset}")
        sys.exit(1)

def get_wireless_interfaces():
    """Lấy danh sách các card mạng không dây."""
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
    """Chọn card mạng không dây."""
    global INTERFACE
    
    print(f"{cyan}[*] Card mạng không dây có sẵn:{reset}")
    interfaces = get_wireless_interfaces()
    
    if not interfaces:
        print(f"{red}[!] Không tìm thấy card mạng không dây nào{reset}")
        return
        
    for i, iface in enumerate(interfaces, 1):
        print(f"{i}. {iface}")
        
    print(f"{yellow}Card mạng hiện tại: {INTERFACE}{reset}")
    choice = input(f"{green}Chọn card mạng (số hoặc tên, Enter để giữ nguyên): {reset}")
    
    if choice.strip():
        try:
            if choice.isdigit() and 1 <= int(choice) <= len(interfaces):
                INTERFACE = interfaces[int(choice) - 1]
            elif choice in interfaces:
                INTERFACE = choice
        except (ValueError, IndexError):
            print(f"{red}[!] Lựa chọn không hợp lệ{reset}")
            return
            
    print(f"{blue}[+] Đã chọn card mạng: {INTERFACE}{reset}")
    input("Nhấn Enter để tiếp tục...")

def run_command(command):
    """Chạy một lệnh và trả về kết quả."""
    try:
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, 
                                  universal_newlines=True)
        
        # In kết quả theo thời gian thực
        while True:
            output = process.stdout.readline()
            if output == '' and process.poll() is not None:
                break
            if output:
                print(output.strip())
                
        return process.poll()
    except subprocess.CalledProcessError as e:
        print(f"{red}[!] Lỗi khi thực thi lệnh: {e}{reset}")
        return -1
    except KeyboardInterrupt:
        print(f"\n{yellow}[*] Người dùng đã hủy bỏ thao tác{reset}")
        return -1

def scan_networks():
    """Quét các mạng có sẵn với WPS."""
    print(f"{cyan}[*] Đang quét các mạng có sẵn với WPS...{reset}")
    print(f"{yellow}[!] Điều này có thể mất một thời gian...{reset}")
    
    command = f"sudo python main.py -i {INTERFACE} -s"
    run_command(command)
    
    print(f"{green}[+] Quá trình quét hoàn tất{reset}")
    input("Nhấn Enter để tiếp tục...")

def auto_attack():
    """Tấn công tự động tất cả các mạng."""
    print(f"{cyan}[*] Bắt đầu tấn công tự động vào tất cả các mạng...{reset}")
    
    command = f"sudo python main.py -i {INTERFACE} -K"
    run_command(command)
    
    input("Nhấn Enter để tiếp tục...")

def attack_specific():
    """Tấn công một BSSID cụ thể."""
    global BSSID
    
    new_bssid = input(f"{green}Nhập BSSID mục tiêu (địa chỉ MAC, định dạng XX:XX:XX:XX:XX:XX): {reset}")
    if not new_bssid.strip():
        print(f"{red}[!] BSSID không được để trống{reset}")
        input("Nhấn Enter để tiếp tục...")
        return
        
    BSSID = new_bssid
    print(f"{cyan}[*] Bắt đầu tấn công vào {BSSID}...{reset}")
    
    command = f"sudo python main.py -i {INTERFACE} -b {BSSID} -K"
    run_command(command)
    
    input("Nhấn Enter để tiếp tục...")

def pin_bruteforce():
    """Thực hiện tấn công bruteforce PIN."""
    global BSSID, PIN_PREFIX
    
    new_bssid = input(f"{green}Nhập BSSID mục tiêu (địa chỉ MAC, hiện tại: {BSSID}): {reset}")
    if new_bssid.strip():
        BSSID = new_bssid
    
    if not BSSID:
        print(f"{red}[!] BSSID không được để trống{reset}")
        input("Nhấn Enter để tiếp tục...")
        return
        
    new_pin = input(f"{green}Nhập tiền tố PIN (ví dụ: 1234, để trống để bruteforce toàn bộ): {reset}")
    PIN_PREFIX = new_pin
    
    if PIN_PREFIX:
        print(f"{cyan}[*] Bắt đầu tấn công bruteforce PIN vào {BSSID} với tiền tố {PIN_PREFIX}...{reset}")
        command = f"sudo python main.py -i {INTERFACE} -b {BSSID} -B -p {PIN_PREFIX}"
    else:
        print(f"{cyan}[*] Bắt đầu tấn công bruteforce toàn bộ PIN vào {BSSID}...{reset}")
        command = f"sudo python main.py -i {INTERFACE} -b {BSSID} -B"
        
    run_command(command)
    
    input("Nhấn Enter để tiếp tục...")

def show_help():
    """Hiển thị thông tin trợ giúp."""
    command = "sudo python main.py --help"
    run_command(command)
    input("Nhấn Enter để tiếp tục...")

def advanced_options():
    """Menu tùy chọn nâng cao."""
    while True:
        show_banner()
        print(f"{cyan}=== Tùy Chọn Nâng Cao ==={reset}")
        print(f"{blue}1.{reset} Thực thi lệnh tùy chỉnh")
        print(f"{blue}2.{reset} Xem thông tin đăng nhập đã lưu")
        print(f"{blue}3.{reset} Kiểm tra cơ sở dữ liệu router dễ bị tấn công")
        print(f"{red}0.{reset} Quay lại menu chính")
        
        choice = input(f"{green}Chọn một tùy chọn: {reset}")
        
        if choice == "1":
            cmd = input(f"{green}Nhập lệnh WIPWN tùy chỉnh (ví dụ: -i wlan0 -b XX:XX:XX:XX:XX:XX -K): {reset}")
            run_command(f"sudo python main.py {cmd}")
            input("Nhấn Enter để tiếp tục...")
        elif choice == "2":
            print(f"{cyan}[*] Thông tin đăng nhập đã lưu (nếu có):{reset}")
            try:
                with open("config.txt", "r") as f:
                    content = f.read()
                    if content.strip():
                        print(content)
                    else:
                        print(f"{yellow}Không tìm thấy thông tin đăng nhập đã lưu{reset}")
            except FileNotFoundError:
                print(f"{red}Không tìm thấy file cấu hình{reset}")
            input("Nhấn Enter để tiếp tục...")
        elif choice == "3":
            print(f"{cyan}[*] Các mẫu router dễ bị tấn công:{reset}")
            try:
                with open("vulnwsc.txt", "r") as f:
                    for line in f:
                        print(f"- {line.strip()}")
            except FileNotFoundError:
                print(f"{red}Không tìm thấy cơ sở dữ liệu router dễ bị tấn công{reset}")
            input("Nhấn Enter để tiếp tục...")
        elif choice == "0":
            break
        else:
            print(f"{red}Tùy chọn không hợp lệ{reset}")
            input("Nhấn Enter để tiếp tục...")

def main_menu():
    """Hiển thị menu chính và xử lý đầu vào của người dùng."""
    while True:
        show_banner()
        print(f"{cyan}=== Cài Đặt Hiện Tại ==={reset}")
        print(f"{yellow}Card mạng: {green}{INTERFACE}{reset}")
        if BSSID:
            print(f"{yellow}BSSID mục tiêu: {green}{BSSID}{reset}")
        if PIN_PREFIX:
            print(f"{yellow}Tiền tố PIN: {green}{PIN_PREFIX}{reset}")
        print()
        
        print(f"{cyan}=== Menu WIPWN ==={reset}")
        print(f"{blue}1.{reset} Chọn card mạng không dây")
        print(f"{blue}2.{reset} Quét các mạng WPS")
        print(f"{blue}3.{reset} Tấn công tự động tất cả các mạng (Pixie Dust)")
        print(f"{blue}4.{reset} Tấn công BSSID cụ thể (Pixie Dust)")
        print(f"{blue}5.{reset} Tấn công bruteforce PIN")
        print(f"{blue}6.{reset} Hiển thị trợ giúp / tùy chọn lệnh")
        print(f"{blue}7.{reset} Tùy chọn nâng cao")
        print(f"{red}0.{reset} Thoát")
        
        choice = input(f"{green}Chọn một tùy chọn: {reset}")
        
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
            print(f"{red}Đang thoát...{reset}")
            sys.exit(0)
        else:
            print(f"{red}Tùy chọn không hợp lệ{reset}")
            input("Nhấn Enter để tiếp tục...")

if __name__ == "__main__":
    try:
        check_root()
        main_menu()
    except KeyboardInterrupt:
        print(f"\n{red}Chương trình bị ngắt bởi người dùng. Đang thoát...{reset}")
        sys.exit(0)
