% UpdateProgDisp(handle,NewText,MaxLines)
%     Maxlines is an option argument

function error = UpdateProgDisp(h,New,varargin)
if isempty(h)
    return
end
    
    
if isempty(varargin)
    Nmax = 4; 
else
    Nmax = varargin{1}; 
end
try
hPrev = get(h,'String');

N = size(hPrev,1);
Nnew = size(New,1);

if N>Nmax, jj = (N-Nmax+1):N; else jj = 1:N; end

if N == 1, hPrev = {hPrev}; end
if Nnew == 1, New = {New}; end
kk = 1;

for ii = jj
    C{kk} = hPrev{ii};
    kk = kk+1;
end

for ii=1:Nnew
C{kk} = New{ii};
kk=kk+1;
end

set(h,'String',C)
    
    error = false;
    catch
        error = true;
end
end