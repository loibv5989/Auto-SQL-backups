# Công cụ Sao lưu SQL Tự động cho Linux

Công cụ tự động sao lưu cơ sở dữ liệu MySQL/MariaDB với 4 chế độ thông báo: email có đính kèm, email không đính kèm, không gửi email, hoặc upload lên cloud storage qua rclone.

## Tính năng chính

- **Sao lưu tự động**: Chạy hàng ngày qua cronjob
- **3 chu kỳ lưu trữ**: Daily (30 ngày), Weekly (12 tuần), Monthly (12 tháng)
- **Kiểm tra dung lượng**: Tự động cảnh báo khi ổ đĩa đầy trước khi backup
- **Bỏ qua bảng log**: Tự động loại trừ các bảng log lớn (itsec_logs, itsec_temp...)
- **4 chế độ thông báo**:
  - `attachments` - Gửi email kèm file backup
  - `no_attachments` - Gửi email chỉ có log
  - `no_email` - Không gửi thông báo
  - `rclone` - Upload lên cloud (Google Drive, OneDrive...) qua rclone
- **Hỗ trợ song ngữ**: Cài đặt bằng Tiếng Việt hoặc English

## Yêu cầu hệ thống

| Thành phần | Bắt buộc | Ghi chú |
|------------|----------|---------|
| Linux/WSL | Có | Ubuntu/Debian/CentOS... |
| MySQL/MariaDB | Có | Có quyền root hoặc user backup |
| Bash | Có | `/bin/bash` |
| Mail service | Tùy chọn | sendmail, exim4, hoặc postfix (cho email) |
| rclone | Tùy chọn | Chỉ cần khi dùng chế độ rclone |

## Cấu trúc dự án

```
Auto-SQL-backups/
├── install.sh          # Script cài đặt wizard (song ngữ)
├── runsqlbackup        # Script backup chính
├── sendmail            # Script gửi email/upload rclone
├── mysqlbackup.cnf     # File cấu hình mẫu
└── README.md           # Tài liệu này
```

## Cài đặt

### Bước 1: Tải và giải nén

```bash
cd /var/www/vhosts
git clone https://github.com/loibv/Auto-SQL-backups.git
cd Auto-SQL-backups
```

### Bước 2: Chạy cài đặt

```bash
sudo chmod +x install.sh
sudo bash ./install.sh
```

### Bước 3: Chọn ngôn ngữ

Trình cài đặt hỗ trợ 2 ngôn ngữ:
- `1` - Tiếng Việt
- `2` - English (mặc định)

### Bước 4: Cấu hình theo wizard

Wizard sẽ hướng dẫn qua 5 bước:
1. **Thư mục backup** (mặc định: `/var/backups/db`)
2. **Kiểm tra mail service** (sendmail/exim4/postfix)
3. **Chọn chế độ thông báo**:
   - `d` - Gửi mail không đính kèm
   - `y` - Gửi mail có đính kèm
   - `n` - Không gửi mail
   - `r` - Dùng rclone upload cloud
4. **Cấu hình email/rclone** (nếu chọn)
5. **Tạo cronjob** hàng ngày

## Chế độ Rclone (Upload Cloud)

### 1. Cài đặt rclone (nếu chưa có)

```bash
curl https://rclone.org/install.sh | sudo bash
```

### 2. Cấu hình rclone

```bash
rclone config
```

- Chọn `n` (new remote)
- Đặt tên (ví dụ: `gdrive`)
- Chọn loại storage (Google Drive = `13`)
- Làm theo hướng dẫn xác thực

### 3. Cấu hình trong install.sh

Khi chọn option `r`, wizard sẽ hỏi:
- **Remote name**: Tên remote vừa tạo (mặc định: `gdrive`)
- **Danh sách thư mục**: Tên thư mục trên cloud để phân loại file backup

**Cách hoạt động:**
```
RCLONE_SITES="nbblo.com,itsmeit.co,wordpress"
→ Tạo 3 thư mục trên cloud: nbblo.com, itsmeit.co, wordpress

Logic matching (dựa trên tên file backup):
- "nbblo" (phần trước dấu ".") → File chứa "nbblo" vào thư mục nbblo.com/
- "itsmeit" → File chứa "itsmeit" vào thư mục itsmeit.co/
- "wordpress" (không có ".") → Toàn bộ tên là keyword
```

Ví dụ file `29-04-2026_nbblo_Tuesday.sql.gz` chứa từ "nbblo" → upload vào `gdrive:nbblo.com/`

### 4. Cấu hình thủ công (nếu cần)

Sửa file `/etc/automysqlbackup/mysqlbackup.cnf`:

