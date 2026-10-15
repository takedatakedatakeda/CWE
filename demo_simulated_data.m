%%%%%%%% Demo program using simulated data
%
% 2010/11/29  Y. Takeda

close all

clear all



%%%% Make simulated data

% --Optional inputs
% parm_data.Ntrial=30; % Number of trials
parm_data.SNR=10; % Signal to noise ratio
% parm_data.Nwaveform=2; % Number of waveforms
% parm_data.Nch=2; % Number of channels

% [data,delay,waveform]=make_sim_data;
[data,delay,waveform]=make_sim_data(parm_data);




%%%%%%%%% Demo for overall procedure %%%%%%%%%

% Estimate the number of waveforms, delays, and waveforms

% --Optional inputs
% parm_delay.Mean=[25 25]; % Mean of delays
% parm_delay.SD=[12 12]; % Standard deviations of delays 
% parm_delay.Nrandom_search=5; % Number of repetitions of a random search
% parm_delay.Ngrid_search=1; % Number of repetitions of a grid search (0 or 1)
% parm_delay.min_delay=[0 0]; % Minimum values of delays
% parm_delay.max_delay=[50 50]; % Maximum values of delays
% parm_delay.FOI=get_FOI(data,100,[1 10]); % Frequency index of interest
% parm_delay.TOI=50:160; % Time index of interest

% parm_evaluate.pre_stim=[1 50]; % time range of prestimulus
% parm_evaluate.pos_stim=[51 120]; %  time range of poststimulus

[e_Nwaveform,e_delay,e_waveform]=est_all(data);
% [e_Nwaveform,e_delay,e_waveform]=est_all(data,parm_delay,parm_evaluate);




%%%%%%%%% Demos for each step %%%%%%%%%

%%% Demo for "Waveform estimation"

e_waveform=est_waveform(data,delay);


%%% Demo for "Delay estimation"

% --Optional inputs
% parm_delay.Mean=[5 25]; % Mean of delays
% parm_delay.SD=[2 12]; % Standard deviations of delays 
% parm_delay.Nrandom_search=5; % Number of iteration of a random search
% parm_delay.Ngrid_search=1; % Number of iteration of a grid search
% parm_delay.min_delay=[0 0]; % Minimum values of delays
% parm_delay.max_delay=[10 50]; % Maximum values of delays
% parm_delay.FOI=get_FOI(data,100,[1 10]); % Frequency index of interest
% parm_delay.TOI=50:160; % Time index of interest

e_delay=est_delay(data,2);
% e_delay=est_delay(data,2,parm_delay);


%%% Demo for "Evaluation"

% --Optional inputs
% parm_evaluate.pre_stim=[1 50]; % time range of prestimulus
% parm_evaluate.pos_stim=[51 120]; %  time range of poststimulus

decision=evaluate(data,delay,waveform);
% decision=evaluate(data,delay,waveform,parm_evaluate);


