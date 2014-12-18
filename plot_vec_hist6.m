function tmp_cat = plot_vec_hist6(vec_hist,itrial,fs)
% function tmp_cat = plot_vec_hist6(vec_hist,itrial,[fs])
% plots the data from trial(itrial) of a new_quatier6-type vec_hist
% 'tmp_cat' is the full time waveform, peiced together from the data frames

if nargin < 3 || isempty(fs)
  fs = 11025;
end

trial_vec_hist = squeeze(vec_hist.data(itrial,:,:));

tmp = trial_vec_hist';
tmp_cat = tmp(:);
taxis = (0:(length(tmp_cat)-1))/fs;
plot(taxis,tmp_cat);
xlabel('Time (sec)');
a = axis;
maxtime = length(tmp_cat)/fs;
axis([0 maxtime a(3:4)]);
