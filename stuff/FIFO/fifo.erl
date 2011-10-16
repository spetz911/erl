-module(fifo).
-export([send2io/0, server/1, get_hash/1]).

server(Path) ->
	A = net_adm:ping(rdr@spetz),
	B = net_adm:ping(ber@spetz),
	{client, rdr@spetz} ! "Hello, man!",
	{client, ber@spetz} ! "Hello, woman!",
	{client, rdr@spetz} ! {'Exit', "bye"},
	{client, ber@spetz} ! {'Exit', "bye"},
	
	
	{_,F} = file:open(Path, [append]),
	io:format(F, "status: ~p ~p ~p ~n", [A, B, node()]),
	file:close(F).


send2io() ->
	io:format("~p~n", [node()]),
	register( client, self()),
	send2io(nothing).


send2io(X) ->
	receive
		{'Exit', Reason} ->
			io:format("~p~n", [Reason]),
			halt();
		Msg ->
			io:format("~p~n", [Msg])
	end,
	send2io(X).
	
	
%% TODO need start:crypto() before 
get_hash(Key) ->
	% key must be list|binary!
	L1 = binary_to_list(crypto:sha(Key)),
	L2 = binary_to_list(crypto:rand_bytes(20)),
	lists:zipwith(fun(X, Y) -> (X+Y) rem 256 end, L1, L2).
%% TODO need stop:crypto() after







