#!/bin/bash

echo "======================================"
echo "  Auto SQL Backup - Setup Wizard"
echo "======================================"
echo ""
echo "1) Tieng Viet"
echo "2) English"
echo ""
read -p "Chon ngon ngu / Select language [1/2, default: 2]: " LANG_CHOICE
LANG_CHOICE=$(echo "$LANG_CHOICE" | xargs)
LANG_CHOICE=${LANG_CHOICE:-2}

if [ "$LANG_CHOICE" = "1" ]; then
  LANG="vi"
else
  LANG="en"
fi

msg() {
  local key="$1"
  local txt=""

  case "$LANG" in
    vi)
      case "$key" in
        mysql_default_info)   txt="Auto SQL Backup dung user root mac dinh, vui long nhap thong tin." ;;
        mysql_enter_user)     txt="Nhap MySQL username [mac dinh: $2]: " ;;
        mysql_user_empty)     txt="Username khong duoc de trong. Vui long nhap lai." ;;
        mysql_enter_pass)     txt="Nhap MySQL password: " ;;
        mysql_pass_empty)     txt="Password khong duoc de trong. Vui long nhap lai." ;;
        mysql_wrong_pass)     txt="Sai username hoac password. Vui long thu lai." ;;
        mysql_ready)          txt="Ket noi MySQL thanh cong! Tiep tuc cau hinh:" ;;
        mysql_config_miss)    txt="Khong tim thay file config $2. Khong the cap nhat." ;;
        step1_title)          txt="Buoc 1: Thu muc luu backup (mac dinh: $2)" ;;
        step1_prompt)         txt="Nhan Enter de dung mac dinh hoac nhap duong dan khac: " ;;
        step1_invalid)        txt="Duong dan khong hop le. Vui long nhap lai." ;;
        step1_ready)          txt="Thu muc backup san sang tai: $2" ;;
        step2_title)          txt="Buoc 2: Kiem tra dich vu gui mail" ;;
        mail_detected)        txt="[${2}] Da phat hien dich vu mail. Ban co muon cau hinh gui email sau khi backup?" ;;
        mail_none)            txt="Server chua cai dich vu mail nao." ;;
        mail_opt_d)           txt="d: Gui mail khong dinh kem" ;;
        mail_opt_n)           txt="n: Khong gui mail" ;;
        mail_opt_y)           txt="y: Gui mail co dinh kem file backup" ;;
        mail_opt_r)           txt="r: Dung rclone de upload backup len cloud" ;;
        mail_prompt)          txt="Chon tuy chon (d/y/n/r): " ;;
        mail_sel_none)        txt="Khong chon, mac dinh: khong gui mail." ;;
        mail_sel_attach)      txt="Se gui mail kem file dinh kem." ;;
        mail_sel_noattach)    txt="Se gui mail khong kem file dinh kem." ;;
        mail_sel_noemail)     txt="Da tat tinh nang gui mail." ;;
        mail_sel_rclone)      txt="Da bat tinh nang upload cloud qua rclone." ;;
        mail_invalid)         txt="Lua chon khong hop le. Vui long nhap 'y', 'd', 'n', hoac 'r'." ;;
        step3_title)          txt="Buoc 3: Cau hinh Email" ;;
        email_enter_to)       txt="Nhap dia chi email nhan thong bao: " ;;
        email_invalid)        txt="Dinh dang email khong hop le. Vui long nhap lai." ;;
        email_enter_sender)   txt="Nhap ten nguoi gui (mac dinh: Admin): " ;;
        email_done)           txt="Cau hinh email hoan tat:" ;;
        email_sender_lbl)     txt="  Ten nguoi gui : $2" ;;
        email_to_lbl)         txt="  Email nhan    : $2" ;;
        email_skipped)        txt="Bo qua cau hinh email." ;;
        step3_rclone_title)   txt="Buoc 3: Cau hinh Rclone" ;;
        rclone_not_installed) txt="[!] rclone CHUA duoc cai tren server nay." ;;
        rclone_install_hint)  txt="    Cai dat sau bang lenh: curl https://rclone.org/install.sh | sudo bash" ;;
        rclone_continue)      txt="    Tiep tuc cai dat... (upload se that bai cho den khi rclone duoc cai va cau hinh)" ;;
        rclone_installed)     txt="[OK] rclone da duoc cai: $2" ;;
        rclone_no_remote)     txt="[!] Chua co remote nao duoc cau hinh. Chay: rclone config" ;;
        rclone_avail_remotes) txt="Cac remote hien co:" ;;
        rclone_remote_prompt) txt="Nhap ten remote muon dung (mac dinh: gdrive): " ;;
        rclone_remote_warn)   txt="[!] CANH BAO: Remote '$2' khong ton tai trong cau hinh rclone." ;;
        rclone_remote_ok)     txt="[OK] Dung remote: $2" ;;
        rclone_sites_intro)   txt="Cau hinh danh sach thu muc tren cloud (de phan loai file backup)." ;;
        rclone_sites_example) txt="Vi du: nbblo.com -> file chua 'nbblo' se duoc upload vao gdrive:nbblo.com/" ;;
        rclone_sites_prompt)  txt="Nhap tung thu muc, nhan Enter de ket thuc." ;;
        rclone_site_input)    txt="  Thu muc $2 (vd: nbblo.com) [Enter de ket thuc]: " ;;
        rclone_site_added)    txt="  [+] Da them: $2" ;;
        rclone_site_invalid)  txt="  Ten thu muc khong hop le (chi chua a-z, 0-9, dau cham, gach ngang). Thu lai." ;;
        rclone_sites_none)    txt="Chua them thu muc nao. Ban co the sua RCLONE_SITES trong /etc/automysqlbackup/mysqlbackup.cnf sau." ;;
        rclone_sites_done)    txt="Cac thu muc da cau hinh: $2" ;;
        rclone_email_notify)  txt="Co muon gui them email thong bao sau khi upload xong? (y/n, mac dinh: n): " ;;
        rclone_email_to)      txt="Nhap dia chi email nhan thong bao: " ;;
        rclone_email_set)     txt="Se gui email thong bao den: $2" ;;
        no_mail_rclone_ask)   txt="Khong co dich vu mail. Ban co muon dung rclone de upload cloud khong?" ;;
        no_mail_rclone_prmpt) txt="Dung rclone? (y/n, mac dinh: n): " ;;
        no_mail_skipped)      txt="Khong co dich vu mail. Bo qua cau hinh email." ;;
        step4_title)          txt="Buoc 4: Cai dat script backup" ;;
        step4_copied)         txt="Da sao chep script vao $2 va cap quyen thuc thi." ;;
        step5_title)          txt="Buoc 5: Tao cau hinh chay hang ngay..." ;;
        rclone_saved)         txt="Da luu cau hinh rclone: remote=$2, sites=$3" ;;
        setup_done)           txt="Cai dat hoan tat! Backup se chay tu dong moi ngay." ;;
        setup_test)           txt="Ban co the chay thu bang lenh: sudo $2" ;;
        setup_missing)        txt="Mot so file bi thieu:" ;;
        *) txt="$key" ;;
      esac
      ;;
    *)
      case "$key" in
        mysql_default_info)   txt="Automatic SQL backup uses root user as default, please enter information." ;;
        mysql_enter_user)     txt="Enter MySQL username [default: $2]: " ;;
        mysql_user_empty)     txt="Username cannot be empty. Please enter a valid username." ;;
        mysql_enter_pass)     txt="Enter MySQL password: " ;;
        mysql_pass_empty)     txt="Password cannot be empty. Please enter a valid password." ;;
        mysql_wrong_pass)     txt="Incorrect username or password. Please try again." ;;
        mysql_ready)          txt="MySQL connection successful! Please proceed with configuration:" ;;
        mysql_config_miss)    txt="Configuration file $2 not found. Unable to update credentials." ;;
        step1_title)          txt="Step 1: Backup Storage Path (default: $2)" ;;
        step1_prompt)         txt="Press Enter to use default or enter a folder path: " ;;
        step1_invalid)        txt="Invalid directory. Please enter a valid directory path." ;;
        step1_ready)          txt="Backup directory is ready at: $2" ;;
        step2_title)          txt="Step 2: Checking for Mail Services" ;;
        mail_detected)        txt="[${2}] service detected. Do you want to configure email notifications?" ;;
        mail_none)            txt="The server has no mail service installed." ;;
        mail_opt_d)           txt="d: Default - send mail without attachments" ;;
        mail_opt_n)           txt="n: No - do not send email" ;;
        mail_opt_y)           txt="y: Yes - send mail with attachments" ;;
        mail_opt_r)           txt="r: Use rclone to upload backups to cloud storage" ;;
        mail_prompt)          txt="Please select an option (d/y/n/r): " ;;
        mail_sel_none)        txt="No option selected, defaulting to no email." ;;
        mail_sel_attach)      txt="Email will be sent with attachments." ;;
        mail_sel_noattach)    txt="Email will be sent without attachments." ;;
        mail_sel_noemail)     txt="Email sending has been disabled." ;;
        mail_sel_rclone)      txt="Rclone cloud upload enabled." ;;
        mail_invalid)         txt="Invalid input. Please enter 'y', 'd', 'n', or 'r'." ;;
        step3_title)          txt="Step 3: Configure Email Settings" ;;
        email_enter_to)       txt="Enter the recipient's email address: " ;;
        email_invalid)        txt="Invalid email format. Please enter a valid email address." ;;
        email_enter_sender)   txt="Enter the sender's name (default: Admin): " ;;
        email_done)           txt="Email configuration completed:" ;;
        email_sender_lbl)     txt="  Sender Name : $2" ;;
        email_to_lbl)         txt="  Recipient   : $2" ;;
        email_skipped)        txt="Email configuration skipped." ;;
        step3_rclone_title)   txt="Step 3: Configure Rclone Settings" ;;
        rclone_not_installed) txt="[!] rclone is NOT installed on this server." ;;
        rclone_install_hint)  txt="    Install it later with: curl https://rclone.org/install.sh | sudo bash" ;;
        rclone_continue)      txt="    Continuing setup... (uploads will fail until rclone is installed and configured)" ;;
        rclone_installed)     txt="[OK] rclone is installed: $2" ;;
        rclone_no_remote)     txt="[!] No rclone remotes configured yet. Run: rclone config" ;;
        rclone_avail_remotes) txt="Available rclone remotes:" ;;
        rclone_remote_prompt) txt="Enter rclone remote name to use (default: gdrive): " ;;
        rclone_remote_warn)   txt="[!] WARNING: Remote '$2' not found in rclone config. Run 'rclone config' to add it." ;;
        rclone_remote_ok)     txt="[OK] Using remote: $2" ;;
        rclone_sites_intro)   txt="Configure cloud folders to organize backup files." ;;
        rclone_sites_example) txt="Example: nbblo.com -> file containing 'nbblo' uploads to gdrive:nbblo.com/" ;;
        rclone_sites_prompt)  txt="Enter folder names one by one. Press Enter with empty input to finish." ;;
        rclone_site_input)    txt="  Folder $2 (e.g. nbblo.com or wordpress) [Enter to finish]: " ;;
        rclone_site_added)    txt="  [+] Added: $2" ;;
        rclone_site_invalid)  txt="  Invalid folder name (only a-z, 0-9, dots, dashes allowed). Try again." ;;
        rclone_sites_none)    txt="No folders added. Edit RCLONE_SITES in /etc/automysqlbackup/mysqlbackup.cnf later." ;;
        rclone_sites_done)    txt="Folders configured: $2" ;;
        rclone_email_notify)  txt="Also send email notification after rclone upload? (y/n, default: n): " ;;
        rclone_email_to)      txt="Enter the recipient's email address: " ;;
        rclone_email_set)     txt="Email notification will be sent to: $2" ;;
        no_mail_rclone_ask)   txt="No mail service detected. Would you like to use rclone for cloud backup instead?" ;;
        no_mail_rclone_prmpt) txt="Use rclone? (y/n, default: n): " ;;
        no_mail_skipped)      txt="No mail service detected (sendmail, exim, postfix). Skipped." ;;
        step4_title)          txt="Step 4: Configure Backup Script" ;;
        step4_copied)         txt="Backup script copied to $2 and set as executable." ;;
        step5_title)          txt="Step 5: Creating daily backup configuration..." ;;
        rclone_saved)         txt="Rclone config saved: remote=$2, sites=$3" ;;
        setup_done)           txt="Setup completed! All database backups are now scheduled to run daily." ;;
        setup_test)           txt="You can test it with: sudo $2" ;;
        setup_missing)        txt="One or more files are missing:" ;;
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

