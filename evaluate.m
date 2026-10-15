function [decision,pvalue]=evaluate(data,delay,waveform,parm)
% Evaluate whether a preset number of waveforms is true.
%
% -- Usage
% decision=evaluate(data,delay,waveform);
% or
% decision=evaluate(data,delay,waveform,parm);
%
% -- Input
% data : EEG/MEG data. (Nsample x Ntrial x Nchannel)
% delay : delays of waveforms. (Ntrial x Nwaveform)
% waveform : waveforms. (Nsample x Nwaveform x Nchannel)
%
% -- Optional input
% Fields of struct 'parm'.
% .pre_stim : time range of prestimulus [time point 1, time point 2]
% .pos_stim : time range of poststimulus [time point 3, time point 4]
%
% -- Output
% decision : decision of the evaluation. ('true' or 'wrong')
%
% -- Note
% This program needs a statistics toolbox.
%
% 2011/5/11 Y. Takeda

% Default parameters
pre_stim=[1 50];
pos_stim=[51 120];

% Check optional inputs
if nargin==4
    if isfield(parm,'pre_stim');pre_stim=parm.pre_stim;end
    if isfield(parm,'pos_stim');pos_stim=parm.pos_stim;end
end

% Calculate residual errors
re=residual_error(data,delay,waveform);

% Divide redisual errors
pre=re(pre_stim(1):pre_stim(2),:,:);%plot(std(pre,0,2));hold on
pre=pre(:);
pos=re(pos_stim(1):pos_stim(2),:,:);%plot(std(pos,0,2),'r');hold off
pos=pos(:);

% Kolmogorov-Smirnov test
[h,pvalue]=kstest2(pre,pos); % a function of a statistics toolbox

% Return decision
if h==0;
    decision='true';
else
    decision='wrong';
end

%Plot distributions of residual error
% fprintf(['Preset number of waveforms is evaluated as ' decision '.\n'])
% figure
% a1=min(re(:));
% a2=max(re(:));
% a=linspace(a1,a2,100);
% h_pre=hist(pre,a);
% h_pos=hist(pos,a);
% plot(a,h_pre/sum(h_pre),'b')
% hold on
% plot(a,h_pos/sum(h_pos),'r')
% hold off
% legend 'Prestimulus' 'Poststimulus'
% xlabel('Value of residual errors')
% ylabel('Normalized frequency')
% title(['Evaluation (Num. of waveforms is ' num2str(size(delay,2)) '.)'])

