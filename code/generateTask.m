function task = generateTask(taskname,varargin)
%Generazione dei task
% task.size : dimensione del task
% task.nrreadout : nr di readout da allenare
% task.kfold : numero di folds

switch taskname
    case Tasks.Simple
        %inizializzazione default per task casuale
        task.dim_in= 3;
        task.dim_out= 2;
        task.kfold=1;
        task.readouts=1;
        task.timesteps=4200;
        task.design= 2200;
        task.transient=200;
        task.training=2000;
        task.test=2000;
        %inizializazione con parametri passati come argomento
        n_arg= length(varargin);
        for iArg = 1:2:n_arg % considerare i parametri in coppie
            name_argument = varargin{iArg}; % nome dell'argomento
            value_argument = varargin{iArg+1}; % valore dell'argomento
            task.(name_argument) = value_argument;
        end
        
        
        for k = 1:task.kfold
            for i= 1: (task.design+task.test)
                for j = 1:task.dim_in
                    task.in{k}(j,i) =-1 + 2*rand();
                end
                for j = 1 :task.dim_out
                    task.out{k,1}(j,i) =-1 + 2*rand();
                end
            end
        end
        
    case Tasks.Narma
        %inizializzazione default per Narma task 
        task.dim_in= 1;
        task.dim_out= 1;
        task.kfold=1;
        task.readouts=1:1;
        task.timesteps=4200;
        task.design= 2200;
        task.transient=200;
        task.training=2200;
        task.test=2000;
        
        %inizializazione con parametri passati come argomento
        n_arg= length(varargin);
        for iArg = 1:2:n_arg % considerare i parametri in coppie
            name_argument = varargin{iArg}; % nome dell'argomento
            value_argument = varargin{iArg+1}; % valore dell'argomento
            task.(name_argument) = value_argument;
        end
        
        if task.dim_in ~= 1 || task.dim_out ~= 1
           disp( "Error: dim_in and dim_out must be 1 in narma task.");
        else
          for k = 1:task.kfold  
              task.in{k}= abs(rand(1,task.design+task.test) -0.5);
              task.out{k,1}= abs(rand(1,task.design+task.test) -0.5);
              for n= 11:task.design+task.test
                  task.out{k,1}(1,n)= 0.3*task.out{k,1}(1,n-1) + 0.05*task.out{k,1}(1,n-1)*(task.out{k,1}(1,n-1)+task.out{k,1}(1,n-2)+task.out{k,1}(1,n-3)+task.out{k,1}(1,n-4)+task.out{k,1}(1,n-5)+task.out{k,1}(1,n-6)+task.out{k,1}(1,n-7)+task.out{k,1}(1,n-8)+task.out{k,1}(1,n-9)+task.out{k,1}(1,n-10))+ 1.5*task.in{k}(1,n-10)*task.in{k}(1,n-1) + 0.1;
              end
          end
        end
        
    case Tasks.Verst
        task.dim_in= 1;
        task.dim_out= 1;
        task.kfold=5;
        task.readouts=1:150;
        task.timesteps=1000;
        task.design= 2000;
        task.training= 2000;
        task.transient=200;
        task.test=0;
        task.p=10;
        task.d=15;
        n_arg= length(varargin);
        for iArg = 1:2:n_arg % considerare i parametri in coppie
            name_argument = varargin{iArg}; % nome dell'argomento
            value_argument = varargin{iArg+1}; % valore dell'argomento
            task.(name_argument) = value_argument;
        end
        aus=0;
        
        for k= 1:task.kfold
            inaus{k}=zeros(1,task.d+2+task.timesteps);
            inbus{k}=zeros(1,task.d+2+task.timesteps);
            for n = 1:1:task.d+1+task.timesteps
                inaus{k}(n)= -0.8 + 1.6*rand();
                inbus{k}(n)= -0.8 + 1.6*rand();
            end
            task.in{k}(1,1:task.timesteps)=inaus{k}(1, task.d+2:task.d+1001);
            task.in{k}(1,task.timesteps+1:2*task.timesteps)=inbus{k}(1, task.d+2:task.d+1001);
        end
        for d = 1:1:task.d
             for p =1:1:task.p
                 aus=aus+1;
                 for k= 1:task.kfold
                     kt=task.d+2;
                     for j= 1:task.timesteps
                         task.out{k,aus}(1,j)=sign(inaus{k}(kt-d)*inaus{k}(kt-d-1))*( abs(inaus{k}(kt-d)*inaus{k}(kt-d-1))).^p;
                         task.out{k,aus}(1,j+task.timesteps)=sign(inbus{k}(kt-d)*inbus{k}(kt-d-1))*( abs(inbus{k}(kt-d)*inbus{k}(kt-d-1))).^p;
                        kt=kt+1;
                     end
                 end
             end
        end
        
    case Tasks.MC
        task.dim_in=1;
        task.dim_out=200;
        task.kfold=1;
        task.readouts=1:200;
        task.timesteps=6000;
        task.design= 5000;
        task.transient=200;
        task.training=5000;
        task.test=1000;
        
        D= importdata('mc100.csv');
        task.in{1}= (D.data(1:6000, 1))';
        for r=1:task.readouts(end)
            task.out{1,r}=(D.data(1:6000, r+1))';
        end
    case Tasks.Laser
        task.dim_in=1;
        task.dim_out=1;
        task.kfold=1;
        task.readouts=1;
        task.timesteps=10092;
        task.design= 5000;
        task.transient=1000;
        task.training=4000;
        task.test=5092;
        
        D= importdata('laser.csv');
        disp(D);
        task.in{1}= (cellfun(@str2num, D.textdata(17:10108, 1)))';
        for r=1:task.readouts
            task.out{1,r}=cellfun(@str2num,D.textdata(17:10108, r+1))';
        end
    case Tasks.MG
        task.dim_in=1;
        task.dim_out=1;
        task.kfold=1;
        task.readouts=1;
        task.timesteps=10000;
        task.design= 5000;
        task.transient=1000;
        task.training=5000;
        task.test=5000;
        
        data= load('MG17_task.mat');
      
        task.in{1}=data.input;
        for r=1:task.readouts
            task.out{1,r}=data.target;
        end
        
    case Tasks.sinMC
        task.dim_in=1;
        task.dim_out=200;
        task.kfold=1;
        task.readouts=1:16;
        task.timesteps=6000;
        task.design= 5000;
        task.transient=200;
        task.training=5000;
        task.test=1000;
        task.v=exp(-1);
        
        n_arg= length(varargin);
        for iArg = 1:2:n_arg 
            name_argument = varargin{iArg}; 
            value_argument = varargin{iArg+1}; 
            task.(name_argument) = value_argument;
        end
        
        D= importdata('mc100.csv');
        task.in{1}= (D.data(1:6000, 1))';
        for r=1:task.readouts(end)
            task.out{1,r}=sin(task.v*(D.data(1:6000, r+1))');
        end
    case Tasks.Mixture
        task.dim_in=1;
        task.dim_out=1;
        task.kfold=1;
        task.readouts=1:1;
        task.timesteps=4200;
        task.design= 2200;
        task.transient=200;
        task.training=2200;
        task.test=2000;
        task.alpha=0;
        task.delay=13;
        
        n_arg= length(varargin);
        for iArg = 1:2:n_arg 
            name_argument = varargin{iArg}; 
            value_argument = varargin{iArg+1}; 
            task.(name_argument) = value_argument;
        end
        
        if task.dim_in ~= 1 || task.dim_out ~= 1
           disp( "Error: dim_in and dim_out must be 1 in narma task.");
        else
          for k = 1:task.kfold
              
              inaus=abs(rand(1,task.design+task.test + task.delay) -0.5);
              task.in{k}= inaus(1,(task.delay+1):(task.design+task.test+task.delay));
              outaus=zeros(1,task.design+task.test + task.delay);
              outausmem=zeros(1,task.design+task.test + task.delay);
              
              for n= task.delay+1:task.design+task.test+task.delay
                  outaus(1,n)= 0.3*outaus(1,n-1)+ 0.05* outaus(1,n-1)*(outaus(1,n-1)+outaus(1,n-2)+outaus(1,n-3)+outaus(1,n-4)+outaus(1,n-5)+outaus(1,n-6)+outaus(1,n-7)+outaus(1,n-8)+outaus(1,n-9)+outaus(1,n-10))+ 1.5*inaus(1,n-10)*inaus(1,n-1) + 0.1;
                  outausmem(1,n)= inaus(1,n-task.delay);
                  task.out{k,1}(1,n-task.delay)= (1-task.alpha)*(outausmem(1,n))+ (task.alpha)*(outaus(1,n));
                  outaus(1,n)=task.out{k,1}(1,n-task.delay);
              end
          end
        end
    
    case default
        disp("type of task is unknown");
        
end
end

