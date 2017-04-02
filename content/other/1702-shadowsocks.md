---
title: VPS:搭建shadowsocks服务器
thumbnail: 
date: 2017-02-14 12:33:16
topics:
- VPN
tags:
- shadowsocks
- vpn
---

[shadowsocks](https://github.com/shadowsocks/shadowsocks/tree/master)有多个版本，目前相对稳定的是`python`版本和`C`版本(shadowsocks-libev),前者可以通过配置开启多端口，`libev`版本不能通过修改配置文件来多端口，只能开启多进程，但是后者占用内存小，cpu消耗少。
<!--more-->
## 安装

我的`VPS`已经安装好了`Ubuntu 14.04 x86 `系统，内存`512MB`尚可。

下面来安装[shadowsocks](https://github.com/shadowsocks/shadowsocks/tree/master)

通过`pip`安装`pyhton`
```
apt-get install python-pip
pip install shadowsocks
```
第一步就卡住了，/尴尬。
```
Reading package lists... Done
Building dependency tree       
Reading state information... Done
E: Unable to locate package python-pip
```

解决方法：
```
wget -P Downloads/ https://svn.apache.org/repos/asf/oodt/tools/oodtsite.publisher/trunk/distribute_setup.py

python Downloads/distribute_setup.py

easy_install pip
```

## 使用

```
ssserver -p 443 -k password -m aes-256-cfb

## 后台运行
sudo ssserver -p 443 -k password -m aes-256-cfb --user nobody -d start

## 停止
sudo ssserver -d stop

## 日志
sudo less /var/log/shadowsocks.log
```

## 使用配置文件

创建 `/etc/shadowsocks.json`.

```
{
    "server":"my_server_ip",
    "server_port":8388,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"mypassword",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false
}
```

运行

```
ssserver -c /etc/shadowsocks.json

后台运行
ssserver -c /etc/shadowsocks.json -d start
ssserver -c /etc/shadowsocks.json -d stop
```

## 后记

至此，`shadowsocks`服务器端就搭建完成了。

附Shadowsocks for OSX下载地址:[https://sourceforge.net/projects/shadowsocksgui/](https://sourceforge.net/projects/shadowsocksgui/)





