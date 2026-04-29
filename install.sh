#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Vui long chay voi quyen root: sudo bash install.sh"
  exit 1
fi

echo "======================================"
echo "  Auto SQL Backup"
echo "======================================"
echo ""
echo "1) Tiếng Việt"
echo "2) English"
echo ""
read -p "Chọn ngôn ngữ: " BACKUP_LANG_CHOICE
BACKUP_LANG_CHOICE=$(echo "$BACKUP_LANG_CHOICE" | xargs)
BACKUP_LANG_CHOICE=${BACKUP_LANG_CHOICE:-2}

if [ "$BACKUP_LANG_CHOICE" = "1" ]; then
  BACKUP_LANG="vi"
else
  BACKUP_LANG="en"
fi

msg() {
  local key="$1"
  local txt=""

  case "$BACKUP_LANG" in
    vi)
      case "$key" in
        mysql_default_info)   txt="Cần xác thực MySQL, vui lòng nhập thông tin đăng nhập." ;;
        mysql_enter_user)     txt="MySQL username [mặc định: $2]: " ;;
        mysql_user_empty)     txt="Username không được để trống." ;;
        mysql_enter_pass)     txt="MySQL password: " ;;
        mysql_pass_empty)     txt="Password không được để trống." ;;
        mysql_wrong_pass)     txt="Sai username hoặc password, thử lại." ;;
        mysql_ready)          txt="✔ Kết nối MySQL thành công." ;;
        mysql_config_miss)    txt="Không tìm thấy file $2." ;;
        step1_title)          txt="Thư mục lưu backup: " ;;
        step1_invalid)        txt="Đường dẫn không hợp lệ, thử lại." ;;
        step1_ready)          txt="✔ Thư mục backup: $2" ;;
        core_done)            txt="✔ Hoàn thành! Backup sẽ tự chạy mỗi ngày." ;;
        core_test)            txt="  Chạy thử: sudo $2" ;;
        optional_header)      txt="--------------------------------------" ;;
        optional_desc)        txt="Thiết lập thêm (tuỳ chọn):" ;;
        opt_mail_noattach)    txt="  1) Gửi email thông báo" ;;
        opt_mail_attach)      txt="  2) Gửi email kèm file backup" ;;
        opt_rclone)           txt="  3) Upload Google Drive (cần cài rclone)" ;;
        opt_exit)             txt="  0) Bỏ qua" ;;
        optional_prompt)      txt="Chọn [0-3]: " ;;
        optional_invalid)     txt="Nhập 0, 1, 2 hoặc 3." ;;
        optional_done)        txt="✔ Đã lưu cấu hình." ;;
        optional_exit)        txt="Hoàn thành. Chạy lại install.sh bất cứ lúc nào để thiết lập thêm." ;;
        step_email_title)     txt="Cấu hình Email" ;;
        email_enter_to)       txt="Email nhận thông báo: " ;;
        email_invalid)        txt="Email không hợp lệ, thử lại." ;;
        email_enter_sender)   txt="Tên người gửi [mặc định: Admin]: " ;;
        email_done)           txt="✔ Cấu hình email:" ;;
        email_sender_lbl)     txt="  Người gửi : $2" ;;
        email_to_lbl)         txt="  Gửi đến   : $2" ;;
        step_rclone_title)    txt="Cấu hình Rclone / Google Drive" ;;
        rclone_not_installed) txt="[!] rclone chưa được cài trên server này." ;;
        rclone_install_hint)  txt="    Cài sau bằng lệnh: curl https://rclone.org/install.sh | sudo bash" ;;
        rclone_continue)      txt="    Tiếp tục cài đặt... (upload sẽ lỗi cho đến khi cài và cấu hình rclone)" ;;
        rclone_installed)     txt="✔ rclone: $2" ;;
        rclone_no_remote)     txt="[!] Chưa có remote nào. Chạy: rclone config" ;;
        rclone_avail_remotes) txt="Remote hiện có:" ;;
        rclone_remote_prompt) txt="Tên remote [mặc định: gdrive]: " ;;
        rclone_remote_warn)   txt="[!] Remote '$2' không tồn tại trong rclone config." ;;
        rclone_remote_ok)     txt="✔ Dùng remote: $2" ;;
        rclone_sites_intro)   txt="Tên thư mục trên Google Drive để chứa backup." ;;
        rclone_sites_example) txt="Ví dụ: nhập 'omgidol' → upload vào gdrive:omgidol/" ;;
        rclone_sites_prompt)  txt="Nhập từng tên, Enter để tiếp tục." ;;
        rclone_site_input)    txt="  Thư mục $2 (vd: omgidol, myproject) [Enter để tiếp tục]: " ;;
        rclone_site_added)    txt="  [+] $2" ;;
        rclone_site_invalid)  txt="  Tên không hợp lệ (chỉ dùng a-z, 0-9, dấu chấm, gạch ngang)." ;;
        rclone_sites_none)    txt="Chưa thêm thư mục nào. Sửa RCLONE_SITES trong /etc/automysqlbackup/mysqlbackup.cnf sau." ;;
        rclone_sites_done)    txt="✔ Thư mục Drive: $2" ;;
        rclone_email_notify)  txt="Gửi email thông báo sau khi upload xong? (y/n, mặc định: n): " ;;
        rclone_email_to)      txt="Email nhận thông báo: " ;;
        rclone_email_set)     txt="✔ Gửi thông báo đến: $2" ;;
        rclone_saved)         txt="✔ Rclone: remote=$2, thư mục=$3" ;;
        setup_missing)        txt="Thiếu file:" ;;
        *) txt="$key" ;;
      esac
      ;;
    *)
      case "$key" in
        mysql_default_info)   txt="MySQL authentication required, please enter credentials." ;;
        mysql_enter_user)     txt="MySQL username [default: $2]: " ;;
        mysql_user_empty)     txt="Username cannot be empty." ;;
        mysql_enter_pass)     txt="MySQL password: " ;;
        mysql_pass_empty)     txt="Password cannot be empty." ;;
        mysql_wrong_pass)     txt="Wrong username or password, try again." ;;
        mysql_ready)          txt="✔ MySQL connection successful." ;;
        mysql_config_miss)    txt="File not found: $2" ;;
        step1_title)          txt="Backup directory [default: $2]: " ;;
        step1_invalid)        txt="Invalid path, try again." ;;
        step1_ready)          txt="✔ Backup directory: $2" ;;
        core_done)            txt="✔ Done! Backups will run automatically every day." ;;
        core_test)            txt="  Test it: sudo $2" ;;
        optional_header)      txt="--------------------------------------" ;;
        optional_desc)        txt="Optional setup:" ;;
        opt_mail_noattach)    txt="  1) Email notification" ;;
        opt_mail_attach)      txt="  2) Email with backup file attached" ;;
        opt_rclone)           txt="  3) Upload to Google Drive (requires rclone)" ;;
        opt_exit)             txt="  0) Skip" ;;
        optional_prompt)      txt="Choose [0-3]: " ;;
        optional_invalid)     txt="Enter 0, 1, 2 or 3." ;;
        optional_done)        txt="✔ Configuration saved." ;;
        optional_exit)        txt="Done. Re-run install.sh anytime to add more settings." ;;
        step_email_title)     txt="Email Setup" ;;
        email_enter_to)       txt="Recipient email: " ;;
        email_invalid)        txt="Invalid email, try again." ;;
        email_enter_sender)   txt="Sender name [default: Admin]: " ;;
        email_done)           txt="✔ Email configured:" ;;
        email_sender_lbl)     txt="  Sender    : $2" ;;
        email_to_lbl)         txt="  Recipient : $2" ;;
        step_rclone_title)    txt="Rclone / Google Drive Setup" ;;
        rclone_not_installed) txt="[!] rclone is not installed on this server." ;;
        rclone_install_hint)  txt="    Install later: curl https://rclone.org/install.sh | sudo bash" ;;
        rclone_continue)      txt="    Continuing... (uploads will fail until rclone is set up)" ;;
        rclone_installed)     txt="✔ rclone: $2" ;;
        rclone_no_remote)     txt="[!] No remotes configured. Run: rclone config" ;;
        rclone_avail_remotes) txt="Available remotes:" ;;
        rclone_remote_prompt) txt="Remote name [default: gdrive]: " ;;
        rclone_remote_warn)   txt="[!] Remote '$2' not found in rclone config." ;;
        rclone_remote_ok)     txt="✔ Using remote: $2" ;;
        rclone_sites_intro)   txt="Folder names on Google Drive to store backups." ;;
        rclone_sites_example) txt="Example: 'nbblo' → uploads to gdrive:nbblo/" ;;
        rclone_sites_prompt)  txt="Enter one per line, blank to finish." ;;
        rclone_site_input)    txt="  Folder $2 (e.g. nbblo, myproject) [Enter to finish]: " ;;
        rclone_site_added)    txt="  [+] $2" ;;
        rclone_site_invalid)  txt="  Invalid name (use a-z, 0-9, dots, dashes only)." ;;
        rclone_sites_none)    txt="No folders added. Edit RCLONE_SITES in /etc/automysqlbackup/mysqlbackup.cnf later." ;;
        rclone_sites_done)    txt="✔ Drive folders: $2" ;;
        rclone_email_notify)  txt="Send email notification after upload? (y/n, default: n): " ;;
        rclone_email_to)      txt="Recipient email: " ;;
        rclone_email_set)     txt="✔ Notify: $2" ;;
        rclone_saved)         txt="✔ Rclone: remote=$2, folders=$3" ;;
        setup_missing)        txt="Missing files:" ;;
        *) txt="$key" ;;
      esac
      ;;
  esac

  echo "$txt"
}

