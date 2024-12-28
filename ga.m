% A solution of GA to resolve 'road and distribution' question
clear;
clc;
%% section 0. Introduction

% @Author   : abcd1234
% @Time     : 2024.6.12
% @Email    : abcd1234dbren@yeah.net

% model params as below:
% @brief 模型参数
% 
% @param K 汽车数量
K = 2;              % 按照论文参考文献[3]中的数据来，有2辆车
% @param Q_k 单汽车载重量上限
Q = 8000;           % 单位为kg，因为数据都相同，则做成一个数值
% @param D_k 单汽车单次行驶距离上限 *原文为h，疑似写错*
D = 40;             % 单位为km，因为数据都相同，则做成一个数值

% @param L 需求物资点数量
L = 8;              % 按照论文参考文献[3]中的数据来，有8物资点
% @param q_i 每个物资点需求数量
q = [1,2,1,2,1,4,2,2];
% @param d_ij 物资点i和物资点j的距离
% @param d_0j 汽车出发地到物资点j的距离 *即出发地下标设为0*
d = [
    0 4.0 6.0 7.5 9.0 20.0 10.0 16.0 8.0 0;
    4.0 0 6.5 4.0 10.0 5.0 7.5 11.0 10.0 4.0;
    6.0 6.5 0 7.5 10.0 10.0 7.5 7.5 7.5 6.0;
    7.5 4.0 7.5 0 10.0 5.0 9.0 9.0 15.0 7.5;
    9.0 10.0 10.0 10.0 0 10.0 7.5 7.5 10.0 9.0;
    20.0 5.0 10.0 5.0 10.0 0 7.0 9.0 7.5 20.0;
    10.0 7.5 7.5 9.0 7.5 7.0 0 7.0 10.0 10.0;
    16.0 11.0 7.5 9.0 7.5 9.0 7.0 0 10.0 16.0;
    8.0 10.0 7.5 15.0 10.0 7.5 10.0 10.0 0 8.0;
    0 4.0 6.0 7.5 9.0 20.0 10.0 16.0 8.0 0;
    ];

% @param R 路径集合
% @param r_k[i] k号路径里第i个经过的物资点 *r_k0即为配送中心*
% @param n_k k号路径的长度 *n_k=0是允许的，即不发车*

%% section I. Encode
%  this section is used to encode for GA

% 论文中，作者的编码方式为：
% 使用自然数为配送中心和物资点进行编码
% 对于有7个物资点、3辆车的示例情况，配送中心采用三个码：0, 8, 9
% 8和9是怎么来的呢？
% 它们是用于标志结尾的。因为有3个车，所以需要有3个路径。而如果想要
% 将整个路径集合建模为一个序列，那就应该有3个路径终点。作者选择，
% 让这几个路径终点的编号均不相同，在默认有一个'0'的情况下，就需要
% 增加两个终点。
% 而又因为有7个物资点，0被占用，所以物资点编码为1-7，那终点就增添
% 为8和9了。

% 作者给的例子，其一
% 如个体129638547，其表示的配送路径方案为：
% 路径1：0－1－2－9(0)
% 路径2：9(0)－6－3－8(0)
% 路径3：8(0)－5－4－7－0
% 共有3条配送路径，确实对应了汽车的数量

% 作者给的例子，其二
% 个体573984216，表示的配送路径方案为：
% 路径1：0－5－7－3－8(0)
% 路径2：9(0)－4－2－1－6－0
% 共有2条配送路径，有一个车不发车了

% 通过上面两个例子，我们可以明显看出：
% 这样的编码使得路径中不出现重复数值了！
% 这就使得我们在制定种群的初始化、遗传、变异等规则时，
% 可以很轻松地做出"正常"的个体

% 按照论文参考文献[3]中的数据来
node = [1,2,3,4,5,6,7,8];   % 需要物资的点
end_point = [0,9];          % 配送中心

%% section II. Init Population
%  this section is used to init the population

