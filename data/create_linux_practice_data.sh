#!/usr/bin/env bash
# ================================================================
# Linux 文件查看 / 查找 / 文本处理练习数据生成器
# 适用：CentOS / Rocky Linux / AlmaLinux / Ubuntu 等 Bash 环境
#
# 生成内容：
#   1. 桌面 LinuxProject 目录及多级子目录
#   2. 不同时间戳、不同文件类型、不同大小的文件
#   3. 模拟医院患者 CSV、检验 CSV
#   4. 包含 INFO / warning / WARNING / Warning / error / Error / ERROR
#      等关键字的长日志
#   5. 适合 cat / more / less / head / tail / nl / find / grep / awk / sed
#
# 用法：
#   chmod +x create_linux_practice_data.sh
#   ./create_linux_practice_data.sh
#
# 若已经生成过，希望重新生成：
#   ./create_linux_practice_data.sh --reset
# ================================================================

set -euo pipefail
export LC_ALL=C

# ---------- 1. 定位桌面目录 ----------
DESKTOP=""
if command -v xdg-user-dir >/dev/null 2>&1; then
    DESKTOP="$(xdg-user-dir DESKTOP 2>/dev/null || true)"
fi

if [[ -z "$DESKTOP" || "$DESKTOP" == "$HOME" ]]; then
    if [[ -d "$HOME/桌面" ]]; then
        DESKTOP="$HOME/桌面"
    else
        DESKTOP="$HOME/Desktop"
    fi
fi

mkdir -p "$DESKTOP"
TARGET="$DESKTOP/LinuxProject"

# ---------- 2. 是否重新生成 ----------
if [[ -e "$TARGET" ]]; then
    if [[ "${1:-}" == "--reset" ]]; then
        echo "[INFO] 删除旧练习目录：$TARGET"
        rm -rf "$TARGET"
    else
        echo "[ERROR] 目录已经存在：$TARGET"
        echo "如需重新生成，请执行："
        echo "  $0 --reset"
        exit 1
    fi
fi

# ---------- 3. 建立目录结构 ----------
mkdir -p \
    "$TARGET/data/patients" \
    "$TARGET/data/labs" \
    "$TARGET/data/statistics" \
    "$TARGET/logs/system" \
    "$TARGET/logs/application" \
    "$TARGET/logs/archive" \
    "$TARGET/reports/2024" \
    "$TARGET/reports/2025" \
    "$TARGET/reports/2026" \
    "$TARGET/config" \
    "$TARGET/docs/manuals" \
    "$TARGET/docs/notes" \
    "$TARGET/archive/backup" \
    "$TARGET/tmp/cache" \
    "$TARGET/mixed/subdir_A" \
    "$TARGET/mixed/subdir_B/deeper"

# ---------- 工具函数 ----------
random_touch() {
    local path="$1"
    local days=$((RANDOM % 720))
    local hours=$((RANDOM % 24))
    local mins=$((RANDOM % 60))
    local ts
    ts="$(date -d "-${days} days -${hours} hours -${mins} minutes" '+%Y-%m-%d %H:%M:%S')"
    touch -d "$ts" "$path"
}

make_text_file() {
    local file="$1"
    local lines="$2"
    local label="$3"
    : > "$file"
    for i in $(seq 1 "$lines"); do
        printf '%04d | %-18s | sample text for Linux command practice | value=%d\n' \
            "$i" "$label" "$((RANDOM % 1000))" >> "$file"
    done
}

# ---------- 4. README：适合 cat / nl ----------
cat > "$TARGET/README.txt" <<'EOF_README'
LinuxProject - Linux command practice dataset

This directory contains SIMULATED data only.
No real patient information is included.

Main folders:
  data/       simulated hospital CSV files
  logs/       system and application logs
  reports/    text reports from different years
  config/     configuration files for sed practice
  docs/       short and long text files
  archive/    backup and binary-like files
  mixed/      mixed file types and nested folders

