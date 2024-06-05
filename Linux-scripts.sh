#!/bin/bash

# 使脚本在任何命令失败时退出
set -e

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE="\033[0;1;33;93m"
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
PURPLE="\033[0;1;34;94m"
BOLD_WHITE='\033[1;37m'
NC='\033[0m'

# 输出彩色的Linux字符画

echo -e ' +-----------------------------------+'
echo -e " | \033[0;1;35;95m⡇\033[0m  \033[0;1;33;93m⠄\033[0m \033[0;1;32;92m⣀⡀\033[0m \033[0;1;36;96m⡀\033[0;1;34;94m⢀\033[0m \033[0;1;35;95m⡀⢀\033[0m \033[0;1;31;91m⡷\033[0;1;33;93m⢾\033[0m \033[0;1;32;92m⠄\033[0m \033[0;1;36;96m⡀⣀\033[0m \033[0;1;34;94m⡀\033[0;1;35;95m⣀\033[0m \033[0;1;31;91m⢀⡀\033[0m \033[0;1;33;93m⡀\033[0;1;32;92m⣀\033[0m \033[0;1;36;96m⢀⣀\033[0m |"
echo -e " | \033[0;1;31;91m⠧\033[0;1;33;93m⠤\033[0m \033[0;1;32;92m⠇\033[0m \033[0;1;36;96m⠇⠸\033[0m \033[0;1;34;94m⠣\033[0;1;35;95m⠼\033[0m \033[0;1;31;91m⠜⠣\033[0m \033[0;1;33;93m⠇\033[0;1;32;92m⠸\033[0m \033[0;1;36;96m⠇\033[0m \033[0;1;34;94m⠏\033[0m  \033[0;1;35;95m⠏\033[0m  \033[0;1;33;93m⠣⠜\033[0m \033[0;1;32;92m⠏\033[0m  \033[0;1;34;94m⠭⠕\033[0m |"
echo -e ' +-----------------------------------+'
echo "                                        "
echo -e "${PURPLE}欢迎使用 GNU/Linux 更换系统软件源脚本${NC}"
echo -e "${PURPLE}系统时间: $(date '+%Y-%m-%d %H:%M:%S %Z')${NC}"

# Node.js
install_node() {
    echo -e "${BLUE}请选择你要安装的版本: (例: 16.17.0): ${NC} \c" 
    read node_version
    echo -e "${BLUE}正在安装Node版本: v$node_version ${NC}"
    cd /usr/local/src/
    wget https://cdn.npm.taobao.org/dist/node/v${node_version}/node-v${node_version}-linux-x64.tar.xz --no-check-certificate
    tar -xvf node-v${node_version}-linux-x64.tar.xz -C /usr/local/
    cd /usr/local/
    mv node-v${node_version}-linux-x64/ node
    rm -f /usr/local/bin/npm
    rm -f /usr/local/bin/node
    ln -s /usr/local/node/bin/npm /usr/local/bin/
    ln -s /usr/local/node/bin/node /usr/local/bin/
    echo -e "${BLUE}Node.js version:${NC}\c"
    node -v
    echo -e "${BLUE}npm version:${NC}\c"
    npm -v
}

# Nginx
install_nginx() {
    echo -e "${BLUE}请选择你要安装的版本: (例: 1.23.0): ${NC}\c" 
    read nginx_version
    echo -e "${BLUE}正在安装Nginx版本: v$nginx_version ${NC}"
    yum install -y gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel wget vim unzip
    cd /usr/local/src
    wget https://github.com/zhanghao123321/ngx_realtime_request_module-master/archive/refs/heads/main.zip
    unzip main.zip
    wget http://nginx.org/download/nginx-${nginx_version}.tar.gz
    tar -zxvf nginx-${nginx_version}.tar.gz
    mkdir -p /usr/local/webserver/
    cd nginx-${nginx_version}
    ./configure --prefix=/usr/local/webserver/nginx --with-http_stub_status_module --with-http_ssl_module --with-file-aio --with-http_realip_module --with-http_gzip_static_module --with-http_realip_module --add-module=../ngx_realtime_request_module-master-main
    make -j$(nproc) && make -j$(nproc) install
    cd /usr/local/webserver/nginx/conf
    mkdir vhost
    # 定义要插入的行号和文本
    line_number=116
    text_to_insert="include vhost/*.conf;"
    # 使用 sed 在指定行之后插入文本
    sed -i "${line_number}a ${text_to_insert}" /usr/local/webserver/nginx/conf/nginx.conf
    cat <<EOL > /usr/lib/systemd/system/nginx.service
[Unit]
Description=nginx
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/webserver/nginx/sbin/nginx
ExecReload=/usr/local/webserver/nginx/sbin/nginx -s reload
ExecStop=/usr/local/webserver/nginx/sbin/nginx -s quit
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOL
    systemctl daemon-reload
    systemctl start nginx
    systemctl status nginx
    nginx_version=$(/usr/local/webserver/nginx/sbin/nginx -v 2>&1 | awk -F/ '{print$2}')
    echo -e "${BLUE}Nginx: v$nginx_version${NC}"
}

