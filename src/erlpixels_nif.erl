-module(erlpixels_nif).

-export([init/0, decode_png/2, decode_jpeg/2]).

-on_load(init/0).

init() ->
    SoName = case code:priv_dir(erlpixels) of
        {error, bad_name} ->
            case filelib:is_dir(filename:join(["..", priv])) of
                true ->
                    filename:join(["..", priv, ?MODULE]);
                _ ->
                    filename:join([priv, ?MODULE])
            end;
        Dir ->
            filename:join(Dir, ?MODULE)
    end,
    ok = erlang:load_nif(SoName, 0).

decode_png(_Data, _Opts) ->
    erlang:nif_error("NIF decode_png/2 not implemented").

decode_jpeg(_Data, _Opts) ->
    erlang:nif_error("NIF decode_jpeg/2 not implemented").
