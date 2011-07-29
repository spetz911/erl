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
event(_Event = {startElement, _, "tdmn_main_config", _, _}, 
      _Location, 
      _State = {Quotes, _}) ->
    {[[]|Quotes], ""};

%% Characters are stores in the parser state
event(_Event = {characters, Chars}, 
      _Location, 
      _State = {Quotes, _}) ->
    {Quotes, Chars};

?QUOTE_VALUE("snmp_oid");
?QUOTE_VALUE("adm_addr");
?QUOTE_VALUE("adm_port");
?QUOTE_VALUE("log");
?QUOTE_VALUE("vips_pool");
?QUOTE_VALUE("exec_dir");
% ?QUOTE_VALUE("daemons");

%% Catch-all. Pass state on as-is    
event(_Event, _Location, State) ->
    State.

