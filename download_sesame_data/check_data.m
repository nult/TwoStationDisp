% read input waveform name files
list_file="final_events_P.lst";
fplst=fopen(list_file,'r');
lst=struct('fname',{},'lon',{},'lat',{},'t1',{},'t2',{},'unuse',{});
i=1;
while ~feof(fplst)
    name=fscanf(fplst,'%s',1);
    if ~strcmp(name,'')
        lst(i).fname=name;
	lst(i).fname
        lst(i).lon=fscanf(fplst,'%f',1);
        lst(i).lat=fscanf(fplst,'%f',1);
	lst(i).t1=fscanf(fplst,'%f',1);
	lst(i).t2=fscanf(fplst,'%f',1);
	lst(i).unuse=fscanf(fplst,'%f',1);
    else
	break
    end
    temp=fgetl(fplst);
    i=i+1;
end
enum=i-1;

for i=1:enum
    temp_files=dir([lst(i).fname,'/*.sac']);
    disp(["Event: ",num2str(i),", total number of files: ",num2str(length(temp_files))]);
    for j=1:length(temp_files)
	sacfile=[lst(i).fname,'/',temp_files(j).name];
	temp_a=readsac(sacfile);
	if max(isnan(temp_a.DATA1))>0.5 || max(abs(temp_a.DATA1))<0.000000001
	    disp(sacfile);
	    delete(sacfile);
        end
    end
end
%a = readsac('
