{******************************************}
{                                          }
{            Copyright (c) 2017            }
{               by Sony NS,                }
{              CrossoverLab.               }
{                                          }
{******************************************}

unit frxMarkReg;

interface

uses
  Classes, frxMarkDateTime, frxMarkItem, frxMarkNoItem, frxMarkOptionItem,
  frxMarkEditor;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FastReport OMR',
    [TfrxMarkItemObject,
     TfrxMarkNoItemObject,
     TfrxMarkDateTimeObject,
     TfrxMarkOptionItemObject
    ]);
end;

end.
