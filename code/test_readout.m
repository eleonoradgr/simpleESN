function [results_test] = test_readout(task,wout,X,T, varargin)
    
    istask(task);

    par.nr= size(X,1);
    par.lambda= 0;
    par.error= 'mse';
    
    %assignement of values passed as parameters
    n_arg= length(varargin);
    for iArg = 1:2:n_arg        % considering couple of parameters
        name_argument = varargin{iArg};       % arguments's name
        value_argument = varargin{iArg+1};    % arguments's value
        par.(name_argument) = value_argument;
    end 
    
    design= task.design -(ceil(task.design/task.timesteps)*task.transient);
    test= task.test -(ceil(task.test/task.timesteps)*task.transient);
    
    if task.kfold==1

        ausX= X(:,design+1:design+test);

        if size(wout,2)~= size(ausX,1)
            for i= 1: size(ausX,2)
                ausX2(:,i)= [ausX(:,i);1];
            end
            ausX=ausX2;
        end

        Ytest= wout*ausX;
        ausT= T(:,design+1:design+test);
    
        switch par.error 
            case 'mse'
                results_test= immse(ausT,Ytest);
            case 'rmse'
                results_test=abs( sqrt( mean(mean((ausT-Ytest).^2) ) ));
            case 'nrmse'
                 results_test= sqrt(mean(mean(((ausT-Ytest).^2)./(max(max(ausT))-min(min(ausT))))));
            case 'mc'
                c=(corrcoef(ausT,Ytest)).^2;
                results_test= c(1,2);
        end
    else
        res = zeros(task.kfold, 1);
        for k= 1:task.kfold
            ausX= X(:, (design*(k-1)+1):(design*k));
            if size(wout,2)~= size(ausX,1)
                for i= 1: size(ausX,2)
                    ausX2(:,i)= [ausX(:,i);1];
                end
                ausX=ausX2;
            end
            Ytest= wout*ausX;
            ausT= T(:,(design*(k-1)+1):(design*k));
            switch par.error 
                case 'mse'
                    res(k,1) =immse(ausT,Y);
                case 'rmse'
                    res(k,1)=abs( sqrt( mean(mean((ausT-Ytest).^2) ) ));
                case 'nrmse'
                    res(k,1)= abs( sqrt( sum(mean((ausT-Ytest).^2)) ) )/(max(max(ausT))-min(min(ausT)));
                case 'mc'
                    c=(corrcoef(ausT,Ytest)).^2;
                    res(k,1)=c(1,2);
            end
        end

        results_test=0;
        for kf= 1:task.kfold
            results_test= results_test+ res(kf,1);
        end
        results_test= results_test./ task.kfold;
    end

end
    