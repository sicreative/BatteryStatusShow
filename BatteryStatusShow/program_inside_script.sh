#!/bin/sh

#  program_inside_script.sh
#  
#
#  Created by slee on 2017/5/27.
#

dir="${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.app/Contents/MacOS/"
excname="${dir}${TARGET_NAME}"
result=$(otool -L ${excname})
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
install_name_tool -id "@rpath/${item}" ${dir}../Frameworks/${item}



install_name_tool -change "${changeorg[i++]}" "@rpath/${item}" "${excname}"
done
#echo ${array[1]}
exit 0
