#!/bin/bash
set -e
start=`date +%s`
file=$1

#编码转化
enca -L zh_CN -x utf-8 $file

tail -n +47 $file | head -n -8 > $file.temp
mv ${file}.temp ${file}

#对于复杂的表达式-regex 比-name好一点
#对每一页处理

echo $file
#提取<span *>，并按重复次数排序，输出到span.txt
sed -n "s/.*\(<span [^>]*>\).*/\1/p" $file | sort -n | uniq -c | sort -rnk 1 | sed -n "s/.*\(<span [^>]*>\).*/\1/p" > ${file}.span.txt

#删除</span>后的换行，方便下一步处理，因为perl的正则替换是按行来的
cat $file | perl -p -e "s/<\/span>\n/<\/span>/g" > ${file}.temp

#设置分隔符
IFS_old=$IFS
IFS=$'\n'
for((i=1;i<=8;i++))
do
    #对每一个span标签处理
    for span in `cat ${file}.span.txt`
    do
        #合并相同的span便签
        perl -p -i -e "s/"${span}"([^<]*)<\/span>"${span}"/"${span}"\1 /g" ${file}.temp
        # echo  ${span}
    done
done
#恢复分隔符
IFS=$IFS_old
sed -i 's/<\/span>/<\/span>\n/g' ${file}.temp
rm -f ${file} ${file}.span.txt
mv ${file}.temp ${file}
