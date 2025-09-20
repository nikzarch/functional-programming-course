%%%-------------------------------------------------------------------
%%% @author nikzarch
%%%
%%% @doc
%%% Module for finding the largest palindrome made from the product of two 3-digits numbers.
%%% @end
%%%-------------------------------------------------------------------
-module(module_4).
-author("nikzarch").
-export([largest_palindrome_product/0]).
-import(palindrome_utils, [is_palindrome/1]).

generate_list_of_products() ->
    [X * Y || X <- lists:seq(100, 999), Y <- lists:seq(100, 999)].
filter_palindromes(Products) ->
    lists:filter(fun(X) -> is_palindrome(X) end, Products).
fold_into_max_product(Palindromes) ->
    [H | T] = Palindromes,
    lists:foldl(
        fun
            (A, B) when A > B -> A;
            (_, B) -> B
        end,
        H,
        T
    ).

%% Finds the largest palindrome made from the product of two 3-digits numbers
largest_palindrome_product() ->
    Products = generate_list_of_products(),
    ProductsFiltered = filter_palindromes(Products),
    fold_into_max_product(ProductsFiltered).
