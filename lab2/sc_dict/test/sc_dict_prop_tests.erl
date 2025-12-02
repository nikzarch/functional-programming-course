-module(sc_dict_prop_tests).

-include_lib("proper/include/proper.hrl").
-compile(export_all).

-include("../src/sc_dict.hrl").
-define(DICT, sc_dict).


key() ->
    oneof([atom(), int(), binary()]).

value() ->
    oneof([int(), binary(), atom()]).

pair() ->
    {key(), value()}.

sc_dict_gen() ->
    ?LET(Pairs, list(pair()), list_to_dict(Pairs)).

list_to_dict(Pairs) ->
    lists:foldl(fun({K, V}, Acc) -> ?DICT:put(K, V, Acc) end, ?DICT:new(), Pairs).


prop_monoid_identity() ->
    ?FORALL(A, sc_dict_gen(),
        begin
            Empty = ?DICT:new(),
            ?DICT:equal(?DICT:merge(A, Empty), A)
                andalso
                ?DICT:equal(?DICT:merge(Empty, A), A)
        end).

prop_monoid_associativity() ->
    ?FORALL({A, B, C}, {sc_dict_gen(), sc_dict_gen(), sc_dict_gen()},
        begin
            Left = ?DICT:merge(A, ?DICT:merge(B, C)),
            Right = ?DICT:merge(?DICT:merge(A, B), C),
            ?DICT:equal(Left, Right)
        end).

prop_put_get() ->
    ?FORALL({K, V, D}, {key(), value(), sc_dict_gen()},
        begin
            D2 = ?DICT:put(K, V, D),
            ?DICT:get(K, D2) =:= {ok, V}
        end).