# GO
install_go() {
    echo -e "${BLUE}请选择你要安装的版本: (例: 1.20.1): \c${NC}"
    read go_version
    echo -e "${BLUE}正在安装Go版本: v$go_version${NC}"
    
    # 下载安装包
    yum install -y wget
    cd /usr/local/src/
    wget https://dl.google.com/go/go${go_version}.linux-amd64.tar.gz
    tar -zxvf go${go_version}.linux-amd64.tar.gz -C /usr/local
    
    # 设置环境变量
    echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile
    source /etc/profile
    
    # 检查Go版本
    go_version=$(go version|awk -F'go' '{print $3}'|awk '{print $1}')
    echo -e "${BLUE}Go: v$go_version${NC}"
    
    # 设置go代理
    go env -w GOPROXY=https://goproxy.cn
}

# PHP
install_php() {
    echo -e "${BLUE}请选择你要安装的版本: (例: 7.2.13): \c${NC}"
    read php_version
    echo -e "${BLUE}正在安装PHP版本: v$php_version${NC}"

    # 安装依赖包
    yum install -y gcc gcc-c++ make zlib zlib-devel pcre pcre-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients sqlite-devel openldap-servers libonig-dev php-mcrypt libmcrypt libmcrypt-devel readline-devel autoconf
    
    # 下载安装包并解压
    cd /usr/local/src/
    wget https://www.php.net/distributions/php-${php_version}.tar.gz
    tar -zxvf php-${php_version}.tar.gz
    
    # 编译安装
    cd ${php_version}
    ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-mbstring --enable-ftp --with-gd --with-jpeg-dir=/usr --with-png-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-sockets --with-freetype-dir=/usr --with-zlib --with-libxml-dir=/usr --with-xmlrpc --enable-zip --enable-fpm --enable-xml --enable-sockets --with-gd --with-zlib --with-iconv --enable-zip --with-freetype-dir=/usr/lib/ --enable-soap --enable-pcntl --enable-cli --with-curl --with-openssl --with-pdo-mysql
    make -j$(nproc) && make -j$(nproc) install
    
    # 修改配置文件
    cp php.ini-production /usr/local/php/etc/php.ini
    sed -i 's/post_max_size = 8M/post_max_size = 10M/' /usr/local/php/etc/php.ini
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/' /usr/local/php/etc/php.ini
    sed -i 's/expose_php = On/expose_php = Off/' /usr/local/php/etc/php.ini
    sed -i 's#;error_log = php_errors.log#error_log = /usr/local/php/logs/php_errors.log#' /usr/local/php/etc/php.ini
    sed -i 's#;date.timezone#date.timezone = Asia/Shanghai#' /usr/local/php/etc/php.ini
    sed -i 's#date.timezone = Asia/Shanghai =#date.timezone = Asia/Shanghai#' /usr/local/php/etc/php.ini
    cat /usr/local/php/etc/php.ini | grep date.timezone
    
    cp ./sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
    chmod +x /etc/init.d/php-fpm
    cd /usr/local/php/etc
    mkdir -p /usr/local/php/logs/
    
    # 配置php-fpm
    echo "[global]
    pid = run/php-fpm.pid
    error_log = /usr/local/php/logs/php-fpm.log
    rlimit_files = 655360
    rlimit_core = 0

    [www]
    user = www
    group = www
    listen = 0.0.0.0:9000
    pm = dynamic
    pm.max_children = 500
    pm.start_servers = 10
    pm.min_spare_servers = 10
    pm.max_spare_servers = 20
    pm.max_requests = 1000
    pm.status_path = /fpm-status
    ping.path = /ping-status
    ping.response = ok
    slowlog = /usr/local/php/logs/php-fpm.slow.log
    request_slowlog_timeout = 6s
    rlimit_files = 655360
    rlimit_core = 0
    security.limit_extensions = .php .html
    php_admin_value['date.timezone'] = 'Asia/Shanghai'" > php-fpm.conf

    cd php-fpm.d
    cp www.conf.default www.conf
    useradd www
    sed -i 's/user = nobody/user = www/' www.conf
    sed -i 's/group = nobody/group = www/' www.conf
    
    # 加入服务启动
    /etc/init.d/php-fpm start
    
    # 设置开机自启动
    chkconfig php-fpm on
    chkconfig --list
    
    # 加入全局变量
    echo 'export PATH=/usr/local/php/bin:$PATH' >> ~/.bashrc
    echo 'export PATH=/usr/local/php/sbin:$PATH' >> ~/.bashrc
    source ~/.bashrc
    
    # 检查PHP版本
    php_version=$(php -v |awk '{print $2}'|head -n 1)
    echo -e "${BLUE}PHP: v$php_version${NC}"
}



# 输出软件选择菜单
echo "                                        "
echo "❖  Node.js                            1)"
echo "❖  Nginx                              2)"
echo "❖  Go                                 3)"
echo "❖  PHP                                4)"
echo "❖  Exit                               5)"
# 选择输入
echo -e "${BOLD_WHITE}└─ 请选择并输入你想安装的软件 [1-5]: ${NC}\c" 
read choice

case $choice in
    1)
        install_node
        ;;
    2)
        install_nginx
        ;;
    3)
        install_go
        ;;
    4)    
        install_php
        ;;
    5)
        echo -e "${RED}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting...${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}Installation complete.${NC}"
