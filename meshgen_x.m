function [x] = meshgen_x(params)

v2struct(params);

meshfigon = 1;

% Linearly spaced
if xmesh_type == 1

    x = linspace(0,xmax,pp+pii+pn);

% Linearly spaced, more points at interfaces   
elseif xmesh_type == 2
   
    x = [linspace(0, tp-tinter, pp),...
        linspace(tp-tinter+deltax, tp, pinter),...
        linspace(tp+deltax, tp+tinter, pinter),...
        linspace(tp+tinter+deltax, tp+ti-tinter-deltax, pii),...
        linspace(tp+ti-tinter, tp+ti-deltax, pinter),...
        linspace(tp+ti, tp+ti+tinter-deltax, pinter),...
        linspace(tp+ti+tinter, xmax, pn)]; 
    
% Linearly spaced, more points at interfaces and electrodes
elseif xmesh_type == 3
   
    x = [linspace(0, te, pepe),...
        linspace(te+deltax, tp-tint, pp),...
        linspace(tp-tint+deltax, tp, pint),...
        linspace(tp+deltax, tp+tint, pint),...
        linspace(tp+tint+deltax, tp+ti-tint-deltax, pii),...
        linspace(tp+ti-tint, tp+ti-deltax, pint),...
        linspace(tp+ti, tp+ti+tint-deltax, pint),...
        linspace(tp+ti+tint, xmax-te-deltax, pn),...
        linspace(xmax-te, xmax, pepe);]; 
    
elseif xmesh_type == 4
    
    x = [linspace(0, tp-tscr, pp),...
        linspace(tp-tscr+(tscr/pscr), tp-tint, pscr),...
        linspace(tp-tint+(tint/pint), tp, pint),...
        linspace(tp+(tint/pint), tp+tint, pint),...
        linspace(tp+tint+(tint/pint), tp+tscr, pscr),...
        linspace(tp+tscr+(tscr/pscr), tp+ti-tscr-(tscr/pscr), pii),...
        linspace(tp+ti-tscr, tp+ti-tint-(tint/pint), pscr),...
        linspace(tp+ti-tint, tp+ti-(tint/pint), pint),...
        linspace(tp+ti, tp+ti+tint-(tint/pint), pint),...
        linspace(tp+ti+tint, tp+ti+tscr-(tscr/pscr), pscr),...
        linspace(tp+ti+tscr, xmax, pn);];
    
end 

if meshfigon == 1

    xmir = x;
    pxmir = 1:1:length(x);
    
    figure(1010);
    plot(xmir, pxmir, '.');
    xlabel('Position');
    ylabel('Point');

end

end
