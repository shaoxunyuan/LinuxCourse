import random
from collections import Counter, defaultdict

random.seed(20261021)

# 真实感更强的双段拼音姓名代号（无空格，单 token）
names = ["ZhangWei","LiMing","WangFang","ZhaoLei","ChenJing","LiuYang","SunHao",
         "WuTong","ZhouMin","XuKai","HuYan","GuoQiang","LinNa","HePing","GaoYuan",
         "LuoXi","HanXue","DengYu","FengLei","CaoBin","YangFan","HuangRui","ZhuJun",
         "QinWei","MaTao"]

req = [(9,"LiMing"),(10,"WangFang"),(85,"ZhangWei"),(92,"ChenJing"),(100,"ZhaoLei")]

distinct = set(req)
while len(distinct) < 100:
    s = random.randint(0, 100)
    n = random.choice(names)
    distinct.add((s, n))

distinct = list(distinct)
random.shuffle(distinct)

unique_records = distinct[:40]
dup_records = distinct[40:100]   # 60 条将重复

mults = [2]*30 + [3]*20 + [4]*10
random.shuffle(mults)
dup_with_mult = list(zip(dup_records, mults))

blocks = []
for rec in unique_records:
    blocks.append([rec])
random.shuffle(dup_with_mult)
adjacent = dup_with_mult[:25]
scattered = dup_with_mult[25:]   # 35
for rec, m in adjacent:
    blocks.append([rec]*m)
for rec, m in scattered:
    for _ in range(m):
        blocks.append([rec])

total = sum(len(b) for b in blocks)
assert total == 200, total

random.shuffle(blocks)
lines = []
for b in blocks:
    for rec in b:
        lines.append(f"{rec[0]} {rec[1]}")

c = Counter(lines)
distinct_count = len(c)
dup_distinct = sum(1 for v in c.values() if v >= 2)
uniq_distinct = sum(1 for v in c.values() if v == 1)
assert distinct_count >= 60 and dup_distinct >= 20 and uniq_distinct >= 10

adj = 0
i, n = 0, len(lines)
while i < n:
    j = i
    while j+1 < n and lines[j+1] == lines[i]:
        j += 1
    if j > i:
        adj += 1
    i = j + 1

sep = 0
pos = defaultdict(list)
for idx, l in enumerate(lines):
    pos[l].append(idx)
for l, idxs in pos.items():
    if len(idxs) >= 2:
        runs = 1
        for k in range(1, len(idxs)):
            if idxs[k] != idxs[k-1] + 1:
                runs += 1
        if runs > 1:
            sep += 1

name_scores = defaultdict(set)
for l in lines:
    s, nm = l.split()
    name_scores[nm].add(int(s))
multi = sum(1 for v in name_scores.values() if len(v) >= 2)
has_req = all(any(l.split()[0] == str(x) for l in lines) for x in [9,10,85,92,100])

print("总行数:", len(lines))
print("不同整行记录种数:", distinct_count)
print("重复记录(>=2次)种数:", dup_distinct)
print("恰好一次记录种数:", uniq_distinct)
print("相邻重复组数:", adj)
print("分散重复组数:", sep)
print("同名不同成绩姓名数:", multi)
print("含关键分数 9/10/85/92/100:", has_req)
print("---- 文件开头 10 行 ----")
for l in lines[:10]:
    print(l)

with open(r"d:/WPSCloud/GithubDesktopRepo/LinuxCourse/docs/Presentations/scores.txt",
          "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines) + "\n")
print("已写出 scores.txt")
