#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

# 清理旧的构建文件
rm -rf dist

# 构建
npm run build

# 进入生成的文件夹
cd dist

git init
git checkout -b main
git add -A
git commit -m 'deploy'

# 使用 SSH 推送到 GitHub Pages
git push -f git@github.com:tyt0630/image-quality-report-vue2.git main:gh-pages

cd -
