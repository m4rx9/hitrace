function make_lines(line_pos,colorcode,linewidth);

if ~exist('colorcode')
  colorcode='r';
end
if ~exist('linewidth')
  linewidth=1;
end

ylim = get(gca,'ylim');
hold on
for i = 1:length( line_pos );
  hold on
  plot( 0.5+line_pos(i)*[1 1], [ylim(1) ylim(2)],'-','color',colorcode,'linewidth',linewidth); 
end
hold off