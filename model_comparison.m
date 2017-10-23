function bms_results = model_comparison
    
    for i = 1:2
        if i==1
            load results_sim1
            data = load_data(1);
            param = [10 10 0];
        elseif i==2
            load results_sim2
            data = load_data(2);
            param = [10 100 100];
        end
        
        for s = 1:length(data)
            latents(s) = kalman_filter(param,data(s));
        end
        
        for j = 1:4
            for s = 1:length(data)
                X = [];
                for n = 1:length(data(s).c)
                    if j==1 % UCB
                        X(n,:) = [latents(s).m(n,1)-latents(s).m(n,2) sqrt(latents(s).s(n,1))-sqrt(latents(s).s(n,2))];
                    elseif j==2 % Thompson
                        X(n,1) = (latents(s).m(n,1)-latents(s).m(n,2))./sqrt(sum(latents(s).s(n,:)));
                    elseif j==3 % Hybrid
                        X(n,:) = [(latents(s).m(n,1)-latents(s).m(n,2))./sqrt(sum(latents(s).s(n,:))) sqrt(latents(s).s(n,1))-sqrt(latents(s).s(n,2))];
                    elseif j==4 % Value-directed exploration
                        X(n,:) = latents(s).m(n,1)-latents(s).m(n,2);
                    end
                end
                c = data(s).c;
                b = glmfit(X,c==1,'binomial','link','probit','constant','off');
                y = glmval(b,X,'probit','constant','off');
                L = sum(log(y(c==1))) + sum(log(1-y(c==2)));
                bic(s,j) = -2*L + size(X,2)*log(n);
            end
        end
        
        [bms_results(i).alpha,bms_results(i).exp_r,bms_results(i).xp,bms_results(i).pxp,bms_results(i).bor] = bms(-0.5*bic);
        
        clear latents bic
    end