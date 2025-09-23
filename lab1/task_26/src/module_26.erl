%%%-------------------------------------------------------------------
%%% @author nikzarch
%%% @doc
%%% Module for finding d < 1000, such so 1/d has the longest recurring cycle
%%% @end
%%%-------------------------------------------------------------------
-module(module_26).
-author("nikzarch").

-import(recurring_cycle_utils, [cycle_length/1]).
-export([find_longest_recurring_cycle/0]).

generate_list_of_numbers() ->
    [X || X <- lists:seq(1, 999)].

filter_numbers_with_recurring_cycle(NumberList) ->
    lists:filter(
        fun(A) ->
            case cycle_length(A) of
                Len when Len > 0 -> true;
                0 -> false
            end
        end,
        NumberList
    ).
fold_into_max_one([H | T]) ->
    lists:foldl(
        fun(A, B) ->
            case cycle_length(A) > cycle_length(B) of
                true -> A;
                false -> B
            end
        end,
        H,
        T
    ).

find_longest_recurring_cycle() ->
    List = generate_list_of_numbers(),
    FilteredList = filter_numbers_with_recurring_cycle(List),
    fold_into_max_one(FilteredList).
