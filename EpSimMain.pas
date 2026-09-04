unit EpSimMain;
// ---------------------------------------------------
// Brin Slice Eplilepsy Simulation
// (c) J. Dempster, University of Strathclyde 2006-2026
// ----------------------------------------------------
// 26/02/06 V1.0
// 12/08/08 V1.1 Lignocaine name changed to Lidocaine
// 08/10/14 V1.2.1 Help file copied to local temp folder to allow opening when run from network folder
// 25.07.24 V1.2.2 Simulation code transferred to Model Data Unit
// 26.07.24 V2.0.0 FMX Multi-platform version
// 13.08.26 V2.0.1 FMX Multi-platform version completed
//                 Current stimulation option added
// 26.08.26        scDisplay.BestPrinterCalibrationBars now used to set clipboard/printer calibration bars.
// 04.09.26 V2.0.1 Both MacOS and Windows versions complete

interface

uses
  System.SysUtils, System.StrUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.Ani, FMX.TabControl,
  FMX.ListBox, FMX.EditBox, FMX.NumberBox,
  SESNumberBox, FMX.Objects, SESScopeDisplay, System.IOUtils, System.ANsiStrings,
  FMX.Menus, FMX.Platform, EpSimModel, FMX.Layouts, System.Actions, FMX.ActnList ;

const
    MaxPoints = 1000000 ;
    MaxChannels = 4 ;
    MaxDisplayPoints = 2000 ;
    MaxMarkers = 500 ;
    NumBytesPerMarker = 40 ;
    FileHeaderSize = (MaxMarkers+10)*NumBytesPerMarker ;
    DataFileExtension = '.EPS' ;

    MaxADCValue = 2047 ;
    MinADCValue = -2048 ;
    NoiseStDev = 10 ;
    MaxVm = 200.0 ;
    MaxIm = 1000.0 ;
    BackgroundNoiseStDev = 0.1 ;  // Background noise (gms)
    ScaleVtomV = 1000.0 ;
//    SecsToMsecs = 1000.0 ;


type

  TMainFrm = class(TForm)
    DisplayGrp: TGroupBox;
    V: TTabControl;
    ChartTab: TTabItem;
    ExperimentTab: TTabItem;
    ExpSetup: TImageControl;
    BitmapAnimation1: TBitmapAnimation;
    ControlsGrp: TGroupBox;
    ExperimentGrp: TGroupBox;
    bNewExperiment: TButton;
    StimulusGrp: TGroupBox;
    DrugsTab: TTabControl;
    AgonistTab: TTabItem;
    bStimulusOn: TButton;
    StyleBook1: TStyleBook;
    cbDrug: TComboBox;
    Label1: TLabel;
    bAddDrug: TButton;
    edDrugCOnc: TSESNumberBox;
    scDisplay: TScopeDisplay;
    TDisplayPanel: TPanel;
    edDisplayWindow: TSESNumberBox;
    edStartAt: TSESNumberBox;
    sbDisplay: TScrollBar;
    bDisplayWindowDouble: TButton;
    bDisplayWindowHalf: TButton;
    lbTDisplay: TLabel;
    lbStartTime: TLabel;
    Timer: TTimer;
    bRecord: TButton;
    bStop: TButton;
    MenuBar1: TMenuBar;
    mnFile: TMenuItem;
    mnNewExperiment: TMenuItem;
    mnLoadExperiment: TMenuItem;
    mnSaveExperiment: TMenuItem;
    mnEdit: TMenuItem;
    mnHelp: TMenuItem;
    mnPrint: TMenuItem;
    mnCopyData: TMenuItem;
    mnCopyImage: TMenuItem;
    mnExit: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    mnWebHelp: TMenuItem;
    edStimulusDuration: TSESNumberBox;
    edStimulusCurrent: TSESNumberBox;
    lbStimAmplitude: TLabel;
    lbStimDuration: TLabel;
    bRemoveDrugs: TButton;
    SaltSolutionPage: TTabControl;
    TabItem1: TTabItem;
    bLowCaSaltSolution: TButton;
    bStandardSaltSolution: TButton;
    GroupBox1: TGroupBox;
    rbEpilepsy: TRadioButton;
    rbNormal: TRadioButton;
    ckVm: TCheckBox;
    ckINa: TCheckBox;
    ckIm: TCheckBox;
    ckIK: TCheckBox;
    bStimulusOff: TButton;
    edStimulusRate: TSESNumberBox;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure bNewExperimentClick(Sender: TObject);
    procedure bStimulusOnClick(Sender: TObject);
    procedure bRecordClick(Sender: TObject);
    procedure bStopClick(Sender: TObject);
    procedure edDisplayWindowKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure bAddDrugClick(Sender: TObject);
    procedure scDisplayMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure mnExitClick(Sender: TObject);
    procedure mnCopyDataClick(Sender: TObject);
    procedure mnCopyImageClick(Sender: TObject);
    procedure mnNewExperimentClick(Sender: TObject);
    procedure mnLoadExperimentClick(Sender: TObject);
    procedure mnSaveExperimentClick(Sender: TObject);
    procedure mnContentsClick(Sender: TObject);
    procedure mnPrintClick(Sender: TObject);
    procedure bDisplayWindowHalfClick(Sender: TObject);
    procedure bDisplayWindowDoubleClick(Sender: TObject);
    procedure edStartAtKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure sbDisplayChange(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure mnWebHelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure bRemoveDrugsClick(Sender: TObject);
    procedure bLowCaSaltSolutionClick(Sender: TObject);
    procedure bStandardSaltSolutionClick(Sender: TObject);
    procedure rbNormalClick(Sender: TObject);
    procedure rbEpilepsyClick(Sender: TObject);
    procedure ckVmChange(Sender: TObject);
    procedure ckImChange(Sender: TObject);
    procedure ckINaChange(Sender: TObject);
    procedure ckIKChange(Sender: TObject);
    procedure bStimulusOffClick(Sender: TObject);
    procedure edStimulusRateKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure edStimulusDurationKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure edStimulusCurrentKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);

  private
    { Private declarations }

    ADC : Array[0..MaxPoints*MaxChannels-1] of SmallInt ;
    NumPointsInBuf : Integer ;   // No. of data points in buffer
    StartPoint : Integer ;
    NumPointsDisplayed : Integer ;
    TimerEventRunning : Boolean ;

    // Nerve stimulus
    MarkerList : TStringList ;   // Chart annotation list

    UnsavedData : Boolean ;  // Un-saved data flag

    ChangeDisplayWindow : Boolean ;
    ClearExperiment : Boolean ;
    VertCursor : Integer ;
    HorCursor : Integer ;

    HelpFilePath : string ;

    MarkerAddedToChart : Boolean ;

    procedure NewExperiment ;
    procedure EraseExperimentQuery( ModalQuery : Boolean ) ;

    procedure AddChartAnnotations ;
    procedure UpdateDisplay( var States : Array of Single ) ;
    procedure AddDrugMarker( ChartAnnotation : String ) ;
    procedure LoadFromFile( FileName : String ) ;
    procedure SaveToFile( FileName : String ) ;
    procedure StopSimulation ;
    procedure UpdateDisplayWindow ;

    procedure SetComboBoxFontSize(
              ComboBox : TComboBox ;           // Combo box
              FontSize : Integer ) ;           // Size of text


  public
    { Public declarations }
    TissueIndex : Integer ;      // Menu index of tissue type in use
