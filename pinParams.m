function [params] = pinParams
% Generates parameters structure for pinDrift

% Physical constants
kB = 8.6173324e-5;    % Boltzmann constant [eV K^-1]
T = 300;              % Temperature [K]
epp0 = 552434;        % [e^2 eV^-1 cm^-1] -Checked (02-11-15)
q = 1;                % in e
e = 1.61917e-19;      % Charge of an electron in Coulombs for current calculations

% Device Dimensions [cm]
tp = 200e-7;         % p-type layer thickness
pp = 100;             % p-type layer points
ti = 400e-7;         % Intrinsic layer thickness
pii = 200;           % Intrinsic points
tn = 200e-7;         % n-type thickness
pn = 100;             % n-type points
tint = 5e-7;      % 0.5x Interfacial region thickness (x_mesh_type = 3)
pint = 40;         % 0.5x Interfacial points (x_mesh_type = 3)
tscr = 50e-7;
pscr = 100;
pepe = 20;           % electrode interface points
te = 10e-7;          % electrode interface thickness
deltax = tint/pint;    % spacing in the interfacial region- requires for mesh generation

% Parameters for spatial mesh of solution points - see meshgen_x for
% xmesh_type specification
xmesh_type = 4; 
xmax = tp + ti + tn;      % cm

if xmesh_type == 1 || xmesh_type == 5

    x0 = 0;

else
    
    x0 = xmax/1e3;

end

% General Parameters
OC = 1;                % Closed circuit = 0, Open Circuit = 1 
Int = 1;             % Bias Light intensity (Suns Eq.)
G0 = 2.5e21;           % Uniform generation rate @ 1 Sun
tmax = 1e0;         % Time
pulseon = 0;           % Switch pulse on TPC or TPV
Vapp = 0;              % Applied bias
BC = 1;                % Boundary Conditions. Must be set to one for first solution
figson = 1;            % Toggle figures on/off 
side = 1;              % illumination side 1 = EE, 2 = SE
calcJ = 0;             % Calculates Currents- slows down solving calcJ = 1, calculates DD currents at every position, calcJ = 2, calculates DD at boundary.
mobset = 1;            % Switch on/off electron hole mobility- MUST BE SET TO ZERO FOR INITIAL SOLUTION
mobseti = 0;           % Switch on/off ion mobility- MUST BE SET TO ZERO FOR INITIAL SOLUTION
JV = 0;

% OM = Optical Model 
% 0 = Uniform Generation 
% 1 = Beer-Lamber (Requires pre calculation using Igor code & gen profile in base workspace)
% 2 = Transfer Matrix (Stanford) Requires function TMPC1
OM  = 0;

% Parameters for time mesh
tpoints = 200;              % Number of time points
tmesh_type = 2;             % Mesh type- for use with meshgen_t
t0 = tmax/1e4;
deltat = tmax/(1e6*tpoints);

%%%%%%%% TRANSIENT SETTINGS %%%%%%%%
if pulseon == 1 && OC == 1        % Record length for TPV
    
    pulselen = 1e-6;       % Transient pulse length
    pulseint = 1e6;          % Transient pulse intensity- for BL and TM models, 100 mW/cm2 assumed
    pulsestart = 1e-7;     % Time before pulse- required for baseline
    tmesh_type = 3;
    tmax = 1000e-6;
    t0 = 0;
    tpoints = 400;
    deltat = tmax/(1e4*tpoints);

end    

if pulseon == 1 && OC == 0        % Record length for TPC
    
    pulselen = 1e-6;       % Transient pulse length
    pulseint = 0.2;            % Transient pulse intensity- for BL and TM models, 100 mW/cm2 assumed
    pulsestart = 1e-7;
    tmesh_type = 3;
    tmax = 100e-6;  
    t0 = 0;%tmax/1000;
    tpoints = 400;
    deltat = tmax/(1e4*tpoints);
    calcJ = 2;
    
end 

%%%%%%%%%% CURRENT VOLTAGE SCAN %%%%%%%%%%%%
% NOT 100% reliable- requires further development and investigation
Vstart = 0;
Vend = 1.1;
JVscan_pnts = 1000;

%%%%%%%%%%% MATERIAL PROPERTIES %%%%%%%%%%%%%%%%%%%%
if mobset == 0
   
    mue_i = 0;     % [Vcm-2s-1] electron mobility
    muh_i = 0;     % hole mobility
    mue_p = 0;
    muh_p = 0;
    mue_n = 0;
    muh_n = 0;
    
else
    
    mue_i = 1;          % electron mobility
    muh_i = mue_i;      % hole mobility
    mue_p = mue_i;
    muh_p = mue_i;
    mue_n = mue_i;
    muh_n = mue_i;
    
end

if mobseti == 0
        
    mui = 0;    % ion mobility
else 
        
    mui = 1e-8;    % ion mobility
end

eppp = 20*epp0;         % Dielectric constant p-type
eppi = 20*epp0;         % Dielectric constant intrinsic
eppn = 20*epp0;         % Dielectric constant n-type
 
% Energy levels
EA = 0;                          % Conduction band energy
IP = -1.6;                       % Valence band energy
PhiC = -0.15;                    % Cathode workfunction
PhiA = -1.45;                    % Anode workfunction
Eg = EA-IP;                      % Band Gap

