 function [Rs, R1, C1, R2, C2, rsquare, mverr] = calcul_rrc2_fit(tm,Um,Im,options,R10,C10,R20,C20)
%% Todo: update commentary once its done
% calcul_rrc identify Rs, R and C from t,U,I profiles

%% Treat input data
% Find the indice where the current changes value
% ind_change = find(abs(diff(Im))>=1) + 1;
ind_change = find(abs(diff(Im))>=1,1,"last") + 1;

% Identify Rs as being in the first 100ms after the current pulse
% TODO : Make it robust
Rs = (Um(ind_change)-Um(ind_change-3))/(Im(ind_change)-Im(ind_change-1));

% figure
% plot(tm, Um, '*')
% hold on
% yyaxis right
% plot(tm, Im, '*')

% Separate only the pure RC response (after Rs)
tm_rc = tm(ind_change:size(tm,1));
Um_rc = Um(ind_change:size(Um,1));
Im_rc = Im(ind_change:size(Im,1));

tm_rc = tm_rc - tm_rc(1);
Um_rc = Um_rc - Um_rc(1);

% Find average current amplitude for the pulse
Im_avg = mean(Im_rc);

% Calculate initial values for the R1C1, R2C2 terms
b0 = R10*Im_avg;
c0 = 1/(R10*C10);
d0 = R20*Im_avg;
f0 = 1/(R20*C20); 


%% Curve fit
% Declare fit function
ft = fittype( '(b+d) - b*exp(-c*x) - d*exp(-f*x)', 'independent', 'x', 'dependent', 'y' );

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.StartPoint = [b0 c0 d0 f0];
    if Im_avg > 0 % code to ensure that R1C1R2C2 always > 0
        % Add constraints to 1/c (R1*C1) and 1/f (R2*C2) that translate
        % into time contraints: R1C1 [0.1 1]s, R2C2 [20 30]s
        opts.Lower = [0 1/1 0 1/30];
        opts.Upper = [Inf 1/0.1 Inf 1/20];
    else
        opts.Lower = [-Inf 1/1 -Inf 1/30];
        opts.Upper = [0 1/0.1 0 1/20];
    end

%         opts.Lower = [0 0 0 0];
%         opts.Upper = [Inf Inf Inf Inf];
%     else
%         opts.Lower = [-Inf 0 -Inf 0];
%         opts.Upper = [0 Inf 0 Inf];
%     end

%         opts.Lower = [0 1/30 0 1/30];
%         opts.Upper = [Inf 1/0.1 Inf 1/0.1];
%     else
%         opts.Lower = [-Inf 1/30 -Inf 1/30];
%         opts.Upper = [0 1/0.1 0 1/0.1];
%     end


% Perform fit
[fitresult, gof] = fit(tm_rc,Um_rc, ft, opts );

% Extract parameters from fit result
    R1 = fitresult.b/Im_avg;
    R2 = fitresult.d/Im_avg;
    C1 = 1/(R1*fitresult.c);
    C2 = 1/(R2*fitresult.f);

% % Plot fit result vs experimental only for the RC part
%     figure
%     plot(tm_rc,Um_rc)
%     hold on
%     plot(fitresult)

% Simulate the voltage response with the parameters that we just found
Us = rrc2_output(tm,Im,Rs,R1,C1,R2,C2);
    
% Calculate max. absolute voltage error between simulation and experimental
mverr = max(abs(Us-Um));

% % Plot simulation vs experimental - if uncommented, will produce 60 curves
%     figure
%     hold on
%     plot(tm,Us,'LineWidth',3)
%     plot(tm,Um,'LineWidth',3)
%     grid on
%     xlabel('temps(s)')
%     ylabel('tension(V)')
%     legend('Simulation','Expérimental')

Is = Im;
ts = tm;

% get rsquare from fitresult
rsquare = gof.rsquare;

% if ~isempty(strfind(options, 'g'))
%         showResult(tm,Im,Um,ts,Is,Us,rsquare);
% end

end

