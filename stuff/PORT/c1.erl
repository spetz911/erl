-module(c1).
-export([start/1, stop/0, ini/1]).
-export([foobar/0]).

delay(Time) ->
	receive
    after Time -> ok
    end.

start(ExtPrg) ->
    delay(300),
    spawn(?MODULE, ini, [ExtPrg]),
    delay(300),
    call_port({foo, 3}),
    halt().

stop() ->
    complex ! stop.
foobar() ->
    call_port({foo, 3}).

call_port(Msg) ->
    complex ! {call, self(), Msg},
    receive
	{complex, Result} ->
	    Result
    end.

ini(ExtPrg) ->
    register(complex, self()),
    process_flag(trap_exit, true),
    Port = open_port({spawn, ExtPrg}, [{packet, 2}]),
    loop(Port).

loop(Port) ->
    receive
	{call, Caller, _Msg} ->
	    Port ! {self(), {command, "hello"}},
	    receive
		{Port, {data, Data}} ->
		    Caller ! {complex, decode(Data)}
	    after 1000 ->
	    	io:format("fail~n")
	    end; % ,
	   % loop(Port);
	stop ->
	    Port ! {self(), close},
	    receive
		{Port, closed} ->
		    exit(normal)
	    end;
	{'EXIT', Port, Reason} ->
		io:format("exit: ~p~n", [Reason]),
	    exit(port_terminated)
    end.

decode(Data) -> io:format("~p~n", [Data]).

