#!/bin/sh
excfile=$(ls -la | grep -E ^-.{2}x\|^-.{5}x\|^-.{8}x |grep -v .sh | grep -oE '[^ ]+$')
result=$(otool -L $excfile)
array=($result)
i=0
for item in ${array[@]};
do
if echo "${item}" | grep -q '^/usr/local/opt/'; then
changenamearray[i]=$(echo "${item}" | grep -oE '[^/]+$')
changeorg[i++]=$(echo "${item}")
fi

done

i=0
for item in ${changenamearray[@]};
  do
install_name_tool -id "@rpath/${item}" ../Frameworks/${item}
install_name_tool -change "${changeorg[i++]}" "@rpath/${item}" "./${excfile}"
done
#echo ${array[1]}
