XML = "../XML/xml_tree.erl"
TCP = "../TCP/socket.erl"
UDP = "../UDP/udp.erl"

all: clean socket.beam udp.beam xml_tree.beam manager.beam

manager.beam: manager.erl
	erlc manager.erl

xml_tree.beam:
	erlc $(XML)

socket.beam:
	erlc $(TCP)

udp.beam:
	erlc $(UDP)


AWK='{print $$1}'
clean:
	rm -f *.beam *.dump *.log
	ps -A | grep ' nc'     | awk ${AWK} | xargs echo | xargs -r kill
	ps -A | grep 'beam.smp'| awk ${AWK} | xargs echo | xargs -r kill
	ps -A | grep 'python'| awk ${AWK} | xargs echo | xargs -r kill
	
	
run: all
	./manager.sh
	
show:
	cat erl.log
	