configure_rclone() {
  echo ""
  msg step3_rclone_title
  echo ""

  if ! command -v rclone >/dev/null 2>&1; then
    msg rclone_not_installed
    msg rclone_install_hint
    msg rclone_continue
    echo ""
    RCLONE_REMOTE="gdrive"
    RCLONE_SITES=""
    return
  fi

  msg rclone_installed "$(rclone --version | head -1)"
  echo ""

  EXISTING_REMOTES=$(rclone listremotes 2>/dev/null)
  if [ -z "$EXISTING_REMOTES" ]; then
    msg rclone_no_remote
    echo ""
    RCLONE_REMOTE="gdrive"
  else
    msg rclone_avail_remotes
    echo "$EXISTING_REMOTES" | nl -w2 -s') '
    echo ""
    read -p "$(prompt rclone_remote_prompt)" RCLONE_REMOTE_INPUT
    RCLONE_REMOTE_INPUT=$(echo "$RCLONE_REMOTE_INPUT" | xargs | tr -d ':')
    RCLONE_REMOTE="${RCLONE_REMOTE_INPUT:-gdrive}"

    if ! echo "$EXISTING_REMOTES" | grep -q "^${RCLONE_REMOTE}:"; then
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

  # Hoi gui email kem
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
}

# KIEM TRA MYSQL
DEFAULT_USER="root"
SQL_USER=$(sudo mysql -u "$DEFAULT_USER" -e "exit" 2>&1)

