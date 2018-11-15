一行 Shell 通过 Nginx access 日志实时统计单台机器QPS
# 实时统计
 
## 方式一

tail -f access.log | awk -F '[' '{print $2}' | awk 'BEGIN{key="";count=0}{if(key==$1){count++}else{printf("%s\t%d\r\n", key, count);count=1;key=$1}}'

 
## 方式二

tail -f access.log | awk -F '[' '{print $2}' | awk '{print $1}' | uniq -c

 
 
 
# 非实时按秒统计QPS

cat access.log | awk -F '[' '{print $2}' | awk '{print $1}' | sort | uniq -c |sort -k1,1nr
