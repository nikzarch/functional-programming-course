-module(sc_dict).

-include("sc_dict.hrl").
-export([new/0, new/1, put/3, get/2, remove/2, to_list/1, merge/2, equal/2, filter/2, map/2, fold/3]).



new(Size) when Size < 10000 ->
    #sc_dict{size = Size, buckets = [[] || _ <- lists:seq(0, Size-1)]}.
new() ->
    new(10).

put(Key, Value, Dict) ->
    Load = Dict#sc_dict.count / Dict#sc_dict.size,
    Dict1 =
        if
            Load > 0.95 ->
                resize(Dict);
            true ->
                Dict
        end,
    Hash = erlang:phash2(Key, Dict1#sc_dict.size),
    NewBuckets = set_in_bucket(Hash, Key, Value, Dict1#sc_dict.buckets),
    case get(Key, Dict1) of
        not_found ->
            Dict1#sc_dict{count = Dict1#sc_dict.count + 1, buckets = NewBuckets};
        _ ->
            Dict1#sc_dict{buckets = NewBuckets}
    end.

get(Key, Dict) ->
    Hash = erlang:phash2(Key, Dict#sc_dict.size),
    get_from_bucket(Hash, Key, Dict#sc_dict.buckets).

get_from_bucket(N, Key, [_ | T]) when N > 0 ->
    get_from_bucket(N - 1, Key, T);
get_from_bucket(0, Key, [Bucket | _]) ->
    case lists:keyfind(Key, 1, Bucket) of
        {_, Value} -> {ok, Value};
        false -> not_found
    end.

set_in_bucket(N, Key, Value, [Bucket | T]) when N > 0 ->
    [Bucket | set_in_bucket(N - 1, Key, Value, T)];
set_in_bucket(0, Key, Value, [Bucket | T]) ->
    case lists:keyfind(Key, 1, Bucket) of
        false ->
            [[{Key, Value} | Bucket] | T];
        {_K, _V} ->
            [lists:keystore(Key, 1, Bucket, {Key, Value}) | T]
    end.


remove(Key, Dict) ->
    Hash = erlang:phash2(Key, Dict#sc_dict.size),
    {NewBuckets, Found} = remove_from_bucket(Hash, Key, Dict#sc_dict.buckets),
    NewCount = if Found -> Dict#sc_dict.count - 1; true -> Dict#sc_dict.count end,
    Dict#sc_dict{count = NewCount, buckets = NewBuckets}.

remove_from_bucket(N, Key, [Bucket | T]) when N > 0 ->
    {Rest, Found} = remove_from_bucket(N - 1, Key, T),
    {[Bucket | Rest], Found};
remove_from_bucket(0, Key, [Bucket | T]) ->
    case lists:keyfind(Key, 1, Bucket) of
        false -> {[Bucket | T], false};
        _ ->
            {[lists:keydelete(Key, 1, Bucket) | T], true}
    end.

resize(Dict) ->
    NewSize = trunc(Dict#sc_dict.size * 1.5),
    NewBuckets = [ [] || _ <- lists:seq(1, NewSize)],
    %% Перехешируем все пары из всех бакетов
    AllPairs = lists:flatten(Dict#sc_dict.buckets),
    NewBuckets2 = lists:foldl(
        fun({Key, Value}, BucketsAcc) ->
            Hash = erlang:phash2(Key, NewSize),
            set_in_bucket(Hash, Key, Value, BucketsAcc)
        end,
        NewBuckets,
        AllPairs
    ),
    #sc_dict{size = NewSize, count = Dict#sc_dict.count, buckets = NewBuckets2}.

to_list(Dict) ->
    lists:flatten(Dict#sc_dict.buckets).

merge(DictA, DictB) ->
    lists:foldl(
        fun({K, V}, Acc) -> sc_dict:put(K, V, Acc) end,
        DictA,
        sc_dict:to_list(DictB)
    ).
% F = fun(Key, Value, Acc) -> Acc
fold(F, Acc0, Dict) ->
    FoldFun = fun({K,V}, Acc) -> F(K, V, Acc) end,
    lists:foldl(FoldFun, Acc0, to_list(Dict)).

% map = fun({key,value} -> {key,value}
map(F, Dict) ->
    Pairs = to_list(Dict),
    New = new(Dict#sc_dict.size),
    lists:foldl(fun({K,V}, Acc) ->
        put(K, F(V), Acc)
                end, New, Pairs).

% pred = fun(pred,key) -> boolean
filter(Pred, Dict) ->
    Pairs = to_list(Dict),
    New = new(Dict#sc_dict.size),
    lists:foldl(fun({K,V}, Acc) ->
        case Pred(K, V) of
            true -> put(K, V, Acc);
            false -> Acc
        end
                end, New, Pairs).

equal(D1, D2)
    when is_record(D1, sc_dict),
    is_record(D2, sc_dict) ->
    if
        D1#sc_dict.count =/= D2#sc_dict.count ->
            false;

        true ->
            FoldFun = fun(Key, Val, Acc) ->
                case Acc of
                    false -> false;
                    true ->
                        case get(Key, D2) of
                            {ok, Val2} when Val2 =:= Val -> true;
                            _ -> false
                        end
                end
                      end,
            fold(FoldFun, true, D1)
    end;
equal(_, _) -> false.
