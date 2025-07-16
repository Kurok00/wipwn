#!/bin/bash
# WIPWN - Giao diện Menu cho Termux và Linux
# Phiên bản tối ưu cho điện thoại di động

# Kiểm tra shell đang chạy
if [ -n "$BASH_VERSION" ]; then
    SHELL_NAME="bash"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_NAME="zsh"
else
    echo "Lỗi: Script này yêu cầu bash hoặc zsh"
    exit 1
fi

# Màu sắc cho giao diện
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m' # Không màu

# Xác định môi trường và đường dẫn
if [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=true
    HOME_DIR="/data/data/com.termux/files/home"
    SCRIPT_NAME=$(basename "$0")
    SCRIPT_DIR="$HOME_DIR/wipwn"
else
    IS_TERMUX=false
    SCRIPT_NAME=$(basename "$0")
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
fi

# Cài đặt mặc định
INTERFACE="wlan0"
BSSID=""
PIN_PREFIX=""
CURRENT_DIR="$SCRIPT_DIR"

# Xác định thư mục temp
if [ "$IS_TERMUX" = true ]; then
    TEMP_DIR="$HOME_DIR/.temp"
else
    TEMP_DIR="/tmp"
fi

# Tạo temp dir nếu không tồn tại
if [ ! -d "$TEMP_DIR" ]; then
    mkdir -p "$TEMP_DIR"
    chmod 700 "$TEMP_DIR"  # Chỉ user hiện tại có quyền truy cập
fi

# Kiểm tra và tạo thư mục script nếu chưa có
if [ ! -d "$SCRIPT_DIR" ]; then
    mkdir -p "$SCRIPT_DIR"
fi

# Kiểm tra file script có tồn tại trong thư mục đích
if [ ! -f "$SCRIPT_DIR/$SCRIPT_NAME" ]; then
    cp "$0" "$SCRIPT_DIR/$SCRIPT_NAME"
    chmod +x "$SCRIPT_DIR/$SCRIPT_NAME"
fi

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}[*] Đang dọn dẹp...${NC}"
    rm -f "$TEMP_DIR"/*.tmp
    echo -e "${GREEN}[✓] Đã dọn dẹp xong${NC}"
    exit 0
}

# Bắt signal để cleanup
trap cleanup SIGINT SIGTERM

# Kiểm tra quyền root/sudo/tsu
check_root() {
    # Bỏ qua kiểm tra root cho Termux, vì sẽ sử dụng tsu khi cần
    if [ "$IS_TERMUX" = true ]; then
        # Kiểm tra xem tsu/sudo có sẵn không
        if command_exists tsu; then
            echo -e "${GREEN}[+] Đã phát hiện Termux với tsu${NC}"
        elif command_exists sudo; then
            echo -e "${GREEN}[+] Đã phát hiện Termux với sudo${NC}"
        else
            echo -e "${RED}[!] Không tìm thấy tsu hoặc sudo. Cài đặt bằng lệnh: pkg install tsu -y${NC}"
            echo -e "${RED}[!] Cần quyền root để WIPWN hoạt động tốt nhất${NC}"
            echo -e "${YELLOW}[*] Vẫn tiếp tục, nhưng có thể gặp lỗi...${NC}"
            sleep 2
        fi
    else
        # Kiểm tra root truyền thống cho các môi trường không phải Termux
        if [ "$(id -u)" -ne 0 ]; then
            echo -e "${RED}[!] Script này phải được chạy với quyền root${NC}"
            exit 1
        fi
    fi
}

# Banner hiển thị tối ưu cho màn hình nhỏ
show_banner() {
    clear
    echo -e "${BLUE}██╗  ██╗██████╗ ██╗    ██╗███╗   ██╗${NC}"
    echo -e "${BLUE}██║  ██║██╔══██╗██║    ██║████╗  ██║${NC}"
    echo -e "${BLUE}██║  ██║██████╔╝██║    ██║██╔██╗ ██║${NC}"
    echo -e "${BLUE}██║  ██║██╔═══╝ ██║    ██║██║╚██╗██║${NC}"
    echo -e "${BLUE}╚██████╔╝██║     ╚███████╔╝██║ ╚████║${NC}"
    echo -e "${BLUE} ╚═════╝ ╚═╝      ╚══════╝ ╚═╝  ╚═══╝${NC}"
    echo -e "${GREEN}== Tool Kiểm Tra Bảo Mật WiFi ==${NC}"
    echo -e "${YELLOW}Menu Tối Ưu Cho Di Động${NC}\n"
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
            echo -e "${YELLOW}[!] Đang chạy không có quyền root, có thể gặp lỗi${NC}"
            $1
        fi
    else
        # Standard Linux environment
        sudo $1
    fi
}

# Function to verify wireless interface
verify_interface() {
    echo -e "${CYAN}[*] Đang kiểm tra giao diện ${INTERFACE}...${NC}"
    
    # Variable to track if we found a valid interface
    local interface_found=false
    
    # First try with ip command
    if command_exists ip; then
        # Check if interface exists
        if ! ip link show "$INTERFACE" &>/dev/null; then
            echo -e "${RED}[!] Giao diện $INTERFACE không tồn tại${NC}"
            
            # List available interfaces
            echo -e "${CYAN}Các giao diện khả dụng:${NC}"
            ip link | grep -E '^[0-9]+:' | cut -d' ' -f2 | sed 's/://g'
            
            # Ask for new interface
            echo -n -e "${GREEN}Nhập tên giao diện chính xác: ${NC}"
            read new_interface
            
            if [ -n "$new_interface" ]; then
                INTERFACE=$new_interface
                echo -e "${BLUE}[+] Giao diện đã được đặt thành: $INTERFACE${NC}"
                # Verify the new interface again
                if ip link show "$INTERFACE" &>/dev/null; then
                    interface_found=true
                else
                    echo -e "${RED}[!] Giao diện mới $INTERFACE vẫn không được tìm thấy${NC}"
                fi
            else
                echo -e "${RED}[!] Không có giao diện nào được cung cấp, sử dụng mặc định: $INTERFACE${NC}"
            fi
        else
            echo -e "${GREEN}[+] Giao diện $INTERFACE tồn tại${NC}"
            interface_found=true
        fi
    # Try alternative methods if ip command not available
    elif command_exists ifconfig; then
        if ! ifconfig "$INTERFACE" &>/dev/null; then
            echo -e "${RED}[!] Giao diện $INTERFACE không tồn tại${NC}"
            echo -e "${CYAN}Các giao diện khả dụng:${NC}"
            ifconfig | grep -E '^[a-zA-Z0-9]+:' | cut -d':' -f1
            
            echo -n -e "${GREEN}Nhập tên giao diện chính xác: ${NC}"
            read new_interface
            
            if [ -n "$new_interface" ]; then
                INTERFACE=$new_interface
                echo -e "${BLUE}[+] Giao diện đã được đặt thành: $INTERFACE${NC}"
                # Verify the new interface again
                if ifconfig "$INTERFACE" &>/dev/null; then
                    interface_found=true
                else
                    echo -e "${RED}[!] Giao diện mới $INTERFACE vẫn không được tìm thấy${NC}"
                fi
            else
                echo -e "${RED}[!] Không có giao diện nào được cung cấp, sử dụng mặc định: $INTERFACE${NC}"
            fi
        else
            echo -e "${GREEN}[+] Giao diện $INTERFACE tồn tại${NC}"
            interface_found=true
        fi
    # For Termux, try different methods
    elif [ "$IS_TERMUX" = true ]; then
        echo -e "${YELLOW}[!] Các lệnh mạng chuẩn không được tìm thấy. Đang sử dụng các kiểm tra đặc biệt cho Termux${NC}"
        if [ -d "/sys/class/net/$INTERFACE" ]; then
            echo -e "${GREEN}[+] Giao diện $INTERFACE tồn tại${NC}"
            interface_found=true
        else
            echo -e "${RED}[!] Giao diện $INTERFACE không tồn tại${NC}"
            echo -e "${CYAN}Các giao diện khả dụng:${NC}"
            ls /sys/class/net/
            
            echo -n -e "${GREEN}Nhập tên giao diện chính xác: ${NC}"
            read new_interface
            
            if [ -n "$new_interface" ]; then
                INTERFACE=$new_interface
                echo -e "${BLUE}[+] Giao diện đã được đặt thành: $INTERFACE${NC}"
                # Verify the new interface again
                if [ -d "/sys/class/net/$INTERFACE" ]; then
                    interface_found=true
                else
                    echo -e "${RED}[!] Giao diện mới $INTERFACE vẫn không được tìm thấy${NC}"
                fi
            else
                echo -e "${RED}[!] Không có giao diện nào được cung cấp, sử dụng mặc định: $INTERFACE${NC}"
            fi
        fi
    else
        # Fallback to checking /sys/class/net directly
        if [ -d "/sys/class/net/$INTERFACE" ]; then
            echo -e "${GREEN}[+] Giao diện $INTERFACE tồn tại${NC}"
            interface_found=true
        else
            echo -e "${RED}[!] Giao diện $INTERFACE không tồn tại${NC}"
            echo -e "${CYAN}Các giao diện khả dụng:${NC}"
            ls /sys/class/net/ 2>/dev/null || echo -e "${RED}[!] Không thể liệt kê các giao diện${NC}"
            
            echo -n -e "${GREEN}Nhập tên giao diện chính xác: ${NC}"
            read new_interface
            
            if [ -n "$new_interface" ]; then
                INTERFACE=$new_interface
                echo -e "${BLUE}[+] Giao diện đã được đặt thành: $INTERFACE${NC}"
                # Verify the new interface again
                if [ -d "/sys/class/net/$INTERFACE" ]; then
                    interface_found=true
                else
                    echo -e "${RED}[!] Giao diện mới $INTERFACE vẫn không được tìm thấy${NC}"
                fi
            else
                echo -e "${RED}[!] Không có giao diện nào được cung cấp, sử dụng mặc định: $INTERFACE${NC}"
            fi
        fi
    fi
    
    # If no valid interface was found, return failure
    if [ "$interface_found" != true ]; then
        echo -e "${RED}[!] Lỗi: Không thể tìm thấy giao diện không dây hợp lệ${NC}"
        echo -e "${YELLOW}[*] Vui lòng đảm bảo rằng bộ điều hợp WiFi của bạn đã được kết nối đúng cách${NC}"
        echo -e "${YELLOW}[*] Nếu đang sử dụng Termux, hãy đảm bảo rằng các quyền WiFi đã được cấp${NC}"
        return 1
    fi
    
    return 0
}

# Function to select wireless interface
select_interface() {
    echo -e "${CYAN}[*] Các giao diện khả dụng:${NC}"
    
    # Use an array to store found interfaces
    declare -a found_interfaces
    
    # Try multiple methods to list interfaces
    if command_exists iw && iw dev | grep -q Interface; then
        # Get wireless interfaces using iw
        echo -e "${CYAN}[+] Các giao diện không dây (iw):${NC}"
        while read -r interface; do
            found_interfaces+=("$interface")
            echo -e "  ${GREEN}→ $interface${NC}"
        done < <(iw dev | grep Interface | awk '{print $2}')
    fi
    
    if command_exists iwconfig; then
        # Get wireless interfaces using iwconfig
        echo -e "${CYAN}[+] Các giao diện không dây (iwconfig):${NC}"
        while read -r interface; do
            # Only add if not already in array
            if [[ ! " ${found_interfaces[@]} " =~ " ${interface} " ]]; then
                found_interfaces+=("$interface")
                echo -e "  ${GREEN}→ $interface${NC}"
            fi
        done < <(iwconfig 2>/dev/null | grep -v "no wireless extensions" | grep -E '^[a-zA-Z0-9]+' | cut -d' ' -f1)
    fi
    
    # Show all interfaces as fallback
    echo -e "${CYAN}[+] Tất cả các giao diện mạng:${NC}"
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
        echo -e "${CYAN}[+] Termux có thể yêu cầu cấu hình thêm cho các giao diện không dây${NC}"
        echo -e "${YELLOW}[*] Hãy chắc chắn rằng bạn đã cấp quyền WiFi cho Termux${NC}"
    fi
    
    echo
    echo -e "${YELLOW}Giao diện hiện tại: $INTERFACE${NC}"
    echo -n -e "${GREEN}Nhập tên giao diện (để trống để giữ nguyên): ${NC}"
    read new_interface
    if [ ! -z "$new_interface" ]; then
        INTERFACE=$new_interface
        echo -e "${BLUE}[+] Giao diện đã được đặt thành: $INTERFACE${NC}"
    fi
    
    # Verify the selected interface
    if ! verify_interface; then
        echo -e "${RED}[!] Không thể xác nhận giao diện. Vui lòng thử lại.${NC}"
        echo -e "${YELLOW}[*] Nhấn Enter để tiếp tục...${NC}"
        read
    fi
}

# Function to scan networks
scan_networks() {
    echo -e "${CYAN}[*] Đang quét các mạng có WPS...${NC}"
    echo -e "${YELLOW}[!] Điều này có thể mất một thời gian...${NC}"
    
    # Verify interface first
    if ! verify_interface; then
        echo -e "${RED}[!] Lỗi: không thể tìm thấy thiết bị wifi${NC}"
        echo -e "${YELLOW}[*] Vui lòng chọn một giao diện không dây hợp lệ trước (Tùy chọn 1)${NC}"
        echo -e "${YELLOW}[*] Nhấn Enter để tiếp tục...${NC}"
        read
        return 1
    fi
    
    run_command "python $CURRENT_DIR/main.py -i $INTERFACE -s"
    echo -e "${GREEN}[+] Quét hoàn tất${NC}"
    echo -e "${YELLOW}Nhấn Enter để tiếp tục...${NC}"
    read
}

# Function to auto-attack all networks
auto_attack() {
    clear  # Xóa màn hình cho gọn
    echo -e "\n${BLUE}┌──────────────────────────────┐${NC}"
    echo -e "${BLUE}│   🚀 TẤN CÔNG TỰ ĐỘNG WiFi   │${NC}"
    echo -e "${BLUE}└──────────────────────────────┘${NC}\n"
    
    # Verify interface first
    if ! verify_interface; then
        echo -e "${RED}[!] Lỗi: Chưa tìm thấy thiết bị WiFi${NC}"
        echo -e "${YELLOW}[↺] Vui lòng chọn card WiFi (Tùy chọn 1)${NC}"
        echo -e "\n${CYAN}Nhấn Enter để quay lại menu...${NC}"
        read
        return 1
    fi

    # Progress display
    echo -e "\n${CYAN}[1/4] ⚡ Đang khởi tạo...${NC}"
    sleep 1
    
    # Check wireless interface
    local is_wireless=false
    if command_exists iw && iw dev "$INTERFACE" info &>/dev/null; then
        is_wireless=true
    elif command_exists iwconfig && iwconfig "$INTERFACE" 2>&1 | grep -v "no wireless extensions" &>/dev/null; then
        is_wireless=true
    elif [ -d "/sys/class/net/$INTERFACE/wireless" ] || [ -d "/sys/class/net/$INTERFACE/phy80211" ]; then
        is_wireless=true
    elif [[ "$INTERFACE" == wlan* ]] || [[ "$INTERFACE" == wlp* ]] || [[ "$INTERFACE" == wlx* ]]; then
        is_wireless=true
    fi

    if [ "$is_wireless" = false ]; then
        echo -e "${RED}[!] Lỗi: ${INTERFACE} không phải là card WiFi${NC}"
        echo -e "${YELLOW}[↺] Vui lòng chọn lại card WiFi${NC}"
        echo -e "\n${CYAN}Nhấn Enter để quay lại...${NC}"
        read
        return 1
    fi

    echo -e "${CYAN}[2/4] 📡 Đang quét mạng...${NC}"
    run_command "python $CURRENT_DIR/main.py -i $INTERFACE -s" >/dev/null 2>&1

    echo -e "${CYAN}[3/4] 🔍 Đang phân tích...${NC}"
    sleep 1

    echo -e "${CYAN}[4/4] 🎯 Bắt đầu tấn công tự động...${NC}\n"
    
    # Attack progress bar
    echo -e "${YELLOW}Đang tấn công mạng WiFi trong khu vực${NC}"
    echo -e "${YELLOW}Quá trình này có thể mất vài phút...${NC}\n"
    
    # Show live progress
    echo -e "${GREEN}[    ] 0% Khởi tạo${NC}\r"
    run_command "python $CURRENT_DIR/main.py -i $INTERFACE --auto" &
    attack_pid=$!
    
    # Hiển thị trạng thái
    local progress=0
    while kill -0 $attack_pid 2>/dev/null; do
        case $(($progress % 4)) in
            0) echo -e "${GREEN}[=   ] Đang quét${NC}\r";;
            1) echo -e "${GREEN}[==  ] Đang phân tích${NC}\r";;
            2) echo -e "${GREEN}[=== ] Đang tấn công${NC}\r";;
            3) echo -e "${GREEN}[====] Đang xử lý${NC}\r";;
        esac
        progress=$((progress + 1))
        sleep 1
    done

    # Final status
    echo -e "\n${GREEN}[✓] Tấn công hoàn tất!${NC}"
    echo -e "${YELLOW}[i] Kiểm tra file vuln.txt để xem kết quả${NC}"
    echo -e "\n${CYAN}Nhấn Enter để quay lại menu chính...${NC}"
    read
}

# Function to attack specific BSSID
attack_specific() {
    echo -n -e "${GREEN}Nhập BSSID mục tiêu (địa chỉ MAC): ${NC}"
    read BSSID
    if [ ! -z "$BSSID" ]; then
        echo -e "${CYAN}[*] Đang tấn công vào $BSSID...${NC}"
        
        # Verify interface first
        if ! verify_interface; then
            echo -e "${RED}[!] Lỗi: không thể tìm thấy thiết bị wifi${NC}"
            echo -e "${YELLOW}[*] Vui lòng chọn một giao diện không dây hợp lệ trước (Tùy chọn 1)${NC}"
            echo -e "${YELLOW}[*] Nhấn Enter để tiếp tục...${NC}"
            read
            return 1
        fi
        
        # Validate BSSID format (basic validation)
        if [[ ! $BSSID =~ ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$ ]]; then
            echo -e "${YELLOW}[!] Cảnh báo: Định dạng BSSID có vẻ không bình thường. Định dạng chuẩn: XX:XX:XX:XX:XX:XX${NC}"
            echo -n -e "${GREEN}Tiếp tục không? (y/n): ${NC}"
            read confirm
            if [[ ! $confirm =~ ^[Yy]$ ]]; then
                return
            fi
        fi
        
        run_command "python $CURRENT_DIR/main.py -i $INTERFACE -b $BSSID -K"
    else
        echo -e "${RED}[!] BSSID không được để trống${NC}"
    fi
}

# Function for PIN bruteforce attack
pin_bruteforce() {
    clear
    echo -e "\n${BLUE}┌───────────────────────────────┐${NC}"
    echo -e "${BLUE}│   🔓 TẤN CÔNG BRUTEFORCE PIN  │${NC}"
    echo -e "${BLUE}└───────────────────────────────┘${NC}\n"

    # Verify interface first
    if ! verify_interface; then
        echo -e "${RED}[!] Lỗi: Chưa tìm thấy thiết bị WiFi${NC}"
        echo -e "${YELLOW}[↺] Vui lòng chọn card WiFi (Tùy chọn 1)${NC}"
        echo -e "\n${CYAN}Nhấn Enter để quay lại menu...${NC}"
        read
        return 1
    fi

    # Quét tìm WiFi xung quanh
    echo -e "${CYAN}[1/4] 📡 Đang quét WiFi xung quanh...${NC}"
    # Tạo file tạm để lưu kết quả quét
    SCAN_RESULT="/tmp/wifi_scan_result.txt"
    run_command "iwlist $INTERFACE scan | grep -E 'ESSID|Address|Channel|Quality|Encryption'" > "$SCAN_RESULT"

    # Parse và hiển thị kết quả quét
    echo -e "\n${GREEN}=== DANH SÁCH WIFI ĐÃ QUÉT ĐƯỢC ===${NC}"
    echo -e "${YELLOW}STT  BSSID              ESSID          CHANNEL  SIGNAL${NC}"
    echo -e "${YELLOW}───────────────────────────────────────────────────${NC}"

    # Array để lưu BSSID
    declare -a BSSID_LIST
    
    # Đọc và parse kết quả
    i=1
    while IFS= read -r line; do
        if [[ $line == *"Address:"* ]]; then
            bssid=$(echo $line | awk '{print $5}')
            BSSID_LIST+=("$bssid")
            printf "${GREEN}%-4d ${CYAN}%-18s" $i "$bssid"
        elif [[ $line == *"ESSID:"* ]]; then
            essid=$(echo $line | cut -d'"' -f2)
            [ -z "$essid" ] && essid="<hidden>"
            printf "%-14s" "$essid"
        elif [[ $line == *"Channel:"* ]]; then
            channel=$(echo $line | awk '{print $2}')
            printf "%-8s" "$channel"
        elif [[ $line == *"Quality="* ]]; then
            quality=$(echo $line | awk -F'=' '{print $2}' | cut -d' ' -f1)
            echo -e "${GREEN}$quality${NC}"
        fi
    done < "$SCAN_RESULT"

    # Xóa file tạm
    rm -f "$SCAN_RESULT"

    echo -e "\n${CYAN}[2/4] 🎯 Chọn mục tiêu tấn công${NC}"
    echo -n -e "${GREEN}Nhập số thứ tự WiFi muốn tấn công (1-$i): ${NC}"
    read choice

    # Validate lựa chọn
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#BSSID_LIST[@]} ]; then
        echo -e "${RED}[!] Lựa chọn không hợp lệ${NC}"
        echo -e "\n${CYAN}Nhấn Enter để quay lại...${NC}"
        read
        return 1
    fi

    # Lấy BSSID từ lựa chọn
    BSSID=${BSSID_LIST[$choice-1]}
    echo -e "${CYAN}[3/4] 🔍 Đã chọn mục tiêu: ${YELLOW}$BSSID${NC}"

    # Hỏi PIN prefix
    echo -e "${CYAN}[4/4] 🔢 Cấu hình tấn công${NC}"
    echo -n -e "${GREEN}Nhập tiền tố PIN (để trống để thử tất cả): ${NC}"
    read PIN_PREFIX

    if [ ! -z "$PIN_PREFIX" ]; then
        # Validate PIN prefix
        if [[ ! $PIN_PREFIX =~ ^[0-9]+$ ]]; then
            echo -e "${RED}[!] Tiền tố PIN chỉ được chứa các số${NC}"
            echo -e "\n${CYAN}Nhấn Enter để quay lại...${NC}"
            read
            return 1
        fi
        echo -e "${YELLOW}[*] Sử dụng tiền tố PIN: $PIN_PREFIX${NC}"
        run_command "python $CURRENT_DIR/main.py -i $INTERFACE -b $BSSID -p $PIN_PREFIX"
    else
        echo -e "${YELLOW}[*] Thử tất cả các PIN có thể${NC}"
        run_command "python $CURRENT_DIR/main.py -i $INTERFACE -b $BSSID"
    fi

    echo -e "\n${GREEN}[✓] Tấn công hoàn tất!${NC}"
    echo -e "${YELLOW}[i] Kiểm tra file PIN.txt để xem kết quả${NC}"
    echo -e "\n${CYAN}Nhấn Enter để quay lại menu chính...${NC}"
    read
}

# Function to show help
show_help() {
    clear
    echo -e "\n${BLUE}┌───────────────────────────────┐${NC}"
    echo -e "${BLUE}│      📚 HƯỚNG DẪN SỬ DỤNG     │${NC}"
    echo -e "${BLUE}└───────────────────────────────┘${NC}\n"

    echo -e "${YELLOW}=== HƯỚNG DẪN CÀI ĐẶT TRÊN TERMUX ===${NC}"
    echo -e "${CYAN}1. Cài đặt các gói cần thiết:${NC}"
    echo -e "   pkg update && pkg upgrade"
    echo -e "   pkg install git python tsu"
    
    echo -e "\n${CYAN}2. Clone repository:${NC}"
    echo -e "   git clone https://github.com/Kurok00/wipwn"
    
    echo -e "\n${CYAN}3. Cấp quyền và cài đặt:${NC}"
    echo -e "   cd wipwn"
    echo -e "   chmod +x wipwn.sh"
    echo -e "   cp wipwn.sh /data/data/com.termux/files/home/wipwn/"
    
    echo -e "\n${CYAN}4. Chạy tool:${NC}"
    echo -e "   ./wipwn.sh"

    echo -e "\n${YELLOW}=== CÁCH SỬ DỤNG ===${NC}"
    echo -e "${GREEN}1. Chọn card mạng không dây${NC}"
    echo -e "${GREEN}2. Quét tìm mạng WPS xung quanh${NC}"
    echo -e "${GREEN}3. Tấn công tự động tất cả mạng${NC}"
    echo -e "${GREEN}4. Tấn công một mạng cụ thể${NC}"
    echo -e "${GREEN}5. Tấn công bruteforce PIN${NC}"
    
    echo -e "\n${YELLOW}=== XỬ LÝ LỖI THƯỜNG GẶP ===${NC}"
    echo -e "${RED}Lỗi: No such file or directory${NC}"
    echo -e "${GREEN}➜ Kiểm tra lại đường dẫn cài đặt${NC}"
    
    echo -e "\n${RED}Lỗi: Permission denied${NC}"
    echo -e "${GREEN}➜ Cấp quyền thực thi: chmod +x wipwn.sh${NC}"
    
    echo -e "\n${RED}Lỗi: Command not found${NC}"
    echo -e "${GREEN}➜ Đảm bảo đã cài đặt đủ các gói cần thiết${NC}"

    echo -e "\n${CYAN}Nhấn Enter để quay lại menu chính...${NC}"
    read
}

# Advanced options menu
advanced_options() {
    while true; do
        show_banner
        echo -e "${CYAN}=== Tùy Chọn Nâng Cao ===${NC}"
        echo -e "${BLUE}1.${NC} Xem thông tin đăng nhập đã lưu"
        echo -e "${BLUE}2.${NC} Kiểm tra các mẫu router dễ bị tấn công"
        echo -e "${BLUE}3.${NC} Thực hiện lệnh tùy chỉnh"
        echo -e "${RED}0.${NC} Quay lại menu chính"
        
        echo -n -e "${GREEN}Chọn một tùy chọn: ${NC}"
        read option
        
        case $option in
            1)
                echo -e "${CYAN}[*] Thông tin đăng nhập đã lưu (nếu có):${NC}"
                if [ -f "$CURRENT_DIR/config.txt" ]; then
                    cat "$CURRENT_DIR/config.txt"
                else
                    echo -e "${RED}[!] Không tìm thấy tệp thông tin đăng nhập${NC}"
                fi
                echo -e "${YELLOW}Nhấn Enter để tiếp tục...${NC}"
                read
                ;;
            2)
                echo -e "${CYAN}[*] Các mẫu router dễ bị tấn công:${NC}"
                if [ -f "$CURRENT_DIR/vulnwsc.txt" ]; then
                    cat "$CURRENT_DIR/vulnwsc.txt"
                else
                    echo -e "${RED}[!] Không tìm thấy cơ sở dữ liệu router dễ bị tấn công${NC}"
                fi
                echo -e "${YELLOW}Nhấn Enter để tiếp tục...${NC}"
                read
                ;;
            3)
                echo -n -e "${GREEN}Nhập lệnh WIPWN tùy chỉnh (ví dụ: -i wlan0 -b XX:XX:XX:XX:XX:XX -K): ${NC}"
                read custom_cmd
                if [ ! -z "$custom_cmd" ]; then
                    run_command "python $CURRENT_DIR/main.py $custom_cmd"
                else
                    echo -e "${RED}[!] Lệnh không được để trống${NC}"
                fi
                echo -e "${YELLOW}Nhấn Enter để tiếp tục...${NC}"
                read
                ;;
            0)
                return
                ;;
            *)
                echo -e "${RED}Tùy chọn không hợp lệ${NC}"
                sleep 1
                ;;
        esac
    done
}

# Kiểm tra dependencies
check_dependencies() {
    local missing_deps=()
    
    # Kiểm tra Python (bắt buộc)
    if ! command -v python &> /dev/null; then
        missing_deps+=("python")
    fi
    
    # Kiểm tra công cụ WiFi (cần ít nhất một trong hai)
    if ! command -v iw &> /dev/null && ! command -v iwconfig &> /dev/null; then
        missing_deps+=("iw/iwconfig")
    fi
    
    # Nếu thiếu dependencies
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}[!] Thiếu các công cụ sau:${NC}"
        printf '%s\n' "${missing_deps[@]}"
        
        if [ "$IS_TERMUX" = true ]; then
            echo -e "${YELLOW}[*] Đang cài đặt các gói cần thiết...${NC}"
            pkg update && pkg upgrade -y
            pkg install python wireless-tools tsu -y
        else
            echo -e "${YELLOW}[*] Vui lòng cài đặt các gói còn thiếu:${NC}"
            echo "sudo apt-get update"
            echo "sudo apt-get install python3 iw wireless-tools aircrack-ng"
        fi
        
        # Kiểm tra lại sau khi cài
        local still_missing=false
        for tool in "${missing_deps[@]}"; do
            if ! command -v "$tool" &> /dev/null; then
                still_missing=true
                echo -e "${RED}[!] Vẫn thiếu công cụ: $tool${NC}"
            fi
        done
        
        if [ "$still_missing" = true ]; then
            echo -e "${RED}[!] Vui lòng cài đặt đầy đủ các công cụ còn thiếu và chạy lại script${NC}"
            exit 1
        fi
    fi
}

# Fix permissions cho các file quan trọng
fix_permissions() {
    echo -e "${YELLOW}[*] Đang kiểm tra và sửa permissions...${NC}"
    
    # Fix for script directory
    if [ ! -w "$SCRIPT_DIR" ]; then
        if [ "$IS_TERMUX" = true ]; then
            chmod 755 "$SCRIPT_DIR"
        else
            sudo chmod 755 "$SCRIPT_DIR"
        fi
    fi
    
    # Fix for script file
    if [ ! -x "$SCRIPT_DIR/$SCRIPT_NAME" ]; then
        if [ "$IS_TERMUX" = true ]; then
            chmod +x "$SCRIPT_DIR/$SCRIPT_NAME"
        else
            sudo chmod +x "$SCRIPT_DIR/$SCRIPT_NAME"
        fi
    fi
    
    # Fix for temp directory
    if [ ! -w "$TEMP_DIR" ]; then
        if [ "$IS_TERMUX" = true ]; then
            chmod 777 "$TEMP_DIR"
        else
            sudo chmod 777 "$TEMP_DIR"
        fi
    fi
    
    echo -e "${GREEN}[✓] Đã fix permissions xong${NC}"
}

# Chạy các kiểm tra ban đầu
check_dependencies
fix_permissions

# Main menu
main_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}=== Cài Đặt Hiện Tại ===${NC}"
        echo -e "${YELLOW}Giao diện: ${GREEN}$INTERFACE${NC}"
        if [ ! -z "$BSSID" ]; then
            echo -e "${YELLOW}BSSID Mục Tiêu: ${GREEN}$BSSID${NC}"
        fi
        if [ ! -z "$PIN_PREFIX" ]; then
            echo -e "${YELLOW>PIN Prefix: ${GREEN}$PIN_PREFIX${NC}"
        fi
        echo
        
        echo -e "${CYAN}=== Menu WIPWN ===${NC}"
        echo -e "${BLUE}1.${NC} Chọn giao diện không dây"
        echo -e "${BLUE}2.${NC} Quét các mạng có WPS"
        echo -e "${BLUE}3.${NC} Tấn công tự động vào tất cả các mạng (Pixie Dust)"
        echo -e "${BLUE}4.${NC} Tấn công vào BSSID cụ thể (Pixie Dust)"
        echo -e "${BLUE}5.${NC} Tấn công bruteforce PIN"
        echo -e "${BLUE}6.${NC} Tùy chọn nâng cao"
        echo -e "${BLUE}7.${NC} Hiển thị trợ giúp / tùy chọn lệnh"
        echo -e "${RED}0.${NC} Thoát"
        
        echo -n -e "${GREEN}Chọn một tùy chọn: ${NC}"
        read option
        
        case $option in
            1) select_interface ;;
            2) scan_networks ;;
            3) auto_attack ;;
            4) attack_specific ;;
            5) pin_bruteforce ;;
            6) advanced_options ;;
            7) show_help ;;
            0) echo -e "${RED}Đang thoát...${NC}"; exit 0 ;;
            *) echo -e "${RED}Tùy chọn không hợp lệ${NC}"; sleep 1 ;;
        esac
    done
}

# Start the script
check_root
main_menu