//    InitialMixing : Cardinal ;

    procedure AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                           Keyword : string ;    // Key
                           Value : single        // Value
                           ) ; Overload ;

    procedure AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                           Keyword : string ;    // Key
                           Value : Integer        // Value
                           ) ; Overload ;

    procedure AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                           Keyword : string ;    // Key
                           Value : String        // Value
                           ) ; Overload ;

   function GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                         KeyWord : string ;   // Key
                         Value : single       // Value
                         ) : Single ; Overload ;        // Return value

   function GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                         KeyWord : string ;   // Key
                         Value : Integer       // Value
                         ) : Integer ; Overload ;        // Return value

   function GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                         KeyWord : string ;   // Key
                         Value : string       // Value
                         ) : string ; Overload ;        // Return value

  function ExtractFloat ( CBuf : string ; Default : Single ) : extended ;
  function ExtractInt ( CBuf : string ) : longint ;

  end;

var
  MainFrm: TMainFrm;

implementation

uses
{$IFDEF MSWINDOWS}
winapi.shellapi,winapi.windows,
{$ENDIF}
{$IFDEF POSIX}
Posix.Stdlib , Posix.Unistd,
{$ENDIF POSIX}
System.Math, FMX.DialogService, ModalBox ;

{$R *.fmx}




procedure TMainFrm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
// -------------------------------------------
// Check with user if program should be closed
// -------------------------------------------
begin
    if not UnSavedData then CanClose := True
    else
        begin
        ModalBoxFrm.Left := Self.Left + 10 ;
        ModalBoxFrm.Top := Self.Top + 10 ;
        ModalBoxFrm.Caption := 'Close Program' ;
        ModalBoxFrm.MessageText := 'Experiment not saved: Are you sure you want to close the program' ;
        if ModalBoxFrm.ShowModal = mrYes then CanClose := True
                                         else CanClose := False ;
        end;
end;


procedure TMainFrm.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
// ----------------------------
// Process key presses on form
// ----------------------------
begin
//
//   Left and right arrow keys used to move vertical cursor on display

     case key of
          VKLEFT : scDisplay.MoveActiveVerticalCursor(-1) ;
          VKRIGHT : scDisplay.MoveActiveVerticalCursor(1) ;
          end ;
end;


procedure TMainFrm.FormShow(Sender: TObject);
// ------------------------------------------------
// Initialise controls when form is first displayed
// ------------------------------------------------
var
    FileName : String ;
   HelpFileName,LocalHelpFilePath : string ;
   ch : Integer ;
