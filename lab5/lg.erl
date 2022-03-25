-module(lg).
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
                    From ! {invalid, ?MODULE},
                    loop(Map)
            end;
        {{login,Username,Passwd}, From} ->
            case maps:get(Username,Map) of
                {badkey,Map} ->
                    From ! {invalid, ?MODULE},
                    loop(Map);
                %caso em que o username existe, tem de veririficar a oass ainda
                Value -> 
                    case Value of
                        %matches with password
                        Passwd ->
                            maps:update(Username,{Passwd,true}),
                            From ! {ok, ?MODULE},
                            loop(Map);
                        _ -> 
                            From ! {invalid, ?MODULE},
                            loop(Map)
                    end
            end;
        {{logout,Username},From} ->
            case maps:get(Username,Map,err) of
                {badkey,_} ->
                    From ! {invalid, ?MODULE},
                    loop(Map);
                err ->
                    From ! {invalid, ?MODULE},
                    loop(Map);
                {Value,_} -> 
                    maps:update(Username,{Value,false},Map),
                    From ! {ok, ?MODULE},
                    loop(Map)
            end;
        {online,From} ->
            %Pred = fun(_,{_,Log}) -> Log end,
            io:write(teste),
            Pred = fun (_,{_,L}) -> L end,
            Online = maps:filter(Pred,Map),
            Onlinenames = maps:keys(Online),
            From ! {Onlinenames,?MODULE},
            loop(Map)
        end.
