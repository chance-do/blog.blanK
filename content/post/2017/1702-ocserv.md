---
title: 记OpenConnect VPN server的搭建
date: 2017-02-15 17:15:43
categories:
- 技术文章
tags:
- vpn
- AnyConnect
toc: true
comments: true
---

目前我认为最好用的`VPN`是`shadowsocks`。配合`Chrome`的`SwitchyOmega`可实现是否通过代理服务器访问。

很遗憾在苹果设备上，很好支持`shadowsocks`的`App`的价钱很高。因此只能使用系统支持的`IPSec`，`L2TP`之类的`VPN`
,用起来感觉有2个缺点：连接慢，爱断线。(*应该是我的优化没做好吧。*)

- OpenConnet Server（ocserv）它通过实现Cisco的AnyConnect协议，用DTLS作为主要的加密传输协议。
- AnyConnect的VPN协议默认使用UDP DTLS作为数据传输，但如果有什么网络问题导致UDP传输出现问题，它会利用最初建立的TCP TLS通道作为备份通道，降低VPN断开的概率。

*（ubuntu 和 CentOS 两部分）*

# 一、Ununtu 14.04 LTS 安装ocserv
vps:

- Ubuntu 14.04 LTS
- OpenVZ架构

## 编译ocserv

首先，我们先下载`ocserv`的最新版本.

```bash
wget ftp://ftp.infradead.org/pub/ocserv/ocserv-0.11.7.tar.xz
tar xvf ocserv-0.11.7.tar.xz
cd ocserv-0.11.7

# 添加编译依赖库。
apt-get install libev-dev  build-essential pkg-config libgnutls28-dev libreadline-dev libseccomp-dev libwrap0-dev libnl-nf-3-dev liblz4-dev

# 编译/安装
```bash
./configure

make  
make install
```

## 配置ocserv

参考[官方文档](http://www.infradead.org/ocserv/manual.html)

### 证书

安装证书工具 `apt-get install gnutls-bin`

证书的配置参考[官方文档](http://www.infradead.org/ocserv/manual.html)即可

** 创建CA证书模板 **
```
mkdir certificates
cd certificates

vi ca.tmpl
cn = "Your CA name" 
organization = "Your fancy name" 
serial = 1 
expiration_days = 3650
ca 
signing_key 
cert_signing_key 
crl_signing_key
```

** 生成CA密钥 和 证书 **
```
certtool --generate-privkey --outfile ca-key.pem
certtool --generate-self-signed --load-privkey ca-key.pem --template ca.tmpl --outfile ca-cert.pem
```

**同样，生成服务器证书**
```
vi server.tmpl
cn = "Your hostname or IP" 
organization = "Your fancy name" 
expiration_days = 3650
signing_key 
encryption_key
tls_www_server
```

**生成Server密钥 和 证书**

```
certtool --generate-privkey --outfile server-key.pem

certtool --generate-certificate --load-privkey server-key.pem --load-ca-certificate ca-cert.pem --load-ca-privkey ca-key.pem --template server.tmpl --outfile server-cert.pem

```

将CA，Server证书与密钥复制到以下文件夹

```
cp ca-cert.pem /etc/ssl/private/my-ca-cert.pem
cp server-cert.pem /etc/ssl/private/my-server-cert.pem
cp server-key.pem /etc/ssl/private/my-server-key.pem
```

### 下面准备配置文件
```
mkdir /etc/ocserv
cd ~/ocserv*
cp doc/sample.config /etc/ocserv/ocserv.conf
vi /etc/ocserv/ocserv.conf
```

配置文件可以[官方文档](http://www.infradead.org/ocserv/manual.html)来写，不过这里我们重点要确保以下条目正确。

```
# 登陆方式，目前先用密码登录
auth = "plain[/etc/ocserv/ocpasswd]"

# 允许同时连接的客户端数量
max-clients = 4

# 限制同一客户端的并行登陆数量
max-same-clients = 2

# 服务监听的IP（服务器IP，可不设置）
#listen-host = 1.2.3.4

# 服务监听的TCP/UDP端口（选择你喜欢的数字）
tcp-port = 9000
udp-port = 9001

# 自动优化VPN的网络性能
try-mtu-discovery = true

