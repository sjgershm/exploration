function latents = kalman_filter(param,data)
    
    % One-dimensional Kalman filter.
    
    % parameters
    q = param(1);           % reward variance
    q1 = param(2);
    q2 = param(3);
    
    for n = 1:length(data.block)
        
        % initialization at the start of each block
        if n == 1 || data.block(n)~=data.block(n-1)
            m = [0 0];  % posterior mean
            s = [q1 q2];  % posterior variance
        end
        
        c = data.c(n);
        r = data.r(n);
        
        
        % store latents
        latents.m(n,:) = m;
        latents.s(n,:) = s;
        
        % update
        k = s(c)/(s(c)+q);         % Kalman gain
        err = r - m(c);            % prediction error
        m(c) = m(c) + k*err;       % posterior mean
        s(c) = s(c) - k*s(c);      % posterior variance
        
    end