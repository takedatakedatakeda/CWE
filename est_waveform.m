function waveform=est_waveform(data,delay)
% Estimate waveforms common across trials using their delays.
%
% -- Usage
% waveform=est_waveform(data,delay);
%
% -- Input
% data : EEG/MEG data. (Nsample x Ntrial x Nchannel)
% delay : delays of waveforms. (Ntrial x Nwaveform)
%
% -- Output
% waveform : estimated waveforms. (Nsample x Nwaveform x Nchannel)
%
% 2013/4/16 Y. Takeda


[data_length,Ntrial,Nch]=size(data);
Nwaveform=size(delay,2);

% Take discrete Fourier transforms
Y=permute(fft(data),[2,3,1]);

e=zeros(data_length,Ntrial,Nwaveform);
for wf=1:Nwaveform
    for trial=1:Ntrial
        e(delay(trial,wf)+1,trial,wf)=1;
    end
end
e=fft(e);

% Estimate waveforms
S=zeros(Nwaveform,Nch,data_length);
for w=2:data_length
    E=reshape(e(w,:,:),Ntrial,Nwaveform);
    S(:,:,w)=E\Y(:,:,w);
end
SS=permute(S,[3,1,2]);
waveform=real(ifft(SS));

% Plot waveforms
% fprintf('%1.0f waveforms are estimated. \n',Nwaveform)
% figure
% k=1;
% for wf=1:Nwaveform
%     for ch=1:Nch
%         subplot(Nwaveform,Nch,k)
%         plot(waveform(:,wf,ch))
%         xlabel('Time point')
%         title(['Waveform ' num2str(wf) ' of channel ' num2str(ch)])
%         k=k+1;
%     end
% end




