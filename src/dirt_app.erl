%%%-------------------------------------------------------------------
%% @doc dirt public API
%% @end
%%%-------------------------------------------------------------------

-module(dirt_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    dirt_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
