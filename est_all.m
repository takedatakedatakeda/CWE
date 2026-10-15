function [Nwaveform,delay,waveform]=est_all(data,parm_delay,parm_evaluate)
% Estimate the number of waveforms common across trials, their delays, and
% all of the waveforms.
%
% -- Usage
% [Nwaveform,delay,waveform]=est_all(data);
% or
% [Nwaveform,delay,waveform]=est_all(data,parm_delay,parm_evaluate)
%
% -- Input
% data : EEG/MEG data. (Nsample x Ntrial x Nchannel)
% 
% -- Optional input
% Fields of struct 'parm_delay'.
% .Mean : means of delays. (1 x Nwaveform) or (Ntrial x Nwaveform)
%         default = data length / 8 for all delays.
% .SD : standard deviations of delays. (1 x Nwaveform)
%       default = Mean / 2 for all delays.
% .Nrandom_search : number of repetitions of a random search.
%                   default = 10.
% .Ngrid_search : number of repetitions of a grid search. (1 or 0)
%                 default = 1.
% .min_delay : minimum values of delays. (1 x Nwaveform) or (Ntrial x
%              Nwaveform)
%              default = 0 for all delays.
% .max_delay : maximum values of delays. (1 x Nwaveform) or (Ntrial x
%              Nwaveform)
%              default = data length / 4 for all delays.
%
% Fields of struct 'parm_evaluate'.
% .pre_stim : time range of prestimulus [time point 1, time point 2]
% .pos_stim : time range of poststimulus [time point 3, time point 4]
%
% -- Output
% Nwaveform : estimated number of waveforms.
% delay : estimated delays. (Ntrial x Nwaveform)
% waveform: estimated waveforms. (Nsample x Nwaveform x Nchannel)
%
% 2010/11/30 Y. Takeda

maxNwav=5;
if ~exist('parm_delay','var')
    parm_delay=[];
else
    if isfield(parm_delay,'Mean')
        maxNwav=size(parm_delay.Mean,2);
    end
end

if ~exist('parm_evaluate','var')
    parm_evaluate=[];
end

for Nwaveform=1:maxNwav
    fprintf('Preset number of waveforms is set to %1.0f. \n',Nwaveform)
    
    % Delay estimation step
    delay=est_delay(data,Nwaveform,parm_delay);
    
    % Waveform estimation step
    waveform=est_waveform(data,delay);
    
    % Evaluation step
    decision=evaluate(data,delay,waveform,parm_evaluate);
    
    % Decision
    if strcmp(decision,'true') || Nwaveform==maxNwav
        fprintf('Finished. \n')
        break
    else
        fprintf('Return to Delay estimation step by increasing preset number of waveforms by 1. \n') 
    end
end