begin

    Timer.Enabled := True ;

    // Find help file
     HelpFileName := 'epsim.chm' ;
     HelpFilePath := ExtractFilePath(ParamStr(0)) + HelpFileName ;
     LocalHelpFilePath := TPath.GetTempPath + HelpFileName ;

     // Create annotation list
     MarkerList := TStringList.Create ;

     { Setup chart display }
     scDisplay.MaxADCValue :=  MaxADCValue ;
     scDisplay.MinADCValue := MinADCValue ;
     scDisplay.DisplayGrid := True ;

     scDisplay.NumPoints := 0 ;
     scDisplay.XOffset := 0 ;
     scDisplay.NumChannels := MaxChannels ;

     { Membrane potential channel }
     ch := 0 ;
     scDisplay.ChanOffsets[ch] := ch ;
     scDisplay.ChanUnits[ch] := 'mV' ;
     scDisplay.ChanName[ch] := 'Vm' ;
     scDisplay.ChanScale[ch] := MaxVm / MaxADCValue ;
     scDisplay.yMin[ch] := MinADCValue ;
     scDisplay.yMax[ch] := (2*MaxADCValue) div 3 ;
     scDisplay.ChanVisible[ch] := True ;
     scDisplay.ChanNumSignals[ch] := 1 ;
     ckVm.Tag := ch ;
     ckVm.IsChecked := scDisplay.ChanVisible[ch] ;

     { Membrane current channel }
     ch := 1 ;
     scDisplay.ChanOffsets[ch] := ch ;
     scDisplay.ChanUnits[ch] := 'pA' ;
     scDisplay.ChanName[ch] := 'Im' ;
     scDisplay.ChanScale[ch] := (MaxIm) / MaxADCValue ;
     scDisplay.yMin[ch] := MinADCValue ;
     scDisplay.yMax[ch] := MaxADCValue ;
     scDisplay.ChanVisible[ch] := False ;
     scDisplay.ChanNumSignals[ch] := 1 ;
     ckIm.Tag := ch ;
     ckIm.IsChecked := scDisplay.ChanVisible[ch] ;

     { Na current channel }
     ch := 2 ;
     scDisplay.ChanOffsets[ch] := ch ;
     scDisplay.ChanUnits[ch] := 'pA' ;
     scDisplay.ChanName[ch] := 'I.Na' ;
     scDisplay.ChanScale[ch] := (MaxIm) / MaxADCValue ;
     scDisplay.yMin[ch] := MinADCValue ;
     scDisplay.yMax[ch] := MaxADCValue ;
     scDisplay.ChanVisible[ch] := False ;
     scDisplay.ChanNumSignals[ch] := 1 ;
     ckINa.Tag := ch ;
     ckINa.IsChecked := scDisplay.ChanVisible[ch] ;


     { K current channel }
     ch := 3 ;
     scDisplay.ChanOffsets[ch] := ch ;
     scDisplay.ChanUnits[ch] := 'pA' ;
     scDisplay.ChanName[ch] := 'I.K' ;
     scDisplay.ChanScale[ch] := (MaxIm) / MaxADCValue ;
     scDisplay.yMin[ch] := MinADCValue ;
     scDisplay.yMax[ch] := MaxADCValue ;
     scDisplay.ChanVisible[ch] := False ;
     scDisplay.ChanNumSignals[ch] := 1 ;
     ckIK.Tag := ch ;
     ckIK.IsChecked := scDisplay.ChanVisible[ch] ;


     scDisplay.TUnits := 's' ;
     edStartAt.Units := scDisplay.TUnits ;
     edDisplayWindow.Units := scDisplay.TUnits ;

     scDisplay.xMin := 0 ;
     scDisplay.xMax := scDisplay.MaxPoints-1 ;
     scDisplay.xOffset := 0 ;

     { Create a set of zero level cursors }
     scDisplay.ClearHorizontalCursors ;
     for ch  := 0 to scDisplay.NumChannels-1 do
        begin
        scDisplay.AddHorizontalCursor( ch, TAlphaColors.Red, True, '' ) ;
        scDisplay.HorizontalCursors[ch] := 0 ;
        end;

     // Vertical readout cursor
     scDisplay.ClearVerticalCursors ;
     scDisplay.AddVerticalCursor(-1,TAlphaColors.Green, 't0') ;
     scDisplay.AddVerticalCursor(-1,TAlphaColors.Green, '?t0?y') ;
     scDisplay.VerticalCursors[0] := scDisplay.MaxPoints div 20 ;
     scDisplay.VerticalCursors[1] := scDisplay.MaxPoints div 2 ;

     // Start new experiment
     NewExperiment ;

     scDisplay.TScale := Model.dt*Model.NumStepsPerDisplayPoint ;
     edDisplayWindow.Value := 5.0/edDisplayWindow.ValueScale ;
     UpdateDisplayWindow ;

     rbNormal.Ischecked := True ;
     Model.EpilepticSeizure := False ;

     // Load experiment if file name in parameter string
     FileName := ParamStr(1) ;
     if LowerCase(ExtractFileExt(FileName)) = '.nvs' then begin
        if FileExists(FileName) then LoadFromFile( FileName ) ;
        end ;

     Timer.Enabled := True ;
     ChangeDisplayWindow := False ;
     MarkerAddedToChart := False ;

     end;


procedure TMainFrm.SetComboBoxFontSize(
          ComboBox : TComboBox ;           // Combo box
          FontSize : Integer ) ;           // Size of text
// ----------------------------------------
// Set font size of items in combo box list
// ----------------------------------------
var
    i : Integer ;
begin
     for i := 0 to ComboBox.Items.Count -1 do
         begin
         ComboBox.ListBox.ListItems[i].TextSettings.Font.Size := FontSize ;
         ComboBox.ListBox.ListItems[i].StyledSettings := ComboBox.ListBox.ListItems[i].StyledSettings - [TStyledSetting.Size];
         end;
end;


procedure TMainFrm.NewExperiment ;
// ------------------------------------
// Start new experiment with new tissue
// ------------------------------------
var
    i,iKeep : Integer ;
begin

     // Initialise Nerve simulation model
     Model.Initialise ;

     // Create list of agonists
     iKeep := Max(cbDrug.ItemIndex,0) ;
     cbDrug.Clear ;
     for i := 0 to Model.NumDrugs-1 do
         cbDrug.Items.AddObject( Model.Drugs[i].Name, TObject(i)) ;
     cbDrug.ItemIndex := iKeep ;
     SetComboBoxFontSize( cbDrug, 13 ) ;

     { Clear buffer  }
     for i := 0 to MaxPoints*MaxChannels-1 do ADC[i] := 0 ;
     StartPoint :=  0 ;
     scDisplay.SetDataBuf( @ADC[StartPoint] ) ;

     scDisplay.XOffset := 0 ;
     NumPointsDisplayed := 0 ;
     NumPointsInBuf := 0 ;

     // Clear chart annotation
     MarkerList.Clear ;

     bRecord.Enabled := True ;
     bStop.Enabled := False ;

     sbDisplay.Max := scDisplay.MaxPoints ;
     sbDisplay.Enabled := False ;
     sbDisplay.Value := 0 ;

     UnSavedData := False ;
     ChangeDisplayWindow := True ;

     updateDisplayWindow ;

     end ;


procedure TMainFrm.rbEpilepsyClick(Sender: TObject);
// --------------------------------
// Epileptic brain slice selected
// --------------------------------
begin
    Model.EpilepticSeizure := True ;
    AddDrugMarker( 'Epileptic' ) ;
end;

procedure TMainFrm.rbNormalClick(Sender: TObject);
// -------------------------------------------
// Normal (non-epileptic) brain slice selected
// -------------------------------------------
begin
    Model.EpilepticSeizure := False ;
    AddDrugMarker( 'Normal' ) ;
end;


procedure TMainFrm.Action1Execute(Sender: TObject);
var
    OK : Boolean ;
