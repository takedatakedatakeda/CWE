function recon=reconstruct(delay,waveform)
% Reconstruct EEG/MEG data using waveforms and their delays.
%
% -- Usage
% recon=residual_error(delay,waveform);
%
% -- Input
% delay : delays of waveforms. (Ntrial x Nwaveform)
% waveform : waveforms. (Nsample x Nwaveform x Nchannel)
%
% -- Output
% recon : reconstructed EEG/MEG data (Nsample x Ntrial x Nchannel)
%
% 2011/6/15  Y. Takeda

[Ntrial,Nwaveform]=size(delay);
[data_length,Nwaveform,Nch]=size(waveform);

% Take discrete Fourier transforms
S=zeros(Nwaveform,data_length,Nch);
for ch=1:Nch
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
recon=zeros(data_length,Ntrial,Nch);
for ch=1:Nch
    for w=1:data_length
        for wf=1:Nwaveform
            E(:,wf)=e(w,:,wf)';
        end
        RE(:,w)=E*S(:,w,ch);
    end
    recon(:,:,ch)=real(ifft(RE'));
end



