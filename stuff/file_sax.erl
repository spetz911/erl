xmerl_eventp

MODULE

xmerl_eventp
MODULE SUMMARY

Simple event-based front-ends to xmerl_scan for processing of XML documents in streams and for parsing in SAX style.
DESCRIPTION

Simple event-based front-ends to xmerl_scan for processing of XML documents in streams and for parsing in SAX style. Each contain more elaborate settings of xmerl_scan that makes usage of the customization functions.

EXPORTS

file_sax(Fname::string(), CallBackModule::atom(), UserState, Options::option_list()) -> NewUserState

Parse file containing an XML document, SAX style. Wrapper for a call to the XML parser xmerl_scan with a hook_fun for using xmerl export functionality directly after an entity is parsed.





%% @spec file_sax(Fname::string(), CallBackModule::atom(), UserState,
%%        Options::option_list()) -> NewUserState
%%
%% @doc Parse file containing an XML document, SAX style.
%% Wrapper for a call to the XML parser <code>xmerl_scan</code> with a
%% <code>hook_fun</code> for using xmerl export functionality directly after
%% an entity is parsed.
file_sax(Fname,CallBack, UserState, Options) ->
    US={xmerl:callbacks(CallBack), UserState},
    AccF=fun(X,Acc,S) -> {[X|Acc], S} end,
    HookF=
	fun(ParsedEntity, S) ->
		{CBs,Arg}=xmerl_scan:user_state(S),
		case ParsedEntity of
		    #xmlComment{} -> % Toss away comments...
			{[],S};
		    _ ->  % Use callback module for the rest
			case xmerl:export_element(ParsedEntity,CBs,Arg) of
			    {error,Reason} ->
				throw({error,Reason});
			    Resp ->
				{Resp,xmerl_scan:user_state({CBs,Resp},S)}
			end
		end
	end,
    
    Opts=scanner_options(Options,[{acc_fun, AccF},
				  {hook_fun,HookF},
				  {user_state,US}]),
    xmerl_scan:file(Fname,Opts).

