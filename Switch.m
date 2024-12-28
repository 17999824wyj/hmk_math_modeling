function son = Switch(father, mother)
    % 接受两个父代个体，返回其产出的更好的子代个体
    load("params.mat", 'K', 'L');
    % 7 的来历：9不行，8不行，所以7
    left = randi([1, K + L - 3]);            % 左区间
    right = randi([left + 1, K + L - 1]);    % 右区间
    % 交换区间为： [left, right]
    A = father(left: right);
    B = mother(left: right);
    son1 = [B, father(~ismember(father, B))];
    son2 = [A, mother(~ismember(mother, A))];
    if Z(son1) > Z(son2)
        son = son1;
    else
        son = son2;
    end
end