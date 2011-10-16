all:
	erlc c1.erl
	gcc port_driver.c -o pr
clean:
	rm pr *.beam *.log *.dump
	ps -A | grep beam.smp| awk '{print $1 }' | xargs echo | xargs -r kill

