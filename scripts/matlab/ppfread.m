function [y,x,t]=ppfread(shot,dda,datatype,seq,userid)
%SHOULD FIX THIS SO THAT T IS NOT STORED EVERY TIME
    % Change dda, datatype and userid to lowercase if they weren't passed 
    % in as such:
    dda=lower(dda);
    datatype=lower(datatype);
    userid=lower(userid);
    
    fname=['C:\WORK\JET_cache\ppf\',num2str(shot),'\',userid,'\',dda,'\',datatype,'\seq',num2str(seq)];
    % If the ppf exists locally just read it, otherwise get it from the JET
    % mdsplus server:
    if exist(fname,'file')==2
        fprintf('Found file')
        y=hdf5read(fname,'/y');
        x=hdf5read(fname,'/x');
        t=hdf5read(fname,'/t');
    else
        fprintf('Need to connect')
        % Connect to mdsplus server if not connected already
        try
            mdsvalue('5');
        catch
            mdsconnect('mdsplus.jet.efda.org');
        end
        % Change to the appropriate username by calling ppfuid
        mdsvalue(['_sig=ppfuid("',userid,'")']);
        % Get the data
        y=mdsvalue(['_sig=jet("ppf/',dda,'/',datatype,'/',num2str(seq),'",',num2str(shot),')']);
        % If y is empty then there is no such ppf and we should give an
        % error message
        if isempty(y)
            error('MDS server returned no ppf. Check it exists');
        % If it's a two dimensional signal then get the x and t values,
        % otherwise just get the t values
        elseif size(y,2)>1
            x=mdsvalue('dim_of(_sig,0)');
            t=mdsvalue('dim_of(_sig,1)');
        else
            x=0;
            t=mdsvalue('dim_of(_sig)');
        end
        % Write the ppf to file.
%         if exist(fname,'file')~=2
%             hdf5write(fname,[dda,'/',datatype,'/seq',num2str(seq),'/',userid,'/y'],y);
%         else
%             hdf5write(fname,[dda,'/',datatype,'/seq',num2str(seq),'/',userid,'/y'],y,'WriteMode','append');
%         end
%         hdf5write(fname,[dda,'/',datatype,'/seq',num2str(seq),'/',userid,'/x'],x,'WriteMode','append');
%         hdf5write(fname,[dda,'/',datatype,'/seq',num2str(seq),'/',userid,'/t'],t,'WriteMode','append');
        
%         mkdir(['C:\WORK\JET_cache\ppf\',num2str(shot),'\',userid,'\',dda,'\',datatype]);
%         hdf5write(fname,'/y',y);
%         hdf5write(fname,'/x',x,'WriteMode','append');
%         hdf5write(fname,'/t',t,'WriteMode','append');
    end
end
