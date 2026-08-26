unit EPSimModel;
// -------------------------------------------------------
// Neuron simulation with normal and epileptiform activity
// -------------------------------------------------------
// 19.08.26 Spontaneous activity in brain slice now inhibiited when Vm < -83 mV

interface

uses
  System.SysUtils, System.Classes{, hodgkin_huxley_squid_axon_model_1952_unit}, math ;

const
    MaxDrugs = 100 ;
    MixingRate = 2000.0 ;
    Const _NB_OF_STATE_VARIABLES_ = 4;
type

  TDrug = record
          Name : String ;
          ShortName : String ;
          FinalBathConcentration : single ;
          BathConcentration : single ;
          EC50_GNa : Single ;
          EC50_GK : Single ;
          EC50_GCaL : Single ;
          EC50_GCaHVA : Single ;
          EC50_BetaADR : Single ;
          EC50_NaClosedState : Single ;
          EC50_GABAA : Single ;
          EC50_Glut : Single ;
          Antagonist : Boolean ;
          end ;

TIon = record
     CIn : Single ;
     COut : Single ;
     FinalCOut : Single ;
     Standard : Single ;
     New : Single ;
     G : Single ;
     GMAX : Single ;
     VRev : single ;
     I : Single ;
     m : single ;
     n : single ;
     h : single ;
     end ;

TStimulus = record
          On : Boolean ;
          Start : single ;
          Amplitude : single ;
          Duration : single ;
          Rate : single ;
          I : single ;
          NumStimDone : Integer ;
          end ;

   Thodgkin_huxley_squid_axon_model_1952 = Class
      Public
         //---------------------------------------------------------------------
         // State variables
         //---------------------------------------------------------------------

         Y: Array[0.._NB_OF_STATE_VARIABLES_-1] Of Double;
         dY: Array[0.._NB_OF_STATE_VARIABLES_-1] Of Double;
         // 0: V (millivolt) (in membrane)
         // 1: n (dimensionless) (in potassium_channel_n_gate)
         // 2: h (dimensionless) (in sodium_channel_h_gate)
         // 3: m (dimensionless) (in sodium_channel_m_gate)

         YNames: Array[0.._NB_OF_STATE_VARIABLES_-1] Of String;
         YUnits: Array[0.._NB_OF_STATE_VARIABLES_-1] Of String;
         YComponents: Array[0.._NB_OF_STATE_VARIABLES_-1] Of String;
         YDimensionless: Array[0.._NB_OF_STATE_VARIABLES_-1] Of Boolean ;

         //---------------------------------------------------------------------
         // Constants
         //---------------------------------------------------------------------

         g_L: Double;   // milliS_per_cm2 (in leakage_current)
         Cm: Double;   // microF_per_cm2 (in membrane)
         E_R: Double;   // millivolt (in membrane)
         g_K: Double;   // milliS_per_cm2 (in potassium_channel)
         g_Na: Double;   // milliS_per_cm2 (in sodium_channel)

         //---------------------------------------------------------------------
         // Computed variables
         //---------------------------------------------------------------------

         E_L: Double;   // millivolt (in leakage_current)
         i_L: Double;   // microA_per_cm2 (in leakage_current)
         i_Stim: Double;   // microA_per_cm2 (in membrane)
         alpha_n: Double;   // per_millisecond (in potassium_channel_n_gate)
         beta_n: Double;   // per_millisecond (in potassium_channel_n_gate)
         E_K: Double;   // millivolt (in potassium_channel)
         i_K: Double;   // microA_per_cm2 (in potassium_channel)
         alpha_h: Double;   // per_millisecond (in sodium_channel_h_gate)
         beta_h: Double;   // per_millisecond (in sodium_channel_h_gate)
         alpha_m: Double;   // per_millisecond (in sodium_channel_m_gate)
         beta_m: Double;   // per_millisecond (in sodium_channel_m_gate)
         E_Na: Double;   // millivolt (in sodium_channel)
         i_Na: Double;   // microA_per_cm2 (in sodium_channel)

         GNa_Available : Double ;
         GK_Available : Double ;
         GCaL_Available : Double ;
         BetaADR_Active : Double ;
         NaClosedStateR : Double ;

         //---------------------------------------------------------------------
         // Procedures
         //---------------------------------------------------------------------

         Procedure Init;
         Procedure Compute(Const time: Double);
         procedure UpdateStates( dt : double ) ;
   End;



  TModel = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

      Temperature : single ;
      rtf : single ;
      Length : single ;
      Radius : single ;
      Area : single ;
      cm : single ;
      c : single ;
      Noise : single ;
      Na : TIon ;
      K : TIon ;
      Cl : TIon ;
      Ca : TIon ;
      Mg : TIon ;
      DAP : TDrug ;
      TTX : TDrug ;
      LIG : TDrug ;
      Stim : TStimulus ;
      Vm : Single ;
      Im : Single ;
      GABA_Gmax : Single ;
      GABA_Vrev : Single ;
      GABA_I : Single ;
      Glut_Gmax : Single ;
      Glut_Vrev : Single ;
      Glut_I : Single ;

      t : double ;
      dt : double ;
      Step : Integer ;
      NumStepsPerDisplayPoint : Integer ;

    Drugs : Array[0..MaxDrugs-1] of TDrug ;    // Drug properties array
    NumDrugs : Integer ;                     // No. of drugs available
    GNa_Available : Single ;                // Fraction Na conductance unblocked
    GK_Available : Single ;                 // Fraction K Channels unblocked
    GCaL_Available : Single ;                 // Fraction Ca Channels unblocked
    GCaHVA_Available : Single ;             // Fraction high voltage activated Ca Channels available
    BetaADR_Active : single ;               // Fraction of beta adrenoceptors active
    NaClosedStateR : single ;         // Prolong Na channel closed state
    GABAAR : single ;                  // GABA A receptor activation (inhibitory)
    GlutR : single ;                  // Glutamate receptor activation (excitatory)
    GlutR_Tau : single ;
    GlutR_Epilepsy  : single ;

    hodgkin_huxley_squid_axon_model_1952 : Thodgkin_huxley_squid_axon_model_1952 ;