if echo "$SQL_USER" | grep -q "using password: NO"; then
  while true; do
    msg mysql_default_info
    read -p "$(prompt mysql_enter_user "$DEFAULT_USER")" MYSQL_USER
    MYSQL_USER=${MYSQL_USER:-$DEFAULT_USER}
    MYSQL_USER=$(echo "$MYSQL_USER" | tr -cd '\11\12\15\40-\176')
    if [ -z "$MYSQL_USER" ]; then
      msg mysql_user_empty
    else
      break
    fi
  done

  while true; do
    read -sp "$(prompt mysql_enter_pass)" MYSQL_PASSWORD
    echo ""
    MYSQL_PASSWORD=$(echo "$MYSQL_PASSWORD" | xargs)
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

# BUOC 1: THU MUC BACKUP
DEFAULT_DIR="/var/backups/db"
echo ""
msg step1_title "$DEFAULT_DIR"
while true; do
  read -e -i "$DEFAULT_DIR" -p "$(prompt step1_prompt)" BACKUP_DIR
  BACKUP_DIR=$(echo "$BACKUP_DIR" | xargs)
  BACKUP_DIR=${BACKUP_DIR:-$DEFAULT_DIR}
  if [ -d "$BACKUP_DIR" ] || mkdir -p "$BACKUP_DIR"; then
    break
  else
    msg step1_invalid
  fi
