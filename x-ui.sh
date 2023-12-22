#!/bin/sh
#

red='\033[31m\033[01m'
green='\033[32m\033[01m'
yellow='\033[33m\033[01m'
plain='\033[0m'
echo -e "#############################################################"
echo -e "#                   ${green}Alpine安装x-ui一键脚本${plain}                  #"
echo -e "#                  ${green}作者${plain}: vaxilu,Misaka-blog                 #"
echo "#############################################################"
echo -e "系统: ${GREEN} $(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2) ${PLAIN}"
echo -e "${red}"
read -p "回车键开始安装..."
echo -e "${plain}"

echo "检查安装环境"
apk add curl && apk add bash && apk add sudo && apk add wget
mkdir /lib64 && cp /lib/ld-musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

arch=$(arch)
if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
    arch="amd64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
    arch="arm64"
elif [[ $arch == "s390x" ]]; then
    arch="s390x"
else
    arch="amd64"
    echo -e "${red}检测架构失败，使用默认架构: ${arch}${plain}"
fi
echo "架构: ${arch}"

last_version=$(curl -Ls "https://api.github.com/repos/FranzKafkaYu/x-ui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [[ -z "$last_version" ]]; then
    red "检测 x-ui 版本失败，可能是超出 Github API 限制，正在使用备用源检测最新版本"
    last_version=$(curl -sm8 https://github.com/FranzKafkaYu/x-ui/raw/main/config/version)
    if [[ -z "$last_version" ]]; then
        red "检测 x-ui 版本失败，请确保你的服务器能够连接 Github 服务"
        exit 1
    fi
fi
echo -e "${yellow}检测到 x-ui 最新版本：${last_version}，开始安装${plain}"
curl -Ls https://github.com/FranzKafkaYu/x-ui/releases/download/${last_version}/x-ui-linux-${arch}.tar.gz -o x-ui-linux-${arch}.tar.gz
tar zxvf x-ui-linux-${arch}.tar.gz -C /usr/local && rm x-ui-linux-${arch}.tar.gz -rf
chmod +x /usr/local/x-ui/x-ui /usr/local/x-ui/bin/xray-linux-*

echo "安装Alpine所需文件"
curl -Ls https://github.com/zlcomcn/x-ui-alpine/raw/main/x-ui.db -o x-ui.db
curl -Ls https://github.com/zlcomcn/x-ui-alpine/raw/main/config.json -o config.json
curl -Ls https://github.com/zlcomcn/x-ui-alpine/raw/main/x-ui -o x-ui
mkdir /etc/x-ui && mv x-ui.db /etc/x-ui/
mv x-ui /etc/init.d/
mv config.json  /usr/local/x-ui/bin/
chown 501.dialout /etc/x-ui/x-ui.db
chown 501.dialout /usr/local/x-ui/bin/config.json
chmod +x /etc/init.d/x-ui
chmod 0644 /etc/x-ui/x-ui.db
chmod 0644 /usr/local/x-ui/bin/config.json
rc-update add /etc/init.d/x-ui
/etc/init.d/x-ui start


apk add gcompat
echo -e "${plain}x-ui安装完成"
echo -e "${yellow}出于安全考虑，安装/更新完成后需要强制修改端口与账户密码${plain}"

read -p "请设置您的账户名:" config_account
echo -e "${yellow}您的账户名将设定为:${config_account}${plain}"
read -p "请设置您的账户密码:" config_password
echo -e "${yellow}您的账户密码将设定为:${config_password}${plain}"
read -p "请设置面板访问端口:" config_port
echo -e "${yellow}您的面板访问端口将设定为:${config_port}${plain}"
echo -e "${yellow}确认设定,设定中${plain}"
/usr/local/x-ui/x-ui setting -username ${config_account} -password ${config_password}
echo -e "${yellow}账户密码设定完成${plain}"
/usr/local/x-ui/x-ui setting -port ${config_port}
echo -e "${yellow}面板端口设定完成${plain}"

echo -e "${green}正在启动x-ui...."
/etc/init.d/x-ui restart
echo -e "${plain}全部完成，如果x-ui没启动成功，需要再安装一次"
echo -e "${plain}请不要用x-ui命令管理x-ui！！！直接在web里进行管理"
