% fNameGet()
% Allows user to select .sfmov files to be imported and adds the directory
% to the working path. Returns a cell with the names of each file selected
% with the filetype removed. If file selection is cancelled, a blank cell
% will be returned.

function fNameOut = fNameGet()

% select filetype
fType='.sfmov';

% add path with IR data files
[fileName, filePath] = uigetfile(['*' fType],...
    'Select IR data',...
    'Multiselect','on');
if ~iscell(fileName)
    if fileName == 0
        fNameOut={};
        youKilledIt();
        return
    else
        addpath(filePath);
        fNameOut=char(fileName);
        fNameOut=cellstr(fNameOut(1:strfind(fNameOut,fType)-1));
    end
else
    addpath(filePath);
    fNameOut=cell(size(fileName));
    for i=1:size(fileName,2)
        fNameTemp=char(fileName(i));
        fNameOut(i)=cellstr(fNameTemp(1:strfind(fNameTemp,fType)-1));
    end
end

    function youKilledIt()
        warndlg('You didn''t select a file. Good job, ya dingus.',...
            'No File Selected',...
            'modal')
    end
end