begin

     if not UnsavedData then NewExperiment
     else
        begin

        ModalBoxFrm.Left := Self.Left + 10 ;
        ModalBoxFrm.Top := Self.Top + 10 ;
        ModalBoxFrm.Caption := 'New Experiment' ;
        ModalBoxFrm.MessageText := 'Experiment not saved: Are you sure you want to erase it?' ;
        ModalBoxFrm.Show ;

        if ModalBoxFrm.ShowModal = mrYes then OK := True
                                         else OK := False ;
        if OK then NewExperiment ;
        end;


     Log.d('action1');
end;

procedure TMainFrm.AddChartAnnotations ;
// -------------------------------------
// Add drug annotations to chart display
// -------------------------------------
var
    i : Integer ;
    MarkerPosition : Integer ;
begin

     scDisplay.ClearMarkers ;
     for i := 0 to MarkerList.Count-1 do
         begin
         MarkerPosition := Integer(MarkerList.Objects[i]) - scDisplay.XOffset ;
         if (MarkerPosition > 0) and (MarkerPosition < scDisplay.MaxPoints) then
            begin
            scDisplay.AddMarker( MarkerPosition, MarkerList.Strings[i] ) ;
            end ;
         end ;
     end ;


procedure TMainFrm.edStartAtKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
// ------------------------
// Start time - Key pressed
// ------------------------
begin
    if Key = 13 then
       begin
       scDisplay.XOffset := Round(edStartAt.Value) ;
       sbDisplay.Value := Round(edStartAt.Value) ;
       UpdateDisplayWindow ;
       end;

    end;



procedure TMainFrm.edStimulusCurrentKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
// ---------------------
// Stimulus amplitude changed
// ---------------------
begin

    if Key = 13 then Model.Stim.Amplitude := edStimulusCurrent.Value

end;


procedure TMainFrm.edStimulusDurationKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
// ---------------------
// Stimulus duration changed
// ---------------------
begin

    if Key = 13 then Model.Stim.Duration := edStimulusDuration.Value

end;


procedure TMainFrm.edStimulusRateKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
// ---------------------
// Stimulus rate changed
// ---------------------
begin

    if Key = 13 then
       begin
       Model.Stim.Rate := edStimulusRate.Value ;
       if Model.Stim.On then AddDrugMarker( format('%dHz',[Round(Model.Stim.Rate)]) ) ;
       end;

end;


procedure TMainFrm.edDisplayWindowKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
// ------------------------------
// Display duration - key pressed
// ------------------------------
begin
    if Key = 13 then
       begin
       UpdateDisplayWindow ;
       end;
    end;


procedure TMainFrm.UpdateDisplay( var States : Array of Single  ) ;
// -------------------
// Update chart display
// -------------------
var
    ch,i : Integer ;
begin

    if NumPointsInBuf >= MaxPoints then
       begin
       StopSimulation ;
       Exit ;
       end;

    i := NumPointsInBuf*MaxChannels ;
    for ch := 0 to MaxChannels-1 do
        begin
        ADC[i] := Round(States[ch]/scDisplay.ChanScale[ch]) ;
        Inc(i) ;
        end;
    Inc(NumPointsDisplayed) ;
    Inc(NumPointsInBuf) ;

    end ;


procedure TMainFrm.UpdateDisplayWindow ;
// ---------------------
// Update display window
// ---------------------
var
    MidPoint : Integer ;
begin

    scDisplay.MaxPoints := Round(edDisplayWindow.Value/(Model.dt*Model.NumStepsPerDisplayPoint));
    MidPoint := scDisplay.XOffset + (scDisplay.MaxPoints div 2) ;
    scDisplay.xMin := 0 ;
    scDisplay.xMax := scDisplay.MaxPoints-1 ;
    scDisplay.XOffset := Max(MidPoint - (scDisplay.MaxPoints div 2),0) ;

    sbDisplay.Value := scDisplay.XOffset ;
    scDisplay.SetDataBuf( @ADC[Round(sbDisplay.Value)*scDisplay.NumChannels] ) ;
    scDisplay.NumPoints := Min( scDisplay.MaxPoints, NumPointsInBuf - scDisplay.XOffset) ;
    scDisplay.VerticalCursors[0] := scDisplay.MaxPoints div 20 ;
    scDisplay.VerticalCursors[1] := scDisplay.MaxPoints div 2 ;

    sbDisplay.SmallChange := Max(scDisplay.MaxPoints div 100,1) ;
    sbDisplay.Max := Max(NumPointsInBuf - scDisplay.MaxPoints,2);
    edStartAt.Value := scDisplay.XOffset ;

    // Add annotations to chart
    AddChartAnnotations ;

    scDisplay.Repaint ;
    ChangeDisplayWindow := False ;

    end ;


procedure TMainFrm.ckIKChange(Sender: TObject);
// -------------------------
// IK channel display on/off
// --------------------------
begin
    scDisplay.ChanVisible[ckIK.Tag] := ckIK.Ischecked ;
    scDisplay.Repaint ;
end;


procedure TMainFrm.ckImChange(Sender: TObject);
// -------------------------
// Im channel display on/off
// --------------------------
begin
    scDisplay.ChanVisible[ckIm.Tag] := ckIm.Ischecked ;
    scDisplay.Repaint ;
end;


procedure TMainFrm.ckINaChange(Sender: TObject);
// -------------------------
// INa channel display on/off
// --------------------------
begin
    scDisplay.ChanVisible[ckINa.Tag] := ckINa.Ischecked ;
    scDisplay.Repaint ;
end;


procedure TMainFrm.ckVmChange(Sender: TObject);
// -------------------------
// Vm channel display on/off
// --------------------------
begin
    scDisplay.ChanVisible[ckVm.Tag] := ckVm.Ischecked ;
    scDisplay.Repaint ;
end;


