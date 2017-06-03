---
title: Hexo常用的内置标签记录
date: 2016-10-15 15:58:42
categories:
  - 技术文章
tags:
  - Markdown
  - Hexo
comments: true
toc: true
---

## Hexo 标签

「标签」(Tag Plugin) 是 Hexo 提供的一种快速生成特定内容的方式。 在标准 Markdown 中，我们无法指定图片的大小，在这种情景下，我们即可使用标签来解决。 Hexo 内置来许多标签来帮助写作者可以更快的书写， [完整的标签列表](https://hexo.io/docs/tag-plugins.html) 可以参考 Hexo 官网。

### 文本居中的引用
此标签将生成一个带上下分割线的引用，同时引用内文本将自动居中。 文本居中时，多行文本若长度不等，视觉上会显得不对称，因此建议在引用单行文本的场景下使用。 例如作为文章开篇引用 或者 结束语之前的总结引用。

#### 使用方式

- HTML方式：使用这种方式时，给 img 添加属性 class="blockquote-center" 即可。
- 标签方式：使用 centerquote 或者 简写 cq。
此标签要求 NexT 的版本在 0.4.5 或以上。 若你正在使用的版本比较低，可以选择使用 HTML 方式。


#### 标调用方法签

** HTML方式 **
<!-- HTML方式: 直接在 Markdown 文件中编写 HTML 来调用 -->
<!-- 其中 class="blockquote-center" 是必须的 -->
  <blockquote class="blockquote-center">
  	如若你非我不嫁</br>
	彼此终必火化</br>
	一生一世等一天需要代价
  </blockquote>


** 标签方式 **

```
{% blockquote [author[, source]] [link] [source_link_title] %}
content
{% endblockquote %}
```

##### Examples 1: No arguments. Plain blockquote

```
{% blockquote %}
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque hendrerit lacus ut purus iaculis feugiat. Sed nec tempor elit, quis aliquam neque. Curabitur sed diam eget dolor fermentum semper at eu lorem.
{% endblockquote %}

```

{% blockquote %}
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque hendrerit lacus ut purus iaculis feugiat. Sed nec tempor elit, quis aliquam neque. Curabitur sed diam eget dolor fermentum semper at eu lorem.
{% endblockquote %}

##### Examples 2 :Quote from a book

```
{% blockquote David Levithan, Wide Awake %}
Do not just seek happiness for yourself. Seek happiness for all. Through kindness. Through mercy.
{% endblockquote %}
```

{% blockquote David Levithan, Wide Awake %}
Do not just seek happiness for yourself. Seek happiness for all. Through kindness. Through mercy.
{% endblockquote %}

##### Examples 3:Quote from Web

```
{% blockquote @DevDocs https://twitter.com/devdocs/status/356095192085962752 %}
NEW: DevDocs now comes with syntax highlighting. http://devdocs.io
{% endblockquote %}
```

{% blockquote @DevDocs https://twitter.com/devdocs/status/356095192085962752 %}
NEW: DevDocs now comes with syntax highlighting. http://devdocs.io
{% endblockquote %}

## Markdown 语法

### 插入表格

| 一个普通标题 | 一个普通标题 | 一个普通标题 |
| ------| ------ | ------ |
| 短文本 | 中等文本 | 稍微长一点的文本 |
| 稍微长一点的文本 | 短文本 | 中等文本 |

| 左对齐标题 | 右对齐标题 | 居中对齐标题 |
| :------| ------: | :------: |
| 短文本 | 中等文本 | 稍微长一点的文本 |
| 稍微长一点的文本 | 短文本 | 中等文本 |   






 