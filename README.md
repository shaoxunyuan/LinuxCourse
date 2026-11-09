南京中医药大学人工智能与信息技术学院

# Linux 操作系统

[![PRESENTATIONS](https://img.shields.io/static/v1?style=flat-square&label=PRESENTATIONS&message=LIVE&color=0284c7&labelColor=333333&logo=github&logoColor=white)](https://shaoxunyuan.github.io/LinuxCourse/Presentations/) [![PRACTICE WEBSITE](https://img.shields.io/static/v1?style=flat-square&label=PRACTICE%20WEBSITE&message=LIVE&color=00c853&labelColor=333333&logo=github&logoColor=white)](https://shaoxunyuan.github.io/LinuxCourse/Practice/)

## 课程结构

- `docs/Practice/`：10 次实验的实验指导（SOP0 课程数据与实验环境 + 实验 1–10）
- `docs/Presentations/`：10 次实验的课堂演示（reveal.js）
- `data/`：实验用模拟数据与练习数据生成脚本
- `scripts/`：页面生成与校验脚本

## 实验目录

| 编号 | 实验 | 主要命令 |
|------|------|----------|
| SOP0 | 认识课程数据与实验环境 | VMware、终端、`~/LinuxProject` |
| 1 | 第一次进入 Linux | `whoami`、`pwd`、`ls`、`cd`、`man` |
| 2 | 文件与目录管理 | `mkdir`、`touch`、`cp`、`mv`、`rm`、通配符 |
| 3 | 文本查看和查找 | `cat`、`more`、`less`、`head`、`tail`、`nl`、`find` |
| 4 | 用户、用户组与权限 | `id`、`chmod`、`chown`、`chgrp`、`sudo` |
| 5 | 文本搜索与统计 | `grep`、`wc`、管道 |
| 6 | 文本排序与去重 | `sort`、`uniq` |
| 7 | 文本字段提取与筛选 | `cut`、`awk` |
| 8 | 文本编辑与替换 | `sed`、Vim / Nano |
| 9 | 文件压缩与解压 | `tar`、`gzip`、`zip` |
| 10 | 系统信息与进程管理 | `ps`、`top`、`df`、`free`、`kill` |

## 本地预览

```bash
cd docs
python3 -m http.server 8000
```

打开 <http://127.0.0.1:8000/>。

## 部署

推送 `main` 分支后，由 `.github/workflows/deploy.yml` 发布 `docs/` 到 GitHub Pages。
