-module(populate).
-export([run/1]).

run(FileName) ->
    {ok, {Quotes, _}, _} = xmerl_sax_parser:file(
			     FileName, 
			     [{event_fun, fun event/3},
			      {event_state, {[], ""}}]),
    Quotes.

%% For the end field event, use the last set of characters 
%% encountered as the value for that field
-define(QUOTE_VALUE(Title),
	event(_Event = {endElement, _, Title, _},
	      _Location, 
	      _State = {[Quote|Rest], Chars}) ->
	       Updated = [{Title, Chars}|Quote],
	       {[Updated|Rest], undefined}).

%% Start "FutureQuote" creates a new, empty key-value list
%% for the quote
event(_Event = {startElement, _, "root", _, _}, 
      _Location, 
      _State = {Quotes, _}) ->
    {[[]|Quotes], ""};

event(_Event = {endElement, _, "root", _}, 
      _Location,
      _State = {[H|Quotes], _}) ->
    io:fwrite("Finish = ~p~n", [_State]),
    io:fwrite("H = ~p~n", [H]),
    io:fwrite("Quote = ~p~n", [Quotes]),

    {{"root",lists:reverse(H ++ Quotes)}, ""};

event(_Event = {startElement, _, "list", _, _}, 
      _Location, 
      _State = {Quotes, _}) ->
    {[[]|Quotes], ""};

event(_Event = {endElement, _, "list", _}, 
      _Location, 
      _State = {[Last,Quotes|Rest], _}) ->
    io:fwrite("FUCK!!!~n"),
%    {[{"list",lists:reverse(Quotes)}], ""};
    {[[],{"list",lists:reverse(Last)}|Quotes ++ Rest], ""};

%   {[[]|Quotes], ""};

event(_Event = {startElement, _, "parent", _, _}, 
      _Location, 
      _State = {Quotes, _}) ->
    {[[]|Quotes], ""};

event(_Event = {endElement, _, "parent", _}, 
      _Location,
      _State = {[Last,Quotes|Rest], _}) ->
    io:fwrite("Event = ~p~n", [_Event]),
    io:fwrite("Loc = ~p~n", [_Location]),
    io:fwrite("Last = ~p~n", [Last]),
    io:fwrite("Quote = ~p~n", [Quotes]),
    io:fwrite("Rest = ~p~n", [Rest]),
    Res = {[[],{"parent",lists:reverse(Last)}|Quotes ++ Rest], ""},
    io:fwrite("Res = ~p~n", [Res]),
    Res;


%% Characters are stores in the parser state
event(_Event = {characters, Chars}, 
      _Location, 
      _State = {Quotes, _}) ->
    {Quotes, Chars};

?QUOTE_VALUE("t0");
?QUOTE_VALUE("t1");
?QUOTE_VALUE("t2");
?QUOTE_VALUE("t3");
?QUOTE_VALUE("t4");
?QUOTE_VALUE("c1");
?QUOTE_VALUE("c2");
% ?QUOTE_VALUE("filter");



%% Catch-all. Pass state on as-is    
event(_Event, _Location, State) ->
    State.

