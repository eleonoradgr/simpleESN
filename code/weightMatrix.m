function [win,w] = weightMatrix(varargin)
    
    %initialization of default parameters
    par.nr=100;         %reservoir units
    par.nu=1;           %input dim
    par.scale_in=0.1;   %input scaling
    par.rho=0.9;        %spectral radius
    par.alpha=1;        %leaking integrator
    par.dist='ud';      %type of distribution
    par.density_con=1;  %density of connections
    
    %assignement of values passed as parameters
    n_arg= length(varargin);
    for iArg = 1:2:n_arg        % considering couple of parameters
        name_argument = varargin{iArg};       % arguments's name
        value_argument = varargin{iArg+1};    % arguments's value
        par.(name_argument) = value_argument;
    end
    
    switch par.dist
            case 'ud'
                %input weignt matrix
                win= (-1 + (2*rand(par.nr, par.nu+1)))*par.scale_in;
                %connection wheight matrix
                aus= -1 + 2*rand(par.nr, par.nr);   
            case 'nd'
                %input weignt matrix
                win= ((1/3)*randn(par.nr, par.nu+1))*par.scale_in;
                %connection wheight matrix
                aus= (1/3)*randn(par.nr, par.nr);               
    end
    w= (1-par.alpha).*eye(par.nr) + par.alpha.*aus;
    w= w .* (par.rho/max(abs(eig(w))));
    w= (1/par.alpha) .* (w - (1-par.alpha).*eye(par.nr));
    %setting element to zero
    nrz= floor( (1-par.density_con)* par.nr);
    if nrz > 0
        for irow = 1:par.nr
             indz= randperm(par.nr,nrz);
             w(irow,indz) = 0;
        end
    end
end
    