//    StimulusOn : Boolean ;
    EpilepticSeizure : Boolean ;     // TRUE = brain slice in epileptic state

    procedure Initialise ;
    procedure UpdateIonConcentrations ;
    procedure UpdateDrugConcentrations ;
    procedure DoNeuronStep( var States : Array of Single  ) ;

  end ;

var
  Model: TModel;

implementation


{$R *.dfm}


{%CLASSGROUP 'Vcl.Controls.TControl'}

procedure TModel.Initialise ;
// ----------------------------
// Initialise neuron simulation
// ----------------------------
var
    i : Integer ;
begin

     // Initialise all EC50's to inneffective
     for I := 0 to High(Drugs) do
         begin
         Drugs[i].EC50_GNa := 1E3 ;
         Drugs[i].EC50_GK := 1E3 ;
         Drugs[i].EC50_GCaL := 1E3 ;
         Drugs[i].EC50_GCaHVA := 1E3 ;
         Drugs[i].EC50_BetaADR := 1E3 ;
         Drugs[i].EC50_NaClosedState := 1E3 ;
         Drugs[i].EC50_GABAA := 1E3 ;
         Drugs[i].EC50_Glut := 1E3 ;
         end;

     NumDrugs := 0 ;

     Drugs[NumDrugs].Name := 'Phenytoin' ;
     Drugs[NumDrugs].ShortName := 'PHY' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_NaClosedState := 5E-5 ;
     Drugs[NumDrugs].Antagonist := False ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Sodium Valproate' ;
     Drugs[NumDrugs].ShortName := 'VAL' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_GABAA := 2E-3 ;
     Drugs[NumDrugs].EC50_NaClosedState := 1.7E-4 ;
     Drugs[NumDrugs].EC50_GCaHVA := 3E-3 ;
     Drugs[NumDrugs].Antagonist := False ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Lamotrigine' ;
     Drugs[NumDrugs].ShortName := 'LAM' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_NaClosedState := 5E-5 ;
     Drugs[NumDrugs].Antagonist := False ;
     Inc(NumDrugs) ;

  {   Drugs[NumDrugs].Name := 'Levetiracetam' ;
     Drugs[NumDrugs].ShortName := 'BNZ' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_GABAA := 1E-6 ;
     Drugs[NumDrugs].Antagonist := False ;
     Inc(NumDrugs) ;    }

     Drugs[NumDrugs].Name := 'Gabapentin' ;
     Drugs[NumDrugs].ShortName := 'GPN' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_GCaHVA := 4E-5 ;
     Drugs[NumDrugs].Antagonist := False ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Midazolam' ;
     Drugs[NumDrugs].ShortName := 'MDZ' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_GABAA := 1E-6 ;
     Drugs[NumDrugs].Antagonist := False ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Carbamazepine' ;
     Drugs[NumDrugs].ShortName := 'CBM' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_NaClosedState := 5E-5 ;
     Drugs[NumDrugs].Antagonist := False ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Topiramate' ;
     Drugs[NumDrugs].ShortName := 'TOP' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_NaClosedState := 1.5E-5 ;
     Drugs[NumDrugs].EC50_GCaHVA := 3E-4 ;
     Drugs[NumDrugs].EC50_GABAA := 2.5E-4 ;
     Drugs[NumDrugs].Antagonist := False ;
     Inc(NumDrugs) ;

     dt := 2E-5 ;

     { Define constant simulation parameters }
     Temperature := 20.0 ;
     rtf := 0.02354*(Temperature + 273.0)/273.0 ;
     Length := 50.0*1E-4 ;  { cm }
     Radius := 20.0*1E-4 ; { cm }
     Area := 2.*PI*Radius*Length ;
     Cm := 1E-6 ; {* Specific membrane capacity F/cm2 }
     C := Cm*Area ;

     { Define initial drug/ion concentrations }
     Na.Cin := 12. ;                  { Internal [Na] mM }
     Na.Cout := 145. ;
     Na.FinalCout := Na.Cout ;

     K.Cin := 140. ;         { Internal [K] mM }
     K.Cout := 5. ;
     K.FinalCout := K.Cout ;

     Cl.Cout := 110.0 ;
     Cl.Cin := 4.0 ;
     K.VRev := rtf * ln( K.Cout / K.Cin ) ;
     Vm := K.VRev ;              { Set resting potential to K reversal pot. }

     Ca.Cout := 2.0 ;
     Ca.Cin := 0.1 ;
     Ca.FinalCout := Ca.Cout ;

     Mg.Cout := 1. ;
     Stim.Amplitude := -2E-9 ;
     Stim.Duration := 1E-3 ;

     NumStepsPerDisplayPoint := 10 ;
     Step := 0 ;

     GlutR := 0.0 ;
     GlutR_Epilepsy := 0.0 ;
     GlutR_Tau := 1E-3 ;

     hodgkin_huxley_squid_axon_model_1952.Init ;
