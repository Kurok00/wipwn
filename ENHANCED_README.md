# WIPWN - Enhanced User Interface

## Giới thiệu

Đây là phiên bản được cải tiến của WIPWN - Công cụ Kiểm tra An ninh WiFi với giao diện người dùng thân thiện hơn. Giao diện người dùng mới được thiết kế để làm cho WIPWN dễ sử dụng hơn mà không cần sửa đổi mã nguồn gốc.

## Các phương thức chạy mới

Bạn có thể sử dụng hai cách để chạy phiên bản cải tiến này:

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

## Các tính năng đã được cải tiến

1. **Giao diện menu trực quan**: Menu tương tác với các tùy chọn rõ ràng
2. **Quản lý giao diện dễ dàng**: Chọn giao diện không dây từ danh sách
3. **Quản lý tham số đơn giản**: Không cần nhớ các cờ và tham số dòng lệnh
4. **Màu sắc tốt hơn**: Giao diện được tô màu để dễ đọc
5. **Tùy chọn nâng cao**: Truy cập vào các tính năng nâng cao từ menu
6. **Bảo toàn chức năng gốc**: Sử dụng tất cả các tính năng mạnh mẽ của WIPWN mà không cần sửa đổi mã nguồn gốc

## Các tùy chọn menu

### Menu chính

- **Chọn giao diện không dây**: Chọn giao diện WiFi để sử dụng
- **Quét mạng WPS**: Quét để tìm các mạng WiFi có hỗ trợ WPS
- **Tự động tấn công tất cả các mạng**: Thực hiện tấn công Pixie Dust trên tất cả các mạng tìm thấy
- **Tấn công BSSID cụ thể**: Nhắm mục tiêu vào một mạng cụ thể bằng địa chỉ MAC
- **Tấn công vét cạn PIN**: Thực hiện tấn công bruteforce PIN WPS
- **Hiển thị trợ giúp**: Xem tài liệu về các tùy chọn lệnh
- **Tùy chọn nâng cao**: Truy cập các tính năng nâng cao

### Menu tùy chọn nâng cao (chỉ có trong phiên bản Python)

- **Thực thi lệnh tùy chỉnh**: Chạy các lệnh WIPWN tùy chỉnh
- **Xem thông tin đăng nhập đã lưu**: Kiểm tra các thông tin xác thực đã lưu trữ
- **Kiểm tra cơ sở dữ liệu bộ định tuyến dễ bị tấn công**: Xem danh sách các mẫu bộ định tuyến dễ bị tấn công

## Lưu ý bảo mật

Nhớ rằng WIPWN chỉ được thiết kế cho mục đích kiểm tra bảo mật được ủy quyền. Việc sử dụng công cụ này trên các mạng không được phép là bất hợp pháp và phi đạo đức.

```
⚠️ LƯU Ý QUAN TRỌNG:
Công cụ này CHỈ dành cho mục đích giáo dục và kiểm tra bảo mật được ủy quyền.
KHÔNG sử dụng trên các mạng không được phép.
Người dùng phải chịu hoàn toàn trách nhiệm về việc sử dụng công cụ này.
```

## Tác giả

- Công cụ gốc: Mohammad Alamin (anbuinfosec)
- Giao diện người dùng nâng cao: Người dùng hiện tại
