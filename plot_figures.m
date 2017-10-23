function varargout = plot_figures(fig,varargin)
    
    switch fig
        
        case 'choice_prob'
            
            mu = linspace(-3,3,100);
            d = 1;
            p(1,:) = 1-normcdf(0,mu+d,1);
            p(2,:) = 1-normcdf(0,mu,1+d);
            
            figure;
            T = {'UCB: intercept shift' 'Thompson: slope shift'};
            for i = 1:2
                subplot(1,2,i);
                plot(mu,1-normcdf(0,mu,1),'-k','LineWidth',5); hold on;
                plot(mu,p(i,:),'-','LineWidth',5,'Color',[0.5 0.5 0.5]);
                if i==1; legend({'Low SD' 'High SD'},'FontSize',25,'Location','East'); end
                set(gca,'FontSize',25,'XLim',[min(mu) max(mu)]);
                ylabel('Choice probability','FontSize',25);
                xlabel('Expected value difference (V)','FontSize',25);
                title(T{i},'FontSize',25','FontWeight','Bold');
            end
            set(gcf,'Position',[200 200 900 400]);
            
        case 'optimality'
            
            load results_optimality2
            gamma = linspace(0.001,2,15);
            p = squeeze(mean(P));
            p(:,2) = mean(p(:,2));
            plot(gamma,p,'LineWidth',4);
            legend({'UCB' 'Thompson' 'Hybrid'},'FontSize',25)
            xlabel('\gamma','FontSize',25);
            ylabel('P(optimal)','FontSize',25);
            set(gca,'FontSize',25)
            
        case 'regression'
            switch varargin{1}
                case 'one-arm'
                    load results_sim1
                    data_human = load_data('../data1');
                    Q = [10 10 0];
                case 'two-arm'
                    load results_sim
                    data_human = load_data('../data');
                    Q = [10 100 100];
            end
            
            for s = 1:length(data_human)
                results(3).latents(s) = kalman_filter(Q,data_human(s));
            end
            T = {'UCB' 'Thompson' 'Data'};
            
            figure;
            v = linspace(min(results(3).latents(s).m(:)),max(results(3).latents(s).m(:)),8)';
            for i = 1:3
                if i==1
                    data = data_ucb;
                elseif i==2
                    data = data_thompson;
                else
                    data = data_human;
                end
                b = [];
                for s = 1:length(results(i).latents)
                    S = sqrt(results(i).latents(s).s(:,1) + results(i).latents(s).s(:,2));
                    Sm = sqrt(results(i).latents(s).s(:,1)) - sqrt(results(i).latents(s).s(:,2));
                    V = results(i).latents(s).m(:,1) - results(i).latents(s).m(:,2);
                    C = double(data(s).c==1);
                    X = [V Sm V./S];
                    b(s,:) = glmfit(X,C,'binomial','link','probit','constant','off');
                    
                    if i==3
                        for j = 1:length(v)-1
                            ix = V>v(j) & V<v(j+1) & S<quantile(S,0.5);
                            if ~any(ix)
                                pc(s,j,1) = nan;
                            else
                                pc(s,j,1) = nanmean(C(ix));
                            end
                            
                            ix = V>v(j) & V<v(j+1) & S>quantile(S,0.5);
                            if ~any(ix)
                                pc(s,j,2) = nan;
                            else
                                pc(s,j,2) = nanmean(C(ix));
                            end
                        end
                    end
                end
                
                [~,p] = ttest(b)
                mu = mean(b); se = std(b)./sqrt(size(b,1));
                
                subplot(2,2,i);
                barerrorbar(mu',se');
                set(gca,'FontSize',25,'XTickLabel',{'V' 'RU' 'V/TU'});
                title(T{i},'FontSize',25,'FontWeight','Bold');
                ylabel('Coefficient','FontSize',25);
            end
            
            varargout{1} = b;
            
            subplot(2,2,4);
            [se,mu] = wse(pc);
            x = v(1:end-1) + diff(v)/2;
            errorbar(x,mu(:,1),se(:,1),'-ok','LineWidth',4,'MarkerSize',12,'MarkerFaceColor','k'); hold on
            errorbar(x,mu(:,2),se(:,2),'-o','LineWidth',4,'MarkerSize',12,'MarkerFaceColor',[0.5 0.5 0.5],'Color',[0.5 0.5 0.5]);
            legend({'Low TU' 'High TU'},'FontSize',25,'Location','East');
            set(gca,'FontSize',25,'XLim',[min(v) max(v)],'YLim',[0 1]);
            ylabel('Choice probability','FontSize',25);
            xlabel('Expected value difference','FontSize',25);
            
            set(gcf,'Position',[200 200 1200 1000]);
            
        case 'choice_RT'
            T = {'Experiment 1' 'Experiment 2'};
            for i = 1:2
                switch i
                    case 1
                        load results_sim1
                        data = load_data('../data1');
                        Q = [10 10 0];
                    case 2
                        load results_sim
                        data = load_data('../data');
                        Q = [10 100 100];
                end
                
                for s = 1:length(data)
                    latents = kalman_filter(Q,data(s));
                    X = [];
                    for n = 1:length(data(s).c)
                        if data(s).c(n)==1
                            X(n,1) = latents.m(n,1) - latents.m(n,2);
                            X(n,2) = sqrt(latents.s(n,1)) - sqrt(latents.s(n,2));
                        else
                            X(n,1) = latents.m(n,2) - latents.m(n,1);
                            X(n,2) = sqrt(latents.s(n,2)) - sqrt(latents.s(n,1));
                        end
                        X(n,3) = sqrt(latents.s(n,2) + latents.s(n,1));
                    end
                    b(s,:) = glmfit(X,log(data(s).rt),'normal');
                end
                b_rt{i} = b;
                mu = mean(b(:,2:4))
                se = std(b(:,2:4))./sqrt(size(b,1));
                [~,p] = ttest(b(:,2:4))
                clear b
                
                subplot(2,2,i);
                barerrorbar(mu',se');
                set(gca,'FontSize',25,'XTickLabel',{'V' 'RU' 'TU'});
                ylabel('Coefficient','FontSize',25);
                title(T{i},'FontSize',25,'FontWeight','Bold');
                
            end
            
            load regression_coefficients
            for i = 1:2
                subplot(2,2,i+2);
                plot(b_choice{i}(:,2),b_rt{i}(:,3),'ok','MarkerSize',10,'LineWidth',4);
                h = lsline;
                set(h,'LineWidth',3);
                xlabel('Choice coefficient (RU)','FontSize',25)
                ylabel('RT coefficient (RU)','FontSize',25)
                set(gca,'FontSize',25);
            end
            
            varargout{1} = b_rt;
            set(gcf,'Position',[200 200 1200 1000]);
            
        case 'bms'
            load bms_results
            pxp = [bms_results(1).pxp; bms_results(2).pxp]';
            bar(pxp); colormap linspecer
            legend({'Experiment 1' 'Experiment 2'},'FontSize',25,'Location','North');
            set(gca,'FontSize',25,'XTickLabel',{'UCB' 'Thompson' 'Hybrid' 'Value'},'YLim',[-0.05 1.05],'XLim',[0.5 4.5]);
            ylabel('PXP','FontSize',25);
            
        case 'uncertainty_bonus'
            for i=1:2
                
                switch i
                    case 1
                        load results_sim1
                        data = load_data(1);
                        Q = [10 10 0];
                    case 2
                        load results_sim2
                        data = load_data(2);
                        Q = [10 100 100];
                end
                
                p = []; b = [];
                for s = 1:length(data)
                    latents(s) = kalman_filter(Q,data(s));
                    X = [];
                    ix = data(s).trial~=1;
                    for n = 1:length(data(s).c)
                        X(n,:) = [(latents(s).m(n,1)-latents(s).m(n,2))./sqrt(sum(latents(s).s(n,:))) sqrt(latents(s).s(n,1))-sqrt(latents(s).s(n,2))];
                    end
                    X = X(ix,:);
                    c = data(s).c(ix);
                    b(s,:) = glmfit(X,c==1,'binomial','link','probit','constant','off');
                    p(s,1)=mean(data(s).c(data(s).trial==1)==1);
                end
                
                [r,pval] = corr(b,p)
                [~,pval,~,stat] = ttest(p,0.5)
                mu(i) = mean(p);
                se(i) = std(p)./sqrt(length(p));
                if i==1; y = [p b(:,2)]; end
            end
            
            subplot(1,2,1);
            barerrorbar(mu',se');
            hold on;
            set(gca,'XTickLabel',{'Experiment 1' 'Experiment 2'},'FontSize',25,'XLim',[0.5 2.5]);
            ylabel('Choice probability','FontSize',25);
            plot(get(gca,'XLim'),[0.5 0.50],'--k','LineWidth',3);
            
            subplot(1,2,2)
            plot(y(:,2),y(:,1),'ok','MarkerSize',10,'LineWidth',4);
            h = lsline;
            set(h,'LineWidth',3);
            set(gca,'FontSize',25,'YLim',[0 1.05],'XLim',[-1 2]);
            xlabel('Coefficient (RU)','FontSize',25)
            ylabel('Choice probability','FontSize',25)
            set(gcf,'Position',[200 200 1000 500])
            
            
        case 'reward_distributions'
            x = linspace(-20,20,1000)';
            y(:,1) = normpdf(x,0,sqrt(10));
            y(:,2) = zeros(size(x)); y(find(x>0,1,'first'),2) = normpdf(0,0,sqrt(10));
            figure;
            subplot(1,2,1);
            myplot([x x],y,'-','LineWidth',5);
            legend({'Option A' 'Option B'},'FontSize',25);
            ylabel('Probability density','FontSize',25);
            xlabel('Reward','FontSize',25);
            title('Experiment 1','FontSize',25,'FontWeight','Bold')
            set(gca,'FontSize',25,'XLim',[min(x) max(x)])
            
            y(:,1) = normpdf(x,0,sqrt(100));
            subplot(1,2,2);
            myplot(x,y(:,1),'-','LineWidth',5);
            ylabel('Probability density','FontSize',25);
            xlabel('Reward','FontSize',25);
            title('Experiment 2','FontSize',25,'FontWeight','Bold')
            set(gca,'FontSize',25,'XLim',[min(x) max(x)])
            
            set(gcf,'Position',[200 200 900 400]);
            
    end