//            Cell.Na.Cin := hodgkin_huxley_squid_axon_model_1952.Y[15] ;{ Internal [Na] mM }
//            Cell.Na.Cout := hodgkin_huxley_squid_axon_model_1952.y[16] ;
//            Cell.K.Cin := hodgkin_huxley_squid_axon_model_1952.Y[13] ;         { Internal [K] mM }
//            Cell.K.Cout := hodgkin_huxley_squid_axon_model_1952.Y[14] ;
     Na.FinalCout := Na.Cout ;
     Na.Standard := Na.Cout ;

     K.FinalCout := K.Cout ;
     K.Standard := K.Cout ;

     Ca.FinalCout := Ca.Cout ;
     Ca.Standard := Ca.Cout ;

     Cl.Cout := 110.0 ;
     Cl.Cin := 4.0 ;

end ;


procedure TModel.UpdateIonConcentrations ;
// ---------------------------------
// Update ion concentrations in bath
// ---------------------------------
var
       dConc : Single ;
begin

    dConc := (Na.FinalCout - Na.Cout)*MixingRate*dt ;
    Na.Cout := Na.Cout + dConc ;
    Na.VRev := rtf * ln( Na.Cout / Na.Cin ) ;

    dConc := (K.FinalCout - K.Cout)*MixingRate*dt ;
    K.Cout := K.Cout + dConc ;
    K.VRev := rtf * ln( K.Cout / K.Cin ) ;

    dConc := (Ca.FinalCout - Ca.Cout)*MixingRate*dt ;
    Ca.Cout := Ca.Cout + dConc ;
    Ca.VRev := rtf * ln( Ca.Cout / Ca.Cin ) ;

    Cl.Cin := Cl.Cout / exp(-K.Vrev/rtf) + 1.0 ;
    Cl.VRev := -rtf * ln( Cl.Cout / Cl.Cin ) ;

    end ;

