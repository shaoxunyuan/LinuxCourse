# 课程数据

本目录存放《Linux 操作系统》课程实验用模拟数据与练习数据生成脚本。

| 文件 | 说明 | 用于实验 |
|------|------|----------|
| `app.log` | 120 行模拟程序运行日志，含 INFO / WARN / ERROR / Error / error 等不同写法 | 实验 5、实验 11 |
| `scores.txt` | 40 行“姓名 成绩”记录，含相邻与不相邻的重复行、个位/两位/三位数成绩 | 实验 6 文本排序与去重 |
| `scores.csv` | 30 行模拟学生成绩表，字段 `Name,Score,Class` | 实验 7、8、11 |
| `create_linux_practice_data.sh` | 生成 `~/LinuxProject` 综合练习数据集（目录、CSV、日志、配置、不同大小与时间戳文件） | 实验 1–11 综合练习 |

## 使用方式

单个实验只需对应文件：把文件拖入 CentOS 课程虚拟机，按实验页面中的目录结构放置即可。

需要完整练习数据集时，在 CentOS 中执行：

```bash
cd ~
bash create_linux_practice_data.sh
# 如需重新生成
bash create_linux_practice_data.sh --reset
```

脚本会在桌面生成 `LinuxProject/`，并建立 `~/LinuxProject` 符号链接。

## 说明

所有数据均为教学模拟数据，不含真实患者信息，不用于临床诊断或真实医疗活动。
