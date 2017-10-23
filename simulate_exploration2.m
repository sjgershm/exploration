function P = simulate_exploration2
    
    nSubjects = 50;
    nBlocks = 10;       % number of blocks
    N = 20;             % block length
    q0 = 100;           % prior variance
    q = 10;             % observation variance
    b = 1;
    lambda = 1;
    
    % generate data
    for s = 1:nSubjects
        data(s).R = []; data(s).block = []; data(s).mu = [];
        for block = 1:nBlocks
            mu = repmat(normrnd([0 0],[sqrt(q0) sqrt(q0)]),N,1);
            data(s).mu = [data(s).mu; mu];
            data(s).R = [data(s).R; normrnd(mu,sqrt(q))];
            data(s).block = [data(s).block; zeros(N,1)+block];
        end
        
        % simulate algorithms
        [data_ucb(s), results(1).latents(s)] = ucb_sim([q q0 q0 b lambda],data(s));
        [data_thompson(s), results(2).latents(s)] = thompson_sim([q q0 q0],data(s));
        [data_hybrid(s), results(3).latents(s)] = hybrid_sim([q q0 q0 b],data(s));
        
        for n=1:length(data(s).block)
            [~,k] = max(data(s).mu(n,:));
            p(n,:) = [data_ucb(s).c(n) data_thompson(s).c(n) data_hybrid(s).c(n)]==k;
        end
        P(s,:) = mean(p);
    end
    
    save results_sim2 results data_ucb data_thompson data_hybrid P