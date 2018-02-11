{******************************************}
{                                          }
{            Various routines              }
{                                          }
{            Copyright (c) 2017            }
{               by Sony NS,                }
{              CrossoverLab.               }
{                                          }
{******************************************}

unit frxMarkUtils;

interface

{$I frx.inc}

uses Windows, Classes, SysUtils, Types, Graphics, frxClass;

type
  TfrxCellKind = (ckBubble, ckEllipse, ckRectangle);
  TfrxCellOrientation = (orHorizontal, orVertical);
  TfrxStripPosition = (spOdd, spEven, spNone);
  TfrxDateFormat = (dfDDMMYY, dfDDMMYYYY, dfMMDDYY, dfMMDDYYYY, dfDDMMYY_hhmmss);

  TfrxCellHeader = class(TPersistent)
  private
    FCellHeight: Integer;
    FCellWidth: Integer;
    FCellHSpace: Integer;
    FCellVSpace: Integer;
    FHeaderStyle: TfrxCellKind;
    FColor: TColor;
    FVisible: Boolean;
    FVisibleStyle: Boolean;
    FVisibleText: Boolean;
    procedure SetColor(Value: TColor);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    procedure DrawCell(ACanvas: TCanvas; ARect: TRect);
    procedure DrawText(ACanvas: TCanvas; ARect: TRect; AStr: String);

    property VisibleStyle: Boolean read FVisibleStyle write FVisibleStyle;
    property VisibleText: Boolean read FVisibleText write FVisibleText;
  published
    property Height: Integer read FCellHeight write FCellHeight;
    property Width: Integer read FCellWidth write FCellWidth;
    property HorizontalSpace: Integer read FCellHSpace write FCellHSpace;
    property VerticalSpace: Integer read FCellVSpace write FCellVSpace;
    property HeaderStyle: TfrxCellKind read FHeaderStyle write FHeaderStyle default ckRectangle;
    property Color: TColor read FColor write SetColor;
    property Visible: Boolean read FVisible write FVisible;
  end;

  TfrxCell = class(TPersistent)
  private
    FCellHeight: Integer;
    FCellWidth: Integer;
    FCellHSpace: Integer;
    FCellVSpace: Integer;
    FCellStyle: TfrxCellKind;
    FColor: TColor;
    FStripColor: TColor;
    FVisible: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Draw(ACanvas: TCanvas; ARect: TRect; AStr, AStrD: String;
      AFontSize: Integer; AScaleX, AScaleY: Extended);
    procedure DrawOption(ACanvas: TCanvas; ARect: TRect; AHeight, AWidth: Integer;
      AStr: String; AScaleX, AScaleY: Extended);
    procedure DrawText(ACanvas: TCanvas; ARect: TRect; AHeight, AWidth, AFontSize: Integer;
      AStr: String; AScale: Extended);
    procedure DrawVerticalText(ACanvas: TCanvas; ARect: TRect; AHeight, AWidth, AFontSize: Integer;
      AStr: String; AScale: Extended);
  published
    property Height: Integer read FCellHeight write FCellHeight;
    property Width: Integer read FCellWidth write FCellWidth;
    property HorizontalSpace: Integer read FCellHSpace write FCellHSpace;
    property VerticalSpace: Integer read FCellVSpace write FCellVSpace;
    property CellStyle: TfrxCellKind read FCellStyle write FCellStyle default ckBubble;
    property Color: TColor read FColor write FColor;
    property StripColor: TColor read FStripColor write FStripColor;
    property Visible: Boolean read FVisible write FVisible;
  end;

  function frxRemoveStrByByte(sString, sDelimiter: string; bTokenNum: Byte): string;
  function frxIntPad3Str(const AValue: Integer): String;

implementation

function frxRemoveStrByByte(sString, sDelimiter: string; bTokenNum: Byte): string;
var Token: string;
    StrLen,Num,EndofToken: Integer;
begin
  StrLen := Length(sString);
  Num := 1;
  EndofToken := StrLen;
  while ((Num <= bTokenNum) and (EndofToken <> 0)) do
  begin
    EndofToken := Pos(sDelimiter, sString);
    if EndofToken <> 0 then
    begin
      Token := Copy(sString, 1, EndofToken - 1);
      Delete(sString, 1, EndofToken);
      Inc(Num);
    end else
      Token := sString;
  end;
  if Num >= bTokenNum then
    Result := Token
  else
    Result := '';
end;

function frxIntPad3Str(const AValue: Integer): String;
var i: Integer;
    s: String;
begin
  s:= IntToStr(AValue);
  for i:= 1 to (3- Length(s)) do
    s:= ' ' + s;
  Result:= s;
end;

{ TfrxCellHeader }

