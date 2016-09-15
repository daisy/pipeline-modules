#!/bin/bash

# run from whatever directory you'd like; will check all projects with a catalog.xml file under current directory

for catalog in $(find -type f | grep -v "\s" | grep src/main/resources/META-INF/catalog.xml); do
    resource_dir=$(cd `dirname $catalog` && cd .. && pwd)
    module_name=`echo $resource_dir | sed 's/\/src\/main\/.*//' | sed 's/.*\///'`
    cat $catalog | sed ':a;N;$!ba;s/\n/ /g' | sed 's/</\n</g' | grep nextCatalog | sed 's/.*catalog="//' | sed 's/".*//' \
                 | sort > /tmp/check-dependencies.catalog
    find $resource_dir -type f | grep src/main | grep "x[ps]l$" | xargs cat | sed ':a;N;$!ba;s/\n/ /g' | sed 's/</\n</g' \
                 | grep "http:" | grep "href=\"" | sed 's/.*href="http:\/*//' | sed 's/".*//' \
                 | sed 's/^\([^\/]*\.\)*\([^\.\/]\+\)\.\([^\.\/]\+\)\/\(.*\)\/[^\/]*$/\3:\2:\4/' | tr '/' ':' \
                 | sed 's/modules:\([^:]*\):.*/modules:\1/' \
                 | grep -v ":$module_name$" \
                 | grep -v "^com:xmlcalabash:extension:steps$" \
                 | grep -v ":$" | grep -v "^org:w3:" | grep -v "^org:idpf:epub:30:spec$" | grep -v xmlns | grep -v "^com:google:p:.*:wiki$" \
                 | sort | uniq | sort > /tmp/check-dependencies.code
    if [ "`diff /tmp/check-dependencies.catalog /tmp/check-dependencies.code | wc -l`" = "0" ]; then
        echo "$module_name: ok"
    else
        echo
        echo "$module_name:"
        diff /tmp/check-dependencies.catalog /tmp/check-dependencies.code | grep "[><]" | sed 's/>/   only in code: /' | sed 's/</only in catalog: /'
    fi
done
