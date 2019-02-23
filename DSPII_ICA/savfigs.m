function savfigs(fig)
try
    svfgs(fig);
catch
    svfgs(fig);
end

return;
end

function svfgs(fig)
    for i = 1:numel(fig),
        
        fig = openfig(['../figures' fig{i} '.fig']);
        %saving the figure
        pth = sprintf('../figures/%s',fig{i});
        print(fig,pth,'-depsc2');

    end
end