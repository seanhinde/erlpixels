-module(erlpixels).

-export([read_file/1, read_file/2, read/1, read/2]).

-define(SEPARATE_ALPHA, 1).

read_file(File) ->
    read_file(File, []).

read_file(File, Opts) ->
    case file:read_file(File) of
        {ok, Data} ->
            read(Data, Opts);
        Err ->
            Err
    end.

%% """
%%  Decode a PNG or JPEG image from raw binary input data.
%%  """
read(Data) ->
    read(Data, []).

read(Data, Opts) ->
    EncOpts = encode_opts(Opts),
    case identify(Data) of
      jpeg ->
        Res = erlpixels_nif:decode_jpeg(Data, EncOpts),
         process_result(jpeg, Res);

      png ->
        Res = erlpixels_nif:decode_png(Data, EncOpts),
        process_result(png, Res);

      unknown ->
        {error, invalid_data}
    end.

encode_opts(Opts) ->
    lists:foldl(fun encode_opt/2, 0, Opts).

encode_opt(separate_alpha, OptVal) ->
    OptVal bor ?SEPARATE_ALPHA;
encode_opt(_, OptVal) ->
    OptVal.

process_result(_Type, {error, Reason}) ->  {error, Reason};
process_result(_Type, {error, 27, _Message}) ->  {error, invalid_data};
process_result(_Type, {error, _Code, Message}) -> exit({error, Message});
process_result(Type, {Width, Height, Data}) ->
    {Type, {Width, Height, Data}};
process_result(Type, {Width, Height, Data, Alpha}) ->
    {Type, {Width, Height, Data, Alpha}}.

identify( <<16#89, 16#50, 16#4E, 16#47, 16#0D, 16#0A, 16#1A, 16#0A, _Length:32, "IHDR",
          _width:32, _height:32, _bit_depth, _color_type, _compression_method,
          _filter_method, _interlace_method, _crc:32, _chunks/binary>>) ->
           png;
identify(<<16#FF, 16#D8, 16#FF, 16#E0, _length:16, "JFIF", 0, _version:16, _/binary>>) ->
    jpeg;
identify(_Data) -> unknown.
