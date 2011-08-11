-module(xml_tree).
-export([run/1, stream/1, get_tag/2, plain_text/1]).

-define(DEBUG(Expr),
	ok).
%	io:format("DEBUG~n~p;~n", [Expr])).



-define(INVARIANT(Expr),
	if
		not(Expr) -> io:fwrite("AGHTUNG!!~n");
		true -> ok
	end).

-record(xml, {tag,val,attr}).

run(FileName) ->
    {ok, _End = {[[Quotes]], _A},_} = xmerl_sax_parser:file(
			     FileName, 
			     [{event_fun, fun event/3},
			      {event_state, _Start = {[[]],[]} } ]),
    Quotes.

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

plain_text( List) ->
	L1 = lists:filter(fun (X) -> is_list(X#xml.val) end, List),
	L2 = lists:filter(fun (X) -> not(is_tuple(hd(X#xml.val))) end, L1),
	L3 = lists:map(fun(X) -> X#xml.tag ++ " = " ++ X#xml.val ++ "\r\n" end, L2)
	lists:append(L3).
	
	



