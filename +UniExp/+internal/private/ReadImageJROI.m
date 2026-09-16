function [sROI] = ReadImageJROI(cstrFilenames)

% ReadImageJROI - FUNCTION Read an ImageJ ROI into a matlab structure
%
% Usage: [sROI] = ReadImageJROI(strFilename)
%        [cvsROIs] = ReadImageJROI(cstrFilenames)
%        [cvsROIs] = ReadImageJROI(strROIArchiveFilename)
%
% This function reads the ImageJ binary ROI file format.
%
% 'strFilename' is the full path to a '.roi' file.  A list of ROI files can be
% passed as a cell array of filenames, in 'cstrFilenames'.  An ImageJ ROI
% archive can be access by providing a '.zip' filename in
% 'strROIArchiveFilename'.  Single ROIs are returned as matlab structures, with
% variable fields depending on the ROI type.  Multiple ROIs are returned as a
% cell array of ROI structures.
%
% The field '.strName' is guaranteed to exist, and contains the ROI name (the
% filename minus '.roi', or the name set for the ROI).
%
% The field '.strType' is guaranteed to exist, and defines the ROI type:
% {'Rectangle', 'Oval', Line', 'Polygon', 'Freehand', 'Traced', 'PolyLine',
% 'FreeLine', 'Angle', 'Point', 'NoROI'}.
%
% The field '.vnRectBounds' is guaranteed to exist, and defines the rectangular
% bounds of the ROI: ['nTop', 'nLeft', 'nBottom', 'nRight'].
%
% The field '.nVersion' is guaranteed to exist, and defines the version number
% of the ROI format.
%
% The field '.vnPosition' is guaranteed to exist. If the information is
% defined within the ROI, this field will be a three-element vector
% [nCPosition nZPosition nTPosition].
%
% ROI types:
%  Rectangle:
%     .strType = 'Rectangle';
%     .nArcSize         - The arc size of the rectangle's rounded corners
%
%      For a composite, 'shape' ROI:
%     .strSubtype = 'Shape';
%     .vfShapeSegments  - A long, complicated vector of complicated shape
%                          segments.  This vector is in the format passed to the
%                          ImageJ ShapeROI constructor.  I won't decode this for
%                          you! :(
%
%  Oval:
%     .strType = 'Oval';
%
%  Line:
%     .strType = 'Line';
%  	.vnLinePoints     - The end points of the line ['nX1', 'nY1', 'nX2', 'nY2']
%
%     With arrow:
%     .strSubtype = 'Arrow';
%     .bDoubleHeaded    - Does the line have two arrowheads?
%     .bOutlined        - Is the arrow outlined?
%     .nArrowStyle      - The ImageJ style of the arrow (unknown interpretation)
%     .nArrowHeadSize   - The size of the arrowhead (unknown units)
%
%  Polygon:
%     .strType = 'Polygon';
%     .mnCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the polygon vertices.  Each row is [nX nY].
%
%  Freehand:
%     .strType = 'Freehand';
%     .mnCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the polygon vertices.  Each row is [nX nY].
%
%     Ellipse subtype:
%     .strSubtype = 'Ellipse';
%     .vfEllipsePoints  - A vector containing the ellipse control points:
%                          [fX1 fY1 fX2 fY2].
%     .fAspectRatio     - The aspect ratio of the ellipse.
%
%  Traced:
%     .strType = 'Traced';
%     .mnCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the line vertices.  Each row is [nX nY].
%
%  PolyLine:
%     .strType = 'PolyLine';
%     .mnCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the line vertices.  Each row is [nX nY].
%
%  FreeLine:
%     .strType = 'FreeLine';
%     .mnCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the line vertices.  Each row is [nX nY].
%
%  Angle:
%     .strType = 'Angle';
%     .mnCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the angle vertices.  Each row is [nX nY].
%
%  Point:
%     .strType = 'Point';
%     .mfCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the points.  Each row is [fX fY].
%     .vnCounters       - An [Nx1] vector, specifying which counter is
%                          associated with each point. May be empty.
%     .vnSlices         - An [Nx1] vector, specifying on which plane each
%                          point is on. These are specified as linear
%                          indices, with the hyperstack arranged as
%                          [Channels Z-slices T-slices]. If empty, then all
%                          points are placed on the first slice.
%
%  NoROI:
%     .strType = 'NoROI';
%
% Additionally, ROIs from later versions (.nVersion >= 218) may have the
% following fields:
%
%     .nStrokeWidth     - The width of the line stroke
%     .nStrokeColor     - The encoded color of the stroke (ImageJ color format)
%     .nFillColor       - The encoded fill color for the ROI (ImageJ color
%                          format)
%
% If the ROI contains text:
%     .strSubtype = 'Text';
%     .nFontSize        - The desired font size
%     .nFontStyle       - The style of the font (unknown format)
%     .strFontName      - The name of the font to render the text with
%     .strText          - A string containing the text

% Author: Dylan Muir <dylan.muir@unibas.ch>
% Created: 9th August, 2011
%
% 20260916 ZIP handling switched to .NET and in-memory parsing (no Java, no
%          unzipping to disk); single ROIs are parsed from byte buffers
% 20170118 Added code to read slice position for point ROIs
% 20141020 Added code to read 'header 2' fields; thanks to Luca Nocetti
% 20140602 Bug report contributed by Samuel Barnes and Yousef Mazaheri
% 20110810 Bug report contributed by Jean-Yves Tinevez
% 20110829 Bug fix contributed by Benjamin Ricca <ricca@berkeley.edu>
% 20120622 Order of ROIs in a ROI set is now preserved
% 20120703 Different way of reading zip file contents guarantees that ROI order
%           is preserved
%
% Copyright (c) 2011, 2012, 2013, 2014, 2015, 2016 Dylan Muir <dylan.muir@unibas.ch>
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% -- Check arguments

if (nargin < 1)
   disp('*** ReadImageJROI: Incorrect usage');
   help ReadImageJROI;
   return;
end


% -- Check for a cell array of ROI filenames

if (iscell(cstrFilenames))
   % - Read each ROI in turn
   cvsROI = cellfun(@ReadImageJROI, CellFlatten(cstrFilenames), 'UniformOutput', false);
   
   % - Return all ROIs
   sROI = cvsROI;
   return;
   
else
   % - This is not a cell string
   strFilename = cstrFilenames;
   clear cstrFilenames;
end


% -- Check for a zip file

[nul, nul, strExt] = fileparts(strFilename); %#ok<ASGLU>
if (isequal(lower(strExt), '.zip'))
   % - list the .roi entries inside the archive (via .NET)
   cstrEntryNames = listzipcontents_rois(strFilename);
   
   % - read every .roi entry into memory (no unzipping to disk)
   NET.addAssembly('System.IO.Compression');
   fsZip = System.IO.File.OpenRead(char(strFilename));
   zipArchive = System.IO.Compression.ZipArchive(fsZip);
   
   cvsROIs = cell(length(cstrEntryNames), 1);
   for (nFileIndex = 1:length(cstrEntryNames))
      zipEntry = zipArchive.GetEntry(char(cstrEntryNames{nFileIndex}));
      entryStream = zipEntry.Open();
      memStream = System.IO.MemoryStream();
      entryStream.CopyTo(memStream);
      vbEntryBytes = uint8(memStream.ToArray());
      entryStream.Dispose();
      memStream.Dispose();
      
      % - default ROI name: entry name without folder and extension
      [nul, strEntryStem] = fileparts(cstrEntryNames{nFileIndex}); %#ok<ASGLU>
      cvsROIs{nFileIndex} = parse_roi_bytes(vbEntryBytes, strEntryStem);
   end
   
   % - release the archive and the file handle
   zipArchive.Dispose();
   fsZip.Dispose();
   
   % - Return ROIs
   sROI = cvsROIs;
   return;
end


% -- Read ROI

% -- Check file and open
if (~exist(strFilename, 'file'))
   error('ReadImageJROI:FileNotFound', ...
      '*** ReadImageJROI: The file [%s] was not found.', strFilename);
end

fidROI = fopen(strFilename, 'r');
vbFileBytes = fread(fidROI, inf, '*uint8');
fclose(fidROI);

% - Default ROI name: file name without extension
[nul, strDefaultName] = fileparts(strFilename); %#ok<ASGLU>

% -- Parse the ROI entirely in memory
sROI = parse_roi_bytes(vbFileBytes, strDefaultName);


% --- END of ReadImageJROI FUNCTION ---

   function sROI = parse_roi_bytes(vbBytes, strDefaultName)
      
      % parse_roi_bytes - FUNCTION Parse one ImageJ ROI from in-memory bytes
      %
      % Usage: sROI = parse_roi_bytes(vbBytes, strDefaultName)
      %   vbBytes        - uint8 bytes of a single .roi file (or zip entry)
      %   strDefaultName - ROI name used when no name can be read from the
      %                    ROI header
      %
      % The binary access mimics the original fopen/fread/fseek based code,
      % but operates on a byte buffer in memory with manual big-endian
      % decoding. No temporary files, no Java.
      
      st.buf = uint8(vbBytes(:));
      st.N = numel(st.buf);
      st.pos = 0;   % current byte offset; same semantics as a file position
      
      bOpt_SubPixelResolution = 128;
      
      % -- Check magic code
      strMagic = rd('*char', 4, true);
      
      if (~isequal(strMagic, 'Iout'))
         error('ReadImageJROI:FormatError', ...
            '*** ReadImageJROI: The file was not an ImageJ ROI format.');
      end
      
      % -- Read version
      sROI.nVersion = rd('int16', 1);
      
      % -- Read ROI type
      nTypeID = rd('uint8', 1);
      mk_seek(1, 'cof'); % Skip a byte
      
      % -- Read rectangular bounds
      sROI.vnRectBounds = rd('int16', 4, true);
      
      % -- Read number of coordinates
      nNumCoords = rd('uint16', 1);
      
      % -- Read the rest of the header
      vfLinePoints = rd('float32', 4);
      nStrokeWidth = rd('int16', 1);
      nShapeROISize = rd('uint32', 1);
      nStrokeColor = rd('uint32', 1);
      nFillColor = rd('uint32', 1);
      nROISubtype = rd('int16', 1);
      nOptions = rd('int16', 1);
      nArrowStyle = rd('uint8', 1);
      nArrowHeadSize = rd('uint8', 1);
      nRoundedRectArcSize = rd('int16', 1);
      sROI.nPosition = rd('uint32', 1);
      
      
      % -- Read the 'header 2' fields
      nHeader2Offset = rd('uint32', 1);
      
      if (nHeader2Offset > 0) && (mk_seek(nHeader2Offset+32+4, 'bof') == 0)
         % - Seek to start of header 2
         mk_seek(nHeader2Offset+4, 'bof');
         
         % - Read fields
         sROI.vnPosition = rd('uint32', 3).';
         vnNameParams = rd('uint32', 2).';
         nOverlayLabelColor = rd('uint32', 1); %#ok<NASGU>
         nOverlayFontSize = rd('int16', 1); %#ok<NASGU>
         mk_seek(1, 'cof');   % Skip a byte
         nOpacity = rd('uint8', 1); %#ok<NASGU>
         nImageSize = rd('uint32', 1); %#ok<NASGU>
         fStrokeWidth = rd('float32', 1); %#ok<NASGU>
         vnROIPropertiesParams = rd('uint32', 2).'; %#ok<NASGU>
         nCountersOffset = rd('uint32', 1);
         
      else
         sROI.vnPosition = [];
         vnNameParams = [0 0];
         nOverlayLabelColor = []; %#ok<NASGU>
         nOverlayFontSize = []; %#ok<NASGU>
         nOpacity = []; %#ok<NASGU>
         nImageSize = []; %#ok<NASGU>
         fStrokeWidth = []; %#ok<NASGU>
         vnROIPropertiesParams = [0 0]; %#ok<NASGU>
         nCountersOffset = 0;
      end
      
      
      % -- Set ROI name
      if (isempty(vnNameParams) || any(vnNameParams == 0) || (mk_seek(sum(vnNameParams), 'bof') ~= 0))
         sROI.strName = strDefaultName;
         
      else
         % - Try to read ROI name from header
         mk_seek(vnNameParams(1), 'bof');
         sROI.strName = rd('int16=>char', vnNameParams(2)).';
      end
      
      
      % - Seek to get aspect ratio
      mk_seek(52, 'bof');
      fAspectRatio = rd('float32', 1);
      
      % - Seek to after header
      mk_seek(64, 'bof');
      
      
      % -- Build ROI
      
      switch nTypeID
         case 1
            % - Rectangle
            sROI.strType = 'Rectangle';
            sROI.nArcSize = nRoundedRectArcSize;
            
            if (nShapeROISize > 0)
               % - This is a composite shape ROI
               sROI.strSubtype = 'Shape';
               
               % - Read shapes
               sROI.vfShapes = rd('float32', nShapeROISize);
            end
            
            
         case 2
            % - Oval
            sROI.strType = 'Oval';
            
         case 3
            % - Line
            sROI.strType = 'Line';
            sROI.vnLinePoints = round(vfLinePoints);
            
            if (nROISubtype == 2)
               % - This is an arrow line
               sROI.strSubtype = 'Arrow';
               sROI.bDoubleHeaded = nOptions & 2;
               sROI.bOutlined = nOptions & 4;
               sROI.nArrowStyle = nArrowStyle;
               sROI.nArrowHeadSize = nArrowHeadSize;
            end
            
            
         case 0
            % - Polygon
            sROI.strType = 'Polygon';
            sROI.mnCoordinates = read_coordinates;
            
         case 7
            % - Freehand
            sROI.strType = 'Freehand';
            sROI.mnCoordinates = read_coordinates;
            
            if (nROISubtype == 3)
               % - This is an ellipse
               sROI.strSubtype = 'Ellipse';
               sROI.vfEllipsePoints = vfLinePoints;
               sROI.fAspectRatio = fAspectRatio;
            end
            
         case 8
            % - Traced
            sROI.strType = 'Traced';
            sROI.mnCoordinates = read_coordinates;
            
         case 5
            % - PolyLine
            sROI.strType = 'PolyLine';
            sROI.mnCoordinates = read_coordinates;
            
         case 4
            % - FreeLine
            sROI.strType = 'FreeLine';
            sROI.mnCoordinates = read_coordinates;
            
         case 9
            % - Angle
            sROI.strType = 'Angle';
            sROI.mnCoordinates = read_coordinates;
            
         case 10
            % - Point
            sROI.strType = 'Point';
            [sROI.mfCoordinates, vnCounters] = read_coordinates;
            
            % - Set counters and [C Z T] positions
            if (isempty(vnCounters))
               sROI.vnCounters = zeros(nNumCoords, 1);
               sROI.vnSlices = ones(nNumCoords, 1);
            else
               sROI.vnCounters = bitand(vnCounters, 255);
               sROI.vnSlices = bitshift(vnCounters, -8, 'uint32');
            end
            
         case 6
            sROI.strType = 'NoROI';
            
         otherwise
            error('ReadImageJROI:FormatError', ...
               '--- ReadImageJROI: The ROI file contains an unknown ROI type.');
      end
      
      
      % -- Handle version >= 218
      
      if (sROI.nVersion >= 218)
         sROI.nStrokeWidth = nStrokeWidth;
         sROI.nStrokeColor = nStrokeColor;
         sROI.nFillColor = nFillColor;
         sROI.bSplineFit = nOptions & 1;
         
         if (nROISubtype == 1)
            % - This is a text ROI
            sROI.strSubtype = 'Text';
            
            % - Seek to after header
            mk_seek(64, 'bof');
            
            sROI.nFontSize = rd('uint32', 1);
            sROI.nFontStyle = rd('uint32', 1);
            nNameLength = rd('uint32', 1);
            nTextLength = rd('uint32', 1);
            
            % - Read font name
            sROI.strFontName = rd('uint16=>char', nNameLength);
            
            % - Read text
            sROI.strText = rd('uint16=>char', nTextLength);
         end
      end
      
      % --- END of parse_roi_bytes main flow ---
      
      function [mnCoordinates, vnCounters] = read_coordinates
         
         % - Check for sub-pixel resolution
         if bitand(nOptions, bOpt_SubPixelResolution)
            mk_seek(64 + 4*nNumCoords, 'bof');
            
            % - Read X and Y coordinates
            vnX = rd('float32', nNumCoords);
            vnY = rd('float32', nNumCoords);
            
         else
            % - Read X and Y coords
            vnX = rd('int16', nNumCoords);
            vnY = rd('int16', nNumCoords);
            
            % - Trim at zero
            vnX(vnX < 0) = 0;
            vnY(vnY < 0) = 0;
            
            % - Offset by top left ROI bound
            vnX = vnX + sROI.vnRectBounds(2);
            vnY = vnY + sROI.vnRectBounds(1);
         end
         
         mnCoordinates = [vnX vnY];
         
         % - Read counters, if present
         if (nCountersOffset ~= 0)
            mk_seek(nCountersOffset, 'bof');
            vnCounters = rd('uint32', nNumCoords);
         else
            vnCounters = [];
         end
      end
      
      function stts = mk_seek(vnOffset, strWhence)
         
         % mk_seek - mimic fseek on the in-memory buffer
         % Returns 0 on success and -1 on failure (st.pos stays unchanged),
         % exactly like fseek. Seeking to st.N (end of buffer) succeeds;
         % negative or past-the-end targets fail.
         
         vnOffset = double(vnOffset);
         switch lower(strWhence)
            case 'bof'
               nNewPos = vnOffset;
            case 'cof'
               nNewPos = st.pos + vnOffset;
            case 'eof'
               nNewPos = st.N + vnOffset;
            otherwise
               nNewPos = st.pos + vnOffset;
         end
         if (nNewPos < 0) || (nNewPos > st.N)
            stts = -1;
         else
            st.pos = nNewPos;
            stts = 0;
         end
      end
      
      function v = rd(strPrec, nCount, bRow)
         
         % rd - mimic fread(fid, count, precision) on the in-memory buffer,
         % with manual big-endian decoding. If fewer than nCount elements
         % remain, only the available elements are returned (empty if none).
         % bRow=true returns a row vector (like the [1 N] fread shape).
         
         if (nargin < 3)
            bRow = false;
         end
         nCount = double(nCount);
         nSize = elementSize(strPrec);
         nAvail = floor(max(st.N - st.pos, 0) / nSize);
         k = min(nCount, nAvail);
         if (k <= 0)
            v = [];
            return;
         end
         vbRaw = double(st.buf(st.pos + (1:k*nSize)));
         st.pos = st.pos + k*nSize;
         matBytes = reshape(vbRaw, nSize, k).';   % k rows x nSize bytes (big-endian)
         
         switch strPrec
            case {'uint8', '*uint8'}
               v = matBytes(:, 1);
               
            case '*char'
               v = char(uint8(matBytes(:, 1)));
               
            case {'int16', 'int16=>char'}
               v = matBytes(:, 1)*256 + matBytes(:, 2);
               v = v - 65536*(v >= 32768);   % two's complement
               if isequal(strPrec, 'int16=>char')
                  v(v < 0) = 0;
                  v = char(v);
               end
               
            case {'uint16', 'uint16=>char'}
               v = matBytes(:, 1)*256 + matBytes(:, 2);
               if isequal(strPrec, 'uint16=>char')
                  v = char(v);
               end
               
            case 'uint32'
               v = ((matBytes(:, 1)*256 + matBytes(:, 2))*256 + matBytes(:, 3))*256 + matBytes(:, 4);
               
            case {'float32', 'single'}
               uBits = uint32(((matBytes(:, 1)*256 + matBytes(:, 2))*256 + matBytes(:, 3))*256 + matBytes(:, 4));
               v = double(typecast(uBits, 'single'));
         end
         
         if bRow
            v = v.';
         end
      end
      
      function nBytes = elementSize(strPrec)
         switch strPrec
            case {'uint8', '*uint8', '*char'}
               nBytes = 1;
            case {'int16', 'uint16', 'int16=>char', 'uint16=>char'}
               nBytes = 2;
            case {'uint32', 'float32', 'single'}
               nBytes = 4;
            otherwise
               error('ReadImageJROI:FormatError', ...
                  '*** ReadImageJROI: Unsupported precision [%s].', strPrec);
         end
      end
   end

   function [filelist] = listzipcontents_rois(zipFilename)
      
      % listzipcontents_rois - FUNCTION Read the file names in a zip file
      %
      % Usage: [filelist] = listzipcontents_rois(zipFilename)
      %   Returns an Nx1 cell array with the full entry names of all .roi
      %   files inside the zip archive (via .NET, no Java).
      
      % - Read file list via .NET ZipArchive
      NET.addAssembly('System.IO.Compression');
      fsZip = System.IO.File.OpenRead(char(zipFilename));
      zipArchive = System.IO.Compression.ZipArchive(fsZip);
      
      filelist={};
      zipEntries = zipArchive.Entries;
      for (nIndex = 0:zipEntries.Count-1)
         zipEntry = zipEntries.Item(nIndex);
         strEntryName = string(zipEntry.FullName);
         
         % - Filter ROI files
         if endsWith(lower(strEntryName), '.roi') && ~startsWith(strEntryName, '__MACOSX')
            filelist = cat(1,filelist,char(strEntryName));
         end
      end
      
      % - Close zip file
      zipArchive.Dispose();
      fsZip.Dispose();
   end


   function [cellArray] = CellFlatten(varargin)
      
      % CellFlatten - FUNCTION Convert a list of items to a single level cell array
      %
      % Usage: [cellArray] = CellFlatten(arg1, arg2, ...)
      %
      % CellFlatten will convert a list of arguments into a single-level cell array.
      % If any argument is already a cell array, each cell will be concatenated to
      % 'cellArray' in a list.  The result of this function is a single-dimensioned
      % cell array containing a cell for each individual item passed to CellFlatten.
      % The order of cell elements in the argument list is guaranteed to be
      % preserved.
      %
      % This function is useful when dealing with variable-length argument lists,
      % each item of which can also be a cell array of items.
      
      % Author: Dylan Muir <dylan@ini.phys.ethz.ch>
      % Created: 14th May, 2004
      
      % -- Check arguments
      
      if (nargin == 0)
         disp('*** CellFlatten: Incorrect usage');
         help CellFlatten;
         return;
      end
      
      % -- Convert arguments
      
      % - Which elements contain cell subarrays?
      vbIsCellSubarray = cellfun(@iscell, varargin, 'UniformOutput', true);
      
      % - Skip if no cell subarrays
      if ~any(vbIsCellSubarray)
         cellArray = varargin;
         return;
      end
      
      % - Recursively flatten subarrays
      varargin(vbIsCellSubarray) = cellfun(@(c)CellFlatten(c{:}), varargin(vbIsCellSubarray), 'UniformOutput', false);
      
      % - Count the total number of arguments
      vnArgSizes(nargin) = nan;
      vnArgSizes(~vbIsCellSubarray) = 1;
      vnArgSizes(vbIsCellSubarray) = cellfun(@numel, varargin(vbIsCellSubarray), 'UniformOutput', true);
      vnArgEnds = cumsum(vnArgSizes);
      vnArgStarts = [1 vnArgEnds(1:end-1)+1];
      nNumArgs = vnArgEnds(end);
      
      % - Preallocate return array
      cellArray = cell(1, nNumArgs);
      
      % - Deal out non-cell subarray arguments
      cellArray(vnArgEnds(~vbIsCellSubarray)) = varargin(~vbIsCellSubarray);
      
      % - Deal out arguments into return array
      for nIndexArg = find(vbIsCellSubarray)
         cellArray(vnArgStarts(nIndexArg):vnArgEnds(nIndexArg)) = varargin{nIndexArg};
      end
      
      % --- END of CellFlatten.m ---

   end

end
% --- END of ReadImageJROI.m ---