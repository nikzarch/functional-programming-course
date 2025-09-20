%%%-------------------------------------------------------------------
%%% @author nikzarch
%%%
%%% @doc
%%% Module for finding the largest palindrome made from the product of two 3-digits numbers.
%%% @end
%%%-------------------------------------------------------------------
-module(map_4).
-author("nikzarch").
-export([largest_palindrome_product/0]).
-import(palindrome_utils, [is_palindrome/1]).

largest_palindrome_product() ->
    MappedList = lists:map(fun({X, Y}) -> X * Y end, [
        {X, Y}
     || X <- lists:seq(100, 999), Y <- lists:seq(100, 999)
    ]),
    FilteredList = lists:filter(fun(X) -> is_palindrome(X) end, MappedList),
    lists:max(FilteredList).
