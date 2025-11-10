-module(sc_dict).

-include("sc_dict.hrl").
-export([new/0,new/1,put/3,get/2,set/3]).



new(Size) when Size < 10000 ->
    #sc_dict{size = Size, buckets = [{} || _ <- lists:seq(0, Size)]}.
new() ->
    #sc_dict{size = 10, buckets = [{} || _ <- lists:seq(0, 10)]}.

put(Key, Value, Dict) ->
    Load = Dict#sc_dict.count / Dict#sc_dict.size,
    Dict =
        if
            Load > 0.7 ->
                resize(Dict);
            true ->
                Dict
        end,
    Hash = erlang:phash2(Key, Dict#sc_dict.size),
    #sc_dict{
        size = Dict#sc_dict.size,
        count = Dict#sc_dict.count,
        buckets = set({Key, Value}, Hash, Dict#sc_dict.buckets)
    }.

get(Key, Dict) ->
    Hash = erlang:phash2(Key, Dict#sc_dict.size),
    get_from_bucket(Hash, Dict#sc_dict.buckets).
get_from_bucket(N, [_ | T]) when N > 0 ->
    get_from_bucket(N - 1, T);
get_from_bucket(0, [H | _]) ->
    H.
set(Value, N, [H | T]) when N > 0 ->
    [H | set(Value, N - 1, T)];
set(Value, 0, Buckets) ->
    [Value | Buckets].

resize(Dict) ->
    NewSize = Dict#sc_dict.size + Dict#sc_dict.size / 2,
    NewBuckets = lists:map(
        fun({Key, Value}) -> {erlang:phash2(Key, NewSize), Value} end, Dict#sc_dict.buckets
    ),
    #sc_dict{size = NewSize, count = Dict#sc_dict.count, buckets = NewBuckets}.
