-module(manager).
-compile(export_all).
%%% TODO set to imporn_lib
-record(xml, {tag,val,attr}).

-define(DEBUG(Expr),
	ok).
%	io:format("DEBUG~n~p;~n", [Expr])).

-define(INVARIANT(Expr),
	if
		not(Expr) -> io:fwrite("AGHTUNG!!~n");
		true -> ok
	end).

delay(Time) ->
	receive
	after Time -> ok
	end.

d_start({Tag, Tree, Attrs, Exec_dir}) ->
	io:fwrite("each~n"),
	Path = Exec_dir ++ xml_tree:get_attr("path", Attrs),
	Port_in = xml_tree:get_attr("port_in", Attrs),
	Port_out = xml_tree:get_attr("port_out", Attrs),
	Reg = list_to_atom(Tag),
	spawn_link(?MODULE, daemon, [Reg, Path, Port_in, Port_out, Tree]).

daemon(Name, Path, Port_in, Port_out, Tree) ->
	S = "python3 " ++ Path ++ " " ++ Port_out,
	io:format("~s~n", [S]),
	spawn_link(os, cmd, [S]),
	receive % XXX wait while daemon start
	after 100 -> ok
	end,
	Data = xml_tree:plain_text(Tree),
%	os:cmd(S),
	register(Name, self()),
	udp:send_udp("127.0.0.1", list_to_integer(Port_in),
	              Data, _T=3, list_to_integer(Port_out)).
	
	
	
start(Args) ->
	R = socket:get_url(Args),
	
	case R of
	{ok, Data} -> ok;
	{error, Data} ->
		io:format("no TCP connect ~p",[Data]),
%		delay(1000),
%		start(Args),
		halt()
	end,
%	io:format("data =~n~s~n", [Data]),
	Tree = xml_tree:stream(Data),
	Exec_dir = xml_tree:get_tag(["exec_dir"], Tree#xml.val),
%	Sock = udp:open(_Port = 9000, _Times = 3),
	Daemons = [{X#xml.tag, X#xml.val, X#xml.attr, Exec_dir}
		                   || X <- xml_tree:get_tag(["daemons"], Tree#xml.val)],
	lists:foreach(fun d_start/1, Daemons).


	
	
%	Tmp2 = xml_tree:get_tag(["daemons"], Tree#xml.val),
%	io:fwrite("~p~n", [ Daemons ]).
	
%	Tmp2 = xml_tree:get_tag(["parent", "parent2", "list"], Tree#xml.val),
%	Str2 = xml_tree:plain_text(Tmp2),
%	io:fwrite("~s", [Str2]).

% Elem = lists:keyfind(H, #xml.tag, Tree),

stop() ->
	receive
	after 7000 ->
	%	gen_tcp:close(Sock),
		halt()
	end.





