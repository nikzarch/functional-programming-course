%%%-------------------------------------------------------------------
%%% @author nikzarch
%%% @doc
%%% Module for finding d < 1000, such so 1/d has the longest recurring cycle
%%% @end
%%%-------------------------------------------------------------------
-module(map_26).
-author("nikzarch").

-import(recurring_cycle_utils, [cycle_length/1]).
-export([find_longest_recurring_cycle/0]).

find_longest_recurring_cycle() ->
    NumberList = lists:seq(2, 999),
    Pairs = lists:map(fun(D) -> {cycle_length(D), D} end, NumberList),
    NonZero = lists:filter(fun({Len, _}) -> Len > 0 end, Pairs),
    {_, Answer} = lists:max(NonZero),
    Answer.
