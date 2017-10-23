function [data,latents] = ucb_sim(param,data)
    
    % One-dimensional Kalman filter.
    
    % parameters
    q = param(1);           % reward variance
    q1 = param(2);
    q2 = param(3);
    b = param(4);           % uncertainty bonus
    lambda = param(5);         % inverse temperature
    
    for n = 1:length(data.block)
        
        % initialization at the start of each block
        if n == 1 || data.block(n)~=data.block(n-1)
            m = [0 0];  % posterior mean
            s = [q1 q2];  % posterior variance
        end
        
        % choice
        v = m + b*sqrt(s);
        p = normcdf((v(1)-v(2))/lambda); % choice probability
        if rand < p
            c = 1;
        else
            c = 2;
        end
        
        % feedback
        r = data.R(n,c);
        
        % store latents
        latents.m(n,:) = m;
        latents.s(n,:) = s;
        latents.v(n,:) = v;
        latents.p(n,1) = p;
        data.c(n,1) = c;
        data.r(n,1) = r;
        
        % update
        k = s(c)/(s(c)+q);         % Kalman gain
        err = r - m(c);            % prediction error
        m(c) = m(c) + k*err;       % posterior mean
        s(c) = s(c) - k*s(c);      % posterior variance
        
    end