% 由于作者的编码方式很妙，所以，我们只需要生成"1 ` L+K-1"这些自然数
% 然后将其打乱顺序即可得到一个个体，多做一些个体，就拿到了种群

N = 20;                                     % 种群规模
individual_length = L + K - 1;              % 待排列的自然数
population = zeros(N, individual_length);   % 种群，采用矩阵表示
for i = 1:N
    % 生成从1到L+K-1的随机排列
    random_permutation = randperm(individual_length);
    population(i,:) = random_permutation;
end

%% section III. Fitness
%  this section is used to give apis to calculate an indival's fitness

% 首先，我们需要构建"适应度计算函数"
% 公式为：(9)
% function: F

% 其中涉及到了两个函数，Z和M
% Z的作用是，计算该个体代表路径的总长度
% M的作用是，计算不可行路径的数量

% 在计算个体路径总长度时，我们先将路径抽离出来，再依次计算
% 于是，我实现了路径长度计算函数path_length

% 在判断路径是否可行的过程中，我们需要实现各约束条件
% 于是，有了path_weight函数，用于计算路径所需要的总载重量

%% section IV. Choose
%  this section is used to solve the question

generation = 50;                            % 迭代max次数
fits = inf(1, N);                           % 对适应度的记录
p_cross = 0.95;                             % 交叉概率
p_vary = 0.05;                              % 变异概率
son_popu = zeros(N, individual_length);     % 子代种群暂存
J = 5;                                      % 变异后交换的次数

save("params.mat", 'd', 'q', 'Q', 'D', 'J', 'K', 'L');
format long;
for i = 1:generation
    % 按照个体适应度，对当前种群排序
    for j = 1:N
        fits(j) = -1 * F(population(j, :));
    end
    [~, idx] = sort(fits);
    population = population(idx, :);
    
    % 此时，进入到"选择"阶段
    % 对于适应度最高的个体，它直接保留，所以下面的下标是从2开始的
    son_popu(1,:) = population(1,:);
    for j = 2:N
        % 轮赌选择第一步，将适应度映射至概率
        cumulative_probabilities = cumsum(fits / sum(fits));
        parents_idx = zeros(1, 2); % 被选中的父和母
        
        for k = 1:2
            r = rand(); % 轮赌选择第二步，生成一个 [0, 1] 之间的随机数
            
            % 轮赌选择第三步，选择满足条件的第一个个体
            for t = 1:N
                if r <= cumulative_probabilities(t)
                    parents_idx(k) = t;
                    break;
                end
            end
        end
        
        if rand() > 0.95
            % 交叉
            son = Switch(population(parents_idx(1),:), population(parents_idx(2),:));
        else
            % 不交叉，选择更好的父代直接复制
            if Z(population(parents_idx(1),:)) > Z(population(parents_idx(2),:))
                son = population(parents_idx(1), :);
            else
                son = population(parents_idx(2), :);
            end
        end

        if rand() > 0.05
            % 变异
            son = Vary(son);
        end

        son_popu(j, :) = son; % 更新对应的后代
    end
    population = son_popu; % 更新下一代
end

% 按照个体适应度，对迭代出的种群排序
for j = 1:N
    fits(j) = -1 * F(population(j, :));
end
[~, idx] = sort(fits);
population = population(idx, :);

format short;
fprintf('最优适应度 >> %.4f\n', -1 * fits(1));
fprintf('当前种群情况 >>\n');
disp(population);
fprintf('最优个体 >> ');
disp(population(1, :));
fprintf('最优路径长度 >> %.4f\n', Z(population(1,:)));

%% section V. Switch & Vary
%  this section is used to give apis to 'switch and vary'

% 对于选择，由于论文没有说子代的选择规则，所以，我的实现是：
% 选择交换后的子代中，适应度更高的一个，作为唯一的子代
% 函数为Switch，接受两个传参，将更优的子代返回

% 对于变异，按照论文要求，复现了对应的代码
% 函数为Vary，接受一个传参，将变异生成的产物返回