done
msg step1_ready "$BACKUP_DIR"

# BUOC 2: KIEM TRA MAIL SERVICE
echo ""
msg step2_title

MAIL_SERVICE=""
if command -v sendmail >/dev/null 2>&1; then
  MAIL_SERVICE="sendmail"
  msg mail_detected "sendmail"
elif command -v exim4 >/dev/null 2>&1; then
  MAIL_SERVICE="exim4"
  msg mail_detected "exim4"
elif command -v postfix >/dev/null 2>&1; then
  MAIL_SERVICE="postfix"
  msg mail_detected "postfix"
else
  msg mail_none
fi

EMAIL_OPTION=""
EMAIL_TO=""
SENDER_NAME=""
RCLONE_SITES=""
RCLONE_REMOTE="gdrive"

# BUOC 3: CAU HINH EMAIL / RCLONE
if [ -n "$MAIL_SERVICE" ]; then
  while true; do
    echo ""
    msg mail_opt_d
    msg mail_opt_n
    msg mail_opt_y
    msg mail_opt_r
    read -p "$(prompt mail_prompt)" SEND_EMAIL
    SEND_EMAIL=$(echo "$SEND_EMAIL" | xargs)

    if [ -z "$SEND_EMAIL" ]; then
      EMAIL_OPTION="no_email"
      msg mail_sel_none
      break
    elif [ "$SEND_EMAIL" = "y" ] || [ "$SEND_EMAIL" = "Y" ]; then
      EMAIL_OPTION="attachments"
      msg mail_sel_attach
      break
    elif [ "$SEND_EMAIL" = "d" ] || [ "$SEND_EMAIL" = "D" ]; then
      EMAIL_OPTION="no_attachments"
      msg mail_sel_noattach
      break
    elif [ "$SEND_EMAIL" = "n" ] || [ "$SEND_EMAIL" = "N" ]; then
      EMAIL_OPTION="no_email"
      msg mail_sel_noemail
      break
    elif [ "$SEND_EMAIL" = "r" ] || [ "$SEND_EMAIL" = "R" ]; then
      EMAIL_OPTION="rclone"
      msg mail_sel_rclone
      break
    else
      echo ""
      msg mail_invalid
    fi
  done

  if [ "$EMAIL_OPTION" = "attachments" ] || [ "$EMAIL_OPTION" = "no_attachments" ]; then
    echo ""
    msg step3_title
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
    msg email_done
    echo ""
    msg email_sender_lbl "$SENDER_NAME"
    msg email_to_lbl "$EMAIL_TO"

  elif [ "$EMAIL_OPTION" = "rclone" ]; then
    configure_rclone

  else
    echo ""
    msg step3_title
    msg email_skipped
    EMAIL_TO=""
    SENDER_NAME=""
  fi

