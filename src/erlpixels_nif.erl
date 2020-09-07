-module(erlpixels_nif).

-export([init/0, decode_png/1, decode_jpeg/1]).

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

decode_png(_Data) ->
    erlang:nif_error("NIF decode_png/1 not implemented").

decode_jpeg(_Data) ->
    erlang:nif_error("NIF decode_jpeg/1 not implemented").
