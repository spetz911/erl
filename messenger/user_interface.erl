%%%----ФАЙЛ user_interface.erl----

%%% Пользовательский интерфейс к программе отправки сообщений

%%% login(Name)
%%%   Одновременно войти в систему на одном Erlang-узле может только один 
%%%   пользователь, указав соответствующее имя (Name). Если имя уже 
%%%   используется на другом узле, или если кто-то уже вошел в систему на 
%%%   этом узле, во входе будет отказано с соответствующим 
%%%   сообщением об ошибке.
 
%%% logoff()
%%%   Отключает пользователя от системы

%%% message(ToName, Message)
%%%   Отправляет Message ToName. Сообщения об ошибках выдаются, если
%%%   пользователь или получатель (ToName) не вошел в систему.
 
-module(user_interface).
-export([logon/1, logoff/0, message/2]).
-include("mess_interface.hrl").
-include("mess_config.hrl").

logon(Name) ->
  case whereis(mess_client) of 
    undefined ->
      register(mess_client, 
           spawn(mess_client, client, [?server_node, Name]));
    _ -> already_logged_on
  end.

logoff() ->
  mess_client ! logoff.

message(ToName, Message) ->
  case whereis(mess_client) of % Проверяет, запущен ли клиент
    undefined ->
      not_logged_on;
    _ -> mess_client ! #message_to{to_name=ToName, message=Message}, 
       ok
end.

%%%----КОНЕЦ ФАЙЛА ----
