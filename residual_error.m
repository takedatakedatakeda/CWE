function re=residual_error(data,delay,waveform)
% Calculate residual errors using waveforms and their delays.
%
% -- Usage
% re=residual_error(data,delay,waveform);
%
% -- Input
% data : EEG/MEG data. (Nsample x Ntrial x Nchannel)
% delay : delays of waveforms. (Ntrial x Nwaveform)
% waveform : waveforms. (Nsample x Nwaveform x Nchannel)
%
% -- Output
% re : residual errors (Nsample x Ntrial x Nchannel)
%
% 2010/11/29  Y. Takeda

[data_length,Ntrial,Nch]=size(data);
Nwaveform=size(delay,2);

% Take discrete Fourier transforms
Y=zeros(Ntrial,data_length,Nch);
S=zeros(Nwaveform,data_length,Nch);
for ch=1:Nch
    Y(:,:,ch)=fft(data(:,:,ch))';
    S(:,:,ch)=fft(waveform(:,:,ch))';
end

e=zeros(data_length,Ntrial,Nwaveform);
for wf=1:Nwaveform
    for trial=1:Ntrial
        e(delay(trial,wf)+1,trial,wf)=1;
    end
end
e=fft(e);

% Calculate residual errors
E=zeros(Ntrial,Nwaveform);
RE=zeros(Ntrial,data_length);
re=zeros(data_length,Ntrial,Nch);
for ch=1:Nch
    for w=1:data_length
        for wf=1:Nwaveform
            E(:,wf)=e(w,:,wf)';
        end
        RE(:,w)=Y(:,w,ch)-E*S(:,w,ch);
    end
    re(:,:,ch)=real(ifft(RE'));
end



