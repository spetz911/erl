%% ---
%%  Excerpted from "Programming Erlang",
%%  published by The Pragmatic Bookshelf.
%%  Copyrights apply to this code. It may not be used to create training material, 
%%  courses, books, articles, and the like. Contact us if you are in doubt.
%%  We make no guarantees that this code is fit for any purpose. 
%%  Visit http://www.pragmaticprogrammer.com/titles/jaerlang for more book information.
%%---
-module(udp).
-compile(export_all).

% 1> {ok, S} = gen_udp:open(9002).
% {ok,#Port<0.516>}
% 2> gen_udp:send( S, "localhost", 9001, <<"hello">>).
% ok
% [20:23:06 MSD] Олег Баскаков: 5> {ok,S} = gen_udp:open(9001).
% {ok,#Port<0.528>}
% 6> flush().
% Shell got {udp,#Port<0.528>,{127,0,0,1},9002,"hello"}

client_udp() ->
	{ok,Sock} = gen_udp:open(9000),
	cli_loop(Sock).
	
cli_loop(Sock) ->
	receive
		{udp,_,_,_,"Exit"}	->
			io:fwrite("bye~n"),
			halt();
		{udp,_,_,Port,Msg}	->
			io:format("~p~n", [Msg]),
			gen_udp:send(Sock, "localhost", Port, <<"ok">>);
		Other ->
			io:format("~p~n", [Other])
	end,
	cli_loop(Sock).


send_udp(Data) ->
	send_udp("localhost", _Port = 9001, Data, _Times = 2).


send_udp(Host, Port, Data, Times) ->
    case gen_udp:open(Port) of
	{ok,Socket} ->
		_K = send(Socket, Host, 9000, Data, Times),
		ok = gen_tcp:close(Socket);
	{error,Error} when (Times > 0) ->
		io:format("~p~n", [Error]),
		receive % reconnect after 1s
		after 1000 ->
			send_udp(Host, Port, Data, Times-1)
		end
    end.

send(Sock, Host, Port, Data, Times) ->
	ok = gen_udp:send(Sock, Host, Port, Data),
	receive
		{udp,_,Host1,Port, Msg = "ok"}	->
			io:format("~p ~p~n", [Host1, Msg]);
		Error ->
			io:format("~p~n", [Error])
	after % when, without tail
		1000 -> 
			[send(Sock, Host, Port, Data, Times-1) || (Times > 0)]	
	end.

%%% some trash:

send_data(Host, Port, Data, Times) ->
    case gen_tcp:connect(Host,Port,[binary, {packet, 0}]) of
	{ok,Socket} ->
    	ok = gen_tcp:send(Socket, Data),
		ok = gen_tcp:close(Socket);
	{error,econnrefused} ->
		io:format("try connect to server~n"),
		receive
		after 1000 ->
			if (Times > 0) -> send_data(Host, Port, Data, Times-1);
			   true        -> ok
			end
		end
    end.

get_url() ->
    get_url("127.0.0.1", 9000).

get_url(Host, Port) ->
    case gen_tcp:connect(Host,Port,[binary, {packet, 0}]) of %% (1)
	{error,econnrefused} ->
		io:format("can not connect to server~n");
    {ok,Socket} ->
    	ok = gen_tcp:send(Socket, "GET xml config HTTP/1.0\r\n\r\n"),  %% (2)
		Data = receive_data(Socket, []),
%		io:format("~s~p~n", ["data = ", Data]),
		ok = gen_tcp:close(Socket),
		Data
	end.

receive_data(Socket, SoFar) ->
    receive
    % if "ok" in SoFar then return OK
	{tcp,Socket,Bin} ->    %% (3)
		receive_data(Socket, _Res = [Bin|SoFar])
	after 3000 ->
		list_to_binary(lists:reverse(SoFar))
    end.



