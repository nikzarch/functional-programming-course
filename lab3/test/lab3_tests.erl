-module(lab3_tests).
-include_lib("eunit/include/eunit.hrl").


compute_linear_test() ->
  Points = [{0,0},{1,1},{2,4}],
  ?_assertEqual(undefined, lab3:compute_linear( -1, Points)),
  ?_assertEqual(0, lab3:compute_linear(0, Points)),
  ?_assertEqual(0.5, lab3:compute_linear(0.5, Points)),
  ?_assertEqual(1, lab3:compute_linear(1, Points)),
  ?_assertEqual(2.5, lab3:compute_linear(1.5, Points)).

compute_lagrange_test() ->
  Points = [{0,1},{1,3},{2,5}],
  ?_assertEqual(1, lab3:compute_lagrange(0, Points)),
  ?_assertEqual(3, lab3:compute_lagrange(1, Points)),
  ?_assertEqual(5, lab3:compute_lagrange(2, Points)),
  ?_assertEqual(2, lab3:compute_lagrange(0.5, Points)),
  ?_assertEqual(4, lab3:compute_lagrange(1.5, Points)).

compute_newton_test() ->
  Points = [{1,2},{2,4},{3,6}],
  ?_assertEqual(2, lab3:compute_newton(1, Points)),
  ?_assertEqual(4, lab3:compute_newton(2, Points)),
  ?_assertEqual(6, lab3:compute_newton(3, Points)),
  ?_assertEqual(3, lab3:compute_newton(1.5, Points)),
  ?_assertEqual(5, lab3:compute_newton(2.5, Points)).

