<h1 align="center">⚡ WIPWN - Công cụ Kiểm tra Bảo mật WiFi</h1>

<p align="center">
  <img src="assets/image.png" alt="WIPWN Logo" width="120" />
</p>

<p align="center">
  <strong>Quét, Tấn công, và Phân tích Mạng WiFi</strong><br>
  <i>Tương thích với Termux • Yêu cầu Root • Chỉ Sử dụng Hợp pháp</i>
</p>

> ⚠️ **Lưu ý quan trọng:**  
> Công cụ này chỉ dành cho **mục đích giáo dục và kiểm thử được ủy quyền**.  
> **KHÔNG** sử dụng trên các mạng không được phép.  
> Tác giả **không chịu trách nhiệm** cho bất kỳ hành vi lạm dụng nào.

---

## 📚 Giới thiệu

Đây là phiên bản được cải tiến của WIPWN - công cụ kiểm tra bảo mật WiFi với giao diện người dùng thân thiện hơn. Phiên bản này bao gồm các cải tiến về phát hiện giao diện WiFi và hỗ trợ tốt hơn cho cả Termux và Linux.

## ✨ Các Tính Năng Chính

- 🔍 **Quét mạng WiFi hỗ trợ WPS** - Tìm kiếm các mạng dễ bị tấn công
- ⚡ **Tự động tấn công Pixie Dust** - Khai thác lỗ hổng trong giao thức WPS
- 🔓 **Bruteforce PIN WPS** - Thử các mã PIN có thể có
- 🛠️ **Hai chế độ giao diện** - Sử dụng Bash hoặc Python tùy theo sở thích
- 💾 **Tự động lưu mật khẩu** - Tự động lưu thông tin đăng nhập tìm được
- 🌟 **Phát hiện giao diện WiFi nâng cao** - Tự động tìm và xác minh giao diện
- 📊 **Cơ sở dữ liệu bộ định tuyến dễ bị tổn thương** - Giúp xác định mục tiêu dễ tấn công

## 📦 Yêu Cầu Hệ Thống

- ✅ Thiết bị Android đã root hoặc Linux có quyền root
- ✅ Termux (Android) hoặc Terminal (Linux)
- ✅ Card WiFi hỗ trợ chế độ monitor
- ✅ Kết nối internet để cài đặt

### 📥 Các Gói Cần Thiết

| Gói | Mô tả |
|-----|--------|
| `python` | Để chạy script chính |
| `tsu` | Quyền root trong Termux |
| `iw` | Quản lý thiết bị không dây |
| `pixiewps` | Công cụ tấn công WPS Pixie Dust |
| `openssl` | Thực hiện các phép toán mã hóa |
| `wpa_supplicant` | Xác thực WiFi |
| `git` | Để tải mã nguồn |

## ⚙️ Cài Đặt

```bash
# Cập nhật các gói và kho lưu trữ
pkg update && pkg upgrade -y

# Cài đặt kho lưu trữ root
pkg install root-repo -y

# Cài đặt các gói cần thiết
pkg install git tsu python wpa-supplicant pixiewps iw openssl -y

# Tải xuống repository
git clone https://github.com/Kurok00/wipwn

# Di chuyển vào thư mục dự án
cd wipwn

# Cấp quyền thực thi cho các tập tin script
chmod +x main.py
chmod +x wipwn.sh
chmod +x easy_wipwn.py
```

### Lưu ý cài đặt:
Khi được hỏi Y hoặc N, đây là yêu cầu xác nhận cấu hình. Bạn nên chọn Y để có trải nghiệm tốt hơn, nhưng chọn N cũng không ảnh hưởng đến chức năng chính.

## 🚀 Các Phương Thức Chạy

### 1. Menu Bash (Shell Script)

```bash
# Đảm bảo script có quyền thực thi
chmod +x wipwn.sh

# Chạy menu bash
sudo ./wipwn.sh
```

### 2. Menu Python Nâng cao

```bash
# Đảm bảo script có quyền thực thi
chmod +x easy_wipwn.py

# Chạy menu python
sudo ./easy_wipwn.py
```

### 3. Sử dụng lệnh trực tiếp

```bash
# Hiển thị trợ giúp
sudo python main.py --help

# Quét và tấn công tự động tất cả các mạng
sudo python main.py -i wlan0 -K

# Tấn công Pixie Dust vào BSSID cụ thể
sudo python main.py -i wlan0 -b 00:91:4C:C3:AC:28 -K

# Tấn công bruteforce PIN với tiền tố cụ thể
sudo python main.py -i wlan0 -b 50:0F:F5:B0:08:05 -B -p 1234
```

## 🛠️ Tính Năng Đã Cải Tiến

