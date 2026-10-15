function [FOI SD]=get_FOI(data,samplingrate,freqlimits,plt)
% Get frequency index of interest (FOI).
%
% -- Usage
% [FOI SD]=get_FOI(x,samplingrate,freqlimits)
%
% -- Input
% data : EEG/MEG data. (Nsample x Ntrial x Nchannel)
% samplingrate : sampling rate (Hz).
% freqlimits : limits of frequency (Hz). [low, high]
%
% -- Output
% FOI : frequency index of interest (FOI). (1 x Nindex)
% SD : SD across trials of FOI. (Nsample x Nchannel)
%
% 2010/11/29 Y. Takeda

% Convert frequency (Hz) into FOI
[Nt,Ntr,Nch]=size(data);
f1=max([2 round(freqlimits(1)*Nt/samplingrate)]);
f2=min([round(Nt/2) round(freqlimits(2)*Nt/samplingrate)]);
FOI=f1:f2;

% Check time series of SD of FOI across trials
z=zeros(Nt,Ntr,Nch);
xf=fft(data);
z(FOI,:,:)=xf(FOI,:,:);
iz=real(ifft(z));
for ch=1:Nch
    SD(:,ch)=std(iz(:,:,ch),0,2);
end

if exist('plt','var')
    % Plot original SD
    figure
    subplot 211
    plot(mean(std(data,0,2),3))
    xlabel('Time index')
    title('Original SD')
    
    % Plot SD of FOI
    subplot 212
    plot(mean(SD,2),'r')
    xlabel('Time index')
    title('SD of FOI')
end