else
  # Khong co mail service
  echo ""
  msg no_mail_rclone_ask
  read -p "$(prompt no_mail_rclone_prmpt)" USE_RCLONE
  if [ "$USE_RCLONE" = "y" ] || [ "$USE_RCLONE" = "Y" ]; then
    EMAIL_OPTION="rclone"
    configure_rclone
  else
    EMAIL_OPTION="no_email"
    EMAIL_TO=""
    SENDER_NAME=""
    echo ""
    msg step3_title
    msg no_mail_skipped
  fi
fi

# BUOC 4: CAI DAT SCRIPT
echo ""
msg step4_title

CRON_DIR="/etc/cron.daily/"
if echo "$PATH" | grep -q "/usr/local/bin"; then
  EXECS_DIR="/usr/local/bin/"
else
  EXECS_DIR="${CRON_DIR}"
fi

EXECS_FILE="${EXECS_DIR}runsqlbackup"
sudo cp ./runsqlbackup "$EXECS_FILE"
sudo chmod +x "$EXECS_FILE"
msg step4_copied "$EXECS_FILE"

# BUOC 5: TAO CRON
echo ""
msg step5_title
CRON_FILE="${CRON_DIR}runsqlbackup"
echo "#!/bin/sh" > "${CRON_FILE}"
echo "/usr/local/bin/runsqlbackup" >> "${CRON_FILE}"
sudo chmod +x "${CRON_FILE}"

CONFIG_DIR="/etc/automysqlbackup/"
CONFIG_FILE="${CONFIG_DIR}mysqlbackup.cnf"
sudo mkdir -p "${CONFIG_DIR}"
sudo cp ./mysqlbackup.cnf "$CONFIG_FILE"
sudo cp ./sendmail "${CONFIG_DIR}/sendmail"

if [ "$BACKUP_DIR" != "/var/backups/db" ]; then
  sudo sed -i "s|^#\?BACKUP_DIR=.*|BACKUP_DIR=\"$BACKUP_DIR\"|" "$CONFIG_FILE"
fi

sudo sed -i "s|^#\?EMAIL_TO=.*|EMAIL_TO=\"$EMAIL_TO\"|" "$CONFIG_FILE"
sudo sed -i "s|^#\?SENDER_NAME=.*|SENDER_NAME=\"$SENDER_NAME\"|" "$CONFIG_FILE"
sudo sed -i "s|^#\?EMAIL_OPTION=.*|EMAIL_OPTION=\"$EMAIL_OPTION\"|" "$CONFIG_FILE"

if [ "$EMAIL_OPTION" = "rclone" ]; then
  sudo sed -i '/^#\?RCLONE_REMOTE=/d' "$CONFIG_FILE"
  sudo sed -i '/^#\?RCLONE_SITES=/d' "$CONFIG_FILE"
  echo "RCLONE_REMOTE=\"${RCLONE_REMOTE}\"" | sudo tee -a "$CONFIG_FILE" > /dev/null
  echo "RCLONE_SITES=\"${RCLONE_SITES}\"" | sudo tee -a "$CONFIG_FILE" > /dev/null
  msg rclone_saved "$RCLONE_REMOTE" "$RCLONE_SITES"
fi

# Revert credential trong file source
sed -i "s|^#\?MYSQL_USER=.*|MYSQL_USER=\"$DEFAULT_USER\"|" "./mysqlbackup.cnf"
sed -i "s|^#\?MYSQL_PASSWORD=.*|MYSQL_PASSWORD=\"\"|" "./mysqlbackup.cnf"

# Xoa ky tu \r khi copy tu Windows
sudo find "$CONFIG_DIR" -type f -exec sed -i 's/\r//g' {} \;
sudo sed -i 's/\r//g' "$EXECS_FILE"

echo ""
if [ -f "$CONFIG_FILE" ] && [ -f "$CRON_FILE" ] && [ -f "$EXECS_FILE" ]; then
  msg setup_done
  echo ""
  msg setup_test "$EXECS_FILE"
else
  msg setup_missing
  [ ! -f "$CONFIG_FILE" ] && echo "  $CONFIG_FILE"
  [ ! -f "$CRON_FILE" ]   && echo "  $CRON_FILE"
  [ ! -f "$EXECS_FILE" ]  && echo "  $EXECS_FILE"
fi
