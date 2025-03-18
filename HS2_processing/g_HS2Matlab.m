function [channelNames,spiketimestamps,Sampling,centres,cluster_id,times] = g_HS2Matlab(HdfFile,idx)
% import v28 hdf5 files and convert to Matlab arrays
% HdfFile=spontHdfFile;
% minspkfreq=0.01;
% maxspkfreq=100;
% HdfFile=spontHdfFile;

centres = double(h5read(HdfFile,'/centres'));
cluster_id = double(h5read(HdfFile,'/cluster_id'));
times = double(h5read(HdfFile,'/times'));
Sampling = double(h5read(HdfFile,'/Sampling'));
centVersion = size(centres);

temp_units = double(tabulate(cluster_id));
k=1;
for i = 1:length(idx)
   valididx = find(temp_units(:,1)==idx(i));
   if isempty(valididx)==false
       units(k,1:3) = temp_units(valididx,1:3);
   else
       units(k,1) = units(k-1,1)+1;
       units(k,2:3) = 0;
   end
   k=k+1;
   clearvars valididx
end
       
maxspikes = max(units(:,2));
nunits = length(units(:,1));
reclen = max(times)/Sampling; % just an approximation
spiketimestamps(1:maxspikes,1:nunits) = zeros;

for i = 1:nunits
    if units(i,2)>0
        spiketimestamps(1:units(i,2),(i))=times(cluster_id==units(i,1));
        channelNames{1,i} = cellstr(sprintf('Cluster%05d',units(i,1)));
        if centVersion(2) > 4  %new HS format
            channelNames{2,i} = centres(2,units(i,1)+1);
            channelNames{3,i} = centres(1,units(i,1)+1);
        else
            channelNames{2,i} = centres(units(i,1)+1,2);
            channelNames{3,i} = centres(units(i,1)+1,1);
        end
        
        channelNames{4,i} = units(i,1);
        channelNames{5,i} = units(i,2)/reclen;
        channelNames{6,i} = units(i,2);
    else
        channelNames{1,i} = cellstr(sprintf('Cluster%05d',units(i,1)));
        channelNames{2,i} = nan;
        channelNames{3,i} = nan;
        channelNames{4,i} = units(i,1);
        channelNames{5,i} = 0;
        channelNames{6,i} = 0;
    end
    
end

% leaves spaces
% for i = 1:length(units)
%     spiketimestamps(1:units(i,2),(units(i,1)+1))=times(cluster_id==units(i,1));
%     channelNames{1,(units(i,1)+1)} = cellstr(sprintf('Cluster%05d',units(i,1)));
%     if centVersion(2) > 4  %new HS format
%         channelNames{2,(units(i,1)+1)} = centres(2,units(i,1)+1);
%         channelNames{3,(units(i,1)+1)} = centres(1,units(i,1)+1);
%     else
%         channelNames{2,(units(i,1)+1)} = centres(units(i,1)+1,2);
%         channelNames{3,(units(i,1)+1)} = centres(units(i,1)+1,1);
%     end
%     
%     channelNames{4,(units(i,1)+1)} = units(i,1);
%     channelNames{5,(units(i,1)+1)} = units(i,2)/reclen;
%     channelNames{6,(units(i,1)+1)} = units(i,2);
%     
% end


end













