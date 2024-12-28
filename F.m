function res = F(indival)
    % 传入一个个体，将返回其适应度
    G = 100; % 惩罚权重，单位为km
    res = 1 / (Z(indival) + M(indival)*G);
end