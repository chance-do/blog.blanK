---
date: 2017-04-05T14:17:51+08:00
description: ""
tags:
- 开发环境
- sublime
- cocoapods
title: "Mac开发的一些基本配置"
categories:
- 备忘
comments: true
toc: true
---
>工欲善其事，必先利其器。

记一些作为iOS开发必装的工具包。

# Homebrew
**macOS 的包管理工具，许多开发用到的工具都由它安装**</br>
详见：[Homebrew](https://brew.sh/)

- Install [Homebrew](https://brew.sh/)

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

# Cocoapods

## Install Cocoapods
```
# 换源
gem sources --remove https://rubygems.org/
gem sources --add https://gems.ruby-china.org/
# 更新gem
sudo gem update --system
sudo gem install cocoapods
# 遇到问题（?usr/bin?）
# sudo gem install -n /usr/local/bin cocoapods
pod setup
```

## Using
```
#Init
pod init

# open source
source 'https://github.com/CocoaPods/Specs.git'

# my work
source 'https://github.com/Artsy/Specs.git'

target 'App' do

  pod 'Artsy+UIColors'
  pod 'Artsy+UIButtons'

  pod 'FLKAutoLayout'
  pod 'ISO8601DateFormatter', '0.7'
  pod 'AFNetworking', '~> 2.0'

  target 'AppTests' do
    inherit! :search_paths
    pod 'FBSnapshotTestCase'
    pod 'Quick'
    pod 'Nimble'
  end
end
```

# Sublime Text 3
下载安装[Sublime Text 3](https://www.sublimetext.com/3).</br>
关于`Sublime Text 3`的[相关文档](http://feliving.github.io/Sublime-Text-3-Documentation/)。

关于上述文档中关于 OS X Command Line 的描述有些许不完善的地方。
```
//具体路径参照用户所安装的目录。
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ~/bin/subl
```
执行上面的命令往往会报一些权限的问题。
因为在EI Capitan 以及更高的系统版本中，用户是没有对`usr/bin`的写的权限的。
但是我们可以写入`usr/local/bin`中，因为一般情况下，它也是用户的默认路径。

```
sudo rm /usr/local/bin/subl
sudo ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl
```

- 插件
	+ [Package Control](https://packagecontrol.io)

	```
	ctrl + ` OR View>Show Console
	###################Copy - Paste######################
	
	import urllib.request,os,hashlib; h = 'df21e130d211cfc94d9b0905775a7c0f' + '1e3d39e33b79698005270310898eea76'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
	```
	+ OmniMarkupPreviewer
	+ HTML-CSS-JS Prettify
	+ SublimeCodeIntel
	+ Material Theme
	+ Emmet
	+ GoSublime
	+ SideBarEnhancements
- 配置</br>
主要是对 `Material` 主题的配置
```
{
	"always_show_minimap_viewport": true,
	"bold_folder_labels": true,
	"color_scheme": "Packages/Material Theme/schemes/Material-Theme.tmTheme",
	"font_options":
	[
		"gray_antialias",
		"subpixel_antialias"
	],
	"ignored_packages":
	[
	],
	"indent_guide_options":
	[
		"draw_normal",
		"draw_active"
	],
	"line_padding_bottom": 2,
	"line_padding_top": 2,
	"material_theme_contrast_mode": true,
	"material_theme_small_tab": true,
	"material_theme_tabs_separator": true,
	"overlay_scroll_bars": "enabled",
	"theme": "Material-Theme.sublime-theme"
}
```
主题很美观。

![](/media/sublime_snapshot.png)

# 为git设置代理

首先要安装`shadowsocks`,然后为`git`配置全局代理：
```
git config --global http.proxy 'socks5://127.0.0.1:1080'
git config --global https.proxy 'socks5://127.0.0.1:1080'
```
Over!.
