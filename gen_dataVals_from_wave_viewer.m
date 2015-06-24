function [] = gen_dataVals_from_wave_viewer(trialdir,excl)
%GEN_DATAVALS  Scrape subject trial files for data and save.
%   GEN_DATAVALS(EXPTNAME,SUBDIRNAME,SNUM,TRIALDIR,EXCL) scrapes the files
%   of a single subject (SNUM) from that subject's TRIALDIR directory and
%   collects formant data into a single mat file.
%
%CN 3/2010

if nargin < 2, excl = []; end
if nargin < 1 || isempty(trialdir), trialdir = 'trials'; end

subjID=input('Enter participant ID number: ', 's');
outputdir = '/home/houde/data/error_hist';
  if ~exist(outputdir,'dir')
     mkdir(outputdir)
  end
  expt.snum = subjID;
  case_number=input (' Case 1 or Case 2 ? : ','s');
  expt.case = case_number;
  cd(fullfile(outputdir, expt.snum, expt.case));

load('expt.mat');
load('wave_viewer_params.mat');
trialPath = fullfile(outputdir,expt.snum,expt.case,'trials'); % e.g. trials; trials_default
cd('trials');
W = what(trialPath);
matFiles = [W.mat];
goodfiles_index = 1;
for i = 1: length(matFiles)
    load(sprintf('%d',i));
    if trialparams.event_params.is_good_trial == 1
        goodfiles(1,goodfiles_index) = i;
        goodfiles_index = goodfiles_index+1;
        savedir = fullfile(outputdir, expt.snum, expt.case);
save(fullfile(savedir, 'goodfiles.mat'), 'goodfiles');
    end
    
    
end
    


% 
% % Strip off '.mat' and sort
% filenums = zeros(1,length(matFiles));
% for i = 1:length(matFiles)
%     curdir = cd;
%     cd('trials');
%     load(sprintf('%d',i));
%     if trialparams.event_params.is_good_trial == 1
%     [~, name] = fileparts(matFiles{i});
%      
%     filenums(i) = str2double(name);
%     end
%     cd(curdir);
% end
% sortedfiles = sort(filenums);




% Append '.mat' and load
dataVals = struct([]);
for i = 1:length(goodfiles)
    filename = sprintf('%d.mat',goodfiles(i));
    load(fullfile(trialPath,filename));
    
    % find onset
    if exist('trialparams','var') & trialparams.event_params.user_event_times %#ok<AND2>
        % find time of user-created onset event
        onset_time = trialparams.event_params.user_event_times(1);
        timediff = sigmat.ampl_taxis - onset_time;
        [~, onsetIndAmp] = min(abs(timediff));
    else
        % use amplitude threshold to find onset index
        onsetIndAmp = find(sigmat.ampl > sigproc_params.ampl_thresh4voicing);
        if onsetIndAmp, onsetIndAmp = onsetIndAmp(1) + 5;
        else onsetIndAmp = 1;
        end
        onset_time = sigmat.ampl_taxis(onsetIndAmp);
    end
    
    % find offset
    if exist('trialparams','var') && length(trialparams.event_params.user_event_times) > 1 ...
            && trialparams.event_params.user_event_times(1) ~= trialparams.event_params.user_event_times(2)
        % find time of user-created offset event
        offset_time = trialparams.event_params.user_event_times(2);
        timediff = sigmat.ampl_taxis - offset_time;
        [~, offsetIndAmp] = min(abs(timediff));
    else
        % find first sub-threshold amplitude value after onset
        if exist('trialparams','var')
            % use trial-specific amplitude threshold
            offsetIndAmp = find(sigmat.ampl(onsetIndAmp:end) < trialparams.sigproc_params.ampl_thresh4voicing);
        else % use wave_viewer_params default amplitude threshold
            offsetIndAmp = find(sigmat.ampl(onsetIndAmp:end) < sigproc_params.ampl_thresh4voicing);
        end
        if offsetIndAmp
            offsetIndAmp = offsetIndAmp(1) + onsetIndAmp-1; % correct indexing
        else
            offsetIndAmp = length(sigmat.ampl); % use last index if no offset found
        end
        offset_time = sigmat.ampl_taxis(offsetIndAmp); % or -1?
    end

    % find onset/offset indices for each track
    timediff = sigmat.pitch_taxis - onset_time;
    [~, onsetIndf0] = max(1./timediff);
    timediff = sigmat.pitch_taxis - offset_time;
    [~, offsetIndf0] = min(1./timediff);
    timediff = sigmat.ftrack_taxis - onset_time;
    [~, onsetIndfx] = max(1./timediff);
    timediff = sigmat.ftrack_taxis - offset_time;
    [~, offsetIndfx] = min(1./timediff);
    
    % convert to dataVals struct
    dataVals(i).f0 = sigmat.pitch(onsetIndf0:offsetIndf0)';
    dataVals(i).f1 = sigmat.ftrack(1,onsetIndfx:offsetIndfx)';
    dataVals(i).f2 = sigmat.ftrack(2,onsetIndfx:offsetIndfx)';
    dataVals(i).int = sigmat.ampl(onsetIndAmp:offsetIndAmp)';
    dataVals(i).pitch_taxis = sigmat.pitch_taxis(onsetIndf0:offsetIndf0)';
    dataVals(i).ftrack_taxis = sigmat.ftrack_taxis(onsetIndfx:offsetIndfx)';
    dataVals(i).ampl_taxis = sigmat.ampl_taxis(onsetIndfx:offsetIndfx)';
    dataVals(i).dur = offset_time - onset_time;
    dataVals(i).word = expt.allWords(i);
%    dataVals(i).vowel = expt.allVowels(i);
    dataVals(i).cond = expt.allConds(i);
    dataVals(i).token = i;
    if exist('trialparams','var')
        dataVals(i).bExcl = ~trialparams.event_params.is_good_trial;
    else
        dataVals(i).bExcl = 0;
    end
end

savefile = fullfile(outputdir,expt.snum,expt.case,sprintf('dataVals.mat'));

save(savefile, 'dataVals'); end