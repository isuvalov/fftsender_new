len=2048;
% len=30;
fd=100;

t=0:1/fd:len/fd-1/fd;
len2=floor(len/2);

test_signal=sin(2*pi*t*10);

for iterations=1:100

    test_signal=awgn(test_signal,10);
    test_signal_f=abs(fft(test_signal));
    test_signal_f=test_signal_f(1:floor(len/2));
    % plot(test_signal_f);


    max_signal_f=test_signal_f;

     max_array=[];
     nval=1;
    while (nval>0)
         npos=search_maximums(max_signal_f,1,len2);
         nval=max_signal_f(npos);
         max_array=[max_array npos];
         leftpos=npos-5;
         rightpos=npos+5;
         if (leftpos<1) leftpos=1; end;
         if (rightpos>len2) rightpos=len2; end;
         max_signal_f(leftpos:rightpos)=zeros(length(max_signal_f(leftpos:rightpos)),1);
    end

    bp=find(max_array.'<5);
    max_array(bp)=[];
    bp=find(max_array.'>(len2-5));
    max_array(bp)=[];

    % bar(test_signal_f(max_array),max_array);
    true_max_array=[];
    for z=1:length(max_array)
        lev_min=test_signal_f(max_array(z))*0.3;
        if (~((test_signal_f(max_array(z)-1)>lev_min) || (test_signal_f(max_array(z)+1)>lev_min)))
            true_max_array=max_array(z);
        end
    end %z

    stem([1 true_max_array len2],[0 test_signal_f(true_max_array) 0]);
    drawnow; pause(.1)
end % iterations