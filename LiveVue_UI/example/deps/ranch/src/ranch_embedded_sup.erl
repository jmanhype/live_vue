%% Copyright (c) Jan Uhlig <juhlig@hnc-agency.org>
%%
%% Permission to use, copy, modify, and/or distribute this software for any
%% purpose with or without fee is hereby granted, provided that the above
%% copyright notice and this permission notice appear in all copies.
%%
%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
%% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
%% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
%% ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
%% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
%% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
%% OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

-module(ranch_embedded_sup).

-behavior(supervisor).

-export([start_link/5]).
-export([init/1]).

-spec start_link(ranch:ref(), module(), any(), module(), any())
        -> {ok, pid()}.
start_link(Ref, Transport, TransOpts, Protocol, ProtoOpts) ->
	supervisor:start_link(?MODULE, {Ref, Transport, TransOpts, Protocol, ProtoOpts}).

-spec init({ranch:ref(), module(), any(), module(), any()})
	-> {ok, {supervisor:sup_flags(), [supervisor:child_spec()]}}.
init({Ref, Transport, TransOpts, Protocol, ProtoOpts}) ->
	Proxy = #{id => ranch_server_proxy,
		start => {ranch_server_proxy, start_link, []},
		shutdown => brutal_kill},
	Listener = #{id => {ranch_listener_sup, Ref},
		start => {ranch_listener_sup, start_link, [Ref, Transport, TransOpts, Protocol, ProtoOpts]},
		type => supervisor},
	{ok, {#{strategy => rest_for_one}, [Proxy, Listener]}}.