procedure TMainFrm.TimerTimer(Sender: TObject);
// ---------------------
// Timed event scheduler
// ---------------------
var
    i,StartPoints : Integer ;
    States : Array[0..20] of Single ;
    NewPointsOnly : Boolean ;
begin

     if TimerEventRunning then Exit ;
     TimerEventRunning := True ;

     // Erase data and reinitialise for a new experiment
     // ------------------------------------------------
     if (ClearExperiment = True) and (ModalBoxFrm.OK = True) then
        begin
        NewExperiment ;
        ClearExperiment := False ;
        end;

     if not bRecord.Enabled then
        begin

//      Simulation running
//      ==================

        i := 0 ;
        repeat
          Model.UpdateIonConcentrations ;
          Model.UpdateDrugConcentrations ;
          Model.DoNeuronStep(States) ;
          UpdateDisplay(States) ;
          Inc(i) ;
          if (NumPointsDisplayed >= scDisplay.MaxPoints) then ChangeDisplayWindow := True ;
        until (i >= 150) or ChangeDisplayWindow ;

       if ChangeDisplayWindow then
          begin
          StartPoints := scDisplay.MaxPoints div 10 ;
          scDisplay.XOffset := Max( NumPointsInBuf - StartPoints, 0) ;
          sbDisplay.Max := sbDisplay.Max + scDisplay.MaxPoints ;
          NumPointsDisplayed := StartPoints ;
          sbDisplay.Value := scDisplay.XOffset ;
          scDisplay.NumPoints := NumPointsDisplayed - StartPoints ;
          scDisplay.SetDataBuf( @ADC[scDisplay.XOffset*scDisplay.NumChannels] ) ;
          // Add annotations to chart
          AddChartAnnotations ;
          scDisplay.Repaint ;
          ChangeDisplayWindow := False ;
          end
       else
          begin
          NewPointsOnly := not MarkerAddedToChart ;
          scDisplay.DisplayNewPoints( NumPointsInBuf - 1 - scDisplay.XOffset, NewPointsOnly ) ;
          MarkerAddedToChart := False ;
  //        scDisplay.Repaint ;
          end;

        if bStimulusOn.Enabled = Model.Stim.On then
           begin
           bStimulusOn.Enabled := not Model.Stim.On ;
           end;

        end
     else
        begin
        // Display

        if scDisplay.XOffset <> Round(sbDisplay.Value) then
           begin
           scDisplay.XOffset := Round(sbDisplay.Value);
           edStartAt.ValueScale := scDisplay.TScale ;
           edStartAt.Value := scDisplay.XOffset ;
           scDisplay.SetDataBuf( @ADC[Round(sbDisplay.Value)*scDisplay.NumChannels] ) ;
           scDisplay.NumPoints := Min( scDisplay.MaxPoints, NumPointsInBuf - Round(sbDisplay.Value) ) ;
           // Add annotations to chart
           AddChartAnnotations ;
           scDisplay.Repaint ;
           end ;
        end ;

     TimerEventRunning := False  ;

     end;


procedure TMainFrm.AddDrugMarker(
          ChartAnnotation : String
          ) ;
// ------------------------------
// Add drug addition/wash marker
// ------------------------------
begin
     if MarkerList.Count < MaxMarkers then
        begin
        ChartAnnotation := ReplaceStr( ChartAnnotation, '-00', '-' ) ;
        ChartAnnotation := ReplaceStr( ChartAnnotation, '00E', '0E' ) ;
        MarkerList.AddObject( ChartAnnotation, TObject(NumPointsInBuf) ) ;
        scDisplay.AddMarker( NumPointsInBuf - scDisplay.XOffset, ChartAnnotation ) ;
        MarkerAddedToChart := True ;
        end ;
     end ;


procedure TMainFrm.bAddDrugClick(Sender: TObject);
// --------------------------------------------
// Add volume of agonist stock solution to bath
// --------------------------------------------
var
    iDrug : Integer ;
    ChartAnnotation : String ;
begin

     iDrug :=  Integer(cbDrug.Items.Objects[cbDrug.ItemIndex]) ;
     Model.Drugs[iDrug].FinalBathConcentration :=Model.Drugs[iDrug].FinalBathConcentration + edDrugConc.Value ;

     // Add chart annotation
     ChartAnnotation := format('%s= %.3E M',
     [Model.Drugs[iDrug].ShortName,Model.Drugs[iDrug].FinalBathConcentration]) ;
     AddDrugMarker( ChartAnnotation ) ;

      end;


procedure TMainFrm.bRecordClick(Sender: TObject);
// ----------------
// Start simulation
// ----------------
begin
     bRecord.Enabled := False ;
     bStop.Enabled := True ;
     sbDisplay.Enabled := False ;
     bNewExperiment.Enabled := False ;
     bStimulusOn.Enabled := True ;

     UnSavedData := True ;

     NumPointsDisplayed := 0 ;
     sbDisplay.Max := sbDisplay.Max + scDisplay.MaxPoints ;
     sbDisplay.Value := NumPointsInBuf + 1 ;
     scDisplay.XOffset := Round(sbDisplay.Value) ;
     scDisplay.SetDataBuf( @ADC[Round(sbDisplay.Value)*scDisplay.NumChannels] ) ;
     sbDisplay.Max := sbDisplay.Max + scDisplay.MaxPoints ;

     // Add annotations to chart
     AddChartAnnotations ;

     UpdateDisplayWindow ;

     Model.Stim.Start := Model.dt*5 ;

     Model.EpilepticSeizure := rbEpilepsy.IsChecked ;

     end;


procedure TMainFrm.bRemoveDrugsClick(Sender: TObject);
// --------------------------
// Remove all drugs from bath
// --------------------------
var
    i : Integer ;
    ChartAnnotation : String ;
