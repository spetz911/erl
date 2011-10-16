%% ---
%%  Excerpted from "Programming Erlang",
%%  published by The Pragmatic Bookshelf.
%%  Copyrights apply to this code. It may not be used to create training material, 
%%  courses, books, articles, and the like. Contact us if you are in doubt.
%%  We make no guarantees that this code is fit for any purpose. 
%%  Visit http://www.pragmaticprogrammer.com/titles/jaerlang for more book information.
%%---
-module(socket).
-compile(export_all).

send_data(Host, Port, Data, Times) ->
    case gen_tcp:connect(Host,Port,[binary, {packet, 0}]) of
	{ok,Socket} ->
    	ok = gen_tcp:send(Socket, Data),
		ok = gen_tcp:close(Socket);
	{error,econnrefused} ->
		io:format("try connect to server~n"),
		receive
		after 1000 ->
			send_data(Host, Port, Data, Times-1)
		end
    end.

get_url() ->
    get_url("127.0.0.1", 2345).

%% read args from shell
get_url([Host, Port]) when is_list(Port) ->
	get_url(Host, list_to_integer(Port)).

get_url(Host, Port) ->
    case gen_tcp:connect(Host,Port,[binary, {packet, 0}]) of %% (1)
	{error,econnrefused} ->
		io:format("can not connect to server~n");
	{error,closed} -> 
		io:format("connection closed~n");
    {ok,Socket} ->
    	case gen_tcp:send(Socket, "GET xml config HTTP/1.0\r\n\r\n") of  %% (2)
		{error,R} ->
			io:format("aghtung:~p~n", [R]),
			{error,R};
		ok -> 
			Data = receive_data(Socket, []),
	%		io:format("data = ~p~n", [Data]),
			gen_tcp:close(Socket),
			{ok, Data}
		end
	end.

receive_data(Socket, SoFar) ->
    receive
    % if "ok" in SoFar then return OK
	{tcp,Socket,Bin} ->    %% (3)
		receive_data(Socket, _Res = [Bin|SoFar])
	after 1000 ->
		list_to_binary(lists:reverse(SoFar))
    end.



nano_client_eval(Str) ->
    {ok, Socket} = 
	gen_tcp:connect("localhost", 2345,
			[binary, {packet, 4}]),
    ok = gen_tcp:send(Socket, term_to_binary(Str)),
    receive
	{tcp,Socket,Bin} ->
	    io:format("Client received binary = ~p~n",[Bin]),
	    Val = binary_to_term(Bin),
	    io:format("Client result = ~p~n",[Val]),
	    gen_tcp:close(Socket)
    end.



loop(Socket) ->
    receive
	{tcp, Socket, Bin} ->
	    io:format("Server received binary = ~p~n",[Bin]),
	    Str = binary_to_term(Bin),  %% (9)
	    io:format("Server (unpacked)  ~p~n",[Str]),
	    Reply = lib_misc:string2value(Str),  %% (10)
	    io:format("Server replying = ~p~n",[Reply]),
	    gen_tcp:send(Socket, term_to_binary(Reply)),  %% (11)
	    loop(Socket);
	{tcp_closed, Socket} ->
	    io:format("Server socket closed~n")
    end.



error_test() ->
    spawn(fun() -> error_test_server() end),
    lib_misc:sleep(2000),
    {ok,Socket} = gen_tcp:connect("localhost",4321,[binary, {packet, 2}]),
    io:format("connected to:~p~n",[Socket]),
    gen_tcp:send(Socket, <<"123">>),
    receive
	Any ->
	    io:format("Any=~p~n",[Any])
    end.

error_test_server() ->
    {ok, Listen} = gen_tcp:listen(4321, [binary,{packet,2}]),
    {ok, Socket} = gen_tcp:accept(Listen),
    error_test_server_loop(Socket).

error_test_server_loop(Socket) ->
    receive
	{tcp, Socket, Data} ->
	    io:format("received:~p~n",[Data]),
	    _D = atom_to_list(Data),
	    error_test_server_loop(Socket)
    end.

