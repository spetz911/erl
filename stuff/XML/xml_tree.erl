-module(xml_tree).
-export([file/1, stream/1, get_tag/2, plain_text/2]).
-export([test/1, get_attr/2]).
%-record(xml, {tag,val,attr}).
-include("xml_tree.hlr").

-define(DEBUG(Expr),
	ok).
%	io:format("DEBUG~n~p;~n", [Expr])).



-define(INVARIANT(Expr),
	if
		not(Expr) -> io:fwrite("AGHTUNG!!~n");
		true -> ok
	end).


file(FileName) ->
	case file:read_file(FileName) of
	{ok, Binary} ->
		xml_tree:stream(Binary);
	{error, Reason} ->
		io:format("file: ~p~n", [Reason])
	end.

stream(String) ->
    {ok, _End = {[[Quotes]], _A},_} = xmerl_sax_parser:stream(
			     String, 
			     [{event_fun, fun event/3},
			      {event_state, _Start = {[[]],[]} } ]),
    Quotes.

%% For the end field event, use the last set of characters 
%% encountered as the PARENT for that field

event(_Event = {startElement, _Uri, _Title, _QName, Attr},
      _Location, 
      _State = {Quotes, A}) ->
%    io:format("~p~n", [Attr]),
    {[[]|Quotes],[Attr|A]};

event(_Event = {endElement, _Uri, Title, _QName},
      _Location,
      _State = {[Last,Quotes|Rest], [Attr|A]} ) ->
%	io:format("~p~n", [Chars]),
	case Last of
		[]  ->
	    	Res = undefined;
		[Elem] when is_tuple(Elem) ->
	    	Res = [Elem];
		[Elem] ->
	    	Res = Elem;
		_Other ->
			Res = lists:reverse(Last)
	end,
	T = #xml{tag = Title, val = Res, attr = Attr},
	{[[T]++Quotes|Rest], A};


%% Start "FutureQuote" creates a new, empty key-PARENT list
%% for the quote
event(_Event = startDocument,
      _Location,
      _State) ->
%	io:fwrite("START ~p~n", [Quotes]),
	_State;
event(_Event = endDocument,
      _Location,
      _State) ->
%	io:fwrite("FINISH  ~p;;;~n", [Quotes]),
	_State;


%% Characters are stores in the parser state
event(_Event = {characters, Chars}, 
      _Location, 
      _State = {[Last|Quotes], A}) ->
    ?INVARIANT(Last =:= []),
	{[[Chars]|Quotes], A};
%% May be unify here, Chars == Quotes


%% Catch-all. Pass state on as-is    
event(_Event, _Location, State) ->
%	?DEBUG(io:format("FAIL ~p~n",[Event])),
    State.

get_attr(K, List) ->
	case lists:keyfind(K, 3, List) of
		false   -> false; 
	    Element -> element(4, Element)
	end.

get_tag( [], Tree) -> 
	Tree;

get_tag( List, Tree) ->
	[H|Rest] = List,
	Elem = lists:keyfind(H, #xml.tag, Tree),
	?DEBUG(Elem),
	case Elem of
		false  ->
			false;
		_Other ->
			get_tag( Rest, Elem#xml.val)
	end.

plain_text(_, []) -> [];

plain_text(Path, List) ->
	{L1,R1} = lists:partition(fun (X) -> is_list(X#xml.val) end, List),
	{L2,R2} = lists:partition(fun (X) -> not(is_tuple(hd(X#xml.val))) end, L1),
	L3 = lists:map(fun(X) -> ["set "] ++ Path ++ X#xml.tag ++ "="
				++ X#xml.val ++ "\r\n" end, L2),
	io:fwrite("R1=~p~n", [R1]),
	io:fwrite("R2=~p~n", [R2]),
	io:fwrite("L2=~p~n", [L2]),
	Y = lists:append(L3),
	
	X = lists:map(fun(X) -> plain_text(Path ++ X#xml.tag ++ ["."] , X#xml.val) end, R2),
	lists:append(X,Y).
	
	% partition

serialize(L) when is_list(L) ->
	{obj,lists:map(fun serialize/1, L)};


serialize(X) ->
	case X#xml.val of
		T when is_tuple(T) -> {T#xml.tag, serialize(T#xml.val)};
		L when is_list(L) ->
			if is_tuple(hd(L)) -> {X#xml.tag, serialize(L)}; 
				true -> {X#xml.tag, list_to_binary(X#xml.val)}
			end
	end.
	


test(Path) ->
%	D8 = socket:get_url(), ok.
%	xml_tree:stream(D8).
	Tree = xml_tree:file(Path),
	Tmp2 = xml_tree:get_tag(["daemons", "rdr_processor"], Tree#xml.val),

	io:fwrite("Tmp2=~p~n", [hd(Tmp2)]),

	Tmp3 = serialize({xml,"rdr_processor", Tmp2,[]}), % [{X#xml.tag, list_to_binary(X#xml.val)} || X <- Tmp2],

	io:fwrite("Tmp3=~p~n", [Tmp3]),

	Str2 = rfc4627:encode({obj, [Tmp3]}),
	
%	Str2 = xml_tree:plain_text([],Tmp2),
%	T = rfc4627:encode({obj,[Tmp2]}),
	io:fwrite("~s~n", [Str2]).



