-module(dirt).

-export([start_listener/3]).

%%% @doc
%%% Start listening for TCP connections on the given port. The provided callback should
%%% follow the behavior defined in dirt_callback.
%%% @end
-todo("Add SSL option").
-type callback_opts() :: {module(), term()}.
-spec start_listener(
    Name :: atom(),
    Port :: non_neg_integer(),
    CallbackOpts :: callback_opts()
) -> {ok, pid()}.
start_listener(Name, Port, CallbackOpts) ->
    ranch:start_listener(
        Name,
        ranch_tcp,
        #{socket_opts => [{port, Port}]},
        dirt_protocol,
        CallbackOpts
    ).
