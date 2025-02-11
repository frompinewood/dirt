-module(dirt_protocol).

-record(state, 
        {transport, socket, callback, callback_state}).

-export([start_link/3, init/4, handle_info/2, terminate/2]).

start_link(Ref, Transport, {Callback, CallbackOpts}) ->
    Pid = proc_lib:spawn_link(?MODULE, init, 
                              [Ref, Transport, Callback, CallbackOpts]),
    {ok, Pid}.

init(Ref, Transport, Callback, Opts) ->
    {ok, Socket} = ranch:handshake(Ref),
    CallbackState =
        case Callback:init(Opts) of
            {ok, State} ->
                State;
            {ok, Message, State} ->
                Transport:send(Socket, Message),
                State
        end,
    Transport:setopts(Socket, [{active, true}]),
    gen_server:enter_loop(?MODULE, [], #state{
        callback = Callback,
        transport = Transport,
        socket = Socket,
        callback_state = CallbackState
    }).

handle_info({timeout, _Socket}, _) ->
    exit(normal);
handle_info({tcp_closed, _Socket}, _) ->
    exit(normal);
handle_info(
    {tcp, Socket, Data},
    #state{
        callback = Callback,
        callback_state = CallbackState,
        transport = Transport
    } = State
) ->
    {Telnet, Message} = tell:parse(binary_to_list(Data)),
    io:format("~w~n", [Telnet]),
    io:format("~w~n~s~n", [Message, Message]),
    NextCallbackState =
        case Callback:message(Message, CallbackState) of
            {reply, Response, NewCallbackState} ->
                Transport:send(Socket, Response),
                NewCallbackState;
            {noreply, NewCallbackState} ->
                NewCallbackState
        end,
    {noreply, State#state{callback_state = NextCallbackState}}.

terminate(_Reason, _State) -> ok.
