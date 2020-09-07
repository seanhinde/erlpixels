-module(erlpixels_test).

-include_lib("eunit/include/eunit.hrl").

file_not_found_test() ->
    ?assertEqual({error, enoent}, erlpixels:read_file("fxxx.png")).

file_invalid_test() ->
    file:write_file("/tmp/t", "asdf"),
    ?assertEqual({error, invalid_data}, erlpixels:read_file("/tmp/t")).

read_png_file_test() ->
    test_dot(png, "test/images/dot.png").

reads_a_mono_jpg_file_test() ->
    test_dot(jpeg, "test/images/dot.jpg").

reads_a_rgb_jpg_file_test() ->
    test_dot(jpeg, "test/images/dot_rgb.jpg").

test_dot(Type, Filename) ->
   {Type, {8, 8, Data}} = erlpixels:read_file(Filename),

    ?assertMatch( 4 * 8 * 8, erlang:byte_size(Data)),

    <<R1, G1, B1, 255, _r2, _g2, _b2, 255, _/binary>> = Data,
    ?assert( R1 < 10 ),
    ?assert( G1 < 10) ,
    ?assert( B1 < 10).