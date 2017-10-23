function P = simulate_optimality2
    
    nSubjects = 500;
    nBlocks = 10;       % number of blocks
    N = 20;             % block length
    q0 = 100;           % prior variance
    q = 10;             % observation variance
    gamma = linspace(0.001,2,15);
    beta = 4;
    lambda = 1;
    
    % generate data
    for j = 1:length(gamma)
        disp(num2str(j))
        for s = 1:nSubjects
            data(s).R = []; data(s).block = []; data(s).mu = [];
            for block = 1:nBlocks
                mu = repmat(normrnd([0 0],[sqrt(q0) sqrt(q0)]),N,1);
                data(s).mu = [data(s).mu; mu];
                data(s).R = [data(s).R; normrnd(mu,sqrt(q))];
                data(s).block = [data(s).block; zeros(N,1)+block];
            end
            
            % simulate algorithms
            [data_ucb(s), results(1).latents(s)] = ucb_sim([q q0 q0 gamma(j) lambda],data(s));
            [data_thompson(s), results(2).latents(s)] = thompson_sim([q q0 q0],data(s));
            [data_hybrid(s), results(3).latents(s)] = hybrid_sim([q q0 q0 gamma(j) beta],data(s));
            
            for n=1:length(data(s).block)
                [~,k] = max(data(s).mu(n,:));
                p(n,:) = [data_ucb(s).c(n) data_thompson(s).c(n) data_hybrid(s).c(n)]==k;
            end
            P(s,j,:) = mean(p);
        end
    end