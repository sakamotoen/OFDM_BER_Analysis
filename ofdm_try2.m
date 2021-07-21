%% OFDM - Multiple Subcarriers 
%Generate Data Bits
%Apply modulation and Reshape 
%Perform ifft operation
%Assume Channel and add awgn and rayleigh noise
%At receiver equalize and take FFT
%Reshape and demodulate
%Find bit error rate

%% Code
clear all; close all; clc;
data= randi([0 1], 2^16 ,1);
for i=6:1:9
    for j=1:1:4
        if j<3
            mod_data= pskmod(data,2^j);
        elseif j==3
            mod_data= qammod(data,16);
        elseif j==4
            mod_data= qammod(data,64);
        end
        mod_data=reshape(mod_data,[2^i,((2^16)/(2^i))]);
        mod_data=ifft(mod_data,2^i);
        k=1;
        for l=0:1:40
            h=1/(sqrt(randn(1,1)+i*randn(1,1)));
            channel_rayleigh=h*mod_data;
            noise_gaussian=awgn(channel_rayleigh,l,'measured');
            rec_mod_data=inv(h)*noise_gaussian;
            rec_mod_data=fft(rec_mod_data,2^i);
            rec_mod_data=reshape(rec_mod_data,[2^16,1]);
            if j<3
                rec_demod_data=pskdemod(rec_mod_data,2^j);
            elseif j==3
                rec_demod_data=qamdemod(rec_mod_data,16);
            elseif j==4
                rec_demod_data=qamdemod(rec_mod_data,64);
            end
            [number,ratio]=biterr(rec_demod_data,data);
            err(k)=ratio;
            k=k+1;    
        end
        m=0:1:40;
        semilogy(m,err);
        hold on;      
    end
    hold off;
    figure();
end





