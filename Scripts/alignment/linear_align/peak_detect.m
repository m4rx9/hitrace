function [ peak, peak_out ] = peak_detect( data );
% [ peak, peak_out ] = peak_detect( data );

if nargin == 0;  help( mfilename ); return; end;

% jk begin - Peak detection
PEAKDETECT = 1;
if PEAKDETECT
    
    %Parameters for peak detection
    Th_intensity = [1 20]; %best
    Th_width = [0 5];
    Th_adjacent = [0 15];
    
    peak = [];

    for idx = 1:size(data,2)
        fprintf(1,'Peak detection...%d\n',idx);
        
        y = data(:,idx).';
        
        lpf = fir1(20, 0.2); % 11-tap FIR filter, make it odd-tap
        ylpf = filter(lpf,1,y);    
        start = (length(lpf) + 1)/2;
        ylpf = ylpf(start:end);
        ylpf = [ylpf zeros(1, length(y)-length(ylpf))]; % zero-padding at the end
   
        ylpf_d = [0 diff(ylpf)];
        debug_on = 0;
        [peak_out] = FindPeakNew_Ver3(ylpf_d, y, Th_intensity, Th_width, Th_adjacent, debug_on);
        
        % Peak detection using median filter
        MEDIAN_FILTER = 0;
        if MEDIAN_FILTER
            y_med = median_filter(y,3);
            y_med_sq = y_med.^2;
            y_med_sq_d = [0 diff(y_med_sq)];
    
            h = [0.8 1.4 0.8]/3;
            y_med_sq_d_avg = filter(h, 1, [y_med_sq_d y_med_sq_d(end)*ones(1,10)]);
            y_med_sq_d_avg = y_med_sq_d_avg(1, 2 : length(y_med_sq_d)+1);
   
            debug_on = 0;
            [peak_out] = FindPeakNew_Ver3(y_med_sq_d_avg, y, Th_intensity, Th_width, Th_adjacent, debug_on);
%             peak_out = ( min(max( peak_out, 0 ),100) );
%             peak_out(find(peak_out>0))=1;
        end
	
	peak_out = sqrt( peak_out );
        peak_out = peak_out.' + circshift(peak_out.',1) + circshift(peak_out.',-1);

        peak = [peak peak_out(:,1)];
    end

end