Useful keywords inside logs:
  INFO
  warning
  WARNING
  Warning
  error
  Error
  ERROR
  DEBUG
  CRITICAL

The files intentionally have different sizes and timestamps.
EOF_README

# 一个包含空白行的短文本，便于比较 nl 和 nl -ba
cat > "$TARGET/docs/notes/shift_notes.txt" <<'EOF_NOTES'
Morning shift started at 08:00.
Ward A is operating normally.

Two laboratory devices were restarted.
One network timeout was observed.

Please review the evening backup status.
EOF_NOTES

# ---------- 5. 模拟患者病历 CSV ----------
PATIENT_CSV="$TARGET/data/patients/patient_records.csv"
echo "patient_id,sex,age,department,diagnosis,admission_date,stay_days,wbc,crp,temp_c,status" > "$PATIENT_CSV"

sexes=(M F)
departments=(Cardiology Respiratory Neurology Gastroenterology Endocrinology Emergency)
diagnoses=(Hypertension Pneumonia Diabetes Stroke Gastritis Arrhythmia Bronchitis)
statuses=(discharged inpatient followup transferred)

for i in $(seq 1 160); do
    sex="${sexes[$((RANDOM % ${#sexes[@]}))]}"
    age=$((18 + RANDOM % 73))
    dept="${departments[$((RANDOM % ${#departments[@]}))]}"
    diagnosis="${diagnoses[$((RANDOM % ${#diagnoses[@]}))]}"
    days_ago=$((RANDOM % 500))
    admission_date="$(date -d "2026-08-31 -${days_ago} days" '+%Y-%m-%d')"
    stay_days=$((1 + RANDOM % 20))

    wbc10=$((35 + RANDOM % 131))
    wbc="$(printf '%d.%d' $((wbc10 / 10)) $((wbc10 % 10)))"

    crp10=$((RANDOM % 2501))
    crp="$(printf '%d.%d' $((crp10 / 10)) $((crp10 % 10)))"

    temp10=$((360 + RANDOM % 51))
    temp="$(printf '%d.%d' $((temp10 / 10)) $((temp10 % 10)))"

    status="${statuses[$((RANDOM % ${#statuses[@]}))]}"

    printf 'P%04d,%s,%d,%s,%s,%s,%d,%s,%s,%s,%s\n' \
        "$i" "$sex" "$age" "$dept" "$diagnosis" "$admission_date" \
        "$stay_days" "$wbc" "$crp" "$temp" "$status" >> "$PATIENT_CSV"
done

# 更小的患者 CSV，适合直接 cat
cat > "$TARGET/data/patients/patient_demo_small.csv" <<'EOF_SMALL'
patient_id,sex,age,department,diagnosis,status
P9001,F,26,Respiratory,Pneumonia,discharged
P9002,M,71,Cardiology,Hypertension,inpatient
P9003,F,53,Endocrinology,Diabetes,followup
P9004,M,45,Neurology,Stroke,transferred
P9005,F,67,Gastroenterology,Gastritis,discharged
EOF_SMALL

# ---------- 6. 模拟检验数据 CSV ----------
LAB_CSV="$TARGET/data/labs/lab_results.csv"
echo "sample_id,patient_id,test_name,result,unit,flag,test_date" > "$LAB_CSV"

tests=(WBC CRP HGB ALT AST GLU)
units=(10E9_L mg_L g_L U_L U_L mmol_L)
flags=(N N N H L)

