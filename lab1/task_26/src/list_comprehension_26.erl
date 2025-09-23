%%%-------------------------------------------------------------------
%%% @author nikzarch
%%% @doc
%%% Module for finding d < 1000, such so 1/d has the longest recurring cycle
%%% @end
%%%-------------------------------------------------------------------
-module(list_comprehension_26).
-author("nikzarch").

-import(recurring_cycle_utils, [cycle_length/1]).
-export([find_longest_recurring_cycle/0]).

find_longest_recurring_cycle() ->
    {_, Answer} = lists:max([{cycle_length(D), D} || D <- lists:seq(2, 999)]),
    Answer.
