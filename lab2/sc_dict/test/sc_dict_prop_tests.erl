-module(sc_dict_prop_tests).

-include_lib("proper/include/proper.hrl").

-compile(export_all).

-include("../src/sc_dict.hrl").
-define(sc_dict, sc_dict).
prop_monoid_identity() ->
    ?FORALL(A, dict(),
        begin
            Empty = ?sc_dict:new(),
            ?sc_dict:equal(?sc_dict:merge(A, Empty), A)
                andalso
                ?sc_dict:equal(?sc_dict:merge(Empty, A), A)
        end).

prop_monoid_associativity() ->
    ?FORALL({A, B, C}, {dict(), dict(), dict()},
        begin
            Left = ?sc_dict:merge(A, ?sc_dict:merge(B, C)),
            Right = ?sc_dict:merge(?sc_dict:merge(A, B), C),
            ?sc_dict:equal(Left, Right)
        end).
