function res = valid(path)
    % 传入一条路径，判断其是否可行
    res = false;
    load("params.mat", 'Q', 'D');
    % 由于编码原因，我们不需要处理：
    % (4) (5) (6) (7)
    % 约束条件(8)被放在了path_length里，所以
    % 只需处理约束条件(2)和(3)

    % 处理(2)
    if path_weight(path) > Q
        return
    end

    % 处理(3)
    if path_length(path) > D
        return
    end

    res = true;
end