prompt() {
  local key="$1"
  shift
  msg "$key" "$@" | tr -d '\n'
}

is_valid_email() {
  echo "$1" | grep -E -q "^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,}$"
}

# ══════════════════════════════════════════════
# PHAN 1: SETUP CO BAN (bat buoc)
# ══════════════════════════════════════════════

DEFAULT_USER="root"
SQL_USER=$(mysql -u "$DEFAULT_USER" -e "exit" 2>&1)

if echo "$SQL_USER" | grep -q "using password: NO"; then
  echo ""
  msg mysql_default_info
  echo ""

  while true; do
    read -p "$(prompt mysql_enter_user "$DEFAULT_USER")" MYSQL_USER
    MYSQL_USER=${MYSQL_USER:-$DEFAULT_USER}
    MYSQL_USER=$(echo "$MYSQL_USER" | tr -cd '\11\12\15\40-\176')
    [ -n "$MYSQL_USER" ] && break
    msg mysql_user_empty
  done

  while true; do
    read -sp "$(prompt mysql_enter_pass)" MYSQL_PASSWORD
    echo ""
    if [ -z "$MYSQL_PASSWORD" ]; then
      msg mysql_pass_empty
    else
      CONNECT_TEST=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "exit" 2>&1)
      if echo "$CONNECT_TEST" | grep -q "Access denied"; then
        msg mysql_wrong_pass
      else
        break
      fi
    fi
  done

  CONFIG_FILE="./mysqlbackup.cnf"
  if [ -f "$CONFIG_FILE" ]; then
    sed -i "s|^#\?MYSQL_USER=.*|MYSQL_USER=\"$MYSQL_USER\"|" "$CONFIG_FILE"
    sed -i "s|^#\?MYSQL_PASSWORD=.*|MYSQL_PASSWORD=\"$MYSQL_PASSWORD\"|" "$CONFIG_FILE"
    msg mysql_ready
    echo ""
  else
    msg mysql_config_miss "$CONFIG_FILE"
    exit 1
  fi
