all: xml_tree.beam

xml_tree.beam:
	erlc xml_tree.erl
clean:
	rm -f *.beam *.dump *.log
run:
	erl -noshell -run xml_tree test test.xml -s erlang halt

