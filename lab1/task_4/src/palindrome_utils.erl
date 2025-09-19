%%%-------------------------------------------------------------------
%%% @author nikzarch
%%% @doc
%%% Module of palindrome utils, such as is_palindrome() check
%%% @end
%%%-------------------------------------------------------------------
-module(palindrome_utils).
-author("nikzarch").
-export([is_palindrome/1]).
-spec is_palindrome(integer()) -> boolean().

is_palindrome(Number) when is_integer(Number) ->
    NumberList = integer_to_list(Number),
    is_palindrome_list(NumberList).
is_palindrome_list(List) ->
    List == lists:reverse(List).
