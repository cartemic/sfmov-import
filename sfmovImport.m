%.----------------------------------------------------------.
%|                     sfmovImport.m                        |
%|----------------------------------------------------------|
%| Written by Mick Carter                                   |
%| For use in the Oregon State University CIRE Lab          |
%| Contact cartemic@oregonstate.edu to report issues        |
%| Last updated 01/05/2016                                  |
%| ---------------------------------------------------------|
%| Reads in data from .sfmov files gathered by FLIR SC6700. |
%| Frame rate and number data are pulled from .inc and .pod |
%| files (if they exist) or are input by the user (if they  |
%| don't).                                                  |
%| ---------------------------------------------------------|
%| Output:                                                  |
%| [rawData, fps]                                           |
%|       rawData: raw photon count data            (uint16) |
%|       fps:     frame rate in frames per second  (double) |
%' ---------------------------------------------------------'

function [rawData,fps] = sfmovImport(fName)
% set filetype to open - for easier debugging
fType='.sfmov';
fName=char(fName);
    % pull frame rate from .inc file
    switch exist([fName '.inc'],'file')

        % if the .inc file exists
        case 2
            fid1=fopen([fName '.inc']);
            incFile=fscanf(fid1,'%c');
            loc=regexp(incFile,'FRate_. ')+8;
            
            if isempty(loc)
                fps = manFps();                 % go to manual entry if frame rate isn't found
            else
                % finish building location vector
                crLoc=find(incFile==13);        % position of carriage returns
                loc(2)=crLoc(find(crLoc>loc,1));% first carriage return after FRate

                % extract frame rate and close file
                fps=str2double(incFile(loc(1):loc(2)));
                fclose(fid1);
            end

        % if the .inc file doesn't exist go to manual entry
        otherwise
            fps = manFps();

    end

        % pull number of frames from .pod file
        switch exist([fName '.pod'],'file')
            % if file exists, extract number of frames
            case 2
                fid1=fopen([fName '.pod']);
                incFile=fscanf(fid1,'%c');
                nFrames=size(find(incFile==13),2)-11;
                fclose(fid1);

            % if file doesn't exist, get manually
            otherwise
                nFrames = manFrame();
        end

        % give the user a warm fuzzy
        fprintf('Reading %s...\n',[fName fType])
        
        % get data start location and image width, height from dataChop()
        [loc, wIm, hIm]=dataChop([fName fType]);
        
        % open file and remove header
        fid1=fopen([fName fType], 'r');
        fscanf(fid1,'%c',loc);
        
        % reshape raw data into video matrix
        rawData = uint16(...
            permute(...
                reshape(...
                    fread(fid1, [wIm hIm*nFrames], 'uint16', 'l'),...
                    wIm,hIm,nFrames...
                ),...
                [2,1,3]...
            )...
        );
    
        % close file and alert user to finished status
        fclose('all');
        fprintf('Done!\n\n')
        
%% SUBFUNCTIONS

% chop out irrelevant portions of data
    function [loc,wIm,hIm] = dataChop(fName)
        % open file and inspect header
        fid1=fopen(fName, 'r');
        dataIn=fscanf(fid1,'%c',10000); %       10000 is just an arbitrarily large line number
        
        % location of interesting information
        loc = [regexp(dataIn,'DATA')+3 ...      data start location
            regexp(dataIn,'xPixls')+6 ...       x pixel count location
            regexp(dataIn,'yPixls')+6]; %       y pixel count location
        crLoc=find(dataIn==13); %               locate carriage returns
        loc(4)=crLoc(find(crLoc>loc(3),1));%    find carriage return after yPixls

        % output image width, height, and data start location
        wIm=str2double(dataIn(loc(2):loc(3)-8));
        hIm=str2double(dataIn(loc(3):loc(4)));
        loc=loc(1);

        % close file
        fclose('all');
    end

% manually input frame rate
    function [fps] = manFps()
        % see if user wants to manually input
        % otherwise, exit
        a = questdlg(['Oops! There was an error importing' ...
                      ' the frame rate. Enter manually?'],...
                      'Import error',...
                      'Yes',...
                      'No',...
                      'Yes');
            switch a
                case 'Yes'
                    a = inputdlg('Input frame rate (fps):',...
                        'Frame rate');
                    fps=str2double(a);
                    if isempty(fps) || strcmp(fps,'NaN')
                            fps = 0;
                            dingus();
                    end
                otherwise
                    fps = 0;
                    dingus();
            end
    end

% manually input frame count
    function [nFrames] = manFrame()
        % see if user wants to manually input
        % otherwise, exit
        a = questdlg(['Oops! There was an error importing' ...
                      ' the number of frames. Enter manually?'],...
                      'Import error',...
                      'Yes',...
                      'No',...
                      'Yes');
            switch a
                case 'Yes'
                    a = inputdlg('Input number of frames:',...
                        'Number of frames');
                    nFrames=str2double(a);
                    if isempty(nFrames) || strcmp(nFrames,'NaN')
                            nFrames = 1;
                            dingus();
                    end
                otherwise
                    nFrames = 1;
                    dingus();
            end
    end

% inform the user that they are being a dingus
    function dingus()
        waitfor(msgbox('Well, that wasn''t helpful...','>.<','modal'));
    end
end