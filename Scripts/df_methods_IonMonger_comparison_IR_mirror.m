initialise_df

%% Read in base parameters
par_df_im = pc('Input_files/IonMonger_default_IR_mirror.csv');

%% Get equilibrium solutions
soleq_df_im = equilibrate(par_df_im);

%% Perform JV scan at 1.2 Vs-1
% For comparison with IonMonger default parameters
% sol_CV = doCV(sol_ini, light_intensity, V0, Vmax, Vmin, scan_rate, cycles, tpoints)
CV_df_50mVs_df = doCV(soleq_df_im.ion, 1.0398, 0, 1.2, 0, 50e-3, 1, 241);
CV_df_100mVs_df = doCV(soleq_df_im.ion, 1.0398, 0, 1.2, 0, 100e-3, 1, 241);
CV_df_200mVs_df = doCV(soleq_df_im.ion, 1.0398, 0, 1.2, 0, 200e-3, 1, 241);

%% CV plots
dfplot.JtotVapp(CV_df_50mVs_df, 0)
hold on
dfplot.JtotVapp(CV_df_100mVs_df, 0)
hold on
dfplot.JtotVapp(CV_df_200mVs_df, 0)
ylim([-10e-3,25e-3])
xlim([0, 1.1])
legend('50 mVs-1', '100 mVs-1', '200 mVs-1') 
hold off