procedure TModel.UpdateDrugConcentrations ;
// ---------------------------------
// Update drug concentrations in bath
// ---------------------------------
var
       Sum,dConc,Occupancy,Efficacy : Single ;
       i : Integer ;
begin

    // Update drug bath concentrations
    for i := 0 to NumDrugs-1 do
         begin
         dConc := (Drugs[i].FinalBathConcentration - Drugs[i].BathConcentration)
                  *MixingRate*dt ;
         Drugs[i].BathConcentration := Drugs[i].BathConcentration + dConc ;
         end ;

    // Fraction of Na channels unblocked
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do
        begin
        Sum := Sum + (Drugs[i].BathConcentration/Drugs[i].EC50_GNa) ;
        end ;
    GNa_Available := 1.0 / (1.0 + Sum ) ;

    // Fraction of K channels unblocked
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do
        begin
        Sum := Sum + (Drugs[i].BathConcentration/Drugs[i].EC50_GK) ;
        end ;
    GK_Available := 1.0 / (1.0 + Sum ) ;

    // Fraction of CaL channels unblocked
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do
        begin
        Sum := Sum + (Drugs[i].BathConcentration/Drugs[i].EC50_GCaL) ;
        end ;
    GCaL_Available := 1.0 / (1.0 + Sum ) ;

    // Fraction of CaHVA channels available
    // Note. Availability can only be reduced by 50%
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do
        begin
        Sum := Sum + (Drugs[i].BathConcentration/Drugs[i].EC50_GCaHVA) ;
        end ;
    GCaHVA_Available := (1.0 / (1.0 + Sum )) ;

    // Beta-adrenoceptor activation
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do
        begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_BetaADR ;
        end ;
    Occupancy := Sum / ( 1. + Sum ) ;

    Efficacy := 0.0 ;
    for i := 0 to NumDrugs-1 do if not Drugs[i].Antagonist then
        begin
        Efficacy := Efficacy + Drugs[i].BathConcentration/Drugs[i].EC50_BetaADR ;
        end ;
    Efficacy := Efficacy / ( Sum + 0.001 ) ;
    BetaADR_Active :=  Efficacy*Occupancy ;

    // Fraction of Na channel closed states prolonged
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do
        begin
        Sum := Sum + (Drugs[i].BathConcentration/Drugs[i].EC50_NaClosedState) ;
        end ;
    NaClosedStateR := Sum / ( 1. + Sum ) ;

    // Fraction of GABA A receptors activated
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do
        begin
        Sum := Sum + (Drugs[i].BathConcentration/Drugs[i].EC50_GABAA) ;
        end ;
    GABAAR := Sum / ( 1. + Sum ) ;

    // Fraction of glutamate receptors activated
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do
        begin
        Sum := Sum + (Drugs[i].BathConcentration/Drugs[i].EC50_Glut) ;
        end ;
 //   GlutR := Sum / ( 1. + Sum ) ;

    end ;


procedure TModel.DataModuleCreate(Sender: TObject);
// ----------------------------------
// Initialisations when model created
// ----------------------------------
begin

   // Create HH action potential model and initialise it
   hodgkin_huxley_squid_axon_model_1952 := Thodgkin_huxley_squid_axon_model_1952.Create ;
   hodgkin_huxley_squid_axon_model_1952.Init ;

end;

procedure TModel.DataModuleDestroy(Sender: TObject);
// -----------------------------
// Tidy up when module destroyed
// -----------------------------
begin
     hodgkin_huxley_squid_axon_model_1952.free ;
end;

procedure TModel.DoNeuronStep(
              var States : Array of Single  ) ;
// ------------------------------
// Calculate next simulation step
// ------------------------------
var
     i : Integer ;
     ExcitatoryTransmitterRelease : double ;
     GlutR_Tau : single ;
