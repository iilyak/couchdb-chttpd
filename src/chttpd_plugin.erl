-module(chttpd_plugin).

-export([
    before_request/1,
    after_request/2,
    handle_error/1,
    authorize_request/1
]).

-include_lib("couch/include/couch_db.hrl").

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------

authorize_request(HttpReq) ->
    Handle = couch_epi:get_handle(chttpd),
    %% callbacks return true only if it specifically allow the given Id
    couch_epi:any(Handle, chttpd, authorize_request, [HttpReq], [ignore_providers]).

before_request(HttpReq) ->
    [HttpReq1] = with_pipe(before_request, [HttpReq]),
    {ok, HttpReq1}.

after_request(HttpReq, Result) ->
    [_, Result1] = with_pipe(after_request, [HttpReq, Result]),
    {ok, Result1}.

handle_error(Error) ->
    [Error1] = with_pipe(after_request, [Error]),
    Error1.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

with_pipe(Func, Args) ->
    do_apply(Func, Args, [ignore_providers, pipe]).

do_apply(Func, Args, Opts) ->
    Handle = couch_epi:get_handle(chttpd),
    couch_epi:apply(Handle, chttpd, Func, Args, Opts).
