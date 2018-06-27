function demo_semaphore()
% In this demo, each of n_users (8 by default) performs some work, that
% consists of 3 steps.
%
% # 1st step is time-consuming, but might be executed in parallel
% # 2nd step is fast, but some limited resource is needed (e.g. a lot of RAM)
% # 3rd step is just like first.
%
% In this demo, each of 8 workers need 1 GB of RAM on 2nd step, but only 2
% workers are allowed to perform it simultaneously.   
    
    max_users = 2;
    timeout = 50;
    
    sem_host = SemaphoreHost(max_users);    
    
    t0 = tic();
    parfor i=1:8
        % step1
        fprintf('i=%d \t time=%08.3f \t p1 \n',i, toc(t0));        
        step1(i);        
        
        % step2
        fprintf('i=%d \t time=%08.3f \t p2 - before wait \n',i, toc(t0));
        sem_usr = sem_host.wait(timeout); %#ok<PFBNS>
        fprintf('i=%d \t time=%08.3f \t p3 - token granted \n',i, toc(t0));
        step2(i);
        sem_usr.post();
        fprintf('i=%d \t time=%08.3f \t p4 - token released \n',i, toc(t0));
        
        % step3
        step3(i);        
        fprintf('i=%d \t time=%08.3f \t p5 - finished \n',i, toc(t0));
    end    
end

function step1(~)
    pause(5); 
end

function step2(~)
    x = zeros([1e9 1],'uint8'); %#ok<NASGU>
    pause(1); 
end

function step3(~)
    pause(5); 
end