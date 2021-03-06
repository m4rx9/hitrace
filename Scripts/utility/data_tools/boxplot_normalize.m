function [d_norm, scalefactor, cap_value ] = boxplot_normalize( d_for_scalefactor );
% [d_norm, scalefactor, cap_value ] = boxplot_normalize( d_for_scalefactor );
%
%  'box-plot' normalize, as described in Deigan et al., PNAS, 2009
%
%  -- remove outliers, i.e., any values beyond 1.5 * interquartile range 
%  -- for RNAs with length under 100 nts, also remove values greater than the 95th percentile value.
%  -- scalefactor is mean of top 10th percentile of remaining values
%
%

if nargin == 0;  help( mfilename ); return; end;

FLIPPED = 0;
if size( d_for_scalefactor, 1) == 1
  FLIPPED = 1;
  d_for_scalefactor = d_for_scalefactor';
end

cap_value = 999;
for k = 1:size( d_for_scalefactor, 2 )
  d_OK = d_for_scalefactor( find( ~isnan( d_for_scalefactor(:,k)) ), k );

  dsort = sort( d_OK );
  
  % this attempts to recover the normalization scheme in ShapeFinder, as reported by Deigan et al., 2008.
  q1 = dsort( round( 0.25*length(dsort) ) );
  q3 = dsort( round( 0.75*length(dsort) ) );
  interquartile_range = abs( q3 - q1 );
  
  % test -- based on definition of matlab box().
  outlier_cutoff = min( find( dsort > (q3 + 1.5*interquartile_range ) ) );

  %[outlier_cutoff length( dsort ) ]
  if ~isempty( outlier_cutoff )
    actual_cutoff = outlier_cutoff - 1;
    
    % for smaller RNAs, as described in Deigan et al., 2009.
    if length( dsort ) < 100; actual_cutoff = max( actual_cutoff, round(0.95*length(dsort) ) - 1 ); end;
    %actual_cutoff = max( actual_cutoff, round(0.95*length(dsort) ) - 1 );
    %[actual_cutoff length( dsort) ]
    cap_value = dsort( actual_cutoff+1 );
    dsort = dsort(1: actual_cutoff );
  end
  
  % Take top 10th percentile of values after removing outliers
  scalefactor(k) = mean(dsort(  round( 0.9 * length(dsort)):end ) );

  d_norm(:,k) = d_for_scalefactor(:,k) / scalefactor(k);
end

if FLIPPED
  d_norm = d_norm';
end