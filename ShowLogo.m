function ShowLogo
    opts = delimitedTextImportOptions("NumVariables", 1);
    opts.DataLines = [1, Inf];
    opts.Delimiter = ";";
    opts.VariableNames = "ad88888baI888I88888888ba88Ad888888";
    opts.VariableTypes = "string";
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts.ConsecutiveDelimitersRule = "join";
    opts = setvaropts(opts, "ad88888baI888I88888888ba88Ad888888", "WhitespaceRule", "preserve");
    opts = setvaropts(opts, "ad88888baI888I88888888ba88Ad888888", "EmptyFieldRule", "auto");
    logo = readmatrix("logo.txt", opts);
    for i=1:size(logo,1)
        disp(logo(i,1))
    end
end