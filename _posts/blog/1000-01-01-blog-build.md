---
title: Blog Build
date: 1000-01-01 00:00:00 +0800
categories: [Blog, Build]
tags: [blog]
---

## 搭建网站

使用`Github Pages`搭建网站很简单

- 确定要使用的网站主题，在github上可以通过[`jekyll theme`话题](https://github.com/topics/jekyll-theme)筛选主题
- 阅读主题文档，按照主题文档搭建默认网站，一般就是复制一些`_posts` `_config.yml`之类的文件和文件夹，或者使用其提供的模板仓库，有些主题可能需要使用`Github Actions`
- 添加笔记
- 本地测试，推送测试

```sh
# 本地测试
sudo aptitude install ruby bundler
git clone git@github.com:username/username.github.io
cd username.github.io
bundle config set --local path vendor/bundle
bundle install # 可能很慢，使用代理proxychains bundle install
bundle update
bundle exec jekyll serve
# 推送测试
git push
# 本地测试通过，Github部署不一定能通过，不通过时Github会发送邮件
```
