# Blog

使用 [Hugo](http://hugo.spf13.com)生成的静态网站。

Demo：[https://mjyi.github.io/](https://mjyi.github.io/)。

Hugo 是用Go语言编写的静态网站生成器，它使用简单，效率却非常高，几十个页面生成不到1s。
并且带有`watch`的调试功能。对于markdown 文章，保存修改后。Hugo 会检测到更新并刷新到页面。

# 主题

主题参考了 [http://www.ahonn.me/hexo-theme-even/](http://www.ahonn.me/hexo-theme-even/)，一款`hexo`上的主题。
在theme 目录下,名叫`orange`。因为感觉主题还不是很完善，所以并没用提交 `hugoThemes`。

# Usage

如果你没有用过`Hugo`,你可以先到[这里](https://github.com/spf13/hugo/releases)下载安装Hugo。

```
git clone https://github.com/mjyi/blog.blanK.git blog.blanK
cd blog.blanK
hugo server
```
打开浏览器：[http://localhost:1313](http://localhost:1313)

配置文件

在`config.toml`中
```
title = "Blank's Blog"    	# site title
languageCode = "en-us"
disqusShortname = ""   		# disqus shortname
googleAnalytics = ""		# google analytics
copyright = "Copyright (c) 2015 - 2017, blanK; all rights reserved."
MetaDataFormat = "yaml"
theme = "orange"
[author]
    name = "blanK"

[indexes]
    tag = "tags"
    topic = "topics"

# 自定义的日期格式，主题中有用到。
[Params]
	DateFormat = "2006年01月02日"
```

# 部署

每次更新文件后使用脚本提交更新。`deploy.sh`
