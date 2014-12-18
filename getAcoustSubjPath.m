function [subjPath] = getAcoustSubjPath(exptName,snum,varargin)

subjPath = fullfile(getExptPath(exptName),'acousticdata',sprintf('s%02d',snum),varargin{:});