procedure TfrxCellHeader.Assign(Source: TPersistent);
begin
  if Source is TfrxCellHeader then
  begin
    FColor:= TfrxCellHeader(Source).Color;
    FHeaderStyle:= TfrxCellHeader(Source).HeaderStyle;
    FCellHeight:= TfrxCellHeader(Source).Height;
    FCellWidth:= TfrxCellHeader(Source).Width;
    FCellHSpace:= TfrxCellHeader(Source).HorizontalSpace;
    FCellVSpace:= TfrxCellHeader(Source).VerticalSpace;
  end;
end;

constructor TfrxCellHeader.Create;
begin
  FHeaderStyle:= ckRectangle;
  FColor:= clRed;
  FCellHeight:= 20;
  FCellWidth:= 20;
  FCellHSpace:= 0;
  FCellVSpace:= 0;
  FVisible:= False;
  FVisibleStyle:= False;
  FVisibleText:= False;
end;

destructor TfrxCellHeader.Destroy;
begin

  inherited;
end;

procedure TfrxCellHeader.DrawCell(ACanvas: TCanvas; ARect: TRect);
var {$IFDEF Delphi12}
    Sz: TSize;
    {$ENDIF}
begin
  with ACanvas do
  begin
    case FHeaderStyle of
      ckBubble:
        Ellipse(ARect.Left + FCellHSpace,
            ARect.Top + FCellVSpace,
            ARect.Right - FCellHSpace,
            ARect.Bottom - FCellVSpace);
      ckEllipse:
        Ellipse(ARect.Left + FCellHSpace,
            ARect.Top + 3 + FCellVSpace,
            ARect.Right - FCellHSpace,
            ARect.Bottom - FCellVSpace - 2);
      ckRectangle:
        Rectangle(ARect.Left + FCellHSpace,
            ARect.Top + FCellVSpace,
            ARect.Right - FCellHSpace + 1,
            ARect.Bottom - FCellVSpace + 1);
    end;
  end;
end;

procedure TfrxCellHeader.DrawText(ACanvas: TCanvas; ARect: TRect; AStr: String);
var {$IFDEF Delphi12}
    Sz: TSize;
    {$ENDIF}
begin
  with ACanvas do
  begin
    Brush.Style:= bsClear;

    if FVisibleText then
    begin
      Font.Name:= 'Arial';
      Font.Height := - (ARect.Bottom - ARect.Top);
      //Font.Size:= 8;
      Font.Style:= [];
      Font.Color:= FColor;
      SetBkMode(Handle, Transparent);
      {$IFDEF Delphi12}
      GetTextExtentPoint32A(Handle, PAnsiChar(AStr), Length(AStr), Sz);
      ExtTextOutA(Handle, ARect.Left + (ARect.Right - ARect.Left - Sz.cx) div 2,
        ARect.Top + 1, ETO_CLIPPED, @ARect, PAnsiChar(AStr), 3, nil);
      {$ELSE}
      ExtTextOut(Handle, ARect.Left + (ARect.Right - ARect.Left - TextWidth(AStr)) div 2,
        ARect.Top + 1, ETO_CLIPPED, @ARect, PChar(AStr), 3, nil);
      {$ENDIF}
    end;
  end;
end;

procedure TfrxCellHeader.SetColor(Value: TColor);
begin
  if Value <> FColor then
    FColor:= Value;
end;

{ TfrxCell }

constructor TfrxCell.Create;
begin
  FColor:= clRed;
  FStripColor:= $00BBBBFF;
  FCellHeight:= 20;
  FCellWidth:= 20;
  FCellHSpace:= 2;
  FCellVSpace:= 2;
  FVisible:= True;
end;

destructor TfrxCell.Destroy;
begin

  inherited;
end;

procedure TfrxCell.Draw(ACanvas: TCanvas; ARect: TRect; AStr, AStrD: String;
  AFontSize: Integer; AScaleX, AScaleY: Extended);
var {$IFDEF Delphi12}
    Sz: TSize;
    {$ENDIF}
    x: Extended;