begin
     ChartAnnotation := '' ;
     for i := 0 to Model.NumDrugs-1 do
         begin
         if Model.Drugs[i].FinalBathConcentration > 0.0 then
            begin
            if ChartAnnotation <> '' then ChartAnnotation := ChartAnnotation + ', ' ;
            ChartAnnotation := ChartAnnotation + Model.Drugs[i].ShortName + '=0' ;
            end ;
         Model.Drugs[i].FinalBathConcentration := 0.0 ;
         end ;
     if ChartAnnotation <> '' then
        begin
        ChartAnnotation := ChartAnnotation + ' M' ;
        AddDrugMarker( ChartAnnotation ) ;
        end ;

     end;


procedure TMainFrm.bStimulusOnClick(Sender: TObject);
// --------------
// Start stimulus
// --------------
begin
     bStimulusOn.Enabled := False ;
     bStimulusOff.Enabled := True ;
     Model.Stim.On := True ;
     Model.Stim.Start := Model.t ;

     // Ensure units are visible on stimulus parameters boxes
     edStimulusDuration.Value := edStimulusDuration.Value ;
     edStimulusCurrent.Value := edStimulusCurrent.Value ;
     edStimulusRate.Value := edStimulusRate.Value ;
     Model.Stim.Duration := edStimulusDuration.Value ;
     Model.Stim.Amplitude := edStimulusCurrent.Value ;
     Model.Stim.Rate := edStimulusRate.Value ;

     AddDrugMarker( format('Stim %dHz',[Round(Model.Stim.Rate)]) ) ;

     end;


procedure TMainFrm.bStimulusOffClick(Sender: TObject);
// -------------
// Stop stimulus
// -------------
begin

     bStimulusOn.Enabled := True ;
     bStimulusOff.Enabled := False ;
     Model.Stim.On := False ;
     AddDrugMarker('Stim Off') ;

end;


procedure TMainFrm.bStopClick(Sender: TObject);
/// ----------------
// Stop simulation
// ----------------
begin

     StopSimulation ;

     end;


procedure TMainFrm.bDisplayWindowDoubleClick(Sender: TObject);
// --------------------------------------------
// Increase display time window duration by 25%
// --------------------------------------------
begin
    edDisplayWindow.Value := edDisplayWindow.Value*1.25 ;
    UpdateDisplayWindow ;
end;


procedure TMainFrm.bDisplayWindowHalfClick(Sender: TObject);
// ----------------------------------
// Reduce display time window by half
// -----------------------------------
begin
    edDisplayWindow.Value := edDisplayWindow.Value/1.25 ;
    UpdateDisplayWindow ;
end;


procedure TMainFrm.StopSimulation ;
// ----------------
// Stop simulation
// ----------------
begin

     bRecord.Enabled := True ;
     bStop.Enabled := False ;
     sbDisplay.Enabled := True ;
     bNewExperiment.Enabled := True ;
     bStimulusOn.Enabled := False ;
     UpdateDisplayWindow ;

     end;


procedure TMainFrm.bStandardSaltSolutionClick(Sender: TObject);
// -----------------------------------------------
// Change to standard salt solution in tissue bath
// -----------------------------------------------
begin

     Model.Ca.FinalCout := Model.Ca.Standard ;
     AddDrugMarker( 'Normal Ca soln.' ) ;

     end;




procedure TMainFrm.bNewExperimentClick(Sender: TObject);
// ---------------------
// Select new experiment
// ---------------------
begin
     EraseExperimentQuery( false ) ;
     end;


procedure TMainFrm.bLowCaSaltSolutionClick(Sender: TObject);
// --------------------------------------------------------
// Change concentration of ions in bath to low Ca / high Mg
// --------------------------------------------------------
begin

     Model.Ca.FinalCout := 1E-6 ;
     AddDrugMarker( 'Low Ca soln.' ) ;

     end;



procedure TMainFrm.EraseExperimentQuery( ModalQuery : Boolean ) ;
// -----------------------------------
// Query user to clear experiment data
// -----------------------------------
begin

     ClearExperiment := True ;
     if not UnSavedData then ModalBoxFrm.OK := True
     else
        begin
        ModalBoxFrm.Left := Self.Left + 10 ;
        ModalBoxFrm.Top := Self.Top + 10 ;
        ModalBoxFrm.Caption := 'New Experiment' ;
        ModalBoxFrm.MessageText := 'Experiment not saved: Are you sure you want to erase it?' ;
        if ModalQuery then ModalBoxFrm.ShowModal
                      else ModalBoxFrm.Show ;
        end ;

     if ModalBoxFrm.OK then NewExperiment ;

     Log.d('Eraseexperimentquery');

end;



procedure TMainFrm.SaveToFile(
          FileName : String
          ) ;
// ----------------------------
// Save chart recording to file
// ----------------------------
var
   ANSIHeaderBuf : array[0..FileHeaderSize] of ansichar ;
   Header : TStringList ;
   i,nBytes : Integer ;
   FileHandle : THandle ;
begin

     // Create file header Name=Value string list
     Header := TStringList.Create ;

     FileHandle := FileCreate( FileName ) ;
     if Integer(FileHandle) < 0 then Exit ;

     AddKeyValue( Header, 'NPOINTS', NumPointsInBuf ) ;

     AddKeyValue( Header, 'NMARKERS', MarkerList.Count ) ;
     for i := 0 to MarkerList.Count-1 do begin
         AddKeyValue( Header, format('MKP%d',[i]), Integer(MarkerList.Objects[i])) ;
         AddKeyValue( Header, format('MKT%d',[i]), MarkerList[i] ) ;
         end ;

     // Get ANSIstring copy of header text adn write to file
//     AnsiHeader := AnsiString(Header.Text) ;
     for i := 0 to Length(Header.Text)-1 do
         begin
         AnsiHeaderBuf[i] := ANSIChar(Header.Text[i+1]);
         end;
     AnsiHeaderBuf[Length(Header.Text)] := #0 ;

//     pAnsiHeader :=  Addr(AnsiHeader[1]);
     FileWrite( FileHandle, AnsiHeaderBuf, Length(Header.Text)) ;

     // Write chart data

     FileSeek( FileHandle, FileHeaderSize, 0 ) ;
     nBytes := Min( NumPointsInBuf*MaxChannels*SizeOf(SmallInt),SizeOf(ADC)) ;
     FileWrite( FileHandle, ADC, nBytes ) ;
     // Close file
     FileClose( FileHandle ) ;

     // Free header
     Header.Free ;

     UnSavedData := False ;
     end ;


