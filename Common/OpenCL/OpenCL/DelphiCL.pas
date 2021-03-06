(********************************************)
(*                                          *)
(*                DelphiCL                  *)
(*                                          *)
(*      created by      : Maksym Tymkovych  *)
(*                           (niello)       *)
(*                                          *)
(*      headers versions: 0.07              *)
(*      file name       : DelphiCL.pas      *)
(*      last modify     : 10.12.11          *)
(*      license         : BSD               *)
(*                                          *)
(*      Site            : www.niello.org.ua *)
(*      e-mail          : muxamed13@ukr.net *)
(*      ICQ             : 446-769-253       *)
(*                                          *)
(*********Copyright (c) niello 2008-2011*****)

unit DelphiCL;

interface

uses
  CL,
  Windows,
  SysUtils,
  CL_platform;

{$INCLUDE 'DelphiCL.inc'}
{define LOGGING}

{$IFDEF LOGGING}
var
  DCLFileLOG: TextFile;
  procedure WriteLog(const Str: AnsiString);
{$ENDIF}

type

  TDCLMemFlags = (mfReadWrite, mfWriteOnly, mfReadOnly, mfUseHostPtr, mfAllocHostPtr, mfCopyHostPtr);
  TDCLMemFlagsSet = set of TDCLMemFlags;

  TDCLBuffer = class
  private
    FMem: PCL_mem;
    FStatus: TCL_int;
    FSize: TSize_t;
  protected
    constructor Create(const Context: PCL_context; const Flags: TDCLMemFlagsSet; const Size: TSize_t; const Data: Pointer=nil);
  public
    procedure Free();
    property Size: TSize_t read FSize;
    property Status: TCL_int read FStatus;
  end;

  TDCLImage2D = class
  private
    FMem: PCL_mem;
    FStatus: TCL_int;
    FFormat: TCL_image_format;
    FWidth: TSize_t;
    FHeight: TSize_t;
    FRowPitch: TSize_t;
  protected
    constructor Create(const Context: PCL_context; const Flags: TDCLMemFlagsSet; const Format: PCL_image_format; const Width, Height: TSize_t; const RowPitch: TSize_t = 0; const Data: Pointer = nil);
  public
    procedure Free();
    property Width: TSize_t read FWidth;
    property Height: TSize_t read FHeight;
    property RowPitch: TSize_t read FRowPitch;
    property Status: TCL_int read FStatus;
  end;

  TDCLCommandQueueProperties = (cqpNone, cqpOutOfOrderExecModeEnable);
  TDCLCommandQueuePropertiesSet = set of TDCLCommandQueueProperties;

  TDCLKernel = class
  private
    FKernel: PCL_kernel;
    FStatus: TCL_int;
  protected
    constructor Create(const Program_: PCL_program; const KernelName: PAnsiChar);
    function GetFunctionName(): AnsiString;
    function GetNumArgs(): TCL_uint;
  public
    property Status: TCL_int read FStatus;
    property FunctionName: AnsiString read GetFunctionName;
    property NumArgs: TCL_uint read GetNumArgs;
    procedure SetArg(const Index: TCL_uint; const Size: TSize_t; const Value: Pointer); overload;
    procedure SetArg(const Index: TCL_uint; const Value: TDCLBuffer); overload;
    procedure SetArg(const Index: TCL_uint; const Value: TDCLImage2D); overload;
    procedure Free();
  end;

  TDCLCommandQueue = class
  private
    FCommandQueue: PCL_command_queue;
    FStatus: TCL_int;
    FProperties: TDCLCommandQueuePropertiesSet;
    {$IFDEF PROFILING}
    FExecuteTime: TCL_ulong;
    {$ENDIF}
    constructor Create(const Device_Id: PCL_device_id; const Context: PCL_context; const Properties: TDCLCommandQueuePropertiesSet = [cqpNone]);
  public
    procedure ReadBuffer(const Buffer: TDCLBuffer; const Size: TSize_t; const Data: Pointer);
    procedure WriteBuffer(const Buffer: TDCLBuffer; const Size: TSize_t; const Data: Pointer);
    procedure ReadImage2D(const Image: TDCLImage2D; const Width,Height: TSize_t; const Data: Pointer);
    procedure WriteImage2D(const Image: TDCLImage2D; const Width,Height: TSize_t; const Data: Pointer);
    procedure Execute(const Kernel: TDCLKernel; const Size: TSize_t); overload;
    procedure Execute(const Kernel: TDCLKernel; //const Device: PCL_device_id;
                      const Size: array of TSize_t);overload;
    property Status: TCL_int read FStatus;
    property Properties: TDCLCommandQueuePropertiesSet read FProperties;
    {$IFDEF PROFILING}
    property ExecuteTime: TCL_ulong read FExecuteTime;
    {$ENDIF}
    procedure Free();
  end;

  TArraySize_t = Array of TSize_t;
  TDCLProgram = class
  private
    FProgram: PCL_program;
    FStatus: TCL_int;
    FSource: PAnsiChar;
    FBinarySizesCount: TSize_t;
    FBinarySizes: TArraySize_t;
    //FBinaries: PByte;
  protected
    constructor Create(const Context: PCL_context; const Source: PPAnsiChar; const Options: PAnsiChar = nil);
    function GetBinarySizes(const Index: TSize_t): TSize_t;
  public
    property BinarySizes[const Index: TSize_t]: TSize_t read GetBinarySizes;
    property BinarySizesCount: TSize_t read FBinarySizesCount;
    property Source: PAnsiChar read FSource;
    property Status: TCL_int read FStatus;
    function CreateKernel(const KernelName: PAnsiChar): TDCLKernel;
    procedure Free();
  end;

  TDCLContext = class
  private
    FContext: PCL_context;
    FStatus: TCL_int;
    FNumDevices: TCL_uint;
  protected
    //property Context: PCL_context read FContext;
  public
    constructor Create(Device_id: PCL_device_id);
    property Status: TCL_int read FStatus;
    property NumDevices: TCL_uint read FNumDevices;
    procedure Free();
  end;

  TDCLDevice = class
  //private
    FDevice_id: PCL_device_id;
  private
    FStatus: TCL_int;

    FName: AnsiString;
    FVendor: AnsiString;
    FVersion: AnsiString;
    FProfile: AnsiString;

    FIsCPU: Boolean;
    FIsGPU: Boolean;
    FIsAccelerator: Boolean;
    FIsDefault: Boolean;

    FMaxWorkGroupSize: TSize_t;

    FNativeVectorPreferredChar: TCL_uint;
    FNativeVectorPreferredShort: TCL_uint;
    FNativeVectorPreferredInt: TCL_uint;
    FNativeVectorPreferredLong: TCL_uint;
    FNativeVectorPreferredFloat: TCL_uint;
    FNativeVectorPreferredDouble: TCL_uint;
    FNativeVectorPreferredHalf: TCL_uint;
    FNativeVectorWidthChar: TCL_uint;
    FNativeVectorWidthShort: TCL_uint;
    FNativeVectorWidthInt: TCL_uint;
    FNativeVectorWidthLong: TCL_uint;
    FNativeVectorWidthFloat: TCL_uint;
    FNativeVectorWidthDouble: TCL_uint;
    FNativeVectorWidthHalf: TCL_uint;

    FMaxClockFrequency: TCL_uint;
    FAddressBits: TCL_uint;
    FMaxMemAllocSize: TCL_ulong;

    FIsImageSupport: Boolean;

    FMaxReadImageArgs: TCL_uint;
    FMaxWriteImageArgs: TCL_uint;
    FImage2DMaxWidth: TSize_t;
    FImage2DMaxHeight: TSize_t;
    FImage3DMaxWidth: TSize_t;
    FImage3DMaxHeight: TSize_t;
    FImage3DMaxDepth: TSize_t;
    FMaxSamplers: TCL_uint;
    FMaxParameterSize: TSize_t;
    FMemBaseAddrAlign: TCL_uint;
    FMinDataTypeAlignSize: TCL_uint;

    FGlobalMemCacheLineSize: TCL_uint;
    FGlobalMemCacheSize: TCL_ulong;
    FGlobalMemSize: TCL_ulong;
    FMaxConstantBufferSize: TCL_ulong;
    FMaxConstantArgs: TCL_uint;

    FLocalMemSize: TCL_ulong;
    FIsErrorCorrectionSupport: Boolean;
    FIsHostUnifiedMemory: Boolean;
    FProfilingTimerResolution: TSize_t;
    FIsEndianLittle: Boolean;
    FIsAvailable: Boolean;
    FIsCompilerAvailable: Boolean;

    FVendorId: TCL_uint;
    FMaxComputeUnits: TCL_uint;
    FMaxWorkItemDimensions: TCL_uint;
    FExtensionsString: AnsiString;
    FOpenCLCVersion: AnsiString;
    FDriverVersion: AnsiString;

    FExtensionsCount: TSize_t;
    FExtensions: Array of AnsiString;

    FContext: TDCLContext;

    function GetExtensions(const Index: TSize_t): AnsiString;
    function IsPresentExtension(const ExtensionName: AnsiString): Boolean;
  protected
    constructor Create(Device_id: PCL_device_id);
    property Device_id: PCL_device_id read FDevice_id;
  public
    property Status: TCL_int read FStatus;

    property Name: AnsiString read FName;
    property Vendor: AnsiString read FVendor;
    property Version: AnsiString read FVersion;
    property Profile: AnsiString read FProfile;

    property IsCPU: Boolean read FIsCPU;
    property IsGPU: Boolean read FIsGPU;
    property IsAccelerator: Boolean read FIsAccelerator;
    property IsDefault: Boolean read FIsDefault;

    property MaxWorkGroupSize: TSize_t read FMaxWorkGroupSize;

    property NativeVectorPreferredChar: TCL_uint read FNativeVectorPreferredChar;
    property NativeVectorPreferredShort: TCL_uint read FNativeVectorPreferredShort;
    property NativeVectorPreferredInt: TCL_uint read FNativeVectorPreferredInt;
    property NativeVectorPreferredLong: TCL_uint read FNativeVectorPreferredLong;
    property NativeVectorPreferredFloat: TCL_uint read FNativeVectorPreferredFloat;
    property NativeVectorPreferredDouble: TCL_uint read FNativeVectorPreferredDouble;
    property NativeVectorPreferredHalf: TCL_uint read FNativeVectorPreferredHalf;
    property NativeVectorWidthChar: TCL_uint read FNativeVectorWidthChar;
    property NativeVectorWidthShort: TCL_uint read FNativeVectorWidthShort;
    property NativeVectorWidthInt: TCL_uint read FNativeVectorWidthInt;
    property NativeVectorWidthLong: TCL_uint read FNativeVectorWidthLong;
    property NativeVectorWidthFloat: TCL_uint read FNativeVectorWidthFloat;
    property NativeVectorWidthDouble: TCL_uint read FNativeVectorWidthDouble;
    property NativeVectorWidthHalf: TCL_uint read FNativeVectorWidthHalf;

    property MaxClockFrequency: TCL_uint  read FMaxClockFrequency;
    property AddressBits: TCL_uint  read FAddressBits;
    property MaxMemAllocSize: TCL_ulong  read FMaxMemAllocSize;

    property IsImageSupport: Boolean read FIsImageSupport;

    property MaxReadImageArgs: TCL_uint read FMaxReadImageArgs;
    property MaxWriteImageArgs: TCL_uint read FMaxWriteImageArgs;
    property Image2DMaxWidth: TSize_t read FImage2DMaxWidth;
    property Image2DMaxHeight: TSize_t read FImage2DMaxHeight;
    property Image3DMaxWidth: TSize_t read FImage3DMaxWidth;
    property Image3DMaxHeight: TSize_t read FImage3DMaxHeight;
    property Image3DMaxDepth: TSize_t read FImage3DMaxDepth;
    property MaxSamplers: TCL_uint read FMaxSamplers;
    property MaxParameterSize: TSize_t read FMaxParameterSize;
    property MemBaseAddrAlign: TCL_uint read FMemBaseAddrAlign;
    property MinDataTypeAlignSize: TCL_uint read FMinDataTypeAlignSize;

    property GlobalMemCacheLineSize: TCL_uint read FGlobalMemCacheLineSize;
    property GlobalMemCacheSize: TCL_ulong read FGlobalMemCacheSize;
    property GlobalMemSize: TCL_ulong read FGlobalMemSize;
    property MaxConstantBufferSize: TCL_ulong read FMaxConstantBufferSize;
    property MaxConstantArgs: TCL_uint read FMaxConstantArgs;

    property LocalMemSize: TCL_ulong read FLocalMemSize;
    property IsErrorCorrectionSupport: Boolean read FIsErrorCorrectionSupport;
    property IsHostUnifiedMemory: Boolean read FIsHostUnifiedMemory;
    property ProfilingTimerResolution: TSize_t read FProfilingTimerResolution;
    property IsEndianLittle: Boolean read FIsEndianLittle;
    property IsAvailable: Boolean read FIsAvailable;
    property IsCompilerAvailable: Boolean read FIsCompilerAvailable;

    property VendorId: TCL_uint read FVendorId;
    property MaxComputeUnits: TCL_uint read FMaxComputeUnits;
    property MaxWorkItemDimensions: TCL_uint read FMaxWorkItemDimensions;

    property DriverVersion: AnsiString read FDriverVersion;
    property OpenCLCVersion: AnsiString read FOpenCLCVersion;
    property ExtensionsString: AnsiString read FExtensionsString;

    property Context: TDCLContext read FContext;
    function CreateContext(): TDCLContext;
    function CreateCommandQueue(const properties: TDCLCommandQueuePropertiesSet = [cqpNone]): TDCLCommandQueue;
    function CreateBuffer(const Size: TSize_t; const Data: Pointer = nil; const flags: TDCLMemFlagsSet = [mfReadWrite]): TDCLBuffer;
    function CreateImage2D(const Format: PCL_image_format; const Width,Height,RowPitch: TSize_t; const Data: Pointer = nil; const flags: TDCLMemFlagsSet = [mfReadWrite]): TDCLImage2D;
    function CreateProgram(const Source: PPAnsiChar; const Options: PAnsiChar = nil): TDCLProgram; overload;
    function CreateProgram(const FileName: String; const Options: PAnsiChar = nil): TDCLProgram; overload;

    property ExtensionsCount: TSize_t read FExtensionsCount;
    property Extensions[const Index: TSize_t]: AnsiString read GetExtensions;
    property IsSupportedExtension[const Index: AnsiString]: Boolean read IsPresentExtension;
    procedure Free();
  end;

  TDCLPlatform = class
  private
    FPlatform_id: PCL_platform_id;
    FProfile: AnsiString;
    FVersion: AnsiString;
    FName: AnsiString;
    FVendor: AnsiString;
    FExtensionsString: AnsiString;
    FStatus: TCL_int;
    FDevices: Array of TDCLDevice;
    FDeviceCount: TCL_uint;
    FExtensionsCount: TSize_t;
    FExtensions: Array of AnsiString;
    function GetDevice(Index: TCL_uint): TDCLDevice;
    function GetExtensions(Index: TSize_t): AnsiString;
    function IsPresentExtension(const ExtensionName: AnsiString): Boolean;

    function GetDeviceWithMaxClockFrequency(): TDCLDevice;
    function GetDeviceWithMaxComputeUnits(): TDCLDevice;

    function GetDeviceWithMaxGlobalMemCacheLineSize(): TDCLDevice;
    function GetDeviceWithMaxGlobalMemCacheSize(): TDCLDevice;
    function GetDeviceWithMaxGlobalMemSize(): TDCLDevice;

    function GetDeviceWithMaxImage2DWidth(): TDCLDevice;
    function GetDeviceWithMaxImage2DHeight(): TDCLDevice;
    function GetDeviceWithMaxImage3DWidth(): TDCLDevice;
    function GetDeviceWithMaxImage3DHeight(): TDCLDevice;
    function GetDeviceWithMaxImage3DDepth(): TDCLDevice;

    function GetDeviceWithMaxLocalMemSize(): TDCLDevice;
    function GetDeviceWithMaxConstantArgs(): TDCLDevice;
    function GetDeviceWithMaxConstantBufferSize(): TDCLDevice;
    function GetDeviceWithMaxMemAllocSize(): TDCLDevice;
    function GetDeviceWithMaxParameterSize(): TDCLDevice;
    function GetDeviceWithMaxReadImageArgs(): TDCLDevice;
    function GetDeviceWithMaxSamplers(): TDCLDevice;
    function GetDeviceWithMaxWorkGroupSize(): TDCLDevice;
    function GetDeviceWithMaxWorkItemDimensions(): TDCLDevice;
    function GetDeviceWithMaxWriteImageArgs(): TDCLDevice;
  public
    constructor Create(Platform_id: PCL_platform_id);
    property Profile: AnsiString read FProfile;
    property Version: AnsiString read FVersion;
    property Name: AnsiString read FName;
    property Vendor: AnsiString read FVendor;
    property ExtensionsString: AnsiString read FExtensionsString;

    property DeviceCount: TCL_uint read FDeviceCount;
    property Status: TCL_int read FStatus;
    property Devices[Index: TCL_uint]: TDCLDevice read GetDevice;
    property ExtensionsCount: TSize_t read FExtensionsCount;
    property Extensions[Index: TSize_t]: AnsiString read GetExtensions;
    property IsSupportedExtension[const Index: AnsiString]: Boolean read IsPresentExtension;

    property DeviceWithMaxClockFrequency: TDCLDevice read GetDeviceWithMaxClockFrequency;
    property DeviceWithMaxComputeUnits: TDCLDevice read GetDeviceWithMaxComputeUnits;
    property DeviceWithMaxGlobalMemCacheLineSize: TDCLDevice read GetDeviceWithMaxGlobalMemCacheLineSize;
    property DeviceWithMaxGlobalMemCacheSize: TDCLDevice read GetDeviceWithMaxGlobalMemCacheSize;
    property DeviceWithMaxGlobalMemSize: TDCLDevice read GetDeviceWithMaxGlobalMemSize;
    property DeviceWithMaxImage2DWidth: TDCLDevice read GetDeviceWithMaxImage2DWidth;
    property DeviceWithMaxImage2DHeight: TDCLDevice read GetDeviceWithMaxImage2DHeight;
    property DeviceWithMaxImage3DWidth: TDCLDevice read GetDeviceWithMaxImage3DWidth;
    property DeviceWithMaxImage3DHeight: TDCLDevice read GetDeviceWithMaxImage3DHeight;
    property DeviceWithMaxImage3DDepth: TDCLDevice read GetDeviceWithMaxImage3DDepth;
    property DeviceWithMaxLocalMemSize: TDCLDevice read GetDeviceWithMaxLocalMemSize;
    property DeviceWithMaxConstantArgs: TDCLDevice read GetDeviceWithMaxConstantArgs;
    property DeviceWithMaxConstantBufferSize: TDCLDevice read GetDeviceWithMaxConstantBufferSize;
    property DeviceWithMaxMemAllocSize: TDCLDevice read GetDeviceWithMaxMemAllocSize;
    property DeviceWithMaxParameterSize: TDCLDevice read GetDeviceWithMaxParameterSize;
    property DeviceWithMaxReadImageArgs: TDCLDevice read GetDeviceWithMaxReadImageArgs;
    property DeviceWithMaxSamplers: TDCLDevice read GetDeviceWithMaxSamplers;
    property DeviceWithMaxWorkGroupSize: TDCLDevice read GetDeviceWithMaxWorkGroupSize;
    property DeviceWithMaxWorkItemDimensions: TDCLDevice read GetDeviceWithMaxWorkItemDimensions;
    property DeviceWithMaxWriteImageArgs: TDCLDevice read GetDeviceWithMaxWriteImageArgs;
    procedure Free();
  end;

  TDCLPlatforms = class
  private
    FPlatforms: Array of TDCLPlatform;
    FPlatformCount: TCL_uint;
    FStatus: TCL_int;
    function GetPlatform(Index: TCL_uint): TDCLPlatform;
  public
    constructor Create();
    property PlatformCount: TCL_uint read FPlatformCount;
    property Status: TCL_int read FStatus;
    property Platforms[Index: TCL_uint]: TDCLPlatform read GetPlatform;
    procedure Free();
  end;