begin
  with ACanvas do
  begin
    Pen.Style:= psSolid;
    if Trim(AStrD) <> '' then
    begin
      Brush.Style:= bsSolid;
      Brush.Color:= clBlack;
      Pen.Color:= clBlack;
    end else
    begin
      Brush.Style:= bsClear;
      Pen.Color:= FColor;
    end;


    case FCellStyle of
      ckBubble:
        Ellipse(ARect.Left + FCellHSpace * Round(AScaleX),
            ARect.Top + FCellVSpace * Round(AScaleY),
            ARect.Right - FCellHSpace * Round(AScaleX),
            ARect.Bottom - FCellVSpace * Round(AScaleY));
      ckEllipse:
        Ellipse(ARect.Left + FCellHSpace * Round(AScaleX),
            ARect.Top + 3 + FCellVSpace * Round(AScaleY),
            ARect.Right - FCellHSpace * Round(AScaleX),
            ARect.Bottom - FCellVSpace - 2 * Round(AScaleY));
      ckRectangle:
        Rectangle(ARect.Left + FCellHSpace * Round(AScaleX),
            ARect.Top + FCellVSpace * Round(AScaleY),
            ARect.Right - FCellHSpace + 1 * Round(AScaleX),
            ARect.Bottom - FCellVSpace + 1 * Round(AScaleY));
    end;

    if Trim(AStrD) = '' then
    begin
      Font.Height := - (ARect.Bottom - ARect.Top);
      if AScaleY > 2 then x:= 1 else x:= AScaleY;
      Font.Size:= Round(AFontSize * x);
      SetBkMode(Handle, Transparent);
      {$IFDEF Delphi12}
      {GetTextExtentPoint32A(Handle, PAnsiChar(AStr), Length(AStr), Sz);
       ExtTextOutA(Handle, ARect.Left + ((ARect.Right - ARect.Left - Sz.cx) div 2),
         ARect.Top + 3, ETO_CLIPPED, @ARect, PAnsiChar(AStr), Length(AStr), nil);}
      Windows.DrawText(Handle, PChar(AStr), Length(AStr), ARect, DT_VCENTER or
        DT_SINGLELINE or DT_CENTER);
      {$ELSE}
      ExtTextOut(Handle, ARect.Left + (ARect.Right - ARect.Left - TextWidth(AStr)) div 2,
        ARect.Top + 3, ETO_CLIPPED, @ARect, PChar(AStr), 1, nil);
      {$ENDIF}
    end;
  end;
end;

procedure TfrxCell.DrawOption(ACanvas: TCanvas; ARect: TRect; AHeight,
  AWidth: Integer; AStr: String; AScaleX, AScaleY: Extended);
begin
with ACanvas do
  begin
    Pen.Style:= psSolid;
    if Trim(AStr) <> '' then
    begin
      Brush.Style:= bsSolid;
      Brush.Color:= clBlack;
      Pen.Color:= clBlack;
    end else
    begin
      Brush.Style:= bsClear;
      Pen.Color:= FColor;
    end;

    case FCellStyle of
      ckBubble:
        Ellipse(ARect.Left + FCellHSpace * Round(AScaleX),
            ARect.Top + FCellVSpace * Round(AScaleY),
            ARect.Right - FCellHSpace * Round(AScaleX),
            ARect.Bottom - FCellVSpace * Round(AScaleY));
      ckEllipse:
        Ellipse(ARect.Left + FCellHSpace * Round(AScaleX),
            ARect.Top + 3 + FCellVSpace * Round(AScaleY),
            ARect.Right - FCellHSpace * Round(AScaleX),
            ARect.Top + AHeight - FCellVSpace - 2 * Round(AScaleY));
      ckRectangle:
        Rectangle(ARect.Left + FCellHSpace * Round(AScaleX),
            ARect.Top + FCellVSpace * Round(AScaleY),
            ARect.Right - FCellHSpace + 1 * Round(AScaleX),
            ARect.Top + AHeight - FCellVSpace + 1 * Round(AScaleY));
    end;
  end;
end;

procedure TfrxCell.DrawText(ACanvas: TCanvas; ARect: TRect; AHeight, AWidth,
  AFontSize: Integer; AStr: String; AScale: Extended);
var l: Integer;
    x: Extended;
begin
  if l <= 0 then l:= 1;
  with ACanvas do
  begin
    Font.Height := - (ARect.Bottom - ARect.Top);
    if AScale > 2 then x:= 1 else x:= AScale;
    Font.Size:= Round(AFontSize * x);
    SetBkMode(Handle, Transparent);
    TextOut(ARect.Left, ARect.Top + 3, AStr);
    (*{$IFDEF Delphi12}
    GetTextExtentPoint32A(Handle, PAnsiChar(AStr), Length(AStr), Sz);
    ExtTextOutA(Handle, ARect.Left + (ARect.Right - ARect.Left - Sz.cx) div 2,
      ARect.Top + 3, ETO_CLIPPED, @ARect, PAnsiChar(AStr), AWidth, nil);
    {$ELSE}
    ExtTextOut(Handle, ARect.Left + (ARect.Right - ARect.Left - TextWidth(AStr)) div 2,
      ARect.Top + 3, ETO_CLIPPED, @ARect, PChar(AStr), Length(AStr), nil);
    {$ENDIF}*)
  end;
end;

procedure TfrxCell.DrawVerticalText(ACanvas: TCanvas; ARect: TRect; AHeight,
  AWidth, AFontSize: Integer; AStr: String; AScale: Extended);
var x: Extended;
begin
  with ACanvas do
  begin
    Font.Orientation:= 900;
    Font.Height := - (ARect.Bottom - ARect.Top);
    //8 Feb 2018, karena skala kandang lebih besar..
    if AScale > 2 then x:= 1 else x:= AScale;
    Font.Size:= Round(AFontSize * x);
    //Font.Size:= Round(AFontSize * AScale);
    SetBkMode(Handle, Transparent);

    TextOut(ARect.Left, ARect.Top + AHeight + TextWidth(AStr), AStr);
  end;
end;

end.
