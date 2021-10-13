function move2front(hax_or_h,h)
% function move2front([hax],h)
% move h to the front of hax

if nargin < 2 || isempty(hax_or_h)
  h = hax_or_h;
  hax = gca;
else
  hax = hax_or_h;
end

axkids = get(hax,'Children');
% ih = dsearchn(axkids,h); not sure what function this serves but i
% disabled it KSK 6/24/2021
% if isempty(ih), error('handle(%f) not a child of hax(%f)', h, hax); end not sure what function this serves but i
% disabled it KSK 6/24/2021
remh_axkids = axkids;
% remh_axkids(ih) = []; not sure what function this serves but i
% disabled it KSK 6/24/2021
new_axkids = [h; remh_axkids];
set(hax,'Children',new_axkids);
