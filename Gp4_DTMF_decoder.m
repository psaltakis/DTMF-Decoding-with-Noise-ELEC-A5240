function output = Gp4_DTMF_decoder(input)
%GP4_DTMF_DECODER Summary of this function goes here
%   Detailed explanation goes here

[y, fs]=audioread(input);

y = [zeros(100,1); y / max(abs(y(:))); zeros(100,1)]; % normalization and zero pad to avoid moving average error

t=1:length(y);

% figure;
% plot(y)

% Filtering signal to make the level detection and number detection easier
[b1,a1]=butter(2,0.05,"high");
y=filter(b1,a1,y);
[b1,a1]=butter(2,0.3*fs/fs);
y=filter(b1,a1,y);
% soundsc(y,fs);

% Computing the average of the signal by a moving window
mvavg = movmean(abs(y), [0 fs/80],'omitnan','Endpoints', 'discard'); 

% figure;
% plot(mvavg)

% Setting the level detection threshold
threshold=0.6*max(mvavg); % whatever you want your threshold to be, 0.6 works well

overthrsh = (mvavg >= threshold);  % Checking when the value is over the threshold

transition = diff([overthrsh]); % We compute when the value is changing from nonzero to zero and vice versa
startIdx = find(transition > 0)-1; % starting index when their is signal (i.e value=1)
endIdx = find(transition < 0); % end index when their is no signal anymore (i.e value=-1)

duration = endIdx-startIdx+1; % computing the duration of the non zeros segments
% figure; stem(transition);
% figure; stem(duration);

timetreshold=0.035*fs; % setting a threshold of time, below this the segments will be ignored
stringIdx = (duration >= timetreshold);
% figure; stem(stringIdx);
startIdx = startIdx(stringIdx); % Resizing the indexes
endIdx = endIdx(stringIdx); % getting rid of the first value due to the padding


numSeg = numel(startIdx); % computing total number of segment
yseg(numSeg).y = 0; % creating a structure which will contain all the segments
for h = 1:numSeg
    yseg(h).y = y(startIdx(h):endIdx(h));
end


%% Number detection
% Initializing
phonenumber=zeros(1,numSeg);

lfft=2048*2; % Length of the fft
Nqst=lfft/2; % Nyquist
order=9; % Order of the filters
p2p=0.5; % peak to pick values
cutoff_l=1000/(0.5*fs); % passband frequency for LP filter (1000 Hz)
cutoff_h=1120/(0.5*fs); % passband frequency for HP filter (1120 Hz)

for i=1:numSeg
% soundsc(yseg(i).y,fs);
% pause(0.5);

% Filtering the signal first to isolate the lowest frequency then to
% isolate the highest.
[b,a]=cheby1(order,p2p,cutoff_l);
yfilt1=filter(b,a,yseg(i).y);
hlow=fft(yfilt1,lfft);
lowspectrum=abs(hlow(1:Nqst));
% figure;
% subplot(2,1,1);
% plot(lowspectrum);

[b1,a1]=cheby1(order,p2p,cutoff_h,'high');
yfilt2=filter(b1,a1,yseg(i).y);
hhigh=fft(yfilt2,lfft);
highspectrum=abs(hhigh(1:Nqst));
% subplot(2,1,2);
% plot(highspectrum);

% Finding what frequency is the tone
maxl=max(abs(lowspectrum)); % finding maximum
maxh=max(abs(highspectrum)); 
freqlow=find(maxl==lowspectrum); % finding index of the maximum in the spectrum (i.e frequency)
freqhigh=find(maxh==highspectrum); 
l=((freqlow-1)*fs)/lfft; % multiplying to get the real frequencies
h=((freqhigh-1)*fs)/lfft;


%% Testing for number correspondence
 if max(maxl,maxh)/min(maxl,maxh)>100 % If ratio between the two frequencies is too high we consider it as an error
 phonenumber(1,i)=888;
 elseif l<600 || h>1600 % If the frequencies are out of the DTMF range --> error
 phonenumber(1,i)=888;
 elseif abs(l-697)<0.01*697 && abs(h-1209)<0.01*1209
 phonenumber(1,i)=1;
 elseif abs(l-697)<0.01*697 && abs(h-1336)<0.01*1336
 phonenumber(1,i)=2;
 elseif abs(l-697)<0.01*697 && abs(h-1477)<0.01*1477
 phonenumber(1,i)=3;
 elseif abs(l-697)<0.01*697 && abs(h-1633)<0.01*1633
 phonenumber(1,i)='A';
 elseif abs(l-770)<0.01*770 && abs(h-1209)<0.01*1209
 phonenumber(1,i)=4;
 elseif abs(l-770)<0.01*770 && abs(h-1336)<0.01*1336
 phonenumber(1,i)=5;
 elseif abs(l-770)<0.01*770 && abs(h-1477)<0.01*1477
 phonenumber(1,i)=6;
 elseif abs(l-770)<0.01*770 && abs(h-1633)<0.01*1633
 phonenumber(1,i)='B';
 elseif abs(l-852)<0.01*852 && abs(h-1209)<0.01*1209
 phonenumber(1,i)=7;
 elseif abs(l-852)<0.01*852 && abs(h-1336)<0.01*1336
 phonenumber(1,i)=8;
 elseif abs(l-852)<0.01*852 && abs(h-1477)<0.01*1477
 phonenumber(1,i)=9;
 elseif abs(l-852)<0.01*852 && abs(h-1633)<0.01*1633
 phonenumber(1,i)='C';
 elseif abs(l-941)<0.01*941 && abs(h-1209)<0.01*1209
 phonenumber(1,i)='*';
 elseif abs(l-941)<0.01*941 && abs(h-1336)<0.01*1336
 phonenumber(1,i)=0;
 elseif abs(l-941)<0.01*941 && abs(h-1477)<0.01*1477
 phonenumber(1,i)='#';
 elseif abs(l-941)<0.01*941 && abs(h-1633)<0.01*1633
 phonenumber(1,i)='D';
 else
 phonenumber(1,i)=888; % else --> error
 end
end

finalphonenumber=phonenumber(phonenumber~=888); % Deleting the errors

output=sprintf('%d', finalphonenumber); % putting everything into a string

% disp('Phone number is '); disp(output);

end

