-module(base).
-import("base.hrl").
-compile(export_all).

-define( ERROR(Msg),
	io:format("error:~p~n", [Msg])).

init(Node) ->
	crypto:start(), % XXX
	net_adm:ping(Node),
	mnesia:create_schema([node()|nodes()]),
	mnesia:start(),
	mnesia:create_table(space_id, [
		{disc_copies, [node()]},
		{ram_copies, nodes()},
		{type, set},
		{attributes,record_info(fields, space_id)},
		{index, [hash]}
		]),
	mnesia:wait_for_tables([space_id], 1000).
%	mnesia:

stop() ->
	mnesia:stop(),
	crypto:stop().



read(Key) ->
	case mnesia:dirty_read(space_id, Key) of
		[X] -> X#space_id.hash;
		[ ] ->
			ok = write(Key),
			read(Key);
		Other -> ?EROOR( Other )
		end.


write(Key) ->
	H = get_hash(Key),
	case mnesia:index_read(Tab, H, #space_id.hash) of
		[X] -> write(Key);
		[ ] -> % ok
			mnesia:dirty_write(H);
		Other -> ?EROOR(Other)
	end.
			

% crypto:start()
get_hash(L0) when is_binary(L0); is_list(L0) ->
	L1 = binary_to_list(crypto:sha(L0)),
	LX = binary_to_list(crypto:rand_bytes(20)),
	L2 = lists:zipwith( fun(X,Y) -> (X+Y) rem 256 end, L1, LX),
	L3 = base64:encode_to_string(L2).

% crypto:stop()

