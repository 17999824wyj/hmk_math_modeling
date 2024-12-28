function me = Vary(self)
    % 接受子代个体本身，进行变异
    load("params.mat", 'J');
    idx = randi([1, 9], 2, J); % 2*5矩阵，每列代表要交换的位置
    % 开始交换
    for i = 1:J
        id1 = idx(1, i);
        id2 = idx(2, i);
        while id1 == id2
            % 交换过程中，若发现值相同，则重新随机生成
            id2 = randi([1, 9]);
        end

        tmp = self(id1);
        self(id1) = self(id2);
        self(id2) = tmp;
    end
    me = self;
end