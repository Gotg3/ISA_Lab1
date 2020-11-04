clear all
close all 
clc

%% REFERENCE DATA AND VALUES (MATLAB VERSION)
T=1/500; %% maximum period
fs=10000; %% sampling frequency
tt=0:1/fs:10*T; %% time samples

result_m=importdata('./base_version/results_m.txt');

%figure('Name','Result Matlab Filter')
%plot(tt,result_m)
figure('Name', 'THD Matlab Filter')
thd(result_m,fs,5);
saveas(gcf,'thd_matlab.png')
%% BASE VERSION
result_c_ref=importdata('./base_version/result_c_ref.txt'); % reference without guardbits
result_c_guardbits=importdata('./base_version/result_c_guardbits.txt'); % vhdl-like c filter
result_vhdl_pre_synth=importdata('./base_version/results_vhdl_pre_synth.txt');
result_vhdl_post_synth=importdata('./base_version/results_vhdl_post_synth.txt');
result_vhdl_post_placeroute=importdata('./base_version/results_vhdl_post_placeroute.txt');


diff_c_pre_synth=sum(result_c_guardbits- result_vhdl_pre_synth);
diff_pre_post_synth=sum(result_vhdl_pre_synth-result_vhdl_post_synth);
diff_presynth_post_plcaceroute=sum(result_vhdl_pre_synth-result_vhdl_post_placeroute);

figure('Name', 'THD C Filter reference');
thd(result_c_ref,fs,5);
saveas(gcf,'thd_c_ref.png');

%figure('Name','Result VHDL filter')
%plot(tt,result_vhdl_pre_synth)
figure('Name', 'THD VHDL Filter');
thd(result_vhdl_pre_synth,fs,5);
saveas(gcf,'thd_vhdl.png');


%% LA VERSION

result_c_la_ref=importdata('./la_version/result_c_la_ref.txt');
result_c_la_guardbits=importdata('./la_version/result_c_la_guardbits.txt');
result_c_la_ret_pp=importdata('./la_version/result_c_la_pp_ret.txt');
result_c_la_ret_pp_V2=importdata('./la_version/result_c_la_pp_ret_V2.txt');
result_vhdl_la_pp=importdata('./la_version/results_vhdl_la_pp_ret.txt');
result_vhdl_la_pp_postsynth=importdata('./la_version/result_vhdl_la_pp_ret_postsynth.txt');
result_vhdl_la_pp_placeroutr=importdata('./la_version/results_vhdl_place_route.txt');

diff_retpp=sum(result_c_la_guardbits-result_c_la_ret_pp); %comparison c guardbits ref vs c guardbits + ret + pp
diff_retpp_retppV2=sum(result_c_la_ret_pp-result_c_la_ret_pp_V2); % comparison c V2 vs c V1
diff_claretppV2_vhdllappV2=sum(result_vhdl_la_pp-result_c_la_ret_pp_V2); % comparison c V2 vs VHDL V2
diff_pre_post_synth_la=sum(result_vhdl_la_pp-result_vhdl_la_pp_postsynth); %comparison vhdl pre vs post synth
deff_presynth_postplaceroute=sum(result_vhdl_la_pp-result_vhdl_la_pp_placeroutr); %comparison vhdl pre synth vs post place&route

figure('Name', 'THD C Filter Look-ahead reference');
thd(result_c_la_ref,fs,5);
saveas(gcf,'thd_c_la_ref.png');

figure('Name', 'THD VHDL Filter Look-ahead');
thd(result_c_la_guardbits,fs,5);
saveas(gcf,'thd_vhdl_la.png');