procedure TMainFrm.sbDisplayChange(Sender: TObject);
// ---------------------------
// Scroll bar sosition changed
// ---------------------------
begin
    ChangeDisplayWindow := True ;
end;


procedure TMainFrm.scDisplayMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
// -------------------------------
// Mouse released on chart display
// -------------------------------
begin

     scDisplay.Repaint ;

end;

procedure TMainFrm.LoadFromFile(
          FileName : String
          ) ;
// ----------------------------
// Load chart recording from file
// ----------------------------
var
   AnsiHeaderBuf : Array[0..FileHeaderSize] of ANSIChar ;
   AnsiHeader : ANSIString ;
   Header : TStringList ;
   i,nBytes : Integer ;
   FileHandle : THandle ;
   NumMarkers : Integer ;
   MarkerPoint : Integer ;
   MarkerText : String ;
begin

     // Create file header Name=Value string list
     Header := TStringList.Create ;

     NumPointsInBuf := 0 ;
     FileHandle := FileOpen( FileName, fmOpenRead ) ;
     if NativeInt(FileHandle) < 0 then Exit ;

     // Read header
     FileSeek( FileHandle, 0, 0 ) ;
     FileRead(FileHandle, ANSIHeaderBuf, FileHeaderSize ) ;
     ANSIHeader := ANSIString( ANSIHeaderBuf ) ;
     Header.Text := String(ANSIHeader) ;

     // Erase existing experiment
     NewExperiment ;

     NumPointsInBuf := GetKeyValue( Header, 'NPOINTS', NumPointsInBuf ) ;

     // Load markers

     NumMarkers := 0 ;
     NumMarkers := GetKeyValue( Header, 'NMARKERS', NumMarkers ) ;
     MarkerList.Clear ;
     MarkerPoint := 0 ;
     for i := 0 to NumMarkers-1 do
         begin
         MarkerPoint := GetKeyValue( Header, format('MKPOINT%d',[i]), MarkerPoint ) ;
         MarkerPoint := GetKeyValue( Header, format('MKP%d',[i]), MarkerPoint) ;
         MarkerText := GetKeyValue( Header, format('MKTEXT%d',[i]), MarkerText ) ;
         MarkerText := GetKeyValue( Header, format('MKT%d',[i]), MarkerText ) ;
         MarkerList.AddObject( MarkerText, TObject(MarkerPoint)) ;
         end ;

     // Load data points

     if NumPointsInBuf > 0 then
        begin
        FileSeek( FileHandle, FileHeaderSize, 0 ) ;
        nBytes := Min( NumPointsInBuf*MaxChannels*SizeOf(SmallInt), SizeOf(ADC) ) ;
        FileRead( FileHandle, ADC,  nBytes ) ;
        end ;

     // Close data file
     FileClose( FileHandle ) ;

     Header.Free ;

     UnsavedData := False ;
     scDisplay.XOffset := 0 ;
     sbDisplay.Value := 0 ;
     sbDisplay.Max := NumPointsInBuf ;
     sbDisplay.Enabled := True ;

     UpdateDisplayWindow ;
     ChangeDisplayWindow := True ;

     end ;


procedure TMainFrm.mnCopyDataClick(Sender: TObject);
// -----------------------------
// Copy data points to clipboard
// -----------------------------
begin
    scDisplay.CopyDataToClipBoard ;
    end;


procedure TMainFrm.mnCopyImageClick(Sender: TObject);
// -----------------------------
// Copy image to clipboard
// -----------------------------
begin

    scDisplay.BestPrinterCalibrationBars(0.1) ;
    scDisplay.CopyImageToClipBoard ;

    end;


procedure TMainFrm.mnExitClick(Sender: TObject);
// ------------
// Stop Program
// ------------
begin
     Close ;
     end;


procedure TMainFrm.mnContentsClick(Sender: TObject);
// -----------------------
//  Help/Contents menu item
//  -----------------------
begin

    {$IFDEF MSWINDOWS}
     ShellExecute(0,'open', 'c:\windows\hh.exe',PChar(HelpFilePath), nil, SW_SHOWNORMAL) ;
    {$ENDIF}

     end;


procedure TMainFrm.mnLoadExperimentClick(Sender: TObject);
// -------------------------
// Load experiment from file
// -------------------------
begin

     EraseExperimentQuery( true ) ;

     if ModalBoxFrm.OK then
        begin

        OpenDialog.FileName := '' ;
        OpenDialog.DefaultExt := DataFileExtension ;
        OpenDialog.Filter := format( ' EpSim Expt. (*%s)|*%s',[DataFileExtension,DataFileExtension]) ;
        OpenDialog.Title := 'Load Experiment ' ;

       // Open selected data file
        if OpenDialog.execute then LoadFromFile( OpenDialog.FileName ) ;

        ModalBoxFrm.OK := False ;
        ClearExperiment := False ;
        end;

   end;


procedure TMainFrm.mnNewExperimentClick(Sender: TObject);
// ---------------------
// Select new experiment
// ---------------------
begin
     EraseExperimentQuery( false ) ;
     end;


procedure TMainFrm.mnPrintClick(Sender: TObject);
// ---------------------
// Print displayed trace
// ---------------------
begin

    scDisplay.BestPrinterCalibrationBars(0.1) ;
    scDisplay.Print ;

end;


procedure TMainFrm.mnSaveExperimentClick(Sender: TObject);
// -----------------------
// Save experiment to file
// -----------------------
begin

     { Present user with standard Save File dialog box }