implementation

function UpperCase(const S: AnsiString): AnsiString;
var
  Ch: AnsiChar;
  L: Integer;
  Source, Dest: PAnsiChar;
begin
  L := Length(S);
  SetLength(Result, L);
  Source := Pointer(S);
  Dest := Pointer(Result);
  while L <> 0 do
  begin
    Ch := Source^;
    if (Ch >= 'a') and (Ch <= 'z') then Dec(Ch, 32);
    Dest^ := Ch;
    Inc(Source);
    Inc(Dest);
    Dec(L);
  end;
end;

function IntToStr( Value : Integer ) : AnsiString;
begin
  Str( Value, Result );
end;

{$IFDEF LOGGING}
  procedure WriteLog(const Str: AnsiString);
  begin
    Writeln(DCLFileLOG,Str);
    Flush(DCLFileLOG);
  end;
{$ENDIF}

{ TDCLPlatforms }

constructor TDCLPlatforms.Create;
var
  platforms: Array of PCL_platform_id;
  i: integer;
begin
  FStatus := clGetPlatformIDs(0,nil,@FPlatformCount);
  {$IFDEF LOGGING}
    WriteLog('clGetPlatformIDs: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('PlatformCount: '+IntToStr(FPlatformCount)+';');
  {$ENDIF}
  if FStatus=CL_SUCCESS then
  begin
    if FPlatformCount>0 then
    begin
      SetLength(platforms,FPlatformCount);
      SetLength(FPlatforms,FPlatformCount);
      FStatus := clGetPlatformIDs(FPlatformCount,@platforms[0],nil);
      {$IFDEF LOGGING}
        WriteLog('clGetPlatformIDs: '+GetString(FStatus)+';');
      {$ENDIF}
      for i:=0 to FPlatformCount-1 do
      begin
        FPlatforms[i] := TDCLPlatform.Create(platforms[i]);
      end;
      SetLength(platforms,0);
    end;
  end;
end;

procedure TDCLPlatforms.Free;
var
  i: Integer;
begin
  for i:=0 to FPlatformCount-1 do
  begin
    FPlatforms[i].Free();
  end;
  SetLength(FPlatforms,0);
  inherited Free();
end;

function TDCLPlatforms.GetPlatform(Index: TCL_uint): TDCLPlatform;
begin
  if (Index<FPlatformCount)then Result := FPlatforms[Index]
  else Result := nil;
end;

{ TDCLPlatform }

constructor TDCLPlatform.Create(Platform_id: PCL_platform_id);
var
  Size: TSize_t;
  devices: Array of PCL_device_id;
  i, current, previous: integer;

begin
  inherited Create();
  FPlatform_id := Platform_id;

  FStatus := clGetPlatformInfo(FPlatform_id,CL_PLATFORM_PROFILE,0,nil,@Size);
  {$IFDEF LOGGING}
    WriteLog('clGetPlatformInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  SetLength(FProfile,Size);
  FStatus := clGetPlatformInfo(FPlatform_id,CL_PLATFORM_PROFILE,Size,@FProfile[1],nil);
  {$IFDEF LOGGING}
    WriteLog('clGetPlatformInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_PLATFORM_PROFILE: '+FProfile+';');
  {$ENDIF}
  //FProfile := Buffer;

  FStatus := clGetPlatformInfo(FPlatform_id,CL_PLATFORM_VERSION,0,nil,@Size);
  {$IFDEF LOGGING}
    WriteLog('clGetPlatformInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  SetLength(FVersion,Size);
  FStatus := clGetPlatformInfo(FPlatform_id,CL_PLATFORM_VERSION,Size,@FVersion[1],nil);
  {$IFDEF LOGGING}
    WriteLog('clGetPlatformInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_PLATFORM_VERSION: '+FVersion+';');
  {$ENDIF}

  FStatus := clGetPlatformInfo(FPlatform_id,CL_PLATFORM_NAME,0,nil,@Size);
  {$IFDEF LOGGING}
    WriteLog('clGetPlatformInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  SetLength(FName,Size);
  FStatus := clGetPlatformInfo(FPlatform_id,CL_PLATFORM_NAME,Size,@FName[1],nil);
  {$IFDEF LOGGING}
    WriteLog('clGetPlatformInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_PLATFORM_NAME: '+FName+';');
  {$ENDIF}

  FStatus := clGetPlatformInfo(FPlatform_id,CL_PLATFORM_VENDOR,0,nil,@Size);
  {$IFDEF LOGGING}
    WriteLog('clGetPlatformInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  SetLength(FVendor,Size);
  FStatus := clGetPlatformInfo(FPlatform_id,CL_PLATFORM_VENDOR,Size,@FVendor[1],nil);
  {$IFDEF LOGGING}
    WriteLog('clGetPlatformInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CCL_PLATFORM_VENDOR: '+FVendor+';');
  {$ENDIF}

  FStatus := clGetPlatformInfo(FPlatform_id,CL_PLATFORM_EXTENSIONS,0,nil,@Size);
  {$IFDEF LOGGING}
    WriteLog('clGetPlatformInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  SetLength(FExtensionsString,Size);
  FStatus := clGetPlatformInfo(FPlatform_id,CL_PLATFORM_EXTENSIONS,Size,@FExtensionsString[1],nil);
  {$IFDEF LOGGING}
    WriteLog('clGetPlatformInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_PLATFORM_EXTENSIONS: '+FExtensionsString+';');
  {$ENDIF}

  FExtensionsCount := 0;
  i := 1;
  while (i<=Length(FExtensionsString)) do
  begin
    if ((FExtensionsString[i]=' ') or (FExtensionsString[i]=#0)) then Inc(FExtensionsCount);
    inc(i);
  end;
  SetLength(FExtensions,FExtensionsCount);
  previous := 1;
  current := 1;
  i := 0;
  while (current<=Length(FExtensionsString)) do
  begin
    if ((FExtensionsString[current]=' ') or (FExtensionsString[current]=#0)) then
    begin
      FExtensions[i] := UpperCase( Copy(FExtensionsString,previous,current-previous-1));
      previous := current+1;
      inc(i);
    end;
    inc(current);
  end;

  FStatus := clGetDeviceIDs(FPlatform_id,CL_DEVICE_TYPE_ALL,0,nil,@FDeviceCount);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceIDs: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('FDeviceCount: '+IntToStr(FDeviceCount)+';');
  {$ENDIF}

  if FDeviceCount>0 then
  begin
    SetLength(devices,FDeviceCount);
    FStatus := clGetDeviceIDs(FPlatform_id,CL_DEVICE_TYPE_ALL,FDeviceCount,@devices[0],nil);
    {$IFDEF LOGGING}
      WriteLog('clGetDeviceIDs: '+GetString(FStatus)+';');
    {$ENDIF}
    SetLength(FDevices,FDeviceCount);
    for i:=0 to FDeviceCount-1 do
    begin
      {$IFDEF LOGGING}
        WriteLog('FDevice: '+IntToStr(i)+';');
      {$ENDIF}
      FDevices[i] := TDCLDevice.Create(devices[i]);
    end;
  end;

end;

procedure TDCLPlatform.Free;
var
  i: integer;
begin
  SetLength(FExtensions,0);
  FExtensionsString := '';
  for i:=0 to FDeviceCount-1 do
  begin
    FDevices[i].Free();
  end;
  SetLength(FDevices,0);
  inherited Free();
end;

function TDCLPlatform.GetDevice(Index: TCL_uint): TDCLDevice;
begin
  if (Index<FDeviceCount)then Result := FDevices[Index]
  else Result := nil;
end;



function TDCLPlatform.GetDeviceWithMaxClockFrequency: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TCL_uint;
  begin
    Result := Device.MaxClockFrequency;
  end;
var
  i: Integer;
  MaxValue: TCL_uint;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxComputeUnits: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TCL_uint;
  begin
    Result := Device.MaxComputeUnits;
  end;
var
  i: Integer;
  MaxValue: TCL_uint;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxConstantArgs: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TCL_uint;
  begin
    Result := Device.MaxConstantArgs;
  end;
var
  i: Integer;
  MaxValue: TCL_uint;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxConstantBufferSize: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TCL_ulong;
  begin
    Result := Device.MaxConstantBufferSize;
  end;
var
  i: Integer;
  MaxValue: TCL_ulong;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxGlobalMemCacheLineSize: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TCL_uint;
  begin
    Result := Device.GlobalMemCacheLineSize;
  end;
var
  i: Integer;
  MaxValue: TCL_uint;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxGlobalMemCacheSize: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TCL_ulong;
  begin
    Result := Device.GlobalMemCacheSize;
  end;
var
  i: Integer;
  MaxValue: TCL_ulong;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxGlobalMemSize: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TCL_ulong;
  begin
    Result := Device.GlobalMemSize;
  end;
var
  i: Integer;
  MaxValue: TCL_ulong;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxImage2DHeight: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TSize_t;
  begin
    Result := Device.Image2DMaxHeight;
  end;
var
  i: Integer;
  MaxValue: TSize_t;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxImage2DWidth: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TSize_t;
  begin
    Result := Device.Image2DMaxWidth;
  end;
var
  i: Integer;
  MaxValue: TSize_t;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxImage3DDepth: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TSize_t;
  begin
    Result := Device.Image3DMaxDepth;
  end;
var
  i: Integer;
  MaxValue: TSize_t;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxImage3DHeight: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TSize_t;
  begin
    Result := Device.Image3DMaxHeight;
  end;
var
  i: Integer;
  MaxValue: TSize_t;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxImage3DWidth: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TSize_t;
  begin
    Result := Device.Image3DMaxWidth;
  end;
var
  i: Integer;
  MaxValue: TSize_t;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxLocalMemSize: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TCL_ulong;
  begin
    Result := Device.LocalMemSize;
  end;
var
  i: Integer;
  MaxValue: TCL_ulong;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxMemAllocSize: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TCL_ulong;
  begin
    Result := Device.MaxMemAllocSize;
  end;
var
  i: Integer;
  MaxValue: TCL_ulong;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxParameterSize: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TSize_t;
  begin
    Result := Device.MaxParameterSize;
  end;
var
  i: Integer;
  MaxValue: TSize_t;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxReadImageArgs: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TCL_uint;
  begin
    Result := Device.MaxReadImageArgs;
  end;
var
  i: Integer;
  MaxValue: TCL_uint;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxSamplers: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TCL_uint;
  begin
    Result := Device.MaxSamplers;
  end;
var
  i: Integer;
  MaxValue: TCL_uint;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxWorkGroupSize: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TSize_t;
  begin
    Result := Device.MaxWorkGroupSize;
  end;
var
  i: Integer;
  MaxValue: TSize_t;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxWorkItemDimensions: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TCL_uint;
  begin
    Result := Device.MaxWorkItemDimensions;
  end;
var
  i: Integer;
  MaxValue: TCL_uint;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetDeviceWithMaxWriteImageArgs: TDCLDevice;
  function GetParameterDevice(const Device: TDCLDevice): TCL_uint;
  begin
    Result := Device.MaxWriteImageArgs;
  end;
var
  i: Integer;
  MaxValue: TCL_uint;
  MaxValuePos: TCL_uint;
begin
  if FDeviceCount=0 then
  begin
    Result := nil;
    Exit;
  end;
  MaxValue := GetParameterDevice(FDevices[0]);
  MaxValuePos := 0;
  for i:=1 to FDeviceCount-1 do
  begin
    if GetParameterDevice(FDevices[i])>MaxValue then
    begin
      MaxValue := GetParameterDevice(FDevices[i]);
      MaxValuePos := i;
    end;
  end;
  Result := FDevices[MaxValuePos];
end;

function TDCLPlatform.GetExtensions(Index: TSize_t): AnsiString;
begin
  if Index<FExtensionsCount then Result := FExtensions[Index]
  else Result := '';
end;

function TDCLPlatform.IsPresentExtension(
  const ExtensionName: AnsiString): Boolean;
var
  i: Integer;
  UppName: AnsiString;
begin
  Result := False;
  UppName := UpperCase(ExtensionName);
  for i:=0 to High(FExtensions) do
  begin
    if FExtensions[i]=UppName then
    begin
      Result := True;
      Break;
    end;
  end;
end;

{ TDCLDevice }

constructor TDCLDevice.Create(Device_id: PCL_device_id);
(*
  need to add
  CL_DEVICE_TYPE
  CL_DEVICE_MAX_WORK_ITEM_SIZES
  CL_DEVICE_SINGLE_FP_CONFIG
  CL_DEVICE_GLOBAL_MEM_CACHE_TYPE
  CL_DEVICE_GLOBAL_MEM_CACHE_TYPE
  CL_DEVICE_EXECUTION_CAPABILITIES
  CL_DEVICE_QUEUE_PROPERTIES 
*)

var
  Size: TSize_t;
  device_type: TCL_device_type;
  b_bool: TCL_bool;

  i, current, previous: Integer;
begin
  inherited Create();
  FDevice_id := Device_id;


  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_NAME, 0, nil, @Size);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  SetLength(FName,Size);
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_NAME, Size, @FName[1], nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_NAME: '+FName+';');
  {$ENDIF}


  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_VENDOR, 0, nil, @Size);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  SetLength(FVendor,Size);
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_VENDOR, Size, @FVendor[1], nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_VENDOR: '+FVendor+';');
  {$ENDIF}

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_VERSION, 0, nil, @Size);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  SetLength(FVersion,Size);
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_VERSION, Size, @FVersion[1], nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_VERSION: '+FVersion+';');
  {$ENDIF}

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_PROFILE, 0, nil, @Size);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  SetLength(FProfile,Size);
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_PROFILE, Size, @FProfile[1], nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_PROFILE: '+FProfile+';');
  {$ENDIF}


  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_TYPE, SizeOf(device_type), @device_type, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  if (device_type and CL_DEVICE_TYPE_CPU)<>0 then
  begin
    FIsCPU := True;
    {$IFDEF LOGGING}
      WriteLog('CL_DEVICE_TYPE: CL_DEVICE_TYPE_CPU;');
    {$ENDIF}
  end;
  if (device_type and CL_DEVICE_TYPE_GPU)<>0 then
  begin
    FIsGPU := True;
    {$IFDEF LOGGING}
      WriteLog('CL_DEVICE_TYPE: CL_DEVICE_TYPE_GPU;');
    {$ENDIF}
  end;
  if (device_type and CL_DEVICE_TYPE_ACCELERATOR)<>0 then
  begin
    FIsAccelerator := True;
    {$IFDEF LOGGING}
      WriteLog('CL_DEVICE_TYPE: CL_DEVICE_TYPE_ACCELERATOR;');
    {$ENDIF}
  end;
  if (device_type and CL_DEVICE_TYPE_DEFAULT)<>0 then
  begin
    FIsDefault := True;
    {$IFDEF LOGGING}
      WriteLog('CL_DEVICE_TYPE: CL_DEVICE_TYPE_DEFAULT;');
    {$ENDIF}
  end;

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR  , SizeOf(FMaxWorkGroupSize), @FMaxWorkGroupSize, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR: '+IntToStr(FMaxWorkGroupSize)+';');
  {$ENDIF}

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR , SizeOf(FNativeVectorPreferredChar), @FNativeVectorPreferredChar, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR: '+IntToStr(FNativeVectorPreferredChar)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT , SizeOf(FNativeVectorPreferredShort), @FNativeVectorPreferredShort, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT: '+IntToStr(FNativeVectorPreferredShort)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT , SizeOf(FNativeVectorPreferredInt), @FNativeVectorPreferredInt, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT: '+IntToStr(FNativeVectorPreferredInt)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG , SizeOf(FNativeVectorPreferredLong), @FNativeVectorPreferredLong, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog(' CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG: '+IntToStr(FNativeVectorPreferredLong)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT , SizeOf(FNativeVectorPreferredFloat), @FNativeVectorPreferredFloat, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT: '+IntToStr(FNativeVectorPreferredFloat)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE , SizeOf(FNativeVectorPreferredDouble), @FNativeVectorPreferredDouble, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE: '+IntToStr(FNativeVectorPreferredDouble)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF , SizeOf(FNativeVectorPreferredHalf), @FNativeVectorPreferredHalf, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF: '+IntToStr(FNativeVectorPreferredHalf)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR , SizeOf(FNativeVectorWidthChar), @FNativeVectorWidthChar, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR: '+IntToStr(FNativeVectorWidthChar)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT , SizeOf(FNativeVectorWidthShort), @FNativeVectorWidthShort, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT: '+IntToStr(FNativeVectorWidthShort)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_NATIVE_VECTOR_WIDTH_INT , SizeOf(FNativeVectorWidthInt), @FNativeVectorWidthInt, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_NATIVE_VECTOR_WIDTH_INT: '+IntToStr(FNativeVectorWidthInt)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG , SizeOf(FNativeVectorWidthLong), @FNativeVectorWidthLong, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG: '+IntToStr(FNativeVectorWidthLong)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT , SizeOf(FNativeVectorWidthFloat), @FNativeVectorWidthFloat, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT: '+IntToStr(FNativeVectorWidthFloat)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE , SizeOf(FNativeVectorWidthDouble), @FNativeVectorWidthDouble, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE: '+IntToStr(FNativeVectorWidthDouble)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF , SizeOf(FNativeVectorWidthHalf), @FNativeVectorWidthHalf, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF: '+IntToStr(FNativeVectorWidthHalf)+';');
  {$ENDIF}

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_MAX_CLOCK_FREQUENCY , SizeOf(FMaxClockFrequency), @FMaxClockFrequency, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_MAX_CLOCK_FREQUENCY: '+IntToStr(FMaxClockFrequency)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_ADDRESS_BITS , SizeOf(FAddressBits), @FAddressBits, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_ADDRESS_BITS: '+IntToStr(FAddressBits)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_MAX_MEM_ALLOC_SIZE , SizeOf(FMaxMemAllocSize), @FMaxMemAllocSize, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_MAX_MEM_ALLOC_SIZE: '+IntToStr(FMaxMemAllocSize)+';');
  {$ENDIF}

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_IMAGE_SUPPORT , SizeOf(b_bool), @b_bool, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_IMAGE_SUPPORT: '+IntToStr(b_bool)+';');
  {$ENDIF}
  if b_bool<>0 then FIsImageSupport := True;

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_MAX_READ_IMAGE_ARGS , SizeOf(FMaxReadImageArgs), @FMaxReadImageArgs, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_MAX_READ_IMAGE_ARGS: '+IntToStr(FMaxReadImageArgs)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_MAX_WRITE_IMAGE_ARGS , SizeOf(FMaxWriteImageArgs), @FMaxWriteImageArgs, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_MAX_WRITE_IMAGE_ARGS: '+IntToStr(FMaxWriteImageArgs)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_IMAGE2D_MAX_WIDTH , SizeOf(FImage2DMaxWidth), @FImage2DMaxWidth, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_IMAGE2D_MAX_WIDTH: '+IntToStr(FImage2DMaxWidth)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_IMAGE2D_MAX_HEIGHT , SizeOf(FImage2DMaxHeight), @FImage2DMaxHeight, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_IMAGE2D_MAX_HEIGHT: '+IntToStr(FImage2DMaxHeight)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_IMAGE3D_MAX_WIDTH , SizeOf(FImage3DMaxWidth), @FImage3DMaxWidth, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_IMAGE3D_MAX_WIDTH: '+IntToStr(FImage3DMaxWidth)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_IMAGE3D_MAX_HEIGHT , SizeOf(FImage3DMaxHeight), @FImage3DMaxHeight, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_IMAGE3D_MAX_HEIGHT: '+IntToStr(FImage3DMaxHeight)+';');
  {$ENDIF}

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_IMAGE3D_MAX_DEPTH , SizeOf(FImage3DMaxDepth), @FImage3DMaxDepth, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_IMAGE3D_MAX_DEPTH: '+IntToStr(FImage3DMaxDepth)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_MAX_SAMPLERS , SizeOf(FMaxSamplers), @FMaxSamplers, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_MAX_SAMPLERS: '+IntToStr(FMaxSamplers)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_MAX_PARAMETER_SIZE , SizeOf(FMaxParameterSize), @FMaxParameterSize, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_MAX_PARAMETER_SIZE: '+IntToStr(FMaxParameterSize)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_MEM_BASE_ADDR_ALIGN , SizeOf(FMemBaseAddrAlign), @FMemBaseAddrAlign, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_MEM_BASE_ADDR_ALIGN: '+IntToStr(FMemBaseAddrAlign)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE , SizeOf(FMinDataTypeAlignSize), @FMinDataTypeAlignSize, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE: '+IntToStr(FMinDataTypeAlignSize)+';');
  {$ENDIF}

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE , SizeOf(FGlobalMemCacheLineSize), @FGlobalMemCacheLineSize, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE: '+IntToStr(FGlobalMemCacheLineSize)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_GLOBAL_MEM_CACHE_SIZE , SizeOf(FGlobalMemCacheSize), @FGlobalMemCacheSize, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_GLOBAL_MEM_CACHE_SIZE: '+IntToStr(FGlobalMemCacheSize)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_GLOBAL_MEM_SIZE  , SizeOf(FGlobalMemSize), @FGlobalMemSize, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_GLOBAL_MEM_SIZE: '+IntToStr(FGlobalMemSize)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE , SizeOf(FMaxConstantBufferSize), @FMaxConstantBufferSize, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE: '+IntToStr(FMaxConstantBufferSize)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_MAX_CONSTANT_ARGS , SizeOf(FMaxConstantArgs), @FMaxConstantArgs, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_MAX_CONSTANT_ARGS: '+IntToStr(FMaxConstantArgs)+';');
  {$ENDIF}

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_LOCAL_MEM_SIZE , SizeOf(FLocalMemSize), @FLocalMemSize, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_LOCAL_MEM_SIZE: '+IntToStr(FLocalMemSize)+';');
  {$ENDIF}

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_ENDIAN_LITTLE , SizeOf(b_bool), @b_bool, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_ENDIAN_LITTLE: '+IntToStr(b_bool)+';');
  {$ENDIF}
  if b_bool<>0 then FIsErrorCorrectionSupport := True;

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_ENDIAN_LITTLE , SizeOf(b_bool), @b_bool, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_ENDIAN_LITTLE: '+IntToStr(b_bool)+';');
  {$ENDIF}
  if b_bool<>0 then FIsHostUnifiedMemory := True;

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_PROFILING_TIMER_RESOLUTION , SizeOf(FProfilingTimerResolution), @FProfilingTimerResolution, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_PROFILING_TIMER_RESOLUTION: '+IntToStr(FProfilingTimerResolution)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_ENDIAN_LITTLE , SizeOf(b_bool), @b_bool, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_ENDIAN_LITTLE: '+IntToStr(b_bool)+';');
  {$ENDIF}
  if b_bool<>0 then FIsEndianLittle := True;

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_AVAILABLE , SizeOf(b_bool), @b_bool, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_AVAILABLE: '+IntToStr(b_bool)+';');
  {$ENDIF}
  if b_bool<>0 then FIsAvailable := True;

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_COMPILER_AVAILABLE , SizeOf(b_bool), @b_bool, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_COMPILER_AVAILABLE: '+IntToStr(b_bool)+';');
  {$ENDIF}
  if b_bool<>0 then FIsCompilerAvailable := True;

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_VENDOR_ID , SizeOf(FVendorId), @FVendorId, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_VENDOR_ID: '+IntToStr(FVendorId)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_MAX_COMPUTE_UNITS , SizeOf(FMaxComputeUnits), @FMaxComputeUnits, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_MAX_COMPUTE_UNITS: '+IntToStr(FMaxComputeUnits)+';');
  {$ENDIF}
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS , SizeOf(FMaxWorkItemDimensions), @FMaxWorkItemDimensions, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS: '+IntToStr(FMaxWorkItemDimensions)+';');
  {$ENDIF}

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_EXTENSIONS, 0, nil, @Size);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_EXTENSIONS: '+IntToStr(Size)+';');
  {$ENDIF}
  SetLength(FExtensionsString,Size);
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_EXTENSIONS, Size, @FExtensionsString[1], nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_EXTENSIONS: '+FExtensionsString+';');
  {$ENDIF}

  FExtensionsCount := 0;
  i := 1;
  while (i<=Length(FExtensionsString)) do
  begin
    if ((FExtensionsString[i]=' ') or (FExtensionsString[i]=#0)) then
    begin
      if (i>1) then
      begin
        if ((FExtensionsString[i-1]<>' ') and (FExtensionsString[i-1]<>#0))then
        begin
          Inc(FExtensionsCount);
        end;
      end
      else Inc(FExtensionsCount);
    end;
    inc(i);
  end;
  SetLength(FExtensions,FExtensionsCount);
  previous := 1;
  current := 1;
  i := 0;
  while (current<=Length(FExtensionsString)) do
  begin
    if ((FExtensionsString[current]=AnsiString(' ')) or (FExtensionsString[current]=#0)) then
    begin
      if (current>previous) then FExtensions[i] := UpperCase( Copy(FExtensionsString,previous,current-previous-1));
      previous := current+1;
      inc(i);
    end;
    inc(current);
  end;

  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_OPENCL_C_VERSION, 0, nil, @Size);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}

  SetLength(FOpenCLCVersion,Size);
  FStatus := clGetDeviceInfo(FDevice_id, CL_DEVICE_OPENCL_C_VERSION, Size, @FOpenCLCVersion[1], nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DEVICE_OPENCL_C_VERSION: '+FOpenCLCVersion+';');
  {$ENDIF}

  FStatus := clGetDeviceInfo(FDevice_id, CL_DRIVER_VERSION, 0, nil, @Size);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  SetLength(FDriverVersion,Size);
  FStatus := clGetDeviceInfo(FDevice_id, CL_DRIVER_VERSION, Size, @FDriverVersion[1], nil);
  {$IFDEF LOGGING}
    WriteLog('clGetDeviceInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_DRIVER_VERSION: '+FDriverVersion+';');
  {$ENDIF}
  FContext := TDCLContext.Create(FDevice_id);
end;

function TDCLDevice.CreateBuffer(const Size: TSize_t; const Data: Pointer; const flags: TDCLMemFlagsSet): TDCLBuffer;
begin
  Result := TDCLBuffer.Create(Context.FContext,flags,Size,Data);
end;

function TDCLDevice.CreateCommandQueue(
  const properties: TDCLCommandQueuePropertiesSet): TDCLCommandQueue;
begin
  Result := TDCLCommandQueue.Create(Device_id, Context.FContext, properties);
end;

function TDCLDevice.CreateContext: TDCLContext;
begin
  Result := TDCLContext.Create(FDevice_id);
end;

function TDCLDevice.CreateProgram(const Source: PPAnsiChar;
  const Options: PAnsiChar): TDCLProgram;
begin
  Result := TDCLProgram.Create(FContext.FContext,Source,Options);
end;

function TDCLDevice.CreateImage2D(const Format: PCL_image_format; const Width, Height, RowPitch: TSize_t;
  const Data: Pointer; const flags: TDCLMemFlagsSet): TDCLImage2D;
begin
  Result:= TDCLImage2D.Create(Context.FContext,flags,Format,Width,Height,RowPitch,Data);
end;

function TDCLDevice.CreateProgram(const FileName: String;
  const Options: PAnsiChar): TDCLProgram;
var
  F: TextFile;
  Source: AnsiString;
  buf: AnsiString;
begin
  AssignFile(F,FileName);
  Reset(F);
  Source := '';
  while not(EOF(F))do
  begin
    Readln(F,buf);
    Source := Source+buf+#10+#13;
  end;
  CloseFile(F);
  Result := CreateProgram(@PAnsiString(Source),Options);
end;

procedure TDCLDevice.Free;
begin
  FContext.Free();
  SetLength(FExtensions,0);
  FExtensionsString:='';
  inherited Free();
end;

function TDCLDevice.GetExtensions(const Index: TSize_t): AnsiString;
begin
  if Index<FExtensionsCount then Result := FExtensions[Index]
  else Result:='';
end;

function TDCLDevice.IsPresentExtension(
  const ExtensionName: AnsiString): Boolean;
var
  i: Integer;
  UppName: AnsiString;
begin
  Result := False;
  UppName := UpperCase(ExtensionName);
  for i:=0 to High(FExtensions) do
  begin
    if FExtensions[i]=UppName then
    begin
      Result := True;
      Break;
    end;
  end;
end;

{ TDCLContext }

constructor TDCLContext.Create(Device_id: PCL_device_id);
(*
  CL_CONTEXT_REFERENCE_COUNT
  CL_CONTEXT_DEVICES
  CL_CONTEXT_PROPERTIES
*)
begin
  inherited Create();
  FContext := clCreateContext(nil,1,@Device_id,nil,nil,@FStatus);
  {$IFDEF LOGGING}
    WriteLog('clCreateContext: '+GetString(FStatus)+';');
  {$ENDIF}
  FStatus := clGetContextInfo(FContext, CL_CONTEXT_NUM_DEVICES ,SizeOf(FNumDevices),@FNumDevices,nil);
  {$IFDEF LOGGING}
    WriteLog('clGetContextInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_CONTEXT_NUM_DEVICES: '+IntToStr(FNumDevices)+';');
  {$ENDIF}
end;

{ TDCLQueue }

constructor TDCLCommandQueue.Create(const Device_Id: PCL_device_id; const Context: PCL_context;
  const properties: TDCLCommandQueuePropertiesSet);
var
  props: TCL_command_queue_properties;
begin
    props := 0;
    if cqpOutOfOrderExecModeEnable in properties then
      props := props or CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE;
    {$IFDEF PROFILING}
       props := props or CL_QUEUE_PROFILING_ENABLE;
    {$ENDIF}
    FCommandQueue := clCreateCommandQueue(Context,Device_Id,props,@FStatus);
    {$IFDEF LOGGING}
      WriteLog('clCreateCommandQueue: '+GetString(FStatus)+';');
    {$ENDIF}
    FProperties:=Properties;
end;


procedure TDCLContext.Free;
begin
  FStatus := clReleaseContext(FContext);
  {$IFDEF LOGGING}
    WriteLog('clReleaseContext: '+GetString(FStatus)+';');
  {$ENDIF}
  inherited Free();
end;

{ TDCLBuffer }

constructor TDCLBuffer.Create(const Context: PCL_context;
  const flags: TDCLMemFlagsSet; const Size: TSize_t; const Data: Pointer=nil);
var
  fgs: TCL_mem_flags;
begin
  inherited Create();
  fgs:=0;
  if mfReadWrite in flags then fgs:=fgs or CL_MEM_READ_WRITE;
  if mfWriteOnly in flags then fgs:=fgs or CL_MEM_WRITE_ONLY;
  if mfReadOnly in flags then fgs:=fgs or CL_MEM_READ_ONLY;
  if mfUseHostPtr in flags then fgs:=fgs or CL_MEM_USE_HOST_PTR;
  if mfAllocHostPtr in flags then fgs:=fgs or CL_MEM_ALLOC_HOST_PTR;
  if mfCopyHostPtr in flags then fgs:=fgs or CL_MEM_COPY_HOST_PTR;
  FMem := clCreateBuffer(Context,fgs,Size,Data,@FStatus);
  {$IFDEF LOGGING}
    WriteLog('clCreateBuffer: '+GetString(FStatus)+';');
  {$ENDIF}
  FSize := Size;
end;

procedure TDCLBuffer.Free;
begin
  FStatus:=clReleaseMemObject(FMem);
  inherited Free;
end;

procedure TDCLCommandQueue.Execute(const Kernel: TDCLKernel;
  const Size: TSize_t);
{$IFDEF PROFILING}
var
  TimingEvent: PCL_event;
  StartTime,
  EndTime: TCL_ulong;
{$ENDIF}
begin
  FStatus := clEnqueueNDRangeKernel(FCommandQueue, Kernel.FKernel, 1, nil, @Size, nil, 0, nil, {$IFDEF PROFILING}@TimingEvent{$ELSE}nil{$ENDIF});
  {$IFDEF LOGGING}
    WriteLog('clEnqueueNDRangeKernel: '+GetString(FStatus)+';');
  {$ENDIF}
  FStatus := clFinish(FCommandQueue);
  {$IFDEF LOGGING}
    WriteLog('clFinish: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF PROFILING}
    FStatus := clGetEventProfilingInfo(TimingEvent,CL_PROFILING_COMMAND_START,SizeOf(StartTime),@StartTime,nil);
    {$IFDEF LOGGING}
      WriteLog('clGetEventProfilingInfo: '+GetString(FStatus)+';');
    {$ENDIF}
    FStatus := clGetEventProfilingInfo(TimingEvent,CL_PROFILING_COMMAND_END,SizeOf(EndTime),@EndTime,nil);
    {$IFDEF LOGGING}
      WriteLog('clGetEventProfilingInfo: '+GetString(FStatus)+';');
    {$ENDIF}
    FExecuteTime := EndTime-StartTime;
    {$IFDEF LOGGING}
      WriteLog('Kernel Execution: '+IntToStr(FExecuteTime)+' ns;');
    {$ENDIF}
  {$ENDIF}
end;

procedure TDCLCommandQueue.Execute(const Kernel: TDCLKernel; //const Device: PCL_device_id;
  const Size: array of TSize_t);
{$IFDEF PROFILING}
var
  TimingEvent: PCL_event;
  StartTime,
  EndTime: TCL_ulong;
{$ENDIF}
//var
//  kernel2DWorkGroupSize: TSize_t;
begin
  //FStatus := clGetKernelWorkGroupInfo(Kernel.FKernel, Device, CL_KERNEL_WORK_GROUP_SIZE, SizeOf(TSize_t), @kernel2DWorkGroupSize, nil);
  {$IFDEF LOGGING}
    WriteLog('clGetKernelWorkGroupInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  FStatus := clEnqueueNDRangeKernel(FCommandQueue, Kernel.FKernel, Length(Size), nil, @Size[0], nil, 0, nil, {$IFDEF PROFILING}@TimingEvent{$ELSE}nil{$ENDIF});
  {$IFDEF LOGGING}
    WriteLog('clEnqueueNDRangeKernel: '+GetString(FStatus)+';');
  {$ENDIF}
  FStatus := clFinish(FCommandQueue);
  {$IFDEF LOGGING}
    WriteLog('clFinish: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF PROFILING}
    FStatus := clGetEventProfilingInfo(TimingEvent,CL_PROFILING_COMMAND_START,SizeOf(StartTime),@StartTime,nil);
    {$IFDEF LOGGING}
      WriteLog('clGetEventProfilingInfo: '+GetString(FStatus)+';');
    {$ENDIF}
    FStatus := clGetEventProfilingInfo(TimingEvent,CL_PROFILING_COMMAND_END,SizeOf(EndTime),@EndTime,nil);
    {$IFDEF LOGGING}
      WriteLog('clGetEventProfilingInfo: '+GetString(FStatus)+';');
    {$ENDIF}
    FExecuteTime := EndTime-StartTime;
    {$IFDEF LOGGING}
      WriteLog('Kernel Execution: '+IntToStr(FExecuteTime)+' ns;');
    {$ENDIF}
  {$ENDIF}
end;

procedure TDCLCommandQueue.Free;
begin
  FStatus := clReleaseCommandQueue(FCommandQueue);
  {$IFDEF LOGGING}
    WriteLog('clReleaseCommandQueue: '+GetString(FStatus)+';');
  {$ENDIF}
  inherited Free();
end;

{ TDCLProgram }

constructor TDCLProgram.Create(const Context: PCL_context;
  const Source: PPAnsiChar; const Options: PAnsiChar);
var
  Size: TSize_t;
  //FBinaries: Array of Char;
begin
  FProgram := clCreateProgramWithSource(Context,1,Source,nil,@FStatus);
  {$IFDEF LOGGING}
    WriteLog('clCreateProgramWithSource: '+GetString(FStatus)+';');
  {$ENDIF}
  FStatus := clBuildProgram(FProgram,0,nil,Options,nil,nil);
  {$IFDEF LOGGING}
    WriteLog('clBuildProgram: '+GetString(FStatus)+';');
  {$ENDIF}

  FStatus := clGetProgramInfo(FProgram,CL_PROGRAM_SOURCE,0,nil,@Size);
  {$IFDEF LOGGING}
    WriteLog('clGetProgramInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  FSource := GetMemory(Size);
  FStatus := clGetProgramInfo(FProgram,CL_PROGRAM_SOURCE,Size,FSource,nil);
  {$IFDEF LOGGING}
    WriteLog('clGetProgramInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_PROGRAM_SOURCE: '+AnsiString(FSource)+';');
  {$ENDIF}

  FStatus := clGetProgramInfo(FProgram,CL_PROGRAM_BINARY_SIZES,0,nil,@FBinarySizesCount);
  {$IFDEF LOGGING}
    WriteLog('clGetProgramInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  SetLength(FBinarySizes,FBinarySizesCount);
  FStatus := clGetProgramInfo(FProgram,CL_PROGRAM_BINARY_SIZES,SizeOf(FBinarySizes),@FBinarySizes[0],nil);
  {$IFDEF LOGGING}
    WriteLog('clGetProgramInfo: '+GetString(FStatus)+';');
  {$ENDIF}


  (*  //Not yet
  FStatus := clGetProgramInfo(FProgram,CL_PROGRAM_BINARIES,0,nil,@Size);
  SetLength(FBinaries,Size);
  FStatus := clGetProgramInfo(FProgram,CL_PROGRAM_BINARIES,Size,@FBinaries[0],nil);
  Writeln(String(FBinaries));
  *)

end;

function TDCLProgram.CreateKernel(const KernelName: PAnsiChar): TDCLKernel;
begin
  Result := TDCLKernel.Create(FProgram,KernelName);
end;

procedure TDCLProgram.Free;
begin
  FStatus := clReleaseProgram(FProgram);
  {$IFDEF LOGGING}
    WriteLog('clReleaseProgram: '+GetString(FStatus)+';');
  {$ENDIF}
  FSource := '';
  SetLength(FBinarySizes,0);
  inherited Free;
end;

function TDCLProgram.GetBinarySizes(const Index: TSize_t): TSize_t;
begin
  if (Index<FBinarySizesCount)then Result := FBinarySizes[Index]
  else Result:=0;
end;

{ TDCLKernel }

constructor TDCLKernel.Create(const Program_: PCL_program;
  const KernelName: PAnsiChar);
begin
  FKernel := clCreateKernel(Program_,KernelName,@FStatus);
  {$IFDEF LOGGING}
    WriteLog('clCreateKernel: '+GetString(FStatus)+';');
  {$ENDIF}
end;

procedure TDCLKernel.Free;
begin
  FStatus := clReleaseKernel(FKernel);
  {$IFDEF LOGGING}
    WriteLog('clReleaseKernel: '+GetString(FStatus)+';');
  {$ENDIF}
  inherited Free();
end;

function TDCLKernel.GetFunctionName: AnsiString;
var
  Size: TSize_t;
  buffer: Array of AnsiChar;
begin
  FStatus := clGetKernelInfo(FKernel,CL_KERNEL_FUNCTION_NAME,0,nil,@Size);
  {$IFDEF LOGGING}
    WriteLog('clGetKernelInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  SetLength(buffer,Size);
  FStatus := clGetKernelInfo(FKernel,CL_KERNEL_FUNCTION_NAME,Size,@buffer[0],nil);
  {$IFDEF LOGGING}
    WriteLog('clGetKernelInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_KERNEL_FUNCTION_NAME: '+AnsiString(buffer)+';');
  {$ENDIF}
  Result := AnsiString(buffer);
  SetLength(buffer,0);
end;

function TDCLKernel.GetNumArgs: TCL_uint;
begin
  FStatus := clGetKernelInfo(FKernel,CL_KERNEL_NUM_ARGS,SizeOf(Result),@Result,nil);
  {$IFDEF LOGGING}
    WriteLog('clGetKernelInfo: '+GetString(FStatus)+';');
  {$ENDIF}
  {$IFDEF LOGGING}
    WriteLog('CL_KERNEL_NUM_ARGS: '+IntToStr(Result)+';');
  {$ENDIF}
end;

procedure TDCLKernel.SetArg(const Index: TCL_uint; const Size: TSize_t;
  const Value: Pointer);
begin
  FStatus := clSetKernelArg(FKernel,Index,Size,Value);
  {$IFDEF LOGGING}
    WriteLog('clSetKernelArg: '+GetString(FStatus)+';');
  {$ENDIF}
end;

procedure TDCLKernel.SetArg(const Index: TCL_uint;
  const Value: TDCLBuffer);
begin
  SetArg(Index,SizeOf(@Value.FMem),@Value.FMem);
end;

procedure TDCLKernel.SetArg(const Index: TCL_uint;
  const Value: TDCLImage2D);
begin
  SetArg(Index,SizeOf(@Value.FMem),@Value.FMem);
end;

procedure TDCLCommandQueue.ReadBuffer(const Buffer: TDCLBuffer;
  const Size: TSize_t; const Data: Pointer);
begin
  FStatus := clEnqueueReadBuffer(FCommandQueue,Buffer.FMem,CL_TRUE,0,Size,Data,0,nil,nil);
  {$IFDEF LOGGING}
    WriteLog('clEnqueueReadBuffer: '+GetString(FStatus)+';');
  {$ENDIF}
  clFinish(FCommandQueue);
end;

procedure TDCLCommandQueue.ReadImage2D(const Image: TDCLImage2D;
  const Width, Height: TSize_t; const Data: Pointer);
var
  origin,region: Array [0..2]of TSize_t;
begin
  ZeroMemory(@origin,SizeOf(origin));
  region[0] := Width;
  region[1] := Height;
  region[2] := 1;// Image 2D
  FStatus := clEnqueueReadImage(FCommandQueue,Image.FMem,CL_TRUE,@origin,@region,0,0,Data,0,nil,nil);
  {$IFDEF LOGGING}
    WriteLog('clEnqueueReadImage: '+GetString(FStatus)+';');
  {$ENDIF}
  FStatus := clFinish(FCommandQueue);
  {$IFDEF LOGGING}
    WriteLog('clFinish: '+GetString(FStatus)+';');
  {$ENDIF}
end;

procedure TDCLCommandQueue.WriteImage2D(const Image: TDCLImage2D;
  const Width, Height: TSize_t; const Data: Pointer);
var
  origin,region: Array [0..2]of TSize_t;
begin
  ZeroMemory(@origin,SizeOf(origin));
  region[0] := Width;
  region[1] := Height;
  region[2] := 1;// Image 2D
  FStatus := clEnqueueWriteImage(FCommandQueue,Image.FMem,CL_TRUE,@origin,@region,0,0,Data,0,nil,nil);
  {$IFDEF LOGGING}
    WriteLog('clEnqueueWriteImage: '+GetString(FStatus)+';');
  {$ENDIF}
  FStatus := clFinish(FCommandQueue);
  {$IFDEF LOGGING}
    WriteLog('clFinish: '+GetString(FStatus)+';');
  {$ENDIF}
end;

procedure TDCLCommandQueue.WriteBuffer(const Buffer: TDCLBuffer;
  const Size: TSize_t; const Data: Pointer);
begin
  FStatus := clEnqueueWriteBuffer(FCommandQueue,Buffer.FMem,CL_TRUE,0,Size,Data,0,nil,nil);
  {$IFDEF LOGGING}
    WriteLog('clEnqueueWriteBuffer: '+GetString(FStatus)+';');
  {$ENDIF}
end;

{ TDCLImage2D }

constructor TDCLImage2D.Create(const Context: PCL_context;
  const Flags: TDCLMemFlagsSet; const Format: PCL_image_format; const Width,
  Height, RowPitch: TSize_t; const Data: Pointer);
var
  fgs: TCL_mem_flags;
begin
  inherited Create();
  fgs:=0;
  if mfReadWrite in flags then fgs:=fgs or CL_MEM_READ_WRITE;
  if mfWriteOnly in flags then fgs:=fgs or CL_MEM_WRITE_ONLY;
  if mfReadOnly in flags then fgs:=fgs or CL_MEM_READ_ONLY;
  if mfUseHostPtr in flags then fgs:=fgs or CL_MEM_USE_HOST_PTR;
  if mfAllocHostPtr in flags then fgs:=fgs or CL_MEM_ALLOC_HOST_PTR;
  if mfCopyHostPtr in flags then fgs:=fgs or CL_MEM_COPY_HOST_PTR;
  FFormat:= Format^;
  FMem := clCreateImage2D(Context, fgs, @FFormat, Width, Height, RowPitch, Data, @FStatus);
  {$IFDEF LOGGING}
    WriteLog('clCreateImage2D: '+GetString(FStatus)+';');
  {$ENDIF}
end;

procedure TDCLImage2D.Free;
begin
  FStatus := clReleaseMemObject(FMem);
  {$IFDEF LOGGING}
    WriteLog('clReleaseMemObject: '+GetString(FStatus)+';');
  {$ENDIF}
  inherited Free();
end;

{$IFDEF LOGGING}
initialization
  AssignFile(DCLFileLOG,ExtractFilePath(ParamStr(0))+'DELPHI_LOG.log');
  Rewrite(DCLFileLOG);
finalization
  CloseFile(DCLFileLOG);
{$ENDIF}
end.