fi

# NHAP THU MUC BACKUP
DEFAULT_DIR="/var/backups/db"
echo ""
while true; do
  read -e -i "$DEFAULT_DIR" -p "$(prompt step1_title "$DEFAULT_DIR")" BACKUP_DIR
  BACKUP_DIR=$(echo "$BACKUP_DIR" | xargs)
  BACKUP_DIR=${BACKUP_DIR:-$DEFAULT_DIR}
  if [ -d "$BACKUP_DIR" ] || mkdir -p "$BACKUP_DIR"; then
    break
  else
    msg step1_invalid
  fi
done
msg step1_ready "$BACKUP_DIR"

# GIA TRI MAC DINH
EMAIL_OPTION="no_email"
EMAIL_TO=""
SENDER_NAME=""
RCLONE_SITES=""
RCLONE_REMOTE="gdrive"

# CAI DAT
echo ""
EXECS_FILE="/usr/local/bin/runsqlbackup"
cp ./runsqlbackup "$EXECS_FILE"
chmod +x "$EXECS_FILE"

CRON_DIR="/etc/cron.daily"
CRON_FILE="${CRON_DIR}/runsqlbackup"
echo "#!/bin/sh" | tee "$CRON_FILE" > /dev/null
echo "/usr/local/bin/runsqlbackup" | tee -a "$CRON_FILE" > /dev/null
chmod +x "$CRON_FILE"

