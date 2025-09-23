%%%-------------------------------------------------------------------
%%% @author nikzarch
%%% @doc
%%% Module for finding d < 1000, such so 1/d has the longest recurring cycle
%%% @end
%%%-------------------------------------------------------------------
-module(tail_recursion_26).
-author("nikzarch").

-import(recurring_cycle_utils, [cycle_length/1]).
-export([find_longest_recurring_cycle/0]).

find_longest_recurring_cycle() ->
    {Answer,_ } = find_longest_recurring_cycle(2, 999, 0, 0),
    Answer.

find_longest_recurring_cycle(D, MaxD, BestD, BestLen) when D > MaxD ->
    {BestD, BestLen};
find_longest_recurring_cycle(D, MaxD, BestD, BestLen) ->
    Len = cycle_length(D),
    if
        Len > BestLen ->
            find_longest_recurring_cycle(D + 1, MaxD, D, Len);
        true ->
            find_longest_recurring_cycle(D + 1, MaxD, BestD, BestLen)
    end.
