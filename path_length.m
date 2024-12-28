function res = path_length(path)
    % 传入一条path，返回其长度
    load("params.mat", 'd');
    res = 0;
    if ~isempty(path)
        individual_length = length(path);
        if individual_length == 1
            res = res + d(0+1,path(1)+1) * 2;
        else
            for i = 1:individual_length
                if i == 1
                    % 起点，需要补0计算
                    res = res + d(0+1,path(i)+1); % 由于是无向图，所以顺序随便
                    % path(i) + 1 是因为matlab以1开始
                elseif i == individual_length
                    % 终点，既需要补0计算，又需要计算前距离
                    res = res + d(0+1,path(i)+1);
                    res = res + d(path(i)+1, path(i-1)+1);
                else
                    % 不然的话，范围是 起点+1 -> 终点-1，都计算前结点到自己的距离即可
                    res = res + d(path(i)+1, path(i-1)+1);
                end
            end
        end
    end
end