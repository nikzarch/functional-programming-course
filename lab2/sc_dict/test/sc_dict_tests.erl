-module(sc_dict_tests).
-include("sc_dict.hrl").
-include_lib("eunit/include/eunit.hrl").

new_test() ->
    ?assertEqual(
        #sc_dict{size = 10, count = 0, buckets = [{} || _ <- lists:seq(0, 10)]}, sc_dict:new()
    ).

new_with_size_test() ->
    S = 56,
    ?assertEqual(
        #sc_dict{size = S, count = 0, buckets = [{} || _ <- lists:seq(0, S)]}, sc_dict:new(S)
    ),
    ok.
