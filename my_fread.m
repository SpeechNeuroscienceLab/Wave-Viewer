function [items,count] = my_fread(fpt,nitems,fmt)

% [items, count]  = fread(fpt,nitems,fmt,'ieee-le');
[items, count]  = fread(fpt,nitems,fmt);
