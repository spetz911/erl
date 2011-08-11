-module(python).
-export([start/1, stop/0, init/1]).
-export([exec/1]).

start(ExtPrg) ->
    spawn(?MODULE, init, [ExtPrg]).
stop() ->
    python ! stop.

exec(X) ->
    call_port(X).


call_port(Msg) ->
    python ! {call, self(), Msg},
    receive
        {python, Result} -> 
            Result
    end.

init(ExtPrg) ->
    register(python, self()),
    process_flag(trap_exit, true),
    Port = open_port({spawn, ExtPrg}, [{packet, 2}]),
    loop(Port).

loop(Port) ->
    receive
        {call, Caller, Msg} ->
            Port ! {self(), {command, Msg}},
            receive
                {Port, {data, Data}} ->
                    Caller ! {python, Data}
            end,
            loop(Port);
        stop ->
            Port ! {self(), close},
            receive
            {Port, closed} ->
                exit(normal)
            end;
        {'EXIT', Port, Reason} ->
            exit(port_terminated)
    end.

encode({foo, X}) -> [1, X];
encode({bar, Y}) -> [2, Y].

decode([Int]) -> Int.

