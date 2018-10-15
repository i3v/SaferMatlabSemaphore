function benchmark_semaphore
% Simple serial get-token & free-token benchmark
% The result should be ~0.35s
timeit(@() inner(),1) 
end


function t=inner()
t = SemaphoreHost(2);
for i=1:1e4
    u = t.wait();
    u.post();
end

end