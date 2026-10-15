function [delay,o_final,o_random,o_grid]=est_delay(data,Nwaveform,parm)
% Estimate delays of waveforms common across trials.
%
% -- Usage
% [delay,o_final,o_random,o_grid]=est_delay(data,Nwaveform);
% or
% [delay,o_final,o_random,o_grid]=est_delay(data,Nwaveform,parm);
%
% -- Input
% data : EEG/MEG data. (Nsample x Ntrial x Nchannel)
% Nwaveform : Number of waveforms common across trials.
%
% -- Optional input
% Fields of struct 'parm'.
% .Mean : means of delays. (1 x Nwaveform) or (Ntrial x Nwaveform)
%         default = data length / 8 for all delays.
% .SD : standard deviations of delays. (1 x Nwaveform)
%       default = Mean / 2 for all delays.
% .Nrandom_search : number of repetitions of a random search.
%                   default = 10.
% .Ngrid_search : number of repetitions of a grid search.
%                 default = 1.
% .min_delay : minimum values of delays. (1 x Nwaveform) or (Ntrial x
%              Nwaveform)
%              default = 0 for all delays.
% .max_delay : maximum values of delays. (1 x Nwaveform) or (Ntrial x
%              Nwaveform)
%              default = data length / 4 for all delays.
% .TOI : time index of interest.
%        default = 1 : data length.
% .FOI : frequency index of interest.
%        default = 1 : data length / 2.
% .initial_delay : initial delays. (Ntrial x Nwaveform)
% .plot : 1 = plot objective function, 0 = not plot.
%         default = 1.
%
% -- Output
% delay : estimated delays. (Ntrial x Nwaveform)
% o_final : finally obtained values of objective function.
% o_random : values of objective function during a random search.
%            (Niteration x Nrepetition)
% o_grid : values of objective function during a grid search.
%          (Niteration x 1)
%
% 2014/11/10 Last modified by Y. Takeda

[data_length,Ntrial,Nch]=size(data);

% Default parameters
Mean=ones(Ntrial,Nwaveform)*data_length/8;
SD=mean(Mean./2,1);
Nrandom_search=10;
Ngrid_search=1;
min_delay=ones(Ntrial,Nwaveform)*0;
max_delay=ones(Ntrial,Nwaveform)*round(data_length/4);
TOI=[];
FOI=2:round(data_length/2);
delay0=ones(Ntrial,Nwaveform)-100;
Niteration=10;
plt=1;

% Check optional inputs
if exist('parm','var')
    if isfield(parm,'Mean')
        Mean=parm.Mean;
        if size(Mean,1)==1;
            Mean=repmat(Mean,Ntrial,1);
        end
    end
    if isfield(parm,'SD');SD=parm.SD;end
    if isfield(parm,'Nrandom_search');Nrandom_search=parm.Nrandom_search;end
    if isfield(parm,'Ngrid_search');Ngrid_search=parm.Ngrid_search;end
    if isfield(parm,'min_delay')
        if size(parm.min_delay,1)==1;
            min_delay=repmat(parm.min_delay,Ntrial,1);
        else
            min_delay=parm.min_delay;
        end
    end
    if isfield(parm,'max_delay')
        if size(parm.max_delay,1)==1;
            max_delay=repmat(parm.max_delay,Ntrial,1);
        else
            max_delay=parm.max_delay;
        end
    end
    if isfield(parm,'TOI');TOI=parm.TOI;end
    if isfield(parm,'FOI');FOI=parm.FOI;end
    if isfield(parm,'initial_delay')
        ini=parm.initial_delay;
        if size(ini,2)<=Nwaveform
            delay0(:,1:size(ini,2))=ini;
        else
            delay0=ini(:,1:Nwaveform);
        end
    end
    if isfield(parm,'plot');plt=parm.plot;end
end

% Take a discrete Fourier transform
Y=permute(fft(data),[2,3,1]);
Y=Y(:,:,FOI);

% Initialize values of objective furnctions
o_random=0;
o_grid=0;

% Make initial delays
delay=delay0;
e=zeros(data_length,Ntrial,Nwaveform);
for wf=1:Nwaveform
    for trial=1:Ntrial
        while delay(trial,wf)<min_delay(trial,wf) || delay(trial,wf)>max_delay(trial,wf)
            delay(trial,wf)=round(randn*SD(wf)+Mean(trial,wf));
        end
        e(delay(trial,wf)+1,trial,wf)=1;
    end
