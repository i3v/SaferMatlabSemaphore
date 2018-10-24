% SEMAPHORE  via Win32
% https://msdn.microsoft.com/en-us/library/windows/desktop/ms682438(v=vs.85).aspx
%
% --------------------------------------------------------------------------
%  This function could be dangerous - you can easily hang your Matlab
%  session. Please avoid using it directly unless you know what you're
%  doing. Use SemaphoreHost wrapper instead.
% --------------------------------------------------------------------------
%
%
%   H=SEMAPHORE('create',STR_UID, VAL)
%      Initializes a semaphore which can later by accessed by STR_UID. The
%      argument VAL specifies the initial value for the semaphore.
%      Returns uint64 scalar handle (for debugging).
%
%   SEMAPHORE('destroy',STR_UID)
%      Does not do anything. (Yep, there's a leak.)
%
%   SEMAPHORE('wait',STR_UID, TIMEOUT)
%   SEMAPHORE('wait',STR_UID)
%      Decrements (locks) the semaphore indexed by STR_UID. If the
%      semaphore's value is greater than zero, then the decrement
%      proceeds, and the function returns, immediately. If the semaphore
%      currently has the value zero, then the call blocks until either it
%      becomes possible to perform the decrement (i.e., the semaphore
%      value rises above zero), or a signal handler interrupts the call.
%      TIMEOUT must be uint32. infinite==intmax('uint32') 
%
%   N=SEMAPHORE('post',STR_UID)
%      Increments (unlocks) the semaphore indexed by STR_UID. If the
%      semaphore's value consequently becomes greater than zero, then
%      another process or thread blocked in a 'wait' call will be woken
%      up and proceed to lock the semaphore.
%      Returns double scalar semaphore-value-before-post
%
%   See also WHOSSHARED, SHAREDMATRIX.
%
%   Example:
%      semkey='12345';
%      semaphore('create',semkey,1);
%      semaphore('wait',semkey, uint32(10000));
%      u = semaphore('post',semkey);
%
%   [1] - http://en.wikipedia.org/wiki/Semaphore_(programming)
%
%   Copyright (c) 2011, Joshua V Dillon
%   Copyright (c) 2014, Andrew Smart 
%   Copyright (c) 2018, Igor Varfolomeev
%   All rights reserved.

% Joshua V. Dillon
% jvdillon (a) gmail (.) com
% Wed Aug 10 13:29:01 EDT 2011

function semaphore(command,uid_str,val) %#ok<INUSD>

error('semaphore:notCompiled',...
      [newline ...
       ' It looks like `mex` file for the `semaphore.c` is missing.' newline ...
       ' Please compile it: ' newline ...
       '   1) cd to the folder containing "semaphore.c" ' newline ...
       '   2) >> mex semaphore.c ' newline ...
       '   3) >> clear functions' newline ...
      ]);
   
end