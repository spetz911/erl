-module(test).
-export([run/1]).

-define(DEBUG(Expr), Expr).

run(FileName) ->
    {ok, {[[Quotes]], _}, _} = xmerl_sax_parser:file(
			     FileName, 
			     [{event_fun, fun event/3},
			      {event_state, {[[]], ""}}]),
    Quotes.

%% For the end field event, use the last set of characters 
%% encountered as the PARENT for that field

event(_Event = {startElement, _Uri, _Title, _QName, Attr}, 
      _Location, 
      _State = {Quotes, _Chars}) ->
    io:format("~p~n", [Attr]),
    {[[]|Quotes], ""};

event(_Event = {endElement, _Uri, Title, _QName}, 
      _Location,
      _State = {[Last,Quotes|Rest], Chars}) ->
%	io:format("~p~n", [Chars]),
	case Chars of
	[] when Last =:= [] ->
    	_Res = {[[{Title,undefined}]++Quotes|Rest], ""};
	[] ->
    	_Res = {[[{Title,lists:reverse(Last)}]++Quotes|Rest], ""};
	_Other ->
		_Res = {[[{Title,Chars}]++Quotes|Rest], ""}
	end;



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
      _State = {Quotes, _}) ->
    {Quotes, Chars};
%% May be unify here, Chars == Quotes


%% Catch-all. Pass state on as-is    
event(_Event, _Location, State) ->
%	?DEBUG(io:format("FAIL ~p~n",[Event])),
    State.

