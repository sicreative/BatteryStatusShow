#!/bin/sh
excfiles=$(ls -la | grep  -E '.dylib$' | grep -oE '[^ ]+$')

for excfile in ${excfiles[@]};
do
result=$(otool -L $excfile)
array=($result)
i=0
for item in ${array[@]};
do
if echo "${item}" | grep -q '^/usr/local/'; then
changenamearray[i]=$(echo "${item}" | grep -oE '[^/]+$')
changeorg[i++]=$(echo "${item}")
fi

done

i=0
for item in ${changenamearray[@]};
  do
install_name_tool -id "@rpath/${item}" ${item}
install_name_tool -change "${changeorg[i++]}" "@rpath/${item}" "./${excfile}"
done
done
#echo ${array[1]}


