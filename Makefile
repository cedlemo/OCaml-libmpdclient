.PHONY : documentation
documentation :
	dune build @doc
	find _build/default/_doc/_html/libmpdclient/ -type f |xargs sed -i 's/\.\.\/odoc\.css/odoc\.css/g'
	mv _build/default/_doc/_html/odoc.css _build/default/_doc/_html/libmpdclient/
	rm -rf docs/*
	cp -rf _build/default/_doc/_html/libmpdclient/* docs/
	dune clean

.PHONY : test
test :
	dune runtest
