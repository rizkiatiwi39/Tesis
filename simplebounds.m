function s = simplebounds(s, Lb, Ub)
% % Terapkan batas bawah dan atas
% s(s < Lb) = Lb(s < Lb);
% s(s > Ub) = Ub(s > Ub);

  ns_tmp=s;
  I=ns_tmp<Lb;
  ns_tmp(I)=Lb(I);
  
  % Apply the upper bounds 
  J=ns_tmp>Ub;
  ns_tmp(J)=Ub(J);
  % Update this new move 
  s=ns_tmp;
