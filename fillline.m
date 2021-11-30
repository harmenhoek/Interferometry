function [xx,yy]=fillline(startp,endp,pts)
% take starting, ending point & number of points in between
% make line to connect between 2 coordinates
    m=(endp(2)-startp(2))/(endp(1)-startp(1)); %gradient 
    if m==Inf %vertical line
        xx(1:pts)=startp(1);
        yy(1:pts)=linspace(startp(2),endp(2),pts);
    elseif m==0 %horizontal line
        xx(1:pts)=linspace(startp(1),endp(1),pts);
        yy(1:pts)=startp(2);
    else %if (endp(1)-startp(1))~=0
        xx=linspace(startp(1),endp(1),pts);
        yy=m*(xx-startp(1))+startp(2);
    end
end