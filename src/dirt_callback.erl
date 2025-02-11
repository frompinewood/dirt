-module(dirt_callback).

-callback init(term()) ->
    {ok, term()}
    | {ok, iodata(), term()}.
-callback message(binary(), term()) ->
    {reply, iodata(), term()}
    | {noreply, term()}.

-export([init/1, message/2]).

%%% @doc
%%% Initializes the callback state. An optional middle term can be
%%% provided as a intro term to send to the client when the connection 
%%% is made.
%%% @end
init(Opts) ->
    {ok, Opts}.

message(Data, State) ->
    {reply, Data, State}.