1. **Giao diện menu trực quan**: Menu tương tác với các tùy chọn rõ ràng
2. **Phát hiện giao diện WiFi mạnh mẽ**: Tự động tìm và xác minh các giao diện không dây
3. **Quản lý tham số đơn giản**: Không cần nhớ các cờ và tham số dòng lệnh
4. **Hỗ trợ Termux tốt hơn**: Phát hiện và thích ứng với môi trường Termux
5. **Tùy chọn nâng cao**: Truy cập các tính năng nâng cao từ menu
6. **Bảo toàn chức năng gốc**: Sử dụng tất cả tính năng mạnh mẽ của WIPWN mà không thay đổi mã nguồn chính

## 📋 Các Tùy Chọn Menu

### Menu chính

- **Chọn giao diện không dây**: Chọn giao diện WiFi để sử dụng
- **Quét mạng WPS**: Quét để tìm các mạng WiFi có hỗ trợ WPS
- **Tự động tấn công tất cả các mạng**: Thực hiện tấn công Pixie Dust trên tất cả các mạng tìm thấy
- **Tấn công BSSID cụ thể**: Nhắm mục tiêu vào một mạng cụ thể bằng địa chỉ MAC
- **Tấn công vét cạn PIN**: Thực hiện tấn công bruteforce PIN WPS
- **Hiển thị trợ giúp**: Xem tài liệu về các tùy chọn lệnh

### Menu tùy chọn nâng cao (chỉ có trong phiên bản Python)

- **Thực thi lệnh tùy chỉnh**: Chạy các lệnh WIPWN tùy chỉnh
- **Xem thông tin đăng nhập đã lưu**: Kiểm tra các thông tin xác thực đã lưu trữ
- **Kiểm tra cơ sở dữ liệu bộ định tuyến dễ bị tấn công**: Xem danh sách các mẫu bộ định tuyến dễ bị tấn công

## 🎨 Ghi Chú Màu Sắc và Tỷ Lệ Thành Công

| Màu | Tỷ lệ thành công | Ghi chú |
|-----|-----------------|--------|
| **Màu xanh** | 80% | Với router đã cấu hình WPS |
| **Màu vàng** | 60% | Khả năng thành công trung bình |
| **Màu trắng** | 50% | Khả năng thành công trung bình thấp |
| **Màu đỏ** | 10% | Tỷ lệ thành công thấp |

## 🛠️ Xử Lý Sự Cố Thường Gặp

| Vấn đề | Cách khắc phục |
|--------|---------------|
| "Thiết bị hoặc tài nguyên đang bận (-16)" | Bật Wifi rồi tắt Wifi và thử lại |
| Không tìm thấy mạng nào | Bật Hotspot + Vị trí |
| Lỗi quyền truy cập | Sử dụng `tsu` hoặc `sudo` |
| Không tìm thấy giao diện WiFi | Kiểm tra bằng lệnh `ip a` hoặc `ifconfig` |

## 📁 Cấu Trúc Thư Mục

```
📁 wipwn/
├── assets/           → Logo và ảnh chụp màn hình
├── colors.py         → Hỗ trợ màu sắc cho terminal
├── config.txt        → Định dạng cấu hình đầu ra
├── LICENSE           → Giấy phép MIT
├── main.py           → Script tấn công WiFi chính
├── README.md         → Tài liệu dự án
├── vulnwsc.txt       → Cơ sở dữ liệu BSSID dễ bị tấn công
├── wipwn.sh          → Script khởi chạy Bash
└── easy_wipwn.py     → Giao diện menu Python nâng cao
```

## 🖼️ Ảnh Chụp Màn Hình

| Quét | Đã Crack | Dữ Liệu Đã Lưu | Cấu Hình | 
| :---: | :---: | :---: | :---: |
| ![image](https://raw.githubusercontent.com/Kurok00/wipwn/main/assets/1.jpg) | ![image](https://raw.githubusercontent.com/Kurok00/wipwn/main/assets/2.jpg) | ![image](https://raw.githubusercontent.com/Kurok00/wipwn/main/assets/3.jpg) | ![image](https://raw.githubusercontent.com/Kurok00/wipwn/main/assets/4.jpg) |

## 📜 Giấy Phép

Phần mềm được cấp phép theo [Giấy phép MIT](LICENSE).
Bạn có thể tự do sử dụng, sửa đổi và phân phối một cách có trách nhiệm.

## 👤 Tác Giả

### Phiên Bản Gốc
- **Mohammad Alamin** ([@anbuinfosec](https://github.com/anbuinfosec))

### Phiên Bản Cải Tiến
- **Kurok00** ([@Kurok00](https://github.com/Kurok00))

## ❤️ Hỗ Trợ Dự Án

Nếu bạn thích dự án này, hãy để lại sao (⭐) và theo dõi repository trên GitHub!

> 💡 *"Hack đạo đức không phải là tội ác — mà là kiến thức trong phòng thủ."*