% Effective density of states and doping concentration and band bending
N0 = 1e20;                      % effective Density Of States (eDOS) PVSK (Reenen, 2015) in Cal
ND = N0*exp((PhiC-EA)/(kB*T));  % Based on values for electride workfunctions - ensures self consistency                    
NA = N0*exp((IP-PhiA)/(kB*T));

%%%%% MOBILE ION DEFECT DENSITY %%%%%
NI = 1e19;                      % [cm-3]

% Intrinsic Fermi Energy
Ei = 0.5*((EA+IP)+kB*T*log(N0/N0));

% Charge Densities
ni = N0*(exp(-Eg/(2*kB*T)));          % Intrinsic carrier density
etln0 = N0*exp((PhiC-EA)/(kB*T));     % Background density electrons in etl/n-type
etlp0 = N0*exp((IP-PhiC)/(kB*T));     % Background density holes in etl/n-type
htln0 = N0*exp((PhiA-EA)/(kB*T));     % Background density electrons in htl/p-type
htlp0 = N0*exp((IP-PhiA)/(kB*T));     % Background density holes in htl/p-type

% Built in potential based on equilibrium Fermi energies of the conatct
% regions
Vbi = (kB*T/q)*log((ND*NA)/ni^2);

% This is a FUDGE at the moment- will only work for symmetric doping
% density... Not sure what the problem is here...

%%%%%%% RECOMBINATION %%%%%%%%%%%
% Linear recombination, U = k(n- ni)
% NOT BASED ON A PHYSICAL MODEL- USED FOR CHECKING TPV COEFFICIENTS
klin = 0;               % Coefficients for linear recombination
klincon = 0;

% Radiative recombanation, U = k(np - ni^2)
krad = 1e-12;           % [cm3 s-1] Bulk Radiative Recombination coefficient [nominally 1e-10]
kradetl = krad;         % [cm3 s-1] ETL Radiative Recombination coefficient 
kradhtl = krad;         % [cm3 s-1] HTL Radiative Recombination coefficient

% SRH recmobination in the contact regions, 
% U = (np-ni^2)/(taun(p+pt) +taup(n+nt))
taun_etl = 1e-9;         % [s] SRH time constant for electrons
taup_etl = taun_etl;    % [s] SRH time constant for holes
taun_htl = taun_etl;        %%%% USE a high value of (e.g.) 1 to switch off
taup_htl = taun_htl;    %%%% NOT 0- these variables are in the denominator
sn = 0;%1e7;            % [cm s-1] electron surface recombination velocity (rate constant for recombination at interface)
sp = 0;%sn;             % [cm s-1] hole surface recombination velocity (rate constant for recombination at interface)

% SRH parameters
% se = 1e-15;             % [cm^2] Electron capture cross-section
% v = 1e9;               % [cm/s] Carrier group velocity. Estimates from: http://www.tf.uni-kiel.de/matwis/amat/semi_en/kap_2/advanced/t2_3_1.html
Etetl = -0.8;            % ((EA-IP)/2+IP)-0.2;      % Deep trap energy- currently a guess!
Ethtl = -0.8;
ntetl = ni*exp((Etetl-Ei)/(kB*T));     % Density of CB electrons when Fermi level at trap state energy
ptetl = ni*exp((Ei-Etetl)/(kB*T));     % Density of VB holes when Fermi level at trap state energy
nthtl = ni*exp((Ethtl-Ei)/(kB*T));     % Density of CB electrons when Fermi level at trap state energy
pthtl = ni*exp((Ei-Ethtl)/(kB*T));     % Density of VB holes when Fermi level at trap state energy

% Define geometry of the system (m=0 1D, m=1 cylindrical polar coordinates,
% m=2 spherical polar coordinates).
m = 0;

% Space Charge Region- initial guess required with trial and error better
% than analytical solution
wp = 25e-7;  %((-ti*NA*q) + ((NA^0.5)*(q^0.5)*(((ti^2)*NA*q) + (4*eppi*Vbi))^0.5))/(2*NA*q);
wn = wp;

wscr = wp + ti + wn;    % width of space charge region

% Doped region Fermi levels
Efnside = - Vbi - EA + ((kB*T)/q) * log(ND/N0);
Efpside = - EA - Eg - ((kB*T)/q) * log(NA/N0);

%%%%%%%%%% CURRENT VOLTAGE SCAN %%%%%%%%%%%%
if JV == 1
    
    calcJ = 2;
    tmax = mue_i*1e2;           % Scan time determined by mobility- ensures cell is stable at each point
    t0 = 0;
    tmesh_type = 1;
    tpoints = JVscan_pnts;
    
end

% Parameters for adding and external resistance in series, like in CE
k_extr_ce=1e30; % big value, non physical
Rs=50; % resistance
area=1; % active area of the device
t_npoints_V_step=10; % how fast voltage drops in CE, in time points

% Pack parameters in to structure 'params'
varlist = who('*')';
varstr = strjoin(varlist, ',');

varcell = who('*')';                    % Store variables names in cell array
varcell = ['fieldnames', varcell];      % adhere to syntax for v2struct

params = v2struct(varcell);

end
