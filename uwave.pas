unit uwave;

interface

uses windows, classes, sysutils,  mmsystem;

const MAX_BUFFER_SIZE = 4*1024;
      PLAYBACK_BUFFER_SIZE=64*1024;

type
  UINT = LongWord;

  ESndError = class( Exception);

  TSoundObject=class(TObject)
  private
  protected
    FHandle:THandle;
  public
    procedure Open;virtual;abstract;
    procedure Close;virtual;abstract;
    procedure Start;virtual;abstract;
    procedure Stop;virtual;abstract;
  published
    property Handle:THandle read FHandle;
  end;

  TWaveObject=class(TSoundObject)
  private
    procedure SetupWaveFormat;
    procedure SetBitsPerSample(const Value: word);
    procedure SetChannel(const Value: word);
    procedure SetSamplePerSec(const Value: cardinal);
  protected
    FWaveFormat:TWaveFormatEx;

    procedure WaveProc(const handle:THandle;
                      const msg:UINT;
                      const dwInstance:cardinal;
                      const dwParam1,dwParam2:cardinal);virtual;abstract;
  public
    constructor Create;virtual;
  published
    property Channel:word read FWaveFormat.nChannels write SetChannel;
    property SamplePerSec:cardinal read FWaveFormat.nSamplesPerSec write SetSamplePerSec;
    property BitsPerSample:word read FWaveFormat.wBitsPerSample write SetBitsPerSample;
  end;


implementation     


{ TWaveObject }

constructor TWaveObject.Create;
begin
  FWaveFormat.nChannels:=1;
  FWaveFormat.nSamplesPerSec:=11025;
  FWaveFormat.wBitsPerSample:=8;
  SetupWaveFormat;
end;

procedure TWaveObject.SetBitsPerSample(const Value: word);
begin
  FWaveFormat.wBitsPerSample:=value;
  SetupWaveFormat;
end;

procedure TWaveObject.SetChannel(const Value: word);
begin
  FWaveFormat.nChannels:=value;
  SetupWaveFormat;
end;

procedure TWaveObject.SetSamplePerSec(const Value: cardinal);
begin
  FWaveFormat.nSamplesPerSec:=value;
  SetupWaveFormat;
end;

procedure TWaveObject.SetupWaveFormat;
begin
  with FWaveFormat do
  begin
    wFormatTag:=WAVE_FORMAT_PCM;
    nBlockAlign:=nChannels*wBitsPerSample div 8;
    nAvgBytesPerSec:=nSamplesPerSec*nBlockAlign;
    cbSize:=0;
  end;
end;

end.