begin

      for i := 1 to NumStepsPerDisplayPoint do
       begin

       { Direct neuron stimulation }
       if Stim.On then
          begin
          if t >= Stim.Start then Stim.I := Stim.Amplitude ;
          if t >= (Stim.Start + Stim.Duration) then
             begin
             Stim.I := 0. ;
             Stim.Start := Stim.Start + 1.0 / Stim.Rate ;
             end
          end
       else
          begin
          Stim.I := 0. ;
          Stim.Start := t ;
          end ;

       // Normal excitatory transmitter release from randomly occurring EPSPs in the absence of epileptic fit
       ExcitatoryTransmitterRelease := ((Ca.FinalCout/(Ca.FinalCout + 0.01))){*GCaHVA_Available} ;

       // If resting membrane potential more negative that -83 mV then spontaneous AP activity within netwok of neurons in brain slice is inhibited.
       // Currently disabled so students can see excitatory post-synaptic potentials.
       // if Vm < -83.0 then ExcitatoryTransmitterRelease := 0.0 ;

       if Random < 0.00005 then GlutR := GlutR + ExcitatoryTransmitterRelease*0.8 ;

       // Transmitter release kinetics
       // Epileptic state is simulated by prolonging transmitter release
       // Activation of GABA A receptors and stabilisation of Na channel closed state by AEDs inhibit prolongation
       GlutR_Tau := 1E-3 ;
       if EpilepticSeizure then
          begin
          GlutR_Tau :=  GlutR_Tau + 3E-2*GCaHVA_Available*(1.0-NaClosedStateR)*(1.0-GABAAR) ;
          end ;
       GlutR := Max(GlutR - (GlutR*dt)/GlutR_Tau,0.0) ;

       // Glutamate release due to epileptic activity
       GlutR_Epilepsy := (1.0 - 0.01)*GlutR_Epilepsy ;

       Vm := hodgkin_huxley_squid_axon_model_1952.Y[0] ;

       // GABA channel current (excitatory)
       GABA_Gmax := 1.0 ;
       GABA_Vrev := -90.0 ;
       GABA_I := GABA_GMax * ( Vm - GABA_Vrev ) * GABAAR ;

       // Glutamate channel current (inhibitory)
       Glut_Gmax := 0.7 ;
       Glut_Vrev := 0.0 ;
       Glut_I := Glut_GMax * ( Vm - Glut_Vrev ) * GlutR ;

       // Add currents to model
       hodgkin_huxley_squid_axon_model_1952.i_stim := (Stim.I*1E12) - GABA_I + -Glut_I ;

       hodgkin_huxley_squid_axon_model_1952.GNa_available := GNa_Available ;
       hodgkin_huxley_squid_axon_model_1952.GK_available := GK_Available ;
       hodgkin_huxley_squid_axon_model_1952.GCaL_available := GCaL_Available ;
       hodgkin_huxley_squid_axon_model_1952.BetaADR_Active := BetaADR_Active ;
       hodgkin_huxley_squid_axon_model_1952.NaClosedStateR := NaClosedStateR ;

           Inc(Step) ;
       t := t + dt ;
       hodgkin_huxley_squid_axon_model_1952.Compute(0.0) ;
       hodgkin_huxley_squid_axon_model_1952.UpdateStates(dt) ;

       end;

       States[0] := hodgkin_huxley_squid_axon_model_1952.Y[0] ;
       States[2] := hodgkin_huxley_squid_axon_model_1952.I_Na ;
       States[3] := hodgkin_huxley_squid_axon_model_1952.i_K ;
       States[1] := States[2] + States[3] ;

    end;


//------------------------------------------------------------------------------
// Initialisation
//------------------------------------------------------------------------------

Procedure Thodgkin_huxley_squid_axon_model_1952.Init;
var
    i : Integer ;
Begin
   //---------------------------------------------------------------------------
   // State variables
   //---------------------------------------------------------------------------

   Y[0] := -75.0;   // V (millivolt) (in membrane)
   Y[1] := 0.325;   // n (dimensionless) (in potassium_channel_n_gate)
   Y[2] := 0.6;   // h (dimensionless) (in sodium_channel_h_gate)
   Y[3] := 0.05;   // m (dimensionless) (in sodium_channel_m_gate)

   YNames[0] := 'V';
   YNames[1] := 'n';
   YNames[2] := 'h';
   YNames[3] := 'm';

   YUnits[0] := 'millivolt';
   YUnits[1] := 'dimensionless';
   YUnits[2] := 'dimensionless';
   YUnits[3] := 'dimensionless';

   YComponents[0] := 'membrane';
   YComponents[1] := 'potassium_channel_n_gate';
   YComponents[2] := 'sodium_channel_h_gate';
   YComponents[3] := 'sodium_channel_m_gate';

   for i := 0 to 3 do if YUnits[i] = 'dimensionless' then YDimensionless[i] := True
                                                     else YDimensionless[i] := False ;




   //---------------------------------------------------------------------------
   // Constants
   //---------------------------------------------------------------------------

   g_L := 0.3;   // milliS_per_cm2 (in leakage_current)
   Cm := 1.0;   // microF_per_cm2 (in membrane)
   E_R := -75.0;   // millivolt (in membrane)
   g_K := 36.0;   // milliS_per_cm2 (in potassium_channel)
   g_Na := 120.0;   // milliS_per_cm2 (in sodium_channel)

   //---------------------------------------------------------------------------
   // Computed variables
   //---------------------------------------------------------------------------

   E_L := E_R+10.613;
   E_Na := E_R+115.0;
   E_K := E_R-12.0;
