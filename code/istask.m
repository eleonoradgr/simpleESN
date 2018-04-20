function [] = istask(task)
    if ( ~isfield(task, 'dim_in') || ~isfield(task, 'dim_out') || ~isfield(task, 'kfold') ||...
            ~isfield(task, 'readouts') || ~isfield(task, 'timesteps') || ~isfield(task, 'design') ||...
            ~isfield(task, 'transient') || ~isfield(task, 'training') ||~isfield(task, 'test'))
        error('Task is not well defined, use function generateTask()');
    end
end