CONFIG_DIR="/etc/automysqlbackup"
CONFIG_FILE="${CONFIG_DIR}/mysqlbackup.cnf"
mkdir -p "$CONFIG_DIR"
cp ./mysqlbackup.cnf "$CONFIG_FILE"
cp ./sendmail "${CONFIG_DIR}/sendmail"
chmod 600 "$CONFIG_FILE"

[ "$BACKUP_DIR" != "/var/backups/db" ] && sed -i "s|^#\?BACKUP_DIR=.*|BACKUP_DIR=\"$BACKUP_DIR\"|" "$CONFIG_FILE"
sed -i "s|^#\?EMAIL_TO=.*|EMAIL_TO=\"\"|" "$CONFIG_FILE"
sed -i "s|^#\?SENDER_NAME=.*|SENDER_NAME=\"\"|" "$CONFIG_FILE"
sed -i "s|^#\?EMAIL_OPTION=.*|EMAIL_OPTION=\"no_email\"|" "$CONFIG_FILE"

sed -i "s|^#\?MYSQL_USER=.*|MYSQL_USER=\"$DEFAULT_USER\"|" "./mysqlbackup.cnf"
sed -i "s|^#\?MYSQL_PASSWORD=.*|MYSQL_PASSWORD=\"\"|" "./mysqlbackup.cnf"

find "$CONFIG_DIR" -type f -exec sed -i 's/\r//g' {} \;
sed -i 's/\r//g' "$EXECS_FILE"

chmod 700 "$BACKUP_DIR"
chown root:root "$BACKUP_DIR"

echo ""
msg core_done
msg core_test "$EXECS_FILE"

# ══════════════════════════════════════════════
# PHAN 2: TUY CHON THEM
# ══════════════════════════════════════════════

configure_email() {
  local email_option="$1"
  echo ""
  msg step_email_title
  echo ""

  read -p "$(prompt email_enter_to)" EMAIL_TO
  EMAIL_TO=$(echo "$EMAIL_TO" | tr -cd '\11\12\15\40-\176')
  while ! is_valid_email "$EMAIL_TO"; do
    msg email_invalid
    read -p "$(prompt email_enter_to)" EMAIL_TO
    EMAIL_TO=$(echo "$EMAIL_TO" | tr -cd '\11\12\15\40-\176')
  done

  read -p "$(prompt email_enter_sender)" SENDER_NAME
  SENDER_NAME=$(echo "$SENDER_NAME" | xargs)
  SENDER_NAME=${SENDER_NAME:-Admin}

  echo ""
  msg email_done
  msg email_sender_lbl "$SENDER_NAME"
  msg email_to_lbl "$EMAIL_TO"

  EMAIL_OPTION="$email_option"
}

