function [T] = getTarget(task)
    
    istask(task);
    
    % design + test element
    len= task.design+task.test;
    %target
    T= cell(1,task.readouts(end));
    
    % target storage
    parfor r= task.readouts(1):1:task.readouts(end)
        aus= 1;
        numseq=1;
        for i= 1:task.kfold
            trans=task.transient;
            taskout= task.out{i,r};
            for n= 1:len
                if n > task.timesteps*numseq
                    trans=(task.timesteps*numseq)+task.transient;
                    numseq=numseq+1;
                end
                %delete transient for each target sequence
                if n>trans
                    T{r}(:,aus)= taskout(:,n);
                    aus=aus+1;
                end
            end
        end
    end 
    
end