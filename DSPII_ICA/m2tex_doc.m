function m2tex_doc(m,nm,strg)
% 
%   latex expression for a variable
% 
% 
% 

v_sav = false;

pth = ['../doc/variables'];

% if ~exist(pth,'dir'),
%     mkdir(pth);
% end

if nargin < 2,
   
    warning(sprintf('No variable name!\r\n%s'),...
        'variable will be saved in "var.def".');
    nm = 'var';
    
end

if nargin >= 3 && ~isempty(strg),
    strg = [strg '/'];
else
    strg = '';
end

if ~ischar(nm),
    error('Invalid variable name format!');
end

if ~ischar(strg),
    error('Invalid sub-path name format!');
end

pth = [pth '/' strg(1:end-1)];

if ~exist(pth,'dir')
    mkdir(pth);
end

txstr = latex(sym(m));
disp(txstr);

if exist(['../doc/variables/' strg nm '.def'],'dir'), v_sav = true; end

if ~v_sav,
    save(['../doc/variables/' strg nm '.def'],'txstr','-ascii','-double');
else
    save(['../doc/variables/' strg nm '.def'],'txstr','-ascii','-double','-append');
end

end
