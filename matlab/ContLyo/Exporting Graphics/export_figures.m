function export_figures(figure,filename)

filename1 = fullfile('Figures',  [filename,'.png']);
exportgraphics(figure, filename1,'Resolution',600)
filename2 = fullfile('Figures',  [filename,'.pdf']);
exportgraphics(figure, filename2,'Resolution',1000)
filename3 = fullfile('Figures',  [filename,'.emf']);
exportgraphics(figure, filename3,'Resolution',1000)

return