-module(fib).
-export([run/1, num/0]).

num() -> {0, fun() -> num(0,0) end}.
num(0,0) -> {1, fun() -> num(0,1) end};
num(X1,X0) -> Xres = X1+X0,
              {Xres, fun() -> num(X0, Xres) end}.

Start = fun num/0.

run(X) -> 
	  lists:foldl(fun(I,F) ->
	      {N,F1} = F(),
	      io:format("~p: ~p~n", [I, N]),
	      F1 end,
	      Start, lists:seq(1, X)).

Sasha_gen() ->
     Next = fun(PPrev, Prev, Self) ->
         fun() ->
             {PPrev + Prev , Self(Prev, PPrev + Prev, Self)}
         end
     end,
     Next(1, 0, Next).