for i in $(seq 1 240); do
    patient_no=$((1 + RANDOM % 160))
    idx=$((RANDOM % ${#tests[@]}))
    test="${tests[$idx]}"
    unit="${units[$idx]}"
    result10=$((10 + RANDOM % 2000))
    result="$(printf '%d.%d' $((result10 / 10)) $((result10 % 10)))"
    flag="${flags[$((RANDOM % ${#flags[@]}))]}"
    test_days_ago=$((RANDOM % 400))
    test_date="$(date -d "2026-08-31 -${test_days_ago} days" '+%Y-%m-%d')"
    printf 'S%05d,P%04d,%s,%s,%s,%s,%s\n' \
        "$i" "$patient_no" "$test" "$result" "$unit" "$flag" "$test_date" >> "$LAB_CSV"
done

# ---------- 7. 统计 CSV：方便 awk ----------
cat > "$TARGET/data/statistics/department_summary.csv" <<'EOF_STATS'
department,patients,avg_age,avg_stay_days
Cardiology,128,61.4,7.2
Respiratory,156,57.8,8.6
Neurology,92,63.1,10.4
Gastroenterology,110,49.7,5.8
Endocrinology,134,55.3,4.9
Emergency,205,46.2,1.7
EOF_STATS

# ---------- 8. 生成系统日志：适合 more / less / tail / grep ----------
SYSTEM_LOG="$TARGET/logs/system/system_runtime.log"
: > "$SYSTEM_LOG"

levels=(INFO warning WARNING Warning error Error ERROR DEBUG NOTICE CRITICAL)
services=(network sshd scheduler backup database nginx monitor kernel)
messages=(
    "service started normally"
    "connection timeout detected"
    "retry operation scheduled"
    "disk usage threshold exceeded"
    "authentication attempt recorded"
    "database connection restored"
    "temporary file cleanup completed"
    "configuration reload requested"
    "packet loss detected"
    "backup verification completed"
)

base_epoch="$(date -d '2026-08-01 08:00:00' '+%s')"
for i in $(seq 1 900); do
    ts="$(date -d "@$((base_epoch + i * 180))" '+%Y-%m-%d %H:%M:%S')"
    level="${levels[$((i % ${#levels[@]}))]}"
    service="${services[$((RANDOM % ${#services[@]}))]}"
    message="${messages[$((RANDOM % ${#messages[@]}))]}"
    pid=$((1000 + RANDOM % 8000))
    printf '%s %-8s service=%-10s pid=%d host=centos-lab message="%s"\n' \
        "$ts" "$level" "$service" "$pid" "$message" >> "$SYSTEM_LOG"
done

# ---------- 9. 应用日志：包含患者 ID、HTTP 状态码等 ----------
APP_LOG="$TARGET/logs/application/hospital_app.log"
: > "$APP_LOG"

routes=(/login /patient/list /patient/detail /lab/result /report/export /api/search)
methods=(GET POST PUT)
http_codes=(200 200 200 201 400 401 403 404 500 503)

for i in $(seq 1 520); do
    ts="$(date -d "@$((base_epoch + i * 240))" '+%Y-%m-%d %H:%M:%S')"
    level="${levels[$((RANDOM % ${#levels[@]}))]}"
    route="${routes[$((RANDOM % ${#routes[@]}))]}"
    method="${methods[$((RANDOM % ${#methods[@]}))]}"
    code="${http_codes[$((RANDOM % ${#http_codes[@]}))]}"
    patient="$(printf 'P%04d' $((1 + RANDOM % 160)))"
    elapsed=$((5 + RANDOM % 1200))
    printf '%s %-8s method=%-4s route=%-16s status=%s patient=%s elapsed_ms=%d\n' \
        "$ts" "$level" "$method" "$route" "$code" "$patient" "$elapsed" >> "$APP_LOG"
done

# 专门的错误日志，便于 grep -i error
cat > "$TARGET/logs/application/error_cases.log" <<'EOF_ERR'
2026-08-20 09:10:11 INFO     application boot completed
2026-08-20 09:12:04 warning  cache response slower than expected
2026-08-20 09:13:17 WARNING  memory usage above threshold
2026-08-20 09:15:02 Warning  retrying failed request
2026-08-20 09:18:33 error    cannot connect to database
2026-08-20 09:19:41 Error    patient query timeout
2026-08-20 09:20:12 ERROR    write operation failed
2026-08-20 09:21:50 CRITICAL database unavailable
2026-08-20 09:25:16 INFO     database connection recovered
EOF_ERR

# 归档日志
make_text_file "$TARGET/logs/archive/system_2025.log" 140 "ARCHIVE_LOG"
make_text_file "$TARGET/logs/archive/system_2024.log" 80 "ARCHIVE_LOG"

# ---------- 10. 长文本报告：适合 more / less / head / tail / nl ----------
LONG_REPORT="$TARGET/reports/2026/annual_medical_report.txt"
: > "$LONG_REPORT"
for i in $(seq 1 360); do
    case $((i % 6)) in
        0) section="DATA_QUALITY" ;;
        1) section="PATIENT_FLOW" ;;
        2) section="LAB_ANALYSIS" ;;
        3) section="SYSTEM_STATUS" ;;
        4) section="FOLLOW_UP" ;;
        5) section="SUMMARY" ;;
    esac
    printf 'Line %03d | section=%-14s | hospital simulation report | score=%03d\n' \
        "$i" "$section" "$((RANDOM % 101))" >> "$LONG_REPORT"
    if (( i % 45 == 0 )); then
        echo "" >> "$LONG_REPORT"
    fi
