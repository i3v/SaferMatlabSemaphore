classdef Test_Semaphore  < matlab.unittest.TestCase
% Tests for SemaphoreHost and SemaphoreUser classes
    
    
    methods (TestClassSetup)       
        function classSetup(~)     
             gcp();                                  
        end
    end    

    
    methods (Test)
        function one_user(obj)                                       
            max_in=1;
            n_tasks = 5;
            waitPVC = {};
            t_pause = 2;
            [t_outA,may_in_countA] = obj.payload(max_in,n_tasks,waitPVC,t_pause);
            
            obj.verifyEqual(may_in_countA,zeros([1,n_tasks]));
            
            diff1 = diff(sort(t_outA(1:end)));            
                        
            obj.verifyGreaterThan(min(diff1),2);
            obj.verifyLessThan(max(diff1),2.1);            
        end
        
        function two_users(obj)           
            max_in=2;
            n_tasks = 8;
            waitPVC = {};
            t_pause = 2;
            [t_outA,may_in_countA] = obj.payload(max_in,n_tasks,waitPVC,t_pause);
            
            obj.verifyTrue(all(ismember(may_in_countA,[0,1])));            
            
            t_out_sorted_A = sort(t_outA);
            
            diff1 = diff(t_out_sorted_A);
            diff1 = diff1(1:2:end);
            
            diff2 = diff(t_out_sorted_A);
            diff2 = diff2(2:2:end);
            
            obj.verifyLessThan(max(diff1),0.1);
            obj.verifyGreaterThan(min(diff2),1.9);
            obj.verifyLessThan(max(diff2),2.1);            
        end
        
        function more_users(obj)
            max_in=3;
            n_tasks = 16;
            waitPVC = {16*0.5};
            t_pause = 0.5;
            [~,may_in_countA] = obj.payload(max_in,n_tasks,waitPVC,t_pause);            
                        
            obj.verifyTrue(all(ismember(may_in_countA,[0,1,2])));                        
        end
        
        function wait_limited_time(obj)
            
            max_in=2;
            n_tasks = 5;
            waitPVC = {2.5};
            t_pause = 1;
            [t_outA,~] = obj.payload(max_in,n_tasks,waitPVC,t_pause);
                        
            obj.verifyGreaterThan(max(t_outA),3);
            obj.verifyLessThan(max(t_outA),3.3);
        end
        
        function wait_timeout(obj)
            max_in=1;
            n_tasks = 8;
            waitPVC = {2};
            t_pause = 0.5;            
            
            obj.verifyError( @() obj.payload(max_in,n_tasks,waitPVC,t_pause),...
                            'MATLAB:semaphore:waitTimeout');
                                                               
        end
        
        function wait_timeout2(obj)
             semphr = SemaphoreHost(1);
             usr1=semphr.wait(1);             
             obj.verifyError(@() semphr.wait(1),'MATLAB:semaphore:waitTimeout');
             usr1.post();
             usr3=semphr.wait(1);             
             usr3.post();                                       
        end
        
        function create_key_uniqueness(obj)
            % Test if all keys would be unique. Also used as a quick check
            % that creating a few thousands semaphores won't do anything
            % bad to Windows.
            n = 1e4;
            
            for i=1:n
                semphrA(i) = SemaphoreHost(1); %#ok<AGROW>
            end
            
            obj.verifyEqual(numel(unique({semphrA.semkey})),n);
        end
        
    end
    
    methods (Static)
        function [t_out,may_in_count] = payload(max_in,n_tasks,waitPVC,t_pause)
            semphr = SemaphoreHost(max_in);
            t0=tic();
            parfor i=1:n_tasks
                usr=semphr.wait(waitPVC{:}); %#ok<PFBNS>
                pause(t_pause); % simulates some work
                may_in_count(i) = usr.post();
                t_out(i)=toc(t0);
            end
            
            % "destroy" doesn't actually delete anything (see "semaphore.c")
            % this is just to make sure GC won't kill it before
            delete(semphr); 
                            
        end
    end
end

