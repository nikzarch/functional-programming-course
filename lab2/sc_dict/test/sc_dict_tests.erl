-module(sc_dict_tests).
-include("sc_dict.hrl").
-include_lib("eunit/include/eunit.hrl").

new_test() ->
    D = sc_dict:new(),
    ?assertEqual(10, D#sc_dict.size),
    ?assertEqual(0, D#sc_dict.count),
    ?assert(lists:all(fun(E) -> E == [] end, D#sc_dict.buckets)).

new_with_size_test() ->
    S = 56,
    D = sc_dict:new(S),
    ?assertEqual(S, D#sc_dict.size),
    ?assertEqual(0, D#sc_dict.count),
    ?assertEqual(S, length(D#sc_dict.buckets)).

put_get_test() ->
    D = sc_dict:new(),
    D1 = sc_dict:put(apple, 10, D),
    D2 = sc_dict:put(banana, 20, D1),
    ?assertEqual({ok, 10}, sc_dict:get(apple, D2)),
    ?assertEqual({ok, 20}, sc_dict:get(banana, D2)),
    ?assertEqual(not_found, sc_dict:get(cherry, D2)).

update_existing_key_test() ->
    D = sc_dict:new(),
    D1 = sc_dict:put(apple, 10, D),
    D2 = sc_dict:put(apple, 42, D1),
    ?assertEqual({ok, 42}, sc_dict:get(apple, D2)).

remove_test() ->
    D = sc_dict:new(),
    D1 = sc_dict:put(apple, 1, D),
    D2 = sc_dict:put(banana, 2, D1),
    D3 = sc_dict:remove(apple, D2),
    ?assertEqual(not_found, sc_dict:get(apple, D3)),
    ?assertEqual({ok, 2}, sc_dict:get(banana, D3)).

to_list_test() ->
    D = sc_dict:new(),
    D1 = sc_dict:put(a, 1, D),
    D2 = sc_dict:put(b, 2, D1),
    D3 = sc_dict:put(c, 3, D2),
    List = sc_dict:to_list(D3),
    ?assert(lists:member({a, 1}, List)),
    ?assert(lists:member({b, 2}, List)),
    ?assert(lists:member({c, 3}, List)).

collision_chaining_test() ->
    D = sc_dict:new(1),
    D1 = sc_dict:put(k1, 1, D),
    D2 = sc_dict:put(k2, 2, D1),
    D3 = sc_dict:put(k3, 3, D2),
    Buckets = D3#sc_dict.buckets,
    [Bucket] = Buckets,
    ?assertEqual(3, length(Bucket)),
    ?assertEqual({ok, 2}, sc_dict:get(k2, D3)),
    ?assertEqual({ok, 3}, sc_dict:get(k3, D3)).

prop_monoid_identity_test() ->
    ?assert(proper:quickcheck(sc_dict_prop_tests:prop_monoid_identity())).

prop_monoid_associativity_test() ->
    ?assert(proper:quickcheck(sc_dict_prop_tests:prop_monoid_associativity())).

prop_get_test() ->
    ?assert(proper:quickcheck(sc_dict_prop_tests:prop_put_get())).