done

cat > "$TARGET/reports/2024/old_report.txt" <<'EOF_OLD'
2024 annual archived report
status=archived
review=completed
owner=teaching_demo
EOF_OLD

cat > "$TARGET/reports/2025/midyear_report.txt" <<'EOF_MID'
2025 midyear report
status=completed
warning_count=18
error_count=7
EOF_MID

cat > "$TARGET/reports/2026/recent_report.txt" <<'EOF_RECENT'
2026 recent report
status=active
warning_count=5
error_count=2
EOF_RECENT

cat > "$TARGET/reports/2026/result_summary.txt" <<'EOF_RESULT'
result_id=R2026-001
samples=240
passed=226
failed=14
status=finished
EOF_RESULT

# ---------- 11. 配置文件：适合 cat / grep / sed ----------
cat > "$TARGET/config/hospital.conf" <<'EOF_CONF'
# Hospital application configuration
app_name=HospitalDemo
mode=production
log_level=INFO
max_connections=100
retry_count=3
timeout_seconds=30
backup_enabled=true
backup_hour=02
report_format=csv
EOF_CONF

cp "$TARGET/config/hospital.conf" "$TARGET/config/hospital.conf.bak"

cat > "$TARGET/config/database.conf" <<'EOF_DB'
host=127.0.0.1
port=5432
database=hospital_demo
user=readonly_user
pool_size=20
ssl=false
EOF_DB

# ---------- 12. Markdown / JSON / 其他文本类型 ----------
cat > "$TARGET/docs/manuals/command_notes.md" <<'EOF_MD'
# Linux Text Command Notes

This is a simulated Markdown document.

Topics:
- cat
- more
- less
- head
- tail
- nl
- find
- grep
- awk
- sed
EOF_MD

cat > "$TARGET/data/statistics/summary.json" <<'EOF_JSON'
{
  "hospital": "Teaching Hospital Demo",
  "patients": 160,
  "lab_records": 240,
  "status": "simulated",
  "alerts": {
    "warning": 12,
    "error": 5
  }
}
EOF_JSON

# ---------- 13. mixed 中随机生成若干不同长度文本文件 ----------
for i in $(seq 1 12); do
    lines=$((5 + RANDOM % 180))
    case $((i % 4)) in
        0) ext="txt" ;;
        1) ext="log" ;;
        2) ext="dat" ;;
        3) ext="bak" ;;
    esac
    make_text_file "$TARGET/mixed/sample_$(printf '%02d' "$i").$ext" "$lines" "MIXED_$ext"
done

# 隐藏文件，便于 find 练习
cat > "$TARGET/mixed/.hidden_notes.txt" <<'EOF_HIDDEN'
This is a hidden text file.
keyword=hidden
status=demo
EOF_HIDDEN

