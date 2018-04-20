function [wout, results] = train_readout(task,X,T,varargin)
    
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
     
    training= task.training -(ceil(task.training/task.timesteps)*task.transient);
    design= task.design -(ceil(task.design/task.timesteps)*task.transient); 

    if task.kfold==1
        ausX= X(:,1:training);
        ausT= T(:,1:training);
        
        if par.lambda == 0
            wout= ausT*pinv(ausX);
        else
            ausX2= zeros(par.nr+1,size(ausX,2));
            for i= 1: size(ausX,2)
                ausX2(:,i)= [ausX(:,i);1];
            end
            ausX=ausX2;
            Xt= ausX';
            if det(ausX*Xt + par.lambda*eye(par.nr+1))==0
                wout= ausT*Xt*pinv(ausX*Xt + par.lambda*eye(par.nr+1));
            else
                wout= ausT*Xt/(ausX*Xt + par.lambda*eye(par.nr+1));
            end
        end
        %output rete
        if (training < design)
            ausX= X(:,training+1:design);
            ausT= T(:,training+1:design);
        end
        Y= wout*ausX;
        switch par.error 
            case 'mse'
                results= immse(ausT,Y);
            case 'nmse'
                results= mean(mean((ausT-Y).^2) )/ mean(mean((ausT).^2));
            case 'rmse'
                results=abs( sqrt( mean(mean((ausT-Y).^2) ) ));
            case 'nrmse'
                results= sqrt(mean(mean(((ausT-Y).^2)./(max(max(ausT))-min(min(ausT))))));

            case 'mc'
                c= (corrcoef(ausT,Y)).^2;
                results= c(1,2);
        end
        
    else
        res= zeros(task.kfold,1);
        parfor k= 1:task.kfold
            ausX=0;
            ausT=0;
            for t= 1:task.kfold
                if t~= k
                    if ausX==0
                        ausX= X(:, (design*(k-1)+1):(design*k));
                        ausT= T(:, (design*(k-1)+1):(design*k)); 
                    else
                        ausX= [ausX X(:, (design*(k-1)+1):(design*k))];
                        ausT= [ausT T(:, (design*(k-1)+1):(design*k))];
                    end
                end
            end

            if par.lambda == 0
                auswout{k}= ausT*pinv(ausX);
            else
                ausX2= zeros(par.nr+1,design);
                for i= 1: size(ausX,2)
                    ausX2(:,i)= [ausX(:,i);1];
                end
                ausX=ausX2;
                Xt=ausX2';
                if det(ausX2*Xt + par.lambda*eye(par.nr+1))==0
                    auswout{k}= ausT*Xt*pinv(ausX2*Xt + par.lambda*eye(par.nr+1));
                else
                    auswout{k}= ausT*Xt/(ausX2*Xt + par.lambda*eye(par.nr+1));
                end
            end

            Y{k}= auswout{k}*ausX;

            switch par.error 
                case 'mse'
                    res(k) =immse(ausT,Y{k});
                case 'rmse'
                    res(k)=abs( sqrt( mean(mean((ausT-Y{k}).^2) ) ));
                case 'nrmse'
                     res(k)= sqrt(mean(mean(((ausT-Y{k}).^2)./(max(max(ausT))-min(min(ausT))))));
                case 'mc'
                    c= (corrcoef(ausT,Y{k})).^2;
                    res(k)= c(1,2);   
            end
        end
        %retutn readout with best result
        switch par.error 
            case 'mc'
                [~, idx]=max(res);
                wout= auswout{idx};
            otherwise
                [~, idx]=min(res);
                wout= auswout{idx};
        end
        results=0;
        for k= 1:task.kfold
            results= results + res(k);
        end
        results= results/ task.kfold;
    end
end