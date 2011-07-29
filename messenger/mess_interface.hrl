%%%----ФАЙЛ mess_interface.hrl----

%%% Интерфейс сообщений между клиентом, сервером и клиентской оболочкой для 
%%% программы отправки сообщений

%%% Сообщения от клиента серверу, получаемые в функции server/1.

-record(logon, {client_pid, username}).
-record(message, {client_pid, to_name, message}).

%%% {'EXIT', ClientPid, Reason} клиент завершил работу или вне досягаемости.

%%% Сообщения от сервера клиенту, получаемые в функции await_result/0 

-record(abort_client, {message}).

%%% Сообщения могут быть следующими: user_exists_at_other_node, 
%%% you_are_not_logged_on

-record(server_reply, {message}).

%%% Сообщениями могут быть: logged_on
%%% receiver_not_found
%%% sent  (Сообщение отослано (без гарантии доставки))

%%% Сообщения от сервера клиенту, получаемые в функции client/1

-record(message_from, {from_name, message}).

%%% Сообщения от оболочки клиенту, получаемые в функции client/1 
%%% spawn(mess_client, client, [server_node(), Name])
-record(message_to, {to_name, message}).
%%% отключение

%%%----КОНЕЦ ФАЙЛА ----
