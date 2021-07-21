clc;
clear all;
close all;

%% 基础参数
SNR=0:1:20;                 %信噪比变化范围
SNR1=0.5*(10.^(SNR/10));    %将信噪比转化成直角坐标
N=2^16;                     %仿真点数
X=4;                        %进制数
x=randi([0,3],1,N);         %产生随机信号


%% OFDM

mod_signal = pskmod(x,X,pi/X);            %QPSK调制
%scatterplot(mod_signal);

mod_signal = reshape(mod_signal,[64,((2^16)/64)]);     %串并变换
mod_signal = ifft(mod_signal,64);     %ifft
len_ifft = length(mod_signal);
mod_signal_temp = mod_signal;   %转储

% 添加循环前缀
zero_martix = zeros(64,len_ifft/4);
mod_signal = [mod_signal,zero_martix];
for m = 1:64
    %mod_signal(m,:) = [mod_signal(m,len_ifft-len_ifft/4+1:len_ifft),mod_signal(m,1:len_ifft)];
    mod_signal(m,:) = [mod_signal_temp(m,len_ifft-len_ifft/4+1:len_ifft),mod_signal_temp(m,1:len_ifft)];
end

% 并串转换
mod_signal = reshape(mod_signal,[1,len_ifft*5/4*64]);
len_all = length(mod_signal);
    
for i = 1:length(SNR)
    
    h=1/(sqrt(randn(1,1)+i*randn(1,1)));    %瑞利信道
    channel_rayleigh=h*mod_signal;
    noise_gaussian=awgn(channel_rayleigh,i,'measured');
    rx_signal = inv(h)*noise_gaussian;
%     rx_signal = mod_signal.*h;
%     rx_signal = awgn(rx_signal,SNR(i),'measured');            %AWGN噪声
%     rx_signal = awgn(rx_signal,SNR(i));
%     rx_signal = awgn(mod_signal,SNR(i),'measured');
    
    rx_signal = rx_signal(:,1:len_all);
    rx_signal = reshape(rx_signal,[64,(len_all/64)]);
    rx_signal = rx_signal(:,len_ifft/4+1:len_all/64);
    rx_signal = fft(rx_signal,64);
    rx_signal = reshape(rx_signal,[1,64*len_ifft]);
    
    %% qpsk 解调
    rx_signal_y = pskdemod(rx_signal,X,pi/X);            %QPSK解调
    
    %% 误码率计算
    num = sum([rx_signal_y==x],'all');
    OFDM_s_ray(i) = (N-num)/N;
end

figure
semilogy(SNR,OFDM_s_ray);
grid on;
title('OFDM误码率分析');
xlabel('SNR(dB)');
ylabel('BER');