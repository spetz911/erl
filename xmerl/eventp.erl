% SAX parsing is done via xmerl_eventp:stream/2 and xmerl_eventp:stream_sax/4. 
% 
% xmerl_eventp:stream/2 function take 2 arguments.
% * File name
% * List of options
% 
% For this post, 3 options are important. They are user_state, event_fun and acc_fun. 
% 
% user_state is any term which can be accessed from event_fun and acc_fun. event_fun is called for every event during the SAX parsing. acc_fun is called for every element (after parsing end of element). 
% 
% event_fun has a signature fun/2. First parameter is of type #xmerl_event. Second parameter is a global state. user_state from this global state can be accessed via xmerl_scan:user_state/1 function. User state can be modified via xmerl_scan:user_state/2 function. event_fun should return the new global state.
% 
% Example of event_fun:

event_function(#xmerl_event{event = Event, data = Data}, GlobalState) ->
	UserState = xmerl_scan:user_state(GlobalState),
	NewUserState = do_something(UserState),
	NewGlobalState = xmerl_scan:user_state(NewUserState, GlobalState),
	NewGlobalState.

% Possible values for #xmerl_event.event are started and ended.

% #xmerl_event.data is set to document at the beginning of document parsing and after all the elements are parsed.

% event_function( #xmerl_event{event = started, data = document}, GlobalState) ->
% get the user state
% do something with the user state
% set the new user state in global state
% return global state

% One may want to open a file or open a socket connection at the beginning of the document parsing. In subsequent event, one may want to write the content to the previously opened file or socket connection. 
% 
% End of document parsing event can be used to close the previously opened file handle or socket connection.
% 
% acc_fun can be used to accumulate the content. acc_fun is of the form fun/3. First parameter is the current xml element. Second parameter is the accumulator. Third parameter is the global state. 
% 
% This function should return a new tuple of 2 elements. First element is the new accumulator and 2nd element is a new global state (user state can be changed in the new global state as explained earlier).
% 
% user_state can be any Erlang term. 
% 
% In the next article, I will discuss an implementation of SAX parsing to transform an XML into CSV.



