% Write ! > data file from structure
%
function writeInputFile(filename,points)

Np=length(points);                                                         % Number of points
fn=fieldnames(points);                                                     % Extract fieldnames
Nfn=length(fn);                                                            % Number of fieldnames

fid=fopen(filename,'w');                                                   % overwrites existing file

for p=points
  for ii=1:Nfn
    fprintf(fid,'%s',fn{ii});                                              % write the fieldname to file
    fprintf(fid,'%s !     >  ',blanks(15-length(fn{ii})));                 % add the '>' sign
    data=getfield(p,fn{ii});                                               % extract field data
    if isstr(data)
      fprintf(fid,'%s\n',data);                                            % print a string
    else
      fprintf(fid,'%.11f ',data);                                           % print a scalar or vector
      fprintf(fid,'\n');
    end
  end
  fprintf(fid,'END\n');                                                    % end of case
end

fclose(fid);