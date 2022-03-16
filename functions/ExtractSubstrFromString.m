function substr = ExtractSubstrFromString(str, pattern)
%{
    Extracts substring between first occurance of pattern(1) and last occurance of pattern(2) in str.
    Example:
        ExtractSubstrFromString('recording2022-02-01_15:13:12_image2', {'recording','_'})
        >> '2022-02-01_15:13:12'
%}
    substr = str;
	if ~isempty(pattern{1})
        k = strfind(str, pattern{1});
        substr = substr(k(1)+1:end);
    end
    if ~isempty(pattern{2})
        k = strfind(substr, pattern{2});
        substr = substr(1:k(end)-1);
    end
end