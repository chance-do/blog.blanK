# Blog

使用 [Hugo](http://hugo.spf13.com)生成的静态网站。

**[Demo](https://mjyi.github.io/Hugo-theme-Orange/)**

Hugo 是用Go语言编写的静态网站生成器，它使用简单，效率却非常高，几十个页面生成不到1s。
并且带有`watch`的调试功能。对于markdown 文章，保存修改后。Hugo 会检测到更新并刷新到页面。

# Usage

如果你没有用过`Hugo`,你可以先到[这里](https://github.com/spf13/hugo/releases)下载安装Hugo。

```
git clone https://github.com/mjyi/blog.blanK.git blog.blanK
cd blog.blanK
hugo server
```
打开浏览器：[http://localhost:1313](http://localhost:1313)

# 配置文件

见 [config.toml](config.toml)

# 部署

每次更新文件后使用脚本提交更新。`deploy.sh`
