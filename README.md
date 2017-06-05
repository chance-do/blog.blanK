# Blog

使用 [Hugo](https://gohugo.io)生成的静态网站。

# Usage

如果你没有用过`Hugo`,你可以先到[这里](https://github.com/spf13/hugo/releases)下载安装Hugo。

```
git clone https://github.com/mjyi/blog.blanK.git blog.blanK
cd blog.blanK
git submodule init
git submodule update

hugo server
```
打开浏览器：[http://localhost:1313](http://localhost:1313)

# 配置文件

见 [config.toml](config.toml)

# 更新部署

每次更新文件后使用脚本提交更新。`deploy.sh`

# 更新

2017.6.3 更换主题**Gemini**, 并使用`git submodule`引用。