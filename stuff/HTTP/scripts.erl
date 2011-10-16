-module(scripts).
-export([test/3]).


test(SessionID, Env, _Input) ->
    mod_esi:deliver(SessionID,
        ["Content-Type: text/html\r\n\r\n" | format(Env)]).


format([]) ->
    "";
format([{Key, Value} | Env]) ->
    [io_lib:format("<b>~p:</b> ~p<br />\~n", [Key, Value]) | format(Env)].
