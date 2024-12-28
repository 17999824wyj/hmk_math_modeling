function res = M(indival)
    % 传入一个个体，将返回其中不可行的路径的数量
    res = 0;
    index = find(indival == 9);
    % 分割路径，不包含元素 9
    path1 = indival(1:index-1);
    path2 = indival(index+1:end);
    if ~valid(path1)
        res = res + 1;
    end
    if ~valid(path2)
        res = res + 1;
    end
end