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

is_palindrome(Number) ->
  NumberList = integer_to_list(Number),
  is_palindrome_list(NumberList).
is_palindrome_list(List) ->
  List == lists:reverse(List).

generate_list_of_products() ->
  [X * Y || X <- lists:seq(100, 999), Y <- lists:seq(100, 999)].
filter_palindromes(Products) ->
  lists:filter(fun(X) -> is_palindrome(X) end, Products).
fold_into_max_product(Palindromes) ->
  [H | T] = Palindromes,
  lists:foldl(fun(A, B) when A > B -> A; (_, B) -> B end, H, T).

%% Finds the largest palindrome made from the product of two 3-digits numbers
largest_palindrome_product() ->
  Products = generate_list_of_products(),
  ProductsFiltered = filter_palindromes(Products),
  fold_into_max_product(ProductsFiltered).