End;

//------------------------------------------------------------------------------
// Computation
//------------------------------------------------------------------------------

Procedure Thodgkin_huxley_squid_axon_model_1952.Compute(Const time: Double);
Begin
   // time: time (millisecond)

   i_L := g_L*(Y[0]-E_L);

 {  If ((time >= 10.0) And (time <= 10.5)) Then
      i_Stim := 20.0
   Else
      i_Stim := 0.0;}

   i_Na := GNa_Available*g_Na*Power(Y[3], 3.0)*Y[2]*(Y[0]-E_Na);
   i_K := GK_Available*g_K*Power(Y[1], 4.0)*(Y[0]-E_K);
   dY[0] := -(-i_Stim+i_Na+i_K+i_L)/Cm;
   alpha_n := -0.01*(Y[0]+65.0)/(Exp(-(Y[0]+65.0)/10.0)-1.0);
   beta_n := 0.125*Exp((Y[0]+75.0)/80.0);
   dY[1] := alpha_n*(1.0-Y[1])-beta_n*Y[1];
   alpha_h := 0.07*Exp(-(Y[0]+75.0)/20.0);
   alpha_h :=alpha_h*(1.0 -(0.9*NaClosedStateR)) ;
   beta_h := 1.0/(Exp(-(Y[0]+45.0)/10.0)+1.0);
//   beta_h := beta_h*(1.0 -(0.9*NaClosedStateR)) ;

   dY[2] := alpha_h*(1.0-Y[2])-beta_h*Y[2];
   alpha_m := -0.1*(Y[0]+50.0)/(Exp(-(Y[0]+50.0)/10.0)-1.0);
   beta_m := 4.0*Exp(-(Y[0]+75.0)/18.0);
   dY[3] := alpha_m*(1.0-Y[3])-beta_m*Y[3];
End;

//------------------------------------------------------------------------------
procedure Thodgkin_huxley_squid_axon_model_1952.UpdateStates( dt : double ) ;
var
    i : Integer ;
    k1,k2,k3,k4 : Array[0.._NB_OF_STATE_VARIABLES_-1] Of Double;
    Y_k1,Y_k2,Y_k3 : Array[0.._NB_OF_STATE_VARIABLES_-1] Of Double;
begin

    // Note rates expressed /ms
    dt := dt*1E3 ;

    Compute(0.0) ;
    for i := 0 to _NB_OF_STATE_VARIABLES_-1 do k1[i] := dy[i]*dt ;
    for i := 0 to _NB_OF_STATE_VARIABLES_-1 do Y_k1[i] := Y[i] + k1[i]*0.5  ;

    Compute(0.0) ;
    for i := 0 to _NB_OF_STATE_VARIABLES_-1 do k2[i] := dy[i]*dt ;
    for i := 0 to _NB_OF_STATE_VARIABLES_-1 do Y_k2[i] := Y[i] + k2[i]*0.5  ;

    Compute(0.0) ;
    for i := 0 to _NB_OF_STATE_VARIABLES_-1 do k3[i] := dy[i]*dt ;
    for i := 0 to _NB_OF_STATE_VARIABLES_-1 do Y_k3[i] := Y[i] + k3[i]  ;

    Compute(0.0) ;
    for i := 0 to _NB_OF_STATE_VARIABLES_-1 do k4[i] := dy[i]*dt ;

    for i := 0 to _NB_OF_STATE_VARIABLES_-1 do Y[i] := Y[i] + k1[i]/6.0 + k2[i]/3.0 + k3[i]/3.0 + k4[i]/6.0 ;

    for i := 0 to _NB_OF_STATE_VARIABLES_-1 do if YDimensionless[i] then Y[i] := Min(Max(Y[i],0.0),1.0);

    end;



end.
