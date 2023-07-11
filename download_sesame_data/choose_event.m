clear;
event_file='event_mag5.0_dep0-100.lst';
fpsta=fopen(event_file);
einf=struct('lon',0,'lat',0,'info','');
for i=1:294
    einf(i).lon=fscanf(fpsta,'%f',1);
    einf(i).lat=fscanf(fpsta,'%f',1);
    einf(i).info=fgetl(fpsta);
end
fclose(fpsta);

lon1=-83.9109;
lat1=30.2017;
lon2=-83.9438;
lat2=34.9762;
[~,bazi_ref]=distance(lat2,lon2,lat1,lon1);
bazi_ref
for i=1:length(einf)
    [~,bazi]=distance(lat2,lon2,einf(i).lat,einf(i).lon);
    %bazi
    if abs(bazi-bazi_ref)<3
        disp(['event:',num2str(i),'-',num2str(einf(i).lon),'-',num2str(einf(i).lat),einf(i).info]);
    end
end