#!/bin/bash

# 本地测试博客
# 本地测试正常，推送到Github不一定能build通过=-=

echo
read -rp "bundle config set --local path vendor/bundle? <Y/n> " prompt
if [[ "$prompt" == "Y" || "$prompt" == "y" || "$prompt" == "" ]]; then
    bundle config set --local path vendor/bundle
fi

echo
read -rp "bundle install? <Y/n> " prompt
if [[ "$prompt" == "Y" || "$prompt" == "y" || "$prompt" == "" ]]; then
    bundle install
fi

echo
read -rp "bundle update? <Y/n> " prompt
if [[ "$prompt" == "Y" || "$prompt" == "y" || "$prompt" == "" ]]; then
    bundle update
fi

echo
read -rp "bundle exec jekyll serve? <Y/n> " prompt
if [[ "$prompt" == "Y" || "$prompt" == "y" || "$prompt" == "" ]]; then
    bundle exec jekyll serve
fi