# 确保服务器正确读取用户证书（后面会用到用户证书）
cert-user-oid = 2.5.4.3

# 服务器证书与密钥
ca-cert = /etc/ssl/private/my-ca-cert.pem
server-cert = /etc/ssl/private/my-server-cert.pem
server-key = /etc/ssl/private/my-server-key.pem

# 客户端连上vpn后使用的dns
dns = 8.8.8.8
dns = 8.8.4.4

# 注释掉所有的route，让服务器成为gateway
#route = 192.168.1.0/255.255.255.0

# 启用cisco客户端兼容性支持
cisco-client-compat = true

#据说可以优化速度
output-buffer = 23000 
try-mtu-discovery = true 
```

### 修改防火墙

修改内核设置，使得支持转发，`vi /etc/sysctl.conf`,将`net.ipv4.ip_forward=0`改为`net.ipv4.ip_forward=1`
保存生效`sysctl -p`。

打开OCserv对应的TCP/UDP端口
```
iptables -A INPUT -p tcp -m state --state NEW --dport 9000 -j ACCEPT
iptables -A INPUT -p udp -m state --state NEW --dport 9001 -j ACCEPT
```
开启NAT转发。
```
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o venet0 -j MASQUERADE
iptables -A FORWARD -s 192.168.1.0/24 -j ACCEPT
```
使用`iptables -t nat -L`来验证转发是否开启成功


### 测试服务器

创建一个帐号

```
ocpasswd -c /etc/ocserv/ocpasswd username
```

启动服务
```
ocserv -f -d 1
```

连接手机测试。。。。


### 免密码登录

 创建客户端证书，免密码登录。
```
cd ~/certificates/
vi user.tmpl

cn = "some random name"
unit = "some random unit"
expiration_days = 365
signing_key
tls_www_client
```

**生成User密钥 生成User证书 ** 
```
certtool --generate-privkey --outfile user-key.pem

certtool --generate-certificate --load-privkey user-key.pem --load-ca-certificate ca-cert.pem --load-ca-privkey ca-key.pem --template user.tmpl --outfile user-cert.pem
```

将证书和密钥转为PKCS12的格式
```
certtool --to-p12 --load-privkey user-key.pem --pkcs-cipher 3des-pkcs12 --load-certificate user-cert.pem --outfile user.p12 --outder
```
输入证书名字和密码。

可以使用web服务将`user.p12`导入手机。

我用的是python的一个简单http服务器命令

```
cd ~/targetfolder
python -m SimpleHTTPServer
```
用`Safari`打开下载。


** 修改认证方式 **
```
vi /etc/ocserv/ocserv.conf

# 改为证书登陆，注释掉原来的登陆模式
auth = "certificate"

# 证书认证不支持这个选项，注释掉这行
#listen-clear-file = /var/run/ocserv-conn.socket

# 启用证书验证
ca-cert = /etc/ssl/private/my-ca-cert.pem
```

同时，我们可以制作一个启动脚本。
```
cd /etc/init.d
ln -s /lib/init/upstart-job ocserv

cd /etc/init
vi  ocserv.conf
```
填入：
```
#!upstart
description "OpenConnect Server"

start on runlevel [2345]
stop on runlevel [06]

respawn
respawn limit 20 5

script
    exec start-stop-daemon --start --pidfile /var/run/ocserv.pid --exec /usr/local/sbin/ocserv -- -f >> /dev/null 2>&1
end script
```
这样，我们就可以使用`service ocserv start`和`service ocserv stop`来控制服务了。

**2017-03-23 增**
# 二、在CentOS 7 安装ocserv

**安装时要注意权限问题**

## 安装

[EPEL](http://fedoraproject.org/wiki/EPEL)仓库白提供`ocserv`，所以可以通过`yum`安装
```bash
yum install epel-release
yum install ocserv
yum install -y gnutls-utils   //证书生成工具
```
## 生成证书（同ubuntu）

## 配置文件

```
#auth = "pam"
#auth = "pam[gid-min=1000]"
#auth = "plain[/etc/ocserv/ocpasswd]"
auth = "certificate"
#auth = "radius[config=/etc/radiusclient/radiusclient.conf,groupconfig=true]"

