% This srcipt test DTMF-function with 12 different audio signals and writes
% "dtmf_X.log" file, where X is your teams name.
% You need dtmf_TESTI_[101,..,112].wav.
% 
% Write your own dtmf_decode.m function with takes .wav-file as input and
% returns characterline of the numbers/spaces like '555 9999 434343434'
% (class(numberLine) --> 'char'; num2str(112) -> '112').
% 
% Inspired by Jukka Parviainen, 2011-2015

f_h  = @Gp4_DTMF_decoder;        % Change you function name here
teamName = 'Group_4';        % Change your teams name here
% Run this code ->get log-file

% You can change this code if you want to.

%% 12 ‰‰nitiedoston testaus

loki = ['loki_' teamName '.log'];   % vaihda t‰h‰n lokitiedosto
fid  = fopen(loki, 'w');

CorrectNumbers={...
    '050581051861301520120325';
    '0445330224';
    '0201333328'; 
    '0403283302';
    '0444814111';
    '0417729192';
    '050724113556';
    '0155711432';
    '0947025285';
    '0402221543';
    '0072663526372663'; 
    '007266352637'}; 
    
for k=1:12
    tic;
    result = f_h(['dtmf_TESTI_' num2str(100+k) '.wav']);
    usedTime = toc;
    if strcmp(result, CorrectNumbers{k})
        correct = 1;
    else
        correct = 0;
    end
    disp(['File:           ' num2str(100+k)]);
    disp(['Time:           ' num2str(usedTime) ' s']);
    disp(['Your number:    ' result]);
    disp(['Correct number: ' CorrectNumbers{k}]);
    fprintf(fid,'%s; Audio: %d; Time: %2.4f; Working?: %d; Your number: %s\n', teamName, 100+k, usedTime, correct, result);
%     pause;
end
fclose(fid);
