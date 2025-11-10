-record(sc_dict, {
    size,
    count = 0,
    %% list of tuples like {Key, Value}
    buckets
}).
