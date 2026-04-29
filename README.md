# Auto SQL Backup cho Linux

Script backup MySQL/MariaDB tự động, chạy bằng cron. Có thể gửi email hoặc upload lên cloud (rclone).

## Chức năng

* Backup database mỗi ngày
* Lưu theo chu kỳ:

    * daily: 30 ngày
    * weekly: 12 tuần
    * monthly: 12 tháng
* 4 chế độ:

    * email có file
    * email không file
    * không gửi
    * upload cloud (rclone)
* Bỏ qua bảng log lớn
* Kiểm tra dung lượng trước khi chạy

## Yêu cầu

* Linux (Ubuntu, Debian…)
* MySQL hoặc MariaDB
* Bash
* Mail service (tuỳ chọn)
* rclone (tuỳ chọn)

## Cài đặt

```bash
git clone https://github.com/loibv5989/autosqlbackup.git
cd autosqlbackup
sudo chmod +x install.sh
sudo bash install.sh
```

## Test

```bash
sudo runsqlbackup
```

## Thư mục sao lưu mặc định

```bash
/var/backups/db/daily/
/var/backups/db/weekly/
/var/backups/db/monthly/
```

## Cấu hình

File: 
```bash
/etc/automysqlbackup/mysqlbackup.cnf
```

Ví dụ:

```bash
BACKUP_DIR="/var/backups/db"

MYSQL_USER="root"
MYSQL_PASSWORD="your_password"

EMAIL_OPTION="no_attachments"
EMAIL_TO="admin@example.com"

RCLONE_REMOTE="gdrive"
RCLONE_SITES="site1,site2"
```

## Restore

```bash
gunzip backup.sql.gz
mysql -u root -p db_name < backup.sql
```

Hoặc:

```bash
zcat backup.sql.gz | mysql -u root -p db_name
```

## Lưu ý
* Tắt evkey, unikey khi chạy cấu hình để tránh lỗi.

## Liên hệ

* [buivanloi.2010@gmail.com](mailto:buivanloi.2010@gmail.com)
