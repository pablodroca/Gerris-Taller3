function J=MLC_Gerris_cylinder_evaluator(idv,parameters,i,fig)
    %% Variable grocery
    curdir=pwd;
    if nargin<3
        i=[];
    end
    
    %% Quick drop of innapropriate control laws
    if ~MLC_Gerris_cylinder_pre_evaluator(idv,parameters)
        J=parameters.badvalue;
        return
    end
    
    %% Setting up the simulation
    
    
    try
    
    %% Simulation
    
    if strcmp(parameters.evaluation_method,'mfile_multi')
        t=getCurrentTask();
        WorkerID=t.ID;
    else
        WorkerID=[];
    end
        
        
        
        if ~exist(sprintf('%s%d',parameters.problem_variables.SimDirectory,WorkerID),'dir')
            copyfile(parameters.problem_variables.SimDirectory,sprintf('%s%d',parameters.problem_variables.SimDirectory,WorkerID));
            pause(2);
        end
            
        xSetFinalTime(parameters.problem_variables,parameters.verbose>2,WorkerID);
        xSetActuator(idv,parameters,WorkerID);
            
    cd(sprintf('%s%d',parameters.problem_variables.SimDirectory,WorkerID))
    system('./clear_results')
    system('./exec_from_steady_state.sh')
    cd (curdir)
    
        
     
    
    
    
    
    %% Get the cost
    
    [t,x,y,s,b,dJa,dJb]=xGetResults(idv,parameters,WorkerID);
    [t0,dJ0]=xGetUncontrolledResults();
    if length(t0)~=length(t)
        error('Time vectors does not match with uncontrolled case (length).');
    else
        if any(t~=t0)
            error('Time vectors does not match with uncontrolled case (values).');
        end
    end
    
    
    
    
    
    if t(end)==parameters.problem_variables.total_time
        J=(trapz(t,dJa+parameters.problem_variables.gamma*dJb)/trapz(t,dJ0));
    else
        J=t(end)*parameters.badvalue;
    end
    
    
    
    %% Show results
    
    if nargin>3
        figure(667)
    else
        figure(1)
    end
        
          subplot(4,1,1)
    plot(t,s)
    
    subplot(4,1,2)
    plot(t,b)
    
    subplot(4,1,3)
    plot(t,dJa,t,dJb);hold on
    plot(t,dJ0,'linewidth',1.2,'color','k')
    hold off
    
    subplot(4,1,4)
    plot(t,cumtrapz(t,dJa),t,cumtrapz(t,dJb),...
    t,cumtrapz(t,dJa+parameters.problem_variables.gamma*dJb));
    hold on
    plot(t,cumtrapz(t,dJ0),'linewidth',1.2,'color','k')
    hold off
    
    drawnow
    
    
    %% deal with errors
    catch err
        fprintf(err.message);
       J=parameters.badvalue; 
    end
    
    