//     SaveDialog.options := [ofHideReadOnly,ofPathMustExist] ;
     SaveDialog.FileName := '' ;
     SaveDialog.DefaultExt := DataFileExtension ;
     SaveDialog.Filter := format( '  EPSim Expt. (*%s)|*%s',[DataFileExtension,DataFileExtension]) ;
     SaveDialog.Title := 'Save Experiment' ;

     if SaveDialog.Execute then SaveToFile( SaveDialog.FileName ) ;

     end ;


procedure TMainFrm.mnWebHelpClick(Sender: TObject);
//
// Web Help - Wiki from GitHub repository
// --------------------------------------
var
  URL: string;
begin
  URL := 'https://github.com/johndempster/EPSimFMX/wiki';
{$IFDEF MSWINDOWS}
  URL := StringReplace(URL, '"', '%22', [rfReplaceAll]);
  ShellExecute(0, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL);
  {$ENDIF}

  {$IFDEF MACOS}
      _system(PAnsiChar('open ' + AnsiString(URL)));
    {$ENDIF}
end;



procedure TMainFrm.AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                                KeyWord : string ;    // Key
                                Value : single        // Value
                                 ) ;
// ---------------------
// Add Key=Single Value to List
// ---------------------
begin
     List.Add( Keyword + format('=%.4g',[Value]) ) ;
end;


procedure TMainFrm.AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                                KeyWord : string ;    // Key
                                Value : Integer        // Value
                                 ) ;
// ---------------------
// Add Key=Integer Value to List
// ---------------------
begin
     List.Add( Keyword + format('=%d',[Value]) ) ;
end;


procedure TMainFrm.AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                                KeyWord : string ;    // Key
                                Value : string        // Value
                                 ) ;
// ---------------------
// Add Key=string Value to List
// ---------------------
begin
     List.Add( Keyword + '=' + Value ) ;
end;


function TMainFrm.GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                               KeyWord : string ;   // Key
                               Value : single       // Value
                               ) : Single ;         // Return value
// ------------------------------
// Get Key=Single Value from List
// ------------------------------
var
    istart,idx : Integer ;
    s : string ;
begin

     idx := List.IndexOfName( Keyword ) ;
     if idx >= 0 then
        begin
        s := List[idx] ;
        // Find key=value separator and remove key
        istart := Pos( '=', s ) ;
        if istart > 0 then Delete( s, 1, istart ) ;
        Result := ExtractFloat( s, Value ) ;
        end
     else Result := Value ;

end;


function TMainFrm.GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                               KeyWord : string ;   // Key
                               Value : Integer       // Value
                               ) : Integer ;        // Return value
// ------------------------------
// Get Key=Integer Value from List
// ------------------------------
var
    istart,idx : Integer ;
    s : string ;
begin

     idx := List.IndexOfName( Keyword ) ;
     if idx >= 0 then
        begin
        s := List[idx] ;
        // Find key=value separator and remove key
        istart := Pos( '=', s ) ;
        if istart > 0 then Delete( s, 1, istart ) ;
        Result := STrToInt( s ) ;
        end
     else Result := Value ;

end;


function TMainFrm.GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                               KeyWord : string ;   // Key
                               Value : string       // Value
                               ) : string ;        // Return value
// ------------------------------
// Get Key=Integer Value from List
// ------------------------------
var
    istart,idx : Integer ;
    s : string ;
begin

      idx := List.IndexOfName( Keyword ) ;
     if idx >= 0 then
        begin
        s := List[idx] ;
        // Find key=value separator and remove key
        istart := Pos( '=', s ) ;
        if istart > 0 then Delete( s, 1, istart ) ;
        Result := s ;
        end
     else Result := Value ;

end;


function TMainFrm.ExtractFloat ( CBuf : string ; Default : Single ) : extended ;
{ Extract a floating point number from a string which
  may contain additional non-numeric text }

var CNum : string ;
i : SmallInt ;

begin
     CNum := ' ' ;
     for i := 1 to length(CBuf) do begin
         if CharInSet( CBuf[i], ['0'..'9', 'E', 'e', '+', '-', '.', ',' ] ) then
            CNum := CNum + CBuf[i]
         else CNum := CNum + ' ' ;
         end ;

     { Correct for use of comma/period as decimal separator }
     if (formatsettings.DECIMALSEPARATOR = '.') and (Pos(',',CNum) <> 0) then
        CNum[Pos(',',CNum)] := formatsettings.DECIMALSEPARATOR ;
     if (formatsettings.DECIMALSEPARATOR = ',') and (Pos('.',CNum) <> 0) then
        CNum[Pos('.',CNum)] := formatsettings.DECIMALSEPARATOR ;

     try
        ExtractFloat := StrToFloat( CNum ) ;
     except
        on E : EConvertError do ExtractFloat := Default ;
        end ;
     end ;

function TMainFrm.ExtractInt ( CBuf : string ) : longint ;
{ Extract a 32 bit integer number from a string which
  may contain additional non-numeric text }
Type
    TState = (RemoveLeadingWhiteSpace, ReadNumber) ;
var
   CNum : string ;
   i : integer ;
   Quit : Boolean ;
   State : TState ;

begin
     CNum := '' ;
     i := 1;
     Quit := False ;
     State := RemoveLeadingWhiteSpace ;
     while not Quit do begin

           case State of

           { Ignore all non-numeric ansicharacters before number }
           RemoveLeadingWhiteSpace : begin
               if CharInSet( CBuf[i], ['0'..'9','E','e','+','-','.'] ) then State := ReadNumber
                                                            else i := i + 1 ;
               end ;

           { Copy number into string CNum }
           ReadNumber : begin
                { End copying when a non-numeric ansicharacter
                or the end of the string is encountered }
                if CharInSet( CBuf[i], ['0'..'9','E','e','+','-','.'] ) then begin
                   CNum := CNum + CBuf[i] ;
                   i := i + 1 ;
                   end
                else Quit := True ;
                end ;
           else end ;

           if i > Length(CBuf) then Quit := True ;
           end ;
     try
        ExtractInt := StrToInt( CNum ) ;
     except
        ExtractInt := 1 ;
        end ;
     end ;





end.
