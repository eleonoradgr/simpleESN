function [results] = ESNtest(task,varargin)
%   initialization and training of a Echo State Network.
%   nu: input dim,              default 1
%   scale_in: input scaling,    default 0.1
%   nr: reservoir dimention,    default 100
%   dist: type of distribution, default ud
%   rho: spectra radius w,      default 0.9
%   alpha: leaking rate,        default 1
%   bias: input bias,           default 1
%   ny: output dimention,       default 1 
%   readouts: number of readout,default 1
%   lambda: p reg tikhonov,   default 0
%   error: error mesure,        default mse

    
    p.scale_in = 0.1;
    p.nr = 100;
    p.dist= 'ud';
    p.density_con=1;
    p.rho= 0.9; 
    p.alpha = 1;
    p.bias= 1;
    p.lambda = 0;
    p.error= 'mse';
    p.wout={};
    p.X={};
    
    nu=task.dim_in;
    ny=task.dim_out;
    readouts=task.readouts(end);
    
    %assignement of values passed as pameters
    n_arg= length(varargin);
    for iArg = 1:2:n_arg    % considering couple of pameters
        name_argument = varargin{iArg}; % arguments's name
        value_argument = varargin{iArg+1}; % arguments's value
        p.(name_argument) = value_argument;
    end
    
    T= getTarget(task);
    
    %if readout are not passed as argument, they are produced and trained
    %on both training and validation data.
    
    if ((iscell(p.wout) && isempty(cell2mat(p.wout))) || (~iscell(p.wout) && isempty(p.wout)) ||...
           (iscell(p.X) && isempty(cell2mat(p.X))) || (~iscell(p.X) && isempty(p.X)) )
        [win, w]= weightMatrix('nr', p.nr, 'nu', nu, 'scale_in', p.scale_in, 'rho', p.rho, 'alpha', p.alpha, 'dist', p.dist, 'densit_con', p.density_con );

        %readout weight
        wout= cell(1,readouts);
        %output readout
        Y=cell(task.kfold,readouts);
        %results for each readout
        results=zeros(1, readouts);

        if task.dim_in ~= nu || task.dim_out ~= ny
            disp('Dimentions of this task do not match with nu and ny,');
            disp('Initialize a new ESN with the right pameterd');
        end
        
        task.training=task.design;

        [ X ]= setReservoir(task, win, w, 'alpha', p.alpha, 'bias', p.bias );
        [ T ]= getTarget(task);
        parfor r= task.readouts(1):1:task.readouts(end)
            [wout{1,r}, results(1,r)]= train_readout(task,X,T{r},'lambda', p.lambda,'error',p.error);

        end
        p.wout=wout;
        p.X=X;
    end
    
    parfor r= task.readouts(1):1:task.readouts(end)
        if(iscell(p.wout))
            [results(1,r)]= test_readout(task,p.wout{1,r},p.X,T{r},'lambda',p.lambda,'error', p.error);
        else
            [results(1,r)]= test_readout(task,p.wout,p.X,T{r},'lambda',p.lambda,'error', p.error);
        end
    end

end

