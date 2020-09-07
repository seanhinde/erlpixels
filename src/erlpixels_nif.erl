-module(erlpixels_nif).

-export([init/0, decode_png/1, decode_jpeg/1]).

-on_load(init/0).

init() ->
    SoName = case code:priv_dir(?MODULE) of
        {error, bad_name} ->
            Ebin = filename:dirname(?MODULE),
            App = filename:dirname(Ebin),
            Priv = filename:join(App, "priv"),
            filename:join(Priv, ?MODULE);
        Dir ->
         filename:join(Dir, ?MODULE)
    end,
    ok = erlang:load_nif(SoName, 0).

decode_png(_Data) ->
    erlang:nif_error("NIF decode_png/1 not implemented").

decode_jpeg(_Data) ->
    erlang:nif_error("NIF decode_jpeg/1 not implemented").
