function res = Z(indival)
    % 传入一个row，代表着个体，计算其代表的路径总长度
    index = find(indival == 9);
    % 分割路径，不包含元素 9
    path1 = indival(1:index-1);
    path2 = indival(index+1:end);
    res = path_length(path1) + path_length(path2);
end