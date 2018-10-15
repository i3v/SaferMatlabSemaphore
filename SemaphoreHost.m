classdef SemaphoreHost < handle
    % SEMAPHOREHOST grants access to SemaphoreUsers.    
    % Creates a semaphore that allows at most N_USERS to pass in simultaneously. 
    %
    %%% Usage example:   
    %
    %     sem_host = SemaphoreHost(2);            
    %     parfor i=1:8    
    %         some_work(i)
    %
    %         sem_usr = sem_host.wait(timeout);             
    %         critical_section(i);    
    %         sem_usr.post();
    %         
    %         more_work(i)    
    %     end
    %
    %%% Limitations:
    %    
    % * Windows only           
    % * Does not work on a distributed multi-node cluster.    
    % * Underlying system objects are shared, accessible by any other process.
    % * Underlying system objects are not destroyed properly - e.g. there's a 
    %    system resource (semaphore handles) leak.  Resources are only
    %    freed when Matlab process exits. This should not matter much in
    %    practice, unless you would create ~16,000,000 semaphores one by
    %    one (in which case it would be a good idea to reuse the same one).                
    %    <https://blogs.technet.microsoft.com/markrussinovich/2009/09/29/pushing-the-limits-of-windows-handles/ 
    %    More details about maximum number of handles>.
    % 
    %
    % SEE ALSO: demo_semaphore.m    
    
    
    properties (SetAccess = private)
        semkey
    end
    
    methods 
        function obj=SemaphoreHost(n_users, name, add_uniqueness)
            % Creates a semaphore that allows at most N_USERS to pass in simultaneously. 
            %
            %% Usage:
            %  
            %  sem_host = SemaphoreHost(2);
            %  sem_host = SemaphoreHost(1,'my_critical_section_1');
            %  sem_host = SemaphoreHost(1,'my_critical_section_2', false);
            %
            %% Inputs:
            %
            % * N_USERS - number of users that are allowed simultaneously
            % * NAME - [1 N] character vector. ~200 chars max.                        
            % * ADD_UNIQUENESS - logical scalar. If True, a pseudorandom
            %   part (based on time and pid) is added to the NAME. Default is True.
                        
            
            if nargin < 2
                name = 'unnamed'; 
                add_uniqueness = true;
            else
                assert( ischar(name) && isvector(name) && length(name)<200,...
                        'SemaphoreHost:badName',...
                        'The name should be a short character vector' );
            end
            
            if nargin == 3                
                assert( islogical(add_uniqueness) && isscalar(add_uniqueness),...
                        'SemaphoreHost:badAddUniqueness',...
                        'The add_uniqueness must be a logical scalar' );
            end
            
            if add_uniqueness
                name = SemaphoreHost.new_unique_semkey(name);   
            end
            
            obj.semkey = name;
            semaphore('create',obj.semkey,n_users);
        end
        
        function semaphore_user = wait( obj, max_seconds )            
            % Asks semaphore to "give an entrance token". 
            % Waits inside untill a token would be available. 
            %
            % MAX_SECONDS specifies timeout, after which an exception would
            % be thrown. Use Inf to wait forever.
            %
            % The exception, thrown on timeout:
            %   msgid = 'MATLAB:semaphore:waitTimeout' 
            %   message = 'Timeout (%d msec) waiting for \"%s\".' 
            %              
            % Note:
            % * timeout is per-user - the "countdown timer" for some
            %   "user2" is not reset when "user1" or "user3" gets the ticket.
            %   And the order, in which tickets are issued is not defined,
            %   e.g. it is theoretically possible that "user1" and "user3"
            %   would do 100 tickets, while "user2" would be still waiting.
            %   (Even though this does not happen in practice.)
            % * the SemaphoreUser object, created here would automatically
            %   return ticket upon destruction.
                        
            if nargin<2
                max_seconds=20;
            end
            
            msec_uint32 = uint32(max_seconds*1000);
            semaphore_user = SemaphoreUser(obj.semkey,msec_uint32);                        
        end

    end
    
    methods (Static)
        
        function key_str = new_unique_semkey( name )    
            % Creates a new [1 N] char "unique ID", based on PID and time
            % To make sure 
            
            if nargin<1
                name = 'unnamed';
            end
            
            assert( ischar(name) && isvector(name) && length(name)<200,...
                    'SemaphoreHost:badName',...
                    'The name should be a short character vector' );
            
            % Here we use an undocumented "feature()" function.
            % If it would break at some point - it could be replaced with 
            % >> jpid = java.lang.management.ManagementFactory.getRuntimeMXBean.getName.char; 
            % (which returns something like '3836@hostname')
            % ... or just remove pid info at all.
            pid_str = num2str(feature('getpid'));
            
            t = num2str(tic);
            
            key_str = [name '_' pid_str '_' t];
            
            assert( length(key_str)<250,...
                    'SemaphoreHost:badName',...
                    'The name appear to be too long.' );
            
        end


    end
    
end

