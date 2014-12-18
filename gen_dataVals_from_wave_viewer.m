function [] = gen_dataVals_from_wave_viewer(exptName,subdirname,snum,trialdir,excl)
%GEN_DATAVALS  Scrape subject trial files for data and save.
%   GEN_DATAVALS(EXPTNAME,SUBDIRNAME,SNUM,TRIALDIR,EXCL) scrapes the files
%   of a single subject (SNUM) from that subject's TRIALDIR directory and
%   collects formant data into a single mat file.
%
%CN 3/2010

if nargin < 5, excl = []; end
if nargin < 4 || isempty(trialdir), trialdir = 'trials'; end

dataPath = getAcoustSubjPath(exptName,snum,subdirname);
load(fullfile(dataPath,'expt.mat'));
load(fullfile(dataPath,'wave_viewer_params.mat'));
trialPath = fullfile(dataPath,trialdir); % e.g. trials; trials_default
W = what(trialPath);
matFiles = [W.mat];

% Strip off '.mat' and sort
filenums = zeros(1,length(matFiles));
for i = 1:length(matFiles)
    [~, name] = fileparts(matFiles{i});
    filenums(i) = str2double(name);
end
sortedfiles = sort(filenums);

% Toss out exclusions
goodfiles = setdiff(sortedfiles,excl);

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
    dataVals(i).vowel = expt.allVowels(i);
    dataVals(i).cond = expt.allConds(i);
    dataVals(i).token = i;
    if exist('trialparams','var')
        dataVals(i).bExcl = ~trialparams.event_params.is_good_trial;
    else
        dataVals(i).bExcl = 0;
    end
end

savefile = fullfile(dataPath,sprintf('dataVals%s.mat',trialdir(7:end)));
bSave = savecheck(savefile);
if bSave, save(savefile, 'dataVals'); end