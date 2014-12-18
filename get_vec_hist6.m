function vec_hist = get_vec_hist6(name,file_type,iblock,yes_verbose)
% function vec_hist = get_vec_hist6(name,file_type,[iblock],[yes_verbose])
% loads vec_hists saved with the new system in new_quatieri6,
% in which the first several bytes of vec_hist files is a header
% consisting of the following five int's:
% 1. vec_type (int) (SHORT_VEC, INT_VEC, or FLOAT_VEC)
% 2. vec_size (int)
% 3. nvecs (frames per trial) (int)
% 4. ntrials (per block) (int)
% 5. playable (int) (1 = yes, 0 = no)
%
% so, frames are stored in groups of trials, and one block of trials is
% stored in the file. Thus, the number of frames stored in the file
% should be: # of frames to read = nvecs*ntrials, with every frame stored
% as a series of bytes, with the following structure:
% 
% first bytes: iframe (frame count in the experiment when the frame was
%                      recorded in this vec_hist)
% following bytes: vec_size shorts, ints, or floats, depending on the
%                  vec_type entry in the vec_hist file header.
% 
% optional argument iblock: if present and non-empty, get vec_hist from
% subdirectory blockN\, where N = iblock - 1
% if iblock not present or is empty, get vec_hist from current dir

set_vec_types;

if nargin < 3 || isempty(iblock)
  block_dir = '.';
else
  block_dir = sprintf('block%d',iblock-1);
end
if nargin < 4 || isempty(yes_verbose), yes_verbose = 1; end

switch(file_type)
 case SHORT_VEC
  file_suffix = '_hist.sht';
  item_bytes = 2;
  fread_fmt = 'int16';
 case INT_VEC
  file_suffix = '_hist.int';
  item_bytes = 4;
  fread_fmt = 'int32';
 case FLOAT_VEC
  file_suffix = '_hist.flt';
  item_bytes = 4;
  fread_fmt = 'float32';
 otherwise
  error(sprintf('unrecognized file_suffix(%s)\n',file_suffix));
end
hist_file = [block_dir '/' name file_suffix];

[fpt,vec_type,vec_size,nvecs,ntrials,playable] = fopen_vec_hist_file(hist_file);

if file_type ~= vec_type
  error(sprintf('expected file_type(%d) ~= vec_type(%d) in header of file(%s)', ...
		file_type,vec_type,hist_file));
end
pos_header = ftell(fpt);
fseek(fpt,0,'eof');
pos_end = ftell(fpt);
fseek(fpt,pos_header,'bof');
nbytes = pos_end - pos_header;
bytes_per_frame = 4 + vec_size*item_bytes; % the '+ 4' is for the iframe
frames_in_file = nvecs*ntrials;
expected_nbytes = frames_in_file * bytes_per_frame;
if nbytes ~= expected_nbytes
  error(sprintf('nbytes(%d) in file(%s) after header ~= expected_nbytes(%d) from header info', ...
		nbytes, hist_file, expected_nbytes));
end

vec_hist.name = name;
vec_hist.file = hist_file;
vec_hist.vec_type = vec_type;
vec_hist.vec_size = vec_size;
vec_hist.nvecs = nvecs;
vec_hist.ntrials = ntrials;
vec_hist.playable = playable;

hist_data = zeros(ntrials,nvecs,vec_size);
hist_iframe = zeros(ntrials,nvecs);

for i = 1:ntrials
    [hist_iframe(i,:), count] = my_fread(fpt,nvecs,'int32');
    h_errchk(count,nvecs,sprintf('hist_iframe(%d,%d)',i,j),hist_file);
    [hist_data_read, count] = my_fread(fpt,nvecs*vec_size,fread_fmt);
    hist_data(i,:,:) = reshape(hist_data_read,vec_size,nvecs)';
    h_errchk(count,nvecs*vec_size,sprintf('hist_data(%d,%d)',i,j),hist_file);
end

vec_hist.iframe = hist_iframe;
vec_hist.data = hist_data;

fclose(fpt);
if yes_verbose, fprintf('loaded vec_hist(%s)\n',name); end
