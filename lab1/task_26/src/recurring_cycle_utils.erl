%%%-------------------------------------------------------------------
%%% @author nikzarch
%%% @doc
%%% Cycle utils
%%% @end
%%%-------------------------------------------------------------------
-module(recurring_cycle_utils).
-author("nikzarch").

-export([cycle_length/1]).

cycle_length(D) ->
    check_cycle(1, [], 0, D).

check_cycle(R, Seen, Step, D) ->
    case lists:keyfind(R, 1, Seen) of
        {_, FirstStep} ->
            Step - FirstStep;
        false when R =:= 0 -> 0;
        false ->
            NewR = (R * 10) rem D,
            check_cycle(NewR, [{R, Step} | Seen], Step + 1, D)
    end.
