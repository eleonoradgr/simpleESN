function [results, results_test, wout, X] = ESNtrain(task,varargin)
%   initialization and training of a Echo State Network.
%   nu: input dim,              default 1
%   scale_in: input scaling,    default 0.1
%   nr: reservoir dimention,    default 100
%   dist: type of distribution, default ud
%   density_con: weights~= null,defaut 1
%   rho: spectra radius w,      default 0.9
%   alpha: leaking rate,        default 1
%   bias: input bias,           default 1
%   ny: output dimention,       default 1 
%   readouts: number of readout,default 1
%   lambda: par reg tikhonov,   default 0
%   error: error mesure,        default mse

    
    par.scale_in = 0.1;
    par.nr = 100;
    par.dist= 'ud';
    par.density_con=1;
    par.rho= 0.9;
    par.alpha = 1;
    par.bias= 1;
    par.lambda = 0;
    par.error= 'mse';
    par.test= true;
    
    nu=task.dim_in;
    ny=task.dim_out;
    readouts=task.readouts(end);
    
    %assignement of values passed as parameters
    n_arg= length(varargin);
    for iArg = 1:2:n_arg    % considering couple of parameters
        name_argument = varargin{iArg}; % arguments's name
        value_argument = varargin{iArg+1}; % arguments's value
        par.(name_argument) = value_argument;
    end
    
    [win, w]= weightMatrix('nr', par.nr, 'nu', nu, 'scale_in', par.scale_in, 'rho', par.rho, 'alpha', par.alpha, 'dist', par.dist, 'densit_con', par.density_con );
    
    %readout weight
    wout= cell(1,readouts);
    %output readout
    Y=cell(task.kfold,readouts);
    %results for each readout
    results=zeros(1, readouts);
    
    if task.dim_in ~= nu || task.dim_out ~= ny
        disp('Dimentions of this task do not match with nu and ny,');
        disp('Initialize a new ESN with the right parameterd');
    end
    
    [ X ]= setReservoir(task, win, w, 'alpha', par.alpha, 'bias', par.bias );
    [ T ]= getTarget(task);
    parfor r= task.readouts(1):1:task.readouts(end)
        [wout{1,r}, results(1,r)]= train_readout(task,X,T{r},'lambda', par.lambda,'error',par.error);
        results_test(1,r)=0;
    end
    
    if (par.test)
        parfor r= task.readouts(1):1:task.readouts(end)
            [results_test(1,r)]= test_readout(task,wout{1,r},X,T{r},'lambda',par.lambda,'error', par.error);
        end
    end
end

