function [X] = setReservoir(task,win,w,varargin)
    
    %initialization of default parameters
    par.nr=size(w,1);         %reservoir units
    par.alpha=1;        %leaking integrator
    par.bias=0;         %bias
    
    %assignement of values passed as parameters
    n_arg= length(varargin);
    for iArg = 1:2:n_arg        % considering couple of parameters
        name_argument = varargin{iArg};       % arguments's name
        value_argument = varargin{iArg+1};    % arguments's value
        par.(name_argument) = value_argument;
    end
    
    %training and test elements without transient for each fold
    training= task.training -(ceil(task.training/task.timesteps)*task.transient);
    design= task.design -(ceil(task.design/task.timesteps)*task.transient);
    test= task.test -(ceil(task.test/task.timesteps)*task.transient);
    % design + test element
    len= task.design+task.test;
    % reservoir states
    X= zeros(par.nr,task.kfold*(design+test));
     %target
    T= cell(1,task.readouts(end));
    
    % reservoir initialization
    aus=1;
    numseq=1;
    for i = 1:task.kfold
        taskin= task.in{i};
        x = zeros(par.nr,1);
        trans=task.transient;
        for n = 1:len
            u= taskin(:,n);
            x= (1-par.alpha)* x + par.alpha*tanh(win*[u;par.bias] + w*x );
            if n > task.timesteps*numseq
                numseq=numseq+1;
                trans=trans+task.timesteps;
            end
            %delete transient for each input sequence
            if n>trans
                %reservoir states
                X(:,aus)=x;
                aus=aus+1;
            end
        end
    end
   

end