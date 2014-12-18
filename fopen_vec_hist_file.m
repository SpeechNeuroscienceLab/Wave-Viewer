function [fpt,vec_type,vec_size,nvecs,ntrials,playable] = fopen_vec_hist_file(hist_file)

fpt=fopen(hist_file,'r');
if fpt == -1
  error(sprintf('could not open file(%s)\n',hist_file));
end

[vec_type, count] = my_fread(fpt,1,'int32'); h_errchk(count,1,'vec_type',hist_file);
[vec_size, count] = my_fread(fpt,1,'int32'); h_errchk(count,1,'vec_size',hist_file);
[nvecs, count]    = my_fread(fpt,1,'int32'); h_errchk(count,1,'nvecs',hist_file);
[ntrials, count]  = my_fread(fpt,1,'int32'); h_errchk(count,1,'ntrials',hist_file);
[playable, count] = my_fread(fpt,1,'int32'); h_errchk(count,1,'playable',hist_file);
