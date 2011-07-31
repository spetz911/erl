
<!-- saved from url=(0052)http://www.sics.se/~joe/ericsson/xml/xml_element.erl -->
<html><head><meta http-equiv="Content-Type" content="text/html; charset=windows-1251"></head><body><pre style="word-wrap: break-word; white-space: pre-wrap;">-module(xml_element).
-copyright('Copyright (c) 1997 Ericsson Telecommunications AB').

%% XML element parser version 1.0
%% Author Joe Armstrong &lt;joe@cslab.ericsson.se&gt;
%% The XML grammar sucks
%% Basically it is like this

%% Model := ('(' Seq ')' | '(' Alt ')' Modifier ) | "EMPTY"
%% Seq   := Item {',' Item}
%% Alt   := Item {'|' Item}
%% Item  := ( "String" | "#PCDATA" | "EMPTY" | Model ) Modifier
%% Modifier := ['*' | '?' | '+']


%% We can make this LL(1) like this

%% Mod := '(' Mod1 Modifier
%% Mod1 := Item Mod2
%% 
%% Mod2 := ')'
%%      |  ',' SeqTail
%%      |  '|' AltTail
%% 
%% SeqTail := Item SeqTail1.
%% 
%% SeqTail1 := ')'
%%          | ',' SeqTail
%% 
%% 
%% AltTail := Item AltTail1
%% 
%% AltTail1 := ')'
%%          |  '|' AltTail
%% 
%% Item := Item1 Modifier
%%
%% Item1 := "string" | "#PCDATA" |  Model
%%
%% Modifier := '?', '*', '+'

%% after which the parser is *trivial* :-)

-export([parse/2, test/1]).

-import(xml_tokenise, [tupStr/1]).
-import(xml, [fatal/1, fatal/2]).

test(Str) -&gt;
    Toks = xml_tokenise:tagbody2toks(1, Str),
    io:format("Args=~p~n", [Toks]),
    parse(1, Toks).

parse(Line, Toks) -&gt;
    %% io:format("Parse element (~w) ~p~n", [Line, Toks]),
    case (catch p_Mod(Toks)) of
	{error, Str, Toks1} -&gt;
	    fatal(Line, ["Error in Model expecting:", Str, " found ", Toks1]),
	    error;
	{'EXIT', Why} -&gt;
	    fatal(Line,["Error in xml_element", Why]),
	    error;
	{Model, []} -&gt;
	    %% io:format("Result = ~p~n", [Model]),
	    Model;
	{_, Toks1} -&gt;
	    fatal(Line,["Error in Model expecting EOT found ", Toks1]),
	    error
    end.


p_Mod(['('|T]) -&gt;
    {Mod,T1} = p_Mod1(T),
    p_Modifier(T1, Mod);
p_Mod(["EMPTY"|T]) -&gt;
    {empty, T};
p_Mod(T) -&gt;
    exit_expect("( or EMPTY", T).

p_Mod1(T) -&gt;
    {Item, T1} = p_Item(T),
    p_Mod2(T1, Item).

p_Mod2([')'|T], Item) -&gt; 
    {Item, T};
p_Mod2([','|T], Item) -&gt; 
    {R, T1} = p_SeqTail(T),
    {{seq,Item,R}, T1};
p_Mod2(['|'|T], Item) -&gt; 
    {R, T1} = p_AltTail(T),
    {{alt,Item,R}, T1};
p_Mod2(T, _) -&gt; 
    exit_expect(", | or )", T).

p_SeqTail(T) -&gt;
    {Item, T1} = p_Item(T),
    p_SeqTail1(T1, Item).

p_SeqTail1([')'|T], Item) -&gt; 
    {{seq,Item,nil}, T};
p_SeqTail1([','|T], Item) -&gt; 
    {R, T1} = p_SeqTail(T),
    {{seq,Item,R}, T1};
p_SeqTail1(T, Item) -&gt; 
    exit_expect(") or |", T).

p_AltTail(T) -&gt; 
    {Item, T1} = p_Item(T),
    p_AltTail1(T1, Item).

p_AltTail1([')'|T], Item) -&gt;
    {{alt,Item,fail}, T};
p_AltTail1(['|'|T], Item) -&gt; 
    {R, T1} = p_AltTail(T),
    {{alt,Item,R}, T1};
p_AltTail1(T, _) -&gt; 
    exit_expect(") or |", T).

p_Item(T) -&gt;
    {Item, T1} = p_Item1(T),
    p_Modifier(T1, Item).

p_Item1(['('|T])            -&gt; p_Mod(['('|T]);
p_Item1([H|T]) when list(H) -&gt; {{rule, tupStr(H)}, T};
p_Item1(['#',"PCDATA"|T])   -&gt; {pcdata, T};
p_Item1(T)                  -&gt; exit_expect("'(' or a string", T).

p_Modifier(['*'|T], Thing) -&gt; {{star, Thing}, T};
p_Modifier(['?'|T], Thing) -&gt; {{question, Thing}, T};
p_Modifier(['+'|T], Thing) -&gt; {{plus, Thing}, T};
p_Modifier(T, Thing)       -&gt; {Thing, T}.

exit_expect(Str, Toks) -&gt;
    throw({error, Str, Toks}).

</pre></body></html>