% function erreur = erreurRRC2(Rs,R1,C1,R2,C2,tm,Um,Im)
% %erreur = erreurRC(Q,alpha,tm,Um,Im)
% %erreurCPE simule un circuit RC  et compare le resultat avec des mesures
% %La simulation est faite en utilisant la fonction reponseRC.
% % -R,C [1x1 double]: parametres du circuit RC
% % -tm,Um,Im [nx1 double]: vecteurs temps, tension et courant (mesures)
% %
% 
% if ~isnumeric(R1) ||  ~isnumeric(C1) ||  ~isnumeric(tm) ||  ~isnumeric(Um) ||  ~isnumeric(Im) 
%     erreur = [];
%     fprintf('erreurRC:ERREUR, toutes les entrees doivent etre numeriques\n');
%     return
% end
% if numel(R1) ~= 1 || numel(C1) ~= 1 
%     erreur = [];
%     fprintf('erreurRC:ERREUR, R et C doivent etre scalaires (1x1)\n');
%     return
% end
% if ~isequal(size(tm),size(Um)) || ~isequal(size(tm),size(Im)) || size(tm,1)~=length(tm)
%     erreur = [];
%     fprintf('erreurRC:ERREUR; tm,Um et Im doivent etre vecteurs de la meme taille (nx1)\n');
%     return
% end
% 
% 
% U = rrc2_output(tm,Im,Rs,R1,C1,R2,C2);
% U = U(:);
% Um = Um(:);
% 
% erreur = mean(erreurQuadratique(Um,U));
% 
% end
% function err_qua = erreurQuadratique(Um,Us)
% n = 2;
% 
% % err_qua = abs(Us(end/2:end)-Um(end/2:end)).^n;
% err_qua = abs(Us-Um).^2;
% end
% function showResult(tm,Im,Um,ts,Is,Us,err)
% figure,
% subplot(211),plot(tm,Im,'.-',ts,Is,'r.-'),ylabel('courant (A)')
% subplot(212),plot(tm,Um,'.-',ts,Us,'r.-',tm,Us-Um,'g.'),ylabel('tension (V)')
% legend('mesure','simu',sprintf('erreur quadratique: %f',err),'location','best')
% end
% function [Um2,Im,tm,DoDm,Urelax,Instant_rest]=remove_spikes(Um2,Im,tm,DoDm,p_RC,phase_RC)
% %remove_spikes Nettoie les points de courants abberants lors d'un pulse
% %Um2,Im,tm,sont issus de getPhase2
% %p_RC vient de split_phases
% %See also getPhase2, split_phases
% %%
% 
% 
% %imprecision in rest part
% Instant_rest = tm-p_RC(phase_RC).datetime_ini<0;% negative = rest
% Urelax = mean(Um2(Instant_rest));
% Um2_polarization = Um2-Urelax; %
% 
% % Split rest and pulse voltages, currents and times
% Um2_rest = Um2(Instant_rest);
% Um2_pulse = Um2(~Instant_rest);
% Im_re = Im(Instant_rest);
% Im_pulse = Im(~Instant_rest);
% tm_re = tm(Instant_rest);
% tm_pulse = tm(~Instant_rest);
% DoD_re = DoDm(Instant_rest);
% DoD_pulse = DoDm(~Instant_rest);
% 
% %Rest
% [Um2_rest,Im_re,tm_re,DoD_re]=clean_data(Um2_rest,Im_re,tm_re,DoD_re);
% 
% 
% %Pulse
% [Um2_pulse,Im_pulse,tm_pulse,DoD_pulse]=clean_data(Um2_pulse,Im_pulse,tm_pulse,DoD_pulse);
% 
% %Rebuild:
% tm = [tm_re; tm_pulse];
% Um2 = [Um2_rest; Um2_pulse];
% Im = [Im_re; Im_pulse];
% DoDm=[DoD_re; DoD_pulse];
% 
% %Resort
% [tm,Instants_sorted] = sort(tm);
% Um2 = Um2(Instants_sorted);
% Im = Im(Instants_sorted);
% DoDm=DoDm(Instants_sorted);
% 
% 
% % Remove remaining spikes
% diff_Um2=diff(Um2);
% diff_Im=diff(Im);
% diff_tm=diff(tm);
% diff_DoDm=diff(DoDm);
% 
% Instant_rest = tm-p_RC(phase_RC).datetime_ini<0;% negative = rest
% 
% 
% end
% function [A_clean,B_clean,C_clean,D_clean]=clean_data(Reference_A,Reference_B,Additional_C,Additional_D)
% 
% X = Reference_A.^2+Reference_B.^2;
% distance = abs(X-mode(X));
% [distance_sorted,Instants_sorted] = sort(distance);
% nb = floor(0.95*length(distance));
% Instants_sorted = Instants_sorted(1:nb);
% A_clean = Reference_A(Instants_sorted);
% B_clean = Reference_B(Instants_sorted);
% C_clean = Additional_C(Instants_sorted);
% D_clean = Additional_D(Instants_sorted);
% 
% end

