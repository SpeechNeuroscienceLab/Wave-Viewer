function [exptPath] = getExptPath(exptName)

if nargin < 1, exptName = []; end

if ispc()
  root_dir = 'Z:';
else
  root_dir = '/data/bil-mb10/';
end

if strcmp(exptName,'mpSIS') || strcmp(exptName,'varFx')
exptPath = fullfile(root_dir,'carrien',exptName);
else
exptPath = fullfile('/data/bil-mb5/carrien',exptName);
end