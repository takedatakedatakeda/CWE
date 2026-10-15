% Demo program using real EEG data during Go trials of a Go/NoGo task 
%
% 2010/11/30 Y. Takeda

close all

clear all



%%% Load data

load go_data


%%% Estimate the number of waveforms, their delays, and all the waveforms

% --Optional inputs
parm_delay.Mean=[zeros(96,1) reaction_time./10 ones(96,1)*25]; % Means of delays
parm_delay.SD=[5 5 12]; % Standard deviations of delays
parm_delay.Nrandom_search=10; % Number of repetitions of a random search
parm_delay.Ngrid_search=1; % Number of repetitions of a grid search (0 or 1)
parm_delay.min_delay=[zeros(96,1) reaction_time./10-2 zeros(96,1)]; % Minimum values of delays
parm_delay.max_delay=[ones(96,1)*5 reaction_time./10+2 ones(96,1)*50]; % Maximum values of delays
%parm_delay.FOI=get_FOI(data,100,[2 30]); % Frequency index of interest
%parm_delay.TOI=50:140; % Time index of interest

parm_evaluate.pre_stim=[1 50]; % time range of prestimulus
parm_evaluate.pos_stim=[51 120]; % time range of poststimulus

%[e_Nwaveform,e_delay,e_waveform]=est_all(data);
[e_Nwaveform,e_delay,e_waveform]=est_all(data,parm_delay,parm_evaluate);
