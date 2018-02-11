
{******************************************}
{                                          }
{           MarkOptionItem RTTI            }
{                                          }
{            Copyright (c) 2017            }
{                by Sony NS,               }
{              CrossoverLab.               }
{                                          }
{******************************************}

unit frxMarkOptionItemRTTI;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, SysUtils, Forms, fs_iinterpreter, frxMarkOptionItem, frxClassRTTI
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TFunctions = class(TfsRTTIModule)
  public
    constructor Create(AScript: TfsScript); override;
  end;


{ TFunctions }

constructor TFunctions.Create(AScript: TfsScript);
begin
  inherited Create(AScript);
  with AScript do
  begin
    AddClass(TfrxMarkOptionItem, 'TfrxView');
  end;
end;


initialization
  fsRTTIModules.Add(TFunctions);

finalization
  if fsRTTIModules <> nil then
    fsRTTIModules.Remove(TFunctions);

end.
