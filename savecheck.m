function [bSave] = savecheck(savefile)
%SAVECHECK  Checks for existence of file and confirms before overwriting.

if exist(savefile, 'file')
    messg = {'The file ' savefile ' exists.  Do you want to overwrite?'};
    button = questdlg(messg,'File exists','Overwrite','Cancel','Cancel');
    
    switch button
        case 'Overwrite'
            bSave = 1;
        case 'Cancel'
            bSave = 0;
    end
    
else bSave = 1;
    
end