classdef SemaphoreUser < handle
    % SEMAPHORE_USER represents a holder of a pass-token.
    % Automatically returns token upon destruction.
    % Normally, obj.post() method should be called to return the token.

    
    properties (SetAccess = private)
        semkey
    end
    
    methods (Access = {?SemaphoreHost})
        function obj = SemaphoreUser(semkey, seconds_uint32)
            % The method should be only called from SemaphoreHost.wait() normally.
            semaphore('wait',semkey, seconds_uint32);
            obj.semkey=semkey;
        end
    end
    
    methods
        function may_in_count = post(obj)
            % POST returns used token, so that it could be passed to another user.
            
            assert(~isempty(obj.semkey),...
                   'SemaphoreUser:Post:EmptyKey',...
                   'Attempt to post non-used semaphore');
            
            may_in_count=semaphore('post',obj.semkey);
            obj.semkey='';
        end
        
        function delete(obj)
            if ~isempty(obj.semkey)
                obj.post();
            end     
        end
    end
    
end