# ---------- 14. 不同大小的文件：方便 find -size ----------
# 这些文件主要用于大小查找，不建议 cat。
dd if=/dev/zero of="$TARGET/archive/backup/tiny_backup.bin"   bs=1024 count=2    2>/dev/null
dd if=/dev/zero of="$TARGET/archive/backup/small_backup.bin"  bs=1024 count=16   2>/dev/null
dd if=/dev/zero of="$TARGET/archive/backup/medium_backup.bin" bs=1024 count=128  2>/dev/null
dd if=/dev/zero of="$TARGET/archive/backup/large_backup.bin"  bs=1024 count=1024 2>/dev/null

# ---------- 15. 空文件和临时文件 ----------
: > "$TARGET/tmp/empty_file.txt"
: > "$TARGET/tmp/cache/cache_001.tmp"
: > "$TARGET/tmp/cache/cache_002.tmp"

# ---------- 16. 为所有文件随机设置不同修改时间 ----------
while IFS= read -r -d '' f; do
    random_touch "$f"
done < <(find "$TARGET" -type f -print0)

# 目录时间最后设置，否则创建文件会再次改变目录时间
while IFS= read -r -d '' d; do
    random_touch "$d"
done < <(find "$TARGET" -type d -print0)

# ---------- 17. 设置几个确定的时间，保证课堂 find 时间条件有稳定结果 ----------
touch -d '2024-01-15 08:30:00' "$TARGET/reports/2024/old_report.txt"
touch -d '2025-06-01 12:00:00' "$TARGET/reports/2025/midyear_report.txt"
touch -d '2026-08-30 09:00:00' "$TARGET/reports/2026/recent_report.txt"
touch -d '2026-08-31 18:00:00' "$TARGET/logs/application/error_cases.log"
touch -d '2026-08-31 20:00:00' "$TARGET/data/patients/patient_records.csv"

# ---------- 18. 建立 ~/LinuxProject 符号链接 ----------
# 这样既能在桌面看到目录，也能直接使用 ~/LinuxProject 做 find 练习。
ALIAS="$HOME/LinuxProject"
ALIAS_MSG=""
if [[ "$TARGET" != "$ALIAS" ]]; then
    if [[ -L "$ALIAS" ]]; then
        ln -sfn "$TARGET" "$ALIAS"
        ALIAS_MSG="已更新符号链接：$ALIAS -> $TARGET"
    elif [[ ! -e "$ALIAS" ]]; then
        ln -s "$TARGET" "$ALIAS"
        ALIAS_MSG="已创建符号链接：$ALIAS -> $TARGET"
    else
        ALIAS_MSG="注意：$ALIAS 已存在且不是符号链接，因此未覆盖。"
    fi
fi

# ---------- 19. 输出结果 ----------
file_count="$(find "$TARGET" -type f | wc -l)"
dir_count="$(find "$TARGET" -type d | wc -l)"

cat <<EOF_DONE

============================================================
练习数据生成完成
============================================================
桌面目录：$TARGET
文件数量：$file_count
目录数量：$dir_count
$ALIAS_MSG

可以先执行：
  cd ~/LinuxProject
  ls -lh
  find . -type f | head

适合练习的典型文件：
  README.txt
  docs/notes/shift_notes.txt
  reports/2026/annual_medical_report.txt
  data/patients/patient_records.csv
  data/labs/lab_results.csv
  logs/system/system_runtime.log
  logs/application/hospital_app.log
  logs/application/error_cases.log
  config/hospital.conf

示例练习：
  cat README.txt
  nl -ba docs/notes/shift_notes.txt
  more reports/2026/annual_medical_report.txt
  less logs/system/system_runtime.log
  head -n 5 data/patients/patient_records.csv
  tail -n 10 logs/application/hospital_app.log
  find . -type f -name "*.csv"
  find . -type f -size +100k
  grep -in "error" logs/application/error_cases.log
  grep -E "WARNING|ERROR|CRITICAL" logs/system/system_runtime.log | head
  awk -F, 'NR>1 && \$3>=65 {print \$1, \$3, \$4}' data/patients/patient_records.csv | head
  sed -n '1,10p' config/hospital.conf
  sed 's/log_level=INFO/log_level=DEBUG/' config/hospital.conf
============================================================
EOF_DONE
