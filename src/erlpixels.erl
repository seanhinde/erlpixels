-module(erlpixels).

-export([read_file/1, read/1]).

read_file(File) ->
    case file:read_file(File) of
        {ok, Data} ->
            read(Data);
        Err ->
            Err
    end.

%% """
%%  Decode a PNG or JPEG image from raw binary input data.
%%  """
read(Data) ->
    case identify(Data) of
      jpeg ->
        Res = erlpixels_nif:decode_jpeg(Data),
         process_result(jpeg, Res);

      png ->
        Res = erlpixels_nif:decode_png(Data),
        process_result(png, Res);

      unknown ->
        {error, invalid_data}
    end.


process_result(_Type, {error, Reason}) ->  {error, Reason};
process_result(_Type, {error, 27, _Message}) ->  {error, invalid_data};
process_result(_Type, {error, _Code, Message}) -> exit({error, Message});
process_result(Type, {Width, Height, Data}) ->
    {Type, {Width, Height, Data}}.

identify( <<16#89, 16#50, 16#4E, 16#47, 16#0D, 16#0A, 16#1A, 16#0A, _Length:32, "IHDR",
          _width:32, _height:32, _bit_depth, _color_type, _compression_method,
          _filter_method, _interlace_method, _crc:32, _chunks/binary>>) ->
           png;

 identify(<<16#FF, 16#D8, 16#FF, 16#E0, _length:16, "JFIF", 0, _version:16, _/binary>>) ->
    jpeg;

identify(_Data) -> unknown.
