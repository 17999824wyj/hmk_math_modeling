function res = path_weight(path)
    % 传入一条path，返回其载重量
    load("params.mat", 'q');
    res = 0;
    if ~isempty(path)
        for i = 1:length(path)
            res = res + q(path(i));
        end
    end
end