-module(login_manager).
-export([start/0,
         create_account/2,
         close_account/2,
         login/2,
         logout/1,
         online/0]).

start() ->
    %register(login_manager, spawn(fun() -> loop(...) end ))
    register(?MODULE, spawn(fun() -> loop(#{}) end)).

rpc(Req)->
    ?MODULE ! {Req, self()},
    receive {Res, ?MODULE}-> Res end.

create_account(Username, Passwd) -> rpc({create_account,Username,Passwd}).
close_account(Username, Passwd) -> rpc({close_account,Username,Passwd}).
login(Username, Passwd) ->rpc({login,Username,Passwd}).
logout(Username) ->rpc({logout,Username}).
online() -> rpc(online).

%server process
loop(Map) ->
    receive 
        {{create_account, Username, Passwd}, From} ->
            case maps:is_key(Username,Map) of
                true -> 
                    From ! {user_exists, ?MODULE},
                    loop(Map);
                false ->
                    From ! {ok, ?MODULE},
                    loop(maps:put(Username,{Passwd, true},Map) )
            end;
        {{close_account, Username, Passwd}, From} ->
            case maps:find(Username,Map) of
                {ok, {Passwd, _}} ->
                    From ! {ok, ?MODULE},
                    loop(maps:remove(Username,Map));
                error ->
                    From ! {user_not_exists, ?MODULE},
                    loop(Map)
            end;
        {{login,Username,Passwd}, From} ->
            case maps:get(Username,Map) of
                {badkey,Map} ->
                    From ! {badkey, ?MODULE},
                    loop(Map)
            end
    end.