configure_rclone() {
  echo ""
  msg step_rclone_title
  echo ""

  if ! command -v rclone >/dev/null 2>&1; then
    msg rclone_not_installed
    msg rclone_install_hint
    msg rclone_continue
    echo ""
    RCLONE_REMOTE="gdrive"
    RCLONE_SITES=""
  else
    msg rclone_installed "$(rclone --version | head -1)"
    echo ""
    EXISTING_REMOTES=$(rclone listremotes 2>/dev/null)
    if [ -z "$EXISTING_REMOTES" ]; then
      msg rclone_no_remote
      echo ""
    else
      msg rclone_avail_remotes
      echo "$EXISTING_REMOTES" | nl -w2 -s') '
      echo ""
    fi

    read -p "$(prompt rclone_remote_prompt)" RCLONE_REMOTE_INPUT
    RCLONE_REMOTE_INPUT=$(echo "$RCLONE_REMOTE_INPUT" | xargs | tr -d ':')
    RCLONE_REMOTE="${RCLONE_REMOTE_INPUT:-gdrive}"

    if [ -n "$EXISTING_REMOTES" ] && ! echo "$EXISTING_REMOTES" | grep -q "^${RCLONE_REMOTE}:"; then
      msg rclone_remote_warn "$RCLONE_REMOTE"
    else
      msg rclone_remote_ok "$RCLONE_REMOTE"
    fi
  fi

  echo ""
  msg rclone_sites_intro
  msg rclone_sites_example
  echo ""
  msg rclone_sites_prompt
  echo ""

  SITES_ARRAY=()
  SITE_INDEX=1
  while true; do
    read -p "$(prompt rclone_site_input "$SITE_INDEX")" SITE_INPUT
    SITE_INPUT=$(echo "$SITE_INPUT" | xargs)
    [ -z "$SITE_INPUT" ] && break
    if echo "$SITE_INPUT" | grep -E -q "^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$"; then
      SITES_ARRAY+=("$SITE_INPUT")
      msg rclone_site_added "$SITE_INPUT"
      SITE_INDEX=$((SITE_INDEX + 1))
    else
      msg rclone_site_invalid
    fi
  done

  if [ ${#SITES_ARRAY[@]} -eq 0 ]; then
    msg rclone_sites_none
    RCLONE_SITES=""
  else
    RCLONE_SITES=$(IFS=','; echo "${SITES_ARRAY[*]}")
    echo ""
    msg rclone_sites_done "$RCLONE_SITES"
  fi

  echo ""
  read -p "$(prompt rclone_email_notify)" RCLONE_EMAIL_NOTIFY
  if [ "$RCLONE_EMAIL_NOTIFY" = "y" ] || [ "$RCLONE_EMAIL_NOTIFY" = "Y" ]; then
    read -p "$(prompt rclone_email_to)" EMAIL_TO
    EMAIL_TO=$(echo "$EMAIL_TO" | tr -cd '\11\12\15\40-\176')
    while ! is_valid_email "$EMAIL_TO"; do
      msg email_invalid
      read -p "$(prompt rclone_email_to)" EMAIL_TO
      EMAIL_TO=$(echo "$EMAIL_TO" | tr -cd '\11\12\15\40-\176')
    done
    SENDER_NAME="Admin"
    msg rclone_email_set "$EMAIL_TO"
  else
    EMAIL_TO=""
    SENDER_NAME=""
  fi

  EMAIL_OPTION="rclone"
}

apply_optional_config() {
  sed -i "s|^#\?EMAIL_TO=.*|EMAIL_TO=\"$EMAIL_TO\"|" "$CONFIG_FILE"
  sed -i "s|^#\?SENDER_NAME=.*|SENDER_NAME=\"$SENDER_NAME\"|" "$CONFIG_FILE"
  sed -i "s|^#\?EMAIL_OPTION=.*|EMAIL_OPTION=\"$EMAIL_OPTION\"|" "$CONFIG_FILE"

  if [ "$EMAIL_OPTION" = "rclone" ]; then
    sed -i '/^#\?RCLONE_REMOTE=/d' "$CONFIG_FILE"
    sed -i '/^#\?RCLONE_SITES=/d' "$CONFIG_FILE"
    echo "RCLONE_REMOTE=\"${RCLONE_REMOTE}\"" >> "$CONFIG_FILE"
    echo "RCLONE_SITES=\"${RCLONE_SITES}\"" >> "$CONFIG_FILE"
    msg rclone_saved "$RCLONE_REMOTE" "$RCLONE_SITES"
  fi

  find "$CONFIG_DIR" -type f -exec sed -i 's/\r//g' {} \;
  echo ""
  msg optional_done
}

echo ""
msg optional_header
msg optional_desc
echo ""
msg opt_mail_noattach
msg opt_mail_attach
msg opt_rclone
msg opt_exit
echo ""

while true; do
  read -p "$(prompt optional_prompt)" OPT_CHOICE
  OPT_CHOICE=$(echo "$OPT_CHOICE" | xargs)
  OPT_CHOICE=${OPT_CHOICE:-0}

  case "$OPT_CHOICE" in
    1)
      configure_email "no_attachments"
      apply_optional_config
      break
      ;;
    2)
      configure_email "attachments"
      apply_optional_config
      break
      ;;
    3)
      configure_rclone
      apply_optional_config
      break
      ;;
    0)
      echo ""
      msg optional_exit
      break
      ;;
    *)
      msg optional_invalid
      ;;
  esac
done