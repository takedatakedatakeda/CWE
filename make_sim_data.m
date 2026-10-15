function [data,delay,waveform,noize]=make_sim_data(parm)
% Make simulated data.
%
% -- Usage
% [data,delay,waveform,noize]=make_sim_data;
% or
% [data,delay,waveform,noize]=make_sim_data(parm);
%
% -- Optional input
% Fields of struct 'parm'.
% .Ntrial : Number of trials.
%           default = 50.
% .SNR : signal to noise ratio.
%        default = noise is not added.
% .Nwaveform : Number of waveforms. (1~5)
%              default = 2.
% .Nch : Number of channels.
%        default = 1.
%
% -- Output
% data : simulated data. (Nsample x Ntrial x Nchannel)
% delay : delays of waveforms common across trials. (Ntrial x Nwaveform)
% waveform : waveforms common across trials. (Nsample x Nwaveform x Nchannel)
%            waveforms are identical across channels.
% noize : noize. (Ntime x Ntrial x Nchannel)
%
% 2010/11/29  Y. Takeda

% Default parameters
Ntrial=50;
Nwaveform=2;
Nch=1;

data_length=200;
min_delay=0;
max_delay=49;
delay_width=max_delay-min_delay+1;
waveform_length=data_length-(delay_width);

t1=(1:waveform_length)';
t=(1:data_length)';

% Check optional inputs
if nargin==1;
    if isfield(parm,'Ntrial');Ntrial=parm.Ntrial;end
    if isfield(parm,'SNR');SNR=parm.SNR;end
    if isfield(parm,'Nwaveform');Nwaveform=parm.Nwaveform;end
    if isfield(parm,'Nch');Nch=parm.Nch;end
end

if exist('SNR','var')
    sd_noize=(10^(-SNR/10))^0.5;
else
    sd_noize=0;
end

% Make delays
delay=zeros(Ntrial,Nwaveform);
if Nwaveform>1
   for wf=2:Nwaveform
       trial=1;
       while trial<=Ntrial
          d1=round(randn*10+25);
          if d1>=min_delay && d1<=max_delay;
              delay(trial,wf)=d1;
              trial=trial+1;
          end
       end
   end
end

% Make waveforms
waveform(:,1)=[zeros(50,1);exp(-t1./150*4*pi);zeros(data_length-waveform_length-50,1)];

waveform(:,2)=cos(t./100*4*pi);
waveform(1:50,2)=0;
waveform(101:end,2)=0;

waveform(:,3)=-[zeros(50,1);ones(40,1)./2;-ones(40,1)./2;zeros(data_length-130,1)];

waveform(:,4)=sawtooth(t);
waveform(1:50,4)=0;
waveform(121:end,4)=0;

waveform(:,5)=tripuls(-data_length/2+1:data_length/2,50)';

for ch=1:Nch
    for wf=1:5;
        waveform(:,wf,ch)=waveform(:,wf)./std(waveform(:,wf),0,1);
    end
end

% Make data
noize=randn(data_length+delay_width,Ntrial,Nch)*sd_noize;
data=zeros(data_length+delay_width,Ntrial,Nch)+noize;

for ch=1:Nch
   for trial=1:Ntrial
      for wf=1:Nwaveform
         data(1+delay(trial,wf):data_length+delay(trial,wf),trial,ch)=...
             data(1+delay(trial,wf):data_length+delay(trial,wf),trial,ch)+...
             waveform(:,wf,ch);
      end
   end
end

% Make outputs
data=data(1:data_length,:,:);
noize=noize(1:data_length,:,:);
waveform=waveform(:,1:Nwaveform,:);




