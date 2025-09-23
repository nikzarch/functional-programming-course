%%%-------------------------------------------------------------------
%%% @author nikzarch
%%% @doc
%%% Module for finding d < 1000, such so 1/d has the longest recurring cycle
%%% @end
%%%-------------------------------------------------------------------
-module(regular_recursion_26).
-author("nikzarch").

-import(recurring_cycle_utils, [cycle_length/1]).
-export([find_longest_recurring_cycle/0]).

find_longest_recurring_cycle() ->
    {Answer,_ } = find_longest_recurring_cycle(2, 999),
    Answer.

find_longest_recurring_cycle(D, MaxD) when D > MaxD ->
    {0, 0};
find_longest_recurring_cycle(D, MaxD) ->
    Len = cycle_length(D),
    {BestDNext, BestLenNext} = find_longest_recurring_cycle(D + 1, MaxD),
    if
        Len > BestLenNext -> {D, Len};
        true -> {BestDNext, BestLenNext}
    end.
