function [ a ] = CalculateA( anisotropy, q )
%CALCULATEA Calculates the required a to give desired anisotropy parameter
%at known q.
% This assumes that q_r >> a_r.
a = (anisotropy .* (q .^ 2)/4);
a = -abs(a);

end