```bash
EMAIL_OPTION="rclone"
RCLONE_REMOTE="gdrive"
RCLONE_SITES="folder1.com,folder2,wordpress"
EMAIL_TO="admin@example.com"  # Tùy chọn: gửi email thông báo sau upload
```

## Kiểm tra sau cài đặt

### Chạy test backup

```bash
sudo runsqlbackup
```

### Kiểm tra file backup

```bash
ls -la /var/backups/db/daily/
ls -la /var/backups/db/weekly/   # Chỉ có nếu hôm nay là thứ 7
ls -la /var/backups/db/monthly/  # Chỉ có nếu hôm nay là ngày cuối tháng
```

### Kiểm tra log

```bash
cat /var/backups/db/logs/backup_log_$(date +%d-%m-%Y).log
```

### Kiểm tra cronjob

```bash
cat /etc/cron.daily/runsqlbackup
ls -la /etc/cron.daily/runsqlbackup
```

## Phục hồi dữ liệu

### Bước 1: Giải nén file backup

```bash
gunzip /var/backups/db/daily/mydb/29-04-2026_mydb_Tuesday.sql.gz
```

### Bước 2: Import vào database

```bash
mysql -u root -p mydb < /var/backups/db/daily/mydb/29-04-2026_mydb_Tuesday.sql
```

Hoặc import từ file nén trực tiếp:

```bash
zcat backup.sql.gz | mysql -u root -p mydb
```

## Cấu hình chi tiết

### File cấu hình: `/etc/automysqlbackup/mysqlbackup.cnf`

```bash
# Thư mục lưu backup
BACKUP_DIR="/var/backups/db"

# Thông tin MySQL
MYSQL_USER="root"
MYSQL_PASSWORD="your_password"

# Các database bỏ qua (không backup)
CONFIG_DB_EXCLUDE="mysql|information_schema|performance_schema|sys|test"

# Chế độ email: attachments | no_attachments | no_email | rclone
EMAIL_OPTION="no_attachments"

# Thông tin email
SENDER_NAME="Admin"
EMAIL_TO="admin@example.com"

# Cấu hình rclone (chỉ khi EMAIL_OPTION=rclone)
RCLONE_REMOTE="gdrive"
RCLONE_SITES="site1.com,site2.com"
```

### Các bảng bị loại trừ mặc định

Script tự động bỏ qua các bảng sau (thường là log lớn):
- `itsec_logs`
- `itsec_temp`
- `itsec_lockouts`
- `itsec_distributed_storage`
- `itsec_opaque_tokens`
- `itsec_geolocation_cache`

## Xử lý lỗi thường gặp

### Lỗi line endings (CRLF)

**Triệu chứng**: `: not found`, `Syntax error: "elif" unexpected`

**Nguyên nhân**: File được lưu với Windows line endings

**Cách fix**:
```bash
sed -i 's/\r$//' install.sh runsqlbackup sendmail
```

### Lỗi "rclone remote not found"

**Nguyên nhân**: Chưa cấu hình remote rclone

**Cách fix**:
```bash
rclone config
# Sau đó chạy lại install.sh hoặc sửa mysqlbackup.cnf
```

### Lỗi "Disk full"

Script sẽ tự động:
1. Tính dung lượng cần backup (trước khi nén ~87%)
2. So sánh với dung lượng trống
3. Gửi cảnh báo email nếu không đủ space

**Cách fix**: Dọn dẹp ổ đĩa hoặc tăng dung lượng

### Lỗi gửi mail bị từ chối (attachment quá lớn)

Script tự động:
- Kiểm tra giới hạn của MTA (postfix: 10MB, exim: 10MB...)
- Nếu vượt quá → chuyển sang gửi `no_attachments`

## Lịch sử sửa lỗi (Bug Fixes)

| Bug | Mô tả | Fix |
|-----|-------|-----|
| #1 | Biến TOTAL_BACKUP_SIZE không được khởi tạo | Khởi tạo giá trị mặc định 0 |
| #2 | SHOW TABLE STATUS cột 7 là bytes không phải KB | Dùng information_schema để tính chính xác |
| #3 | Lỗi stderr của mysqldump bị nuốt | Redirect stderr vào log file |
| #4 | wc -l đếm sai khi chuỗi rỗng | Dùng `grep -c '[^[:space:]]'` |
| #5 | Kiểm tra EMAIL_TO khi dùng rclone | Bỏ qua kiểm tra nếu EMAIL_OPTION=rclone |
| #6 | File không khớp domain bị bỏ qua im lặng | Ghi log cảnh báo |

## Tác giả & Liên hệ

- **Email**: buivanloi.2010@gmail.com
- **Facebook**: https://facebook.com/omgidol.bz
- **Website**: https://omgidol.com/