end
e1=e;
o1=obj(Y,e1,data_length,TOI,FOI);

%
% Random search
%
tic
if plt==1
    figure
    xlabel('Iteration number')
    ylabel('Value of objective function');
    title(['Delay estimation (Num. of waveforms is ' num2str(size(delay,2)) '.)'])
    hold on
end
delay2=zeros(Ntrial,1);
if Nrandom_search>0
    fprintf('Estimating delays by a random search... \n')
    
    for search=1:Nrandom_search
        fprintf('%2.0f/%2.0f, ',search,Nrandom_search)
        
        % Make initial delays
        delay=delay0;
        e=zeros(data_length,Ntrial,Nwaveform);
        for wf=1:Nwaveform
            for trial=1:Ntrial
                while delay(trial,wf)<min_delay(trial,wf) || delay(trial,wf)>max_delay(trial,wf)
                    delay(trial,wf)=round(randn*SD(wf)+Mean(trial,wf));
                end
                e(delay(trial,wf)+1,trial,wf)=1;
            end
        end
        e2=e;
        o2=obj(Y,e2,data_length,TOI,FOI);
        
        % Execute a random search
        SD1=SD;
        o_random(1,search)=o2;
        for ite=1:Niteration
            for wf=1:Nwaveform
                if SD(wf)~=0
                    for trial=1:Ntrial
                        e3=e2;
                        c=round(randn*SD1(wf)+Mean(trial,wf));
                        if c>=min_delay(trial,wf) && c<=max_delay(trial,wf)
                            e3(:,trial,wf)=0;
                            e3(c+1,trial,wf)=1;
                            o3=obj(Y,e3,data_length,TOI,FOI);
                            if o3<o2
                                e2=e3;
                                o2=o3;
                            end
                        end
                    end
                    for trial=1:Ntrial
                        delay2(trial,1)=find(e2(:,trial,wf))-1;
                    end
                    SD1(wf)=std(delay2,0,1);
                end
            end
            o_random(ite+1,search)=o2;
            if plt==1;plot(o_random(1:ite+1,search),'bd-');drawnow;end
        end
        if o2<o1
            o1=o2;
            e1=e2;
        end
    end
    fprintf('done. \n')
end
toc
for trial=1:Ntrial
    for wf=1:Nwaveform
        delay(trial,wf)=find(e1(:,trial,wf))-1;
    end
end

%
% Grid search
%
if Ngrid_search>0
    fprintf('Estimating delays by a grid search... \n')
    o2=o1;
    e2=e1;
    o_grid(1,1)=o1;
    ite=1;
    
    % Execute a grid search
    while 1
        fprintf('%2.0f, ',ite)
        for wf=1:Nwaveform
            if SD(wf)~=0
                for trial=1:Ntrial
                    o3=ones(max_delay(trial,wf)+1,1)*o1*10;
                    for c=min_delay(trial,wf):max_delay(trial,wf)
                        e3=e2;
                        e3(:,trial,wf)=0;
                        e3(c+1,trial,wf)=1;
                        o3(c+1,1)=obj(Y,e3,data_length,TOI,FOI);
                    end
                    [o2,c]=min(o3);
                    e2(:,trial,wf)=0;
                    e2(c,trial,wf)=1;
                end
            end
        end
        o_grid(ite+1,1)=o2;
        if plt==1;plot((1:ite+1)+Niteration,o_grid(1:ite+1),'rd-');drawnow;end
        ite=ite+1;
        if o2==o1
            break
        else
            o1=o2;
        end
    end
    for trial=1:Ntrial
        for wf=1:Nwaveform
            delay(trial,wf)=find(e2(:,trial,wf))-1;
        end
    end
    fprintf('done. \n')
end
hold off
o_final=o1;

% Objective function
function y=obj(Y,e,data_length,TOI,FOI)

[Ntrial,Nch,data_length1]=size(Y);
e=fft(e);
Nwaveform=size(e,3);

RE=zeros(Ntrial,Nch,data_length);
w1=1;
for w=FOI
    E=reshape(e(w,:,:),Ntrial,Nwaveform);
    RE(:,:,w)=Y(:,:,w1)-E*(E\Y(:,:,w1));
    w1=w1+1;
end
RE=permute(RE,[3,1,2]);

if isempty(TOI)
    y=sum(sum(sum(abs(RE).^2,1),2),3);
else
    re=real(ifft(RE));
    y=sum(sum(sum(re(TOI,:,:).^2,1),2),3);
end

return



