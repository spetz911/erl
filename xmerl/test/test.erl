-module(test).
-export([run/1]).

run(FileName) ->
    {ok, {Quotes, _}, _} = xmerl_sax_parser:file(
			     FileName, 
			     [{event_fun, fun event/3},
			      {event_state, {[], ""}}]),
    Quotes.

%% For the end field event, use the last set of characters 
%% encountered as the value for that field
-define(VALUE(Title),
	event(_Event = {endElement, _, Title, _},
	      _Location, 
	      _State = {[Quote|Rest], Chars}) ->
	       Updated = [{Title, Chars}|Quote],
	       {[Updated|Rest], undefined}).

-define(PARENT(Title),
event(_Event = {startElement, _, Title, _, _}, 
      _Location, 
      _State = {Quotes, _}) ->
    {[[]|Quotes], ""};

event(_Event = {endElement, _, Title, _}, 
      _Location,
      _State = {[Last,Quotes|Rest], _}) ->
%    io:fwrite("Last = ~p~n", [Last]),
%    io:fwrite("Quote = ~p~n", [Quotes]),
%    io:fwrite("Rest = ~p~n", [Rest]),
    Res = {[[{Title,lists:reverse(Last)}]++Quotes|Rest], ""},
%    io:fwrite("Res = ~p~n", [Res]),
    Res).

?PARENT("parent");
?PARENT("parent2");
?PARENT("list");


%% Start "FutureQuote" creates a new, empty key-value list
%% for the quote
event(_Event = {startElement, _, "root", _, _}, 
      _Location, 
      _State = {Quotes, _}) ->
    {[[]|Quotes], ""};

event(_Event = {endElement, _, "root", _}, 
      _Location,
      _State = {[Quotes], _}) ->
%    io:fwrite("Finish = ~p~n", [_State]),
%    io:fwrite("Quote = ~p~n", [Quotes]),

    {{"root",lists:reverse(Quotes)}, ""};






%% Characters are stores in the parser state
event(_Event = {characters, Chars}, 
      _Location, 
      _State = {Quotes, _}) ->
    {Quotes, Chars};

?VALUE("t0");
?VALUE("t1");
?VALUE("t2");
?VALUE("t3");
?VALUE("t4");
?VALUE("c1");
?VALUE("c2");


%% Catch-all. Pass state on as-is    
event(_Event, _Location, State) ->
    State.

