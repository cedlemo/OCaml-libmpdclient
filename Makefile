.PHONY : documentation
documentation :
	jbuilder build @doc
	find _build/default/_doc/libmpdclient/ -type f |xargs sed -i 's/\.\.\/odoc\.css/odoc\.css/g'
	mv _build/default/_doc/odoc.css _build/default/_doc/libmpdclient/
	rm -rf docs/*
	cp -rf _build/default/_doc/libmpdclient/* docs/
	jbuilder clean

.PHONY : test
test :
	jbuilder runtest