# Specify alternative authentication methods that are sufficient
# for authentication. That is, if set, any of the methods enabled
# will be sufficient to login.
#enable-auth = "certificate"
#enable-auth = "gssapi"
#enable-auth = "gssapi[keytab=/etc/key.tab,require-local-user-map=true,tgt-freshness-time=900]"

# hostname.
#listen-host = [IP|HOSTNAME]

# TCP and UDP port number
tcp-port = 4443
udp-port = 4443

# The user the worker processes will be run as. It should be
# unique (no other services run as this user).
run-as-user = ocserv
run-as-group = ocserv

# socket file used for server IPC (worker-main), will be appended with .PID
# It must be accessible within the chroot environment (if any), so it is best
# specified relatively to the chroot directory.
socket-file = ocserv.sock

# The default server directory. Does not require any devices present.
chroot-dir = /var/lib/ocserv

# Limit the number of clients. Unset or set to zero for unlimited.
#max-clients = 1024
max-clients = 16

# Limit the number of identical clients (i.e., users connecting 
# multiple times). Unset or set to zero for unlimited.
max-same-clients = 4

# Limit the number of client connections to one every X milliseconds 
# (X is the provided value). Set to zero for no limit.
#rate-limit-ms = 100

# Keepalive in seconds
keepalive = 32400

dpd = 90

mobile-dpd = 1800

switch-to-tcp-timeout = 25

# MTU discovery (DPD must be enabled)
try-mtu-discovery = true


# The Certificate 
#ca-cert = /etc/pki/ocserv/cacerts/ca.crt
ca-cert = /etc/ssl/private/my-ca-cert.pem
server-cert = /etc/ssl/private/my-server-cert.pem
server-key = /etc/ssl/private/my-server-key.pem

#  CN = 2.5.4.3, UID = 0.9.2342.19200300.100.1.1
cert-user-oid = 2.5.4.3

#tls-priorities = "NORMAL:%SERVER_PRECEDENCE:%COMPAT:-VERS-SSL3.0"
tls-priorities = "NORMAL:%SERVER_PRECEDENCE:%COMPAT:-VERS-SSL3.0"

auth-timeout = 240

min-reauth-time = 300

max-ban-score = 50

ban-reset-time = 300
cookie-timeout = 300
deny-roaming = false
rekey-time = 172800
rekey-method = ssl
use-occtl = true

# PID file. It can be overriden in the command line.
pid-file = /var/run/ocserv.pid

# The name to use for the tun device
device = vpns

# Whether the generated IPs will be predictable, i.e., IP stays the
# same for the same user when possible.
predictable-ips = true

# The default domain to be advertised
default-domain = example.com

ipv4-network = 192.168.1.0
ipv4-netmask = 255.255.255.0

# An alternative way of specifying the network:
#ipv4-network = 192.168.1.0/24

# The IPv6 subnet that leases will be given from.
ipv6-network = fda9:4efe:7e3b:03ea::/64

dns = 8.8.8.8
dns = 8.8.4.4

ping-leases = false

output-buffer = 23000

#route = 10.10.10.0/255.255.255.0
#route = 192.168.0.0/255.255.0.0
#route = fef4:db8:1000:1001::/64

cisco-client-compat = true

dtls-legacy = true
```
配置有删减。删去的是默认配置和注释。

## 配置系统设置和防火墙转发

- 为`/etc/sysctl.conf` 添加`net.ipv4.ip_forward=1`. 保存并使其生效`sysctl -p`.
- 配置`iptables`。

```
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o venet0 -j MASQUERADE
iptables -A FORWARD -s 192.168.1.0/24 -j ACCEPT
```

因为有了`ubuntu`上安装的经验，在`CentOS`虽然也遇到了些问题，但都是配置文件没有配置好导致的。

凭借回忆操作写下这些步骤，怕只能下次安装的时候来验证了！

、、over..（又瞎折腾一次。。。。）

iphone 客户端：在`APP Store` 搜索`AnyConnect`。</br>

**参考：**

[官方文档](http://www.infradead.org/ocserv/manual.html)</br>
[https://bitinn.net/11084/](https://bitinn.net/11084/)</br>
[OpenConnect VPN server](https://github.com/iMeiji/shadowsocks_install/wiki/OpenConnect-VPN-server)
