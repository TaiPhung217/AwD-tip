#!/bin/bash

# Hàm để kiểm tra quyền ghi vào thư mục
check_write_permission() {
  directory_path=$1
  if [ ! -w "$directory_path" ]; then
    echo "Không có quyền ghi vào thư mục $directory_path"
    exit 1
  fi
}

# Hàm để tạo tệp .htaccess trong thư mục được chỉ định
create_htaccess() {
  directory_path=$1
  check_write_permission "$directory_path"
  
  htaccess_content="
<Directory \"$directory_path\">
Options -ExecCGI -Indexes
AllowOverride None
RemoveHandler .php .phtml .php3 .pht .php4 .php5 .php7 .shtml
RemoveType .php .phtml .php3 .pht .php4 .php5 .php7 .shtml
php_flag engine off
<FilesMatch \".+\\.ph(p[3457]?|t|tml)$\">
deny from all
</FilesMatch>
"

  htaccess_file="$directory_path/.htaccess"

  echo "$htaccess_content" > "$htaccess_file"
  echo "Tạo hoặc cập nhật tệp .htaccess thành công tại $htaccess_file"
}

# Kiểm tra xem có đối số dòng lệnh được truyền hay không
if [ $# -eq 1 ]; then
  # Trường hợp có đối số dòng lệnh, tạo tệp .htaccess trong thư mục đã chỉ định
  directory_path=$1
  create_htaccess "$directory_path"
else
  # Trường hợp không có đối số dòng lệnh, tìm tất cả các thư mục có tên "uploads" hoặc "upload"
  base_directory=$(pwd)  # Thư mục cơ sở

  find "$base_directory" -type d -iname "uploads" -o -iname "upload" | while read -r directory_path; do
    create_htaccess "$directory_path"
  done
fi
