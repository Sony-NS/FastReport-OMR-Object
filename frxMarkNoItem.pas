
{******************************************}
{                                          }
{   MarkNoItem Add-In Object (FastReport)  }
{                                          }
{            Copyright (c) 2017            }
{               by Sony NS,                }
{              CrossoverLab.               }
{                                          }
{******************************************}

unit frxMarkNoItem;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Menus, frxClass, frxMarkUtils
{$IFDEF FR_COM}
, FastReport_TLB
{$ENDIF}
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxMarkNoItemObject = class(TComponent)  // fake component
  end;

  TfrxMarkNoItem = class(TfrxView)
  private
    FCellHeader: TfrxCellHeader;
    FCell: TfrxCell;
    //Scale XY
    FCellHHeight: Integer;
    FCellHWidth: Integer;
    FCellHeight: Integer;
    FCellWidth: Integer;
    FCalcVerticalSize: Integer;
    FCalcHorizontalSize: Integer;
    FCellItems: String;
    FDefaultValues: String;
    FFontSize: Integer;
    FFontHeight: Integer;
    FOrientation: TfrxCellOrientation;
    FMultipleAnswer: Boolean;
    FStripPosition: TfrxStripPosition;
    FStartNumber: Integer;
    FItemChanged: Boolean;
    FStripColor: TColor;
    procedure CalcSize;
    procedure CalcCellSize;
    procedure CalcItemCell;
    procedure CalcOrientationCell;

    procedure DrawHeader(ACanvas: TCanvas; ARect: TRect);
    procedure DrawCell(ACanvas: TCanvas; ARect: TRect);
    procedure DrawStrip(ACanvas: TCanvas; ARect: TRect);
    function GetStartNumber: Integer;
    procedure SetCellItem(AValue: String);
    procedure SetStartNumber(Value: Integer);
    procedure SetOrientation(const Value: TfrxCellOrientation);
    procedure SetCellHeader(const Value: TfrxCellHeader);
    procedure SetStripColor(const Value: TColor);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Diff(AComponent: TfrxComponent): String; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    class function GetDescription: String; override;

    property FontSize: Integer read FFontSize write FFontSize;
    property FontHeight: Integer read FFontHeight write FFontHeight;
  published
    //property BrushStyle;
    property CellHeader: TfrxCellHeader read FCellHeader write SetCellHeader;
    property Cell: TfrxCell read FCell write FCell;
    property CellItems: String read FCellItems write SetCellItem;
    property DefaultValues: String read FDefaultValues write FDefaultValues;
    //property Color;
    //property Cursor;
    property Font;
    property Frame;
    property MultipleAnswer: Boolean read FMultipleAnswer write FMultipleAnswer;
    property Orientation: TfrxCellOrientation read FOrientation write SetOrientation;// default orHorizontal;
    property StartNumber: Integer read GetStartNumber write SetStartNumber;
    property StripPosition: TfrxStripPosition read FStripPosition write FStripPosition default spOdd;
    property StripColor: TColor read FStripColor write SetStripColor;
  end;

implementation

uses frxMarkNoItemRTTI, frxGraphicUtils, frxUtils, frxDsgnIntf, frxRes, frxXML,
  frxMarkEditor;

procedure TfrxMarkNoItem.CalcCellSize;
begin
  FCellHHeight:= FCellHeader.Height;
  FCellHWidth:= FCellHeader.Width;
  FCellHeight:= FCell.Height;
  FCellWidth:= FCell.Width;
end;

procedure TfrxMarkNoItem.CalcItemCell;
var LStr: String;
    x: Integer;
begin
  CalcCellSize;
  LStr:= StringReplace(FCellItems, ':', '', [rfReplaceAll]);
  if FOrientation = orVertical then
  begin
    if FItemChanged then
    begin
      x:= Round(Height / FCellHeight);
      if (x > (Length(LStr) + 1)) then
         FCalcVerticalSize:= Length(LStr) + 1
      else
         FCalcVerticalSize:= x;

      FCalcHorizontalSize:= Round(Width / FCellWidth);
      FItemChanged:= False;
    end else
    begin
      FCalcVerticalSize:= Round(Width / FCellWidth);
      FCalcHorizontalSize:= Round(Height / FCellHeight);
    end;
  end else
  begin
    if (FItemChanged) then
    begin
      x:= Round(Width / FCellWidth);
      if x > (Length(LStr) + 1) then
         FCalcVerticalSize:= Length(LStr) + 1
      else
         FCalcVerticalSize:= x;

      FCalcHorizontalSize:= Round(Height / FCellHeight);
      FItemChanged:= False;
    end else
    begin
      FCalcVerticalSize:= Round(Height / FCellHeight);
      FCalcHorizontalSize:= Round(Width / FCellWidth);
    end;
  end;
  CalcSize;
end;

procedure TfrxMarkNoItem.CalcOrientationCell;
begin
  CalcCellSize;
  if (FOrientation = orVertical) then
  begin
    if Height > Width then
    begin
      FCalcVerticalSize:= Round(Height / FCellHeight);
      FCalcHorizontalSize:= Round(Width / FCellWidth);
    end else
    begin
      FCalcVerticalSize:= Round(Width / FCellWidth);
      FCalcHorizontalSize:= Round(Height / FCellHeight);
    end;
  end else
  begin
    if Width > Height then
    begin
      FCalcVerticalSize:= Round(Width / FCellWidth);
      FCalcHorizontalSize:= Round(Height / FCellHeight);
    end else
    begin
      FCalcVerticalSize:= Round(Height / FCellHeight);
      FCalcHorizontalSize:= Round(Width / FCellWidth);
    end;
  end;
  CalcSize;
end;

procedure TfrxMarkNoItem.CalcSize;
begin
  if FOrientation = orVertical then
  begin
    Height:= FCalcVerticalSize * FCellHeight;
    Width:= FCalcHorizontalSize * FCellWidth;
  end else
  begin
    Width:= FCalcVerticalSize * FCellWidth;
    Height:= FCalcHorizontalSize * FCellHeight;
  end;
end;

constructor TfrxMarkNoItem.Create(AOwner: TComponent);
begin
  inherited;
  FCellHeader:= TfrxCellHeader.Create;
  FCellHeader.VisibleStyle:= False;
  FCellHeader.VisibleText:= True;
  FCellHeader.Visible:= True;
  FCell:= TfrxCell.Create;
  FStripColor:= FCell.StripColor;
  FFontSize:= 8;
  FFontHeight:= 11;
  FCellItems:= 'A:B:C:D:E';
  //FDefaultValues:= '';
  FItemChanged:= False;
  FOrientation:= orHorizontal;
  FStartNumber:= 1;
  FStripPosition:= spOdd;
  //FStripColor:= $00BBBBFF;
  Frame.Color:= clRed;
  Frame.Typ:= [ftLeft, ftRight, ftTop, ftBottom];

  FCellHHeight:= FCellHeader.Height;
  FCellHWidth:= FCellHeader.Width;
  FCellHeight:= FCell.Height;
  FCellWidth:= FCell.Width;

  FCalcVerticalSize:= 6;
  FCalcHorizontalSize:= 5;
  CalcSize;
end;

class function TfrxMarkNoItem.GetDescription: String;
begin
  Result := 'Mark NoItem';//frxResources.Get('obMarkNoItem');
end;

function TfrxMarkNoItem.GetStartNumber: Integer;
begin
  Result:= FStartNumber;
end;
{
procedure TfrxMarkNoItem.ReDraw(CellSize: Integer);
var LStr: String;
begin
  FCellHHeight:= CellSize;
  FCellHWidth:= CellSize;
  FCellHeight:= CellSize;
  FCellWidth:= CellSize;

  try
    LStr:= StringReplace(FCellItems, ':', '', [rfReplaceAll]);

    if FOrientation = orVertical then
      FCalcVerticalSize:= Length(LStr) + 1
    else
      FCalcVerticalSize:= Length(LStr) + 1;
  finally
    CalcSize;
  end;
end;}

procedure TfrxMarkNoItem.SetCellHeader(const Value: TfrxCellHeader);
begin
  FCellHeader.Assign(Value);
end;

procedure TfrxMarkNoItem.SetCellItem(AValue: String);
begin
  if AValue <> FCellItems then
  begin
    FCellItems:= AValue;
    FItemChanged:= True;
    CalcItemCell;
  end;
end;

procedure TfrxMarkNoItem.SetOrientation(const Value: TfrxCellOrientation);
begin
  if Value <> FOrientation then
  begin
    FOrientation:= Value;
    CalcOrientationCell;
  end;
end;

procedure TfrxMarkNoItem.SetStartNumber(Value: Integer);
begin
  if Value <> FStartNumber then
     if Value < 0 then
        FStartNumber:= 0
     else
        FStartNumber:= Value;
end;

procedure TfrxMarkNoItem.SetStripColor(const Value: TColor);
begin
  if FStripColor <> Value then
  begin
    FStripColor := Value;
    FCell.StripColor:= FStripColor;
  end;
end;

destructor TfrxMarkNoItem.Destroy;
begin
  FCellHeader.Free;
  FCell.Free;
  inherited;
end;

function TfrxMarkNoItem.Diff(AComponent: TfrxComponent): String;
begin
  Result := inherited Diff(AComponent);

  if FCellItems <> TfrxMarkNoItem(AComponent).FCellItems then
    Result := Result + ' CellItems="' + frxValueToXML(FCellItems) + '"';
  if FDefaultValues <> TfrxMarkNoItem(AComponent).FDefaultValues then
    Result := Result + ' DefaultValues="' + frxValueToXML(FDefaultValues) + '"';
  if FOrientation <> TfrxMarkNoItem(AComponent).FOrientation then
    Result := Result + ' Orientation="' + frxValueToXML(FOrientation) + '"';
  if FStartNumber <> TfrxMarkNoItem(AComponent).FStartNumber then
    Result := Result + ' StartNumber="' + frxValueToXML(FStartNumber) + '"';
  if FStripPosition <> TfrxMarkNoItem(AComponent).FStripPosition then
    Result := Result + ' StripPosition="' + frxValueToXML(FStripPosition) + '"';
end;

procedure TfrxMarkNoItem.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
begin
  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);

  DrawBackground;

  FCellHHeight:= Round(FCellHeader.Height * FScaleY);
  FCellHWidth:= Round(FCellHeader.Width * FScaleX);
  FCellHeight:= Round(FCell.Height * FScaleY);
  FCellWidth:= Round(FCell.Width * FScaleX);

  DrawHeader(Canvas, Rect(FX, FY, FX1, FY1));
  DrawFrame;
end;

procedure TfrxMarkNoItem.DrawCell(ACanvas: TCanvas; ARect: TRect);
var LX, LY, LIdx, LIdy: Integer;
    {$IFDEF Delphi12}
    Sz: TSize;
    LStr, LStrD, LStrT: AnsiString;
    {$ELSE}
    LStr, LStrD, LStrT: String;
    {$ENDIF}
begin
  DrawStrip(ACanvas, ARect);

  with ACanvas do
  begin
    Font:= Self.Font;
    LIdy:= 1;
    if FOrientation = orHorizontal then
    begin
      LY:= ARect.Top;
      repeat
        LX:= ARect.Left;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', LIdy);
        LStrD:= '';
        LIdx:= 1;
        repeat
          LStr:= frxRemoveStrByByte(FCellItems, ':', LIdx);
          if LStr = LStrT then
          begin
            LStrD:= LStrT;
            LStrT:= '';
          end else
          begin
            if Pos('&', LStrT) > 0 then
            begin
              LStrD:= frxRemoveStrByByte(LStrT, '&', 1);
              LStrT:= frxRemoveStrByByte(LStrT, '&', 2);
            end else
            if Pos('|', LStrT) > 0 then
            begin
              LStrD:= frxRemoveStrByByte(LStrT, '|', 1);
              LStrT:= frxRemoveStrByByte(LStrT, '|', 2);
            end;
            if LStr <> LStrD then
              LStrD:= '';
          end;
          if Trim(LStr) <> '' then
             FCell.Draw(ACanvas, Rect(LX, LY, LX + FCellWidth, LY + FCellHeight),
               LStr, LStrD, FontSize, FScaleX, FScaleY);
          LStrD:= '';
          LX:= LX + FCellWidth;
          Inc(LIdx);
        until LX > ((ARect.Right - ARect.Left) + ARect.Left - FCellWidth);
        LY:= LY + FCellHeight;
        Inc(LIdy);
      until LY > ((ARect.Bottom - ARect.Top) + ARect.Top - FCellHeight);
    end else
    begin
      LX:= ARect.Left;
      repeat
        LY:= ARect.Top;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', LIdy);
        LStrD:= '';
        LIdx:= 1;
        repeat
          LStr:= frxRemoveStrByByte(FCellItems, ':', LIdx);
          if LStr = LStrT then
          begin
            LStrD:= LStrT;
            LStrT:= '';
          end else
          begin
            if Pos('&', LStrT) > 0 then
            begin
              LStrD:= frxRemoveStrByByte(LStrT, '&', 1);
              LStrT:= frxRemoveStrByByte(LStrT, '&', 2);
            end else
            if Pos('|', LStrT) > 0 then
            begin
              LStrD:= frxRemoveStrByByte(LStrT, '|', 1);
              LStrT:= frxRemoveStrByByte(LStrT, '|', 2);
            end;
            if LStr <> LStrD then
              LStrD:= '';
          end;
          if Trim(LStr) <> '' then
             FCell.Draw(ACanvas, Rect(LX, LY, LX + FCellWidth, LY + FCellHeight),
               LStr, LStrD, FontSize, FScaleX, FScaleY);
          LStrD:= '';
          LY:= LY + FCellHeight;
          Inc(LIdx);
        until LY > ((ARect.Bottom - ARect.Top) + ARect.Top - FCellHeight);
        LX:= LX + FCellWidth;
        Inc(LIdy);
      until LX > ((ARect.Right - ARect.Left) + ARect.Left - FCellWidth);
    end;
  end;
end;

procedure TfrxMarkNoItem.DrawHeader(ACanvas: TCanvas; ARect: TRect);
var LX, LY, LIdx: Integer;
    {$IFDEF Delphi12}
    Sz: TSize;
    LStr: AnsiString;
    {$ELSE}
    LStr: String;
    {$ENDIF}
    x: Extended;
begin
  ACanvas.Brush.Style:= bsClear;
  ACanvas.Pen.Color:= FCellHeader.Color;
  LX:= ARect.Left;
  LY:= ARect.Top;
  LIdx:= FStartNumber;

  if FOrientation = orVertical then
  begin
    if FCellHeader.Visible then
    begin
      repeat
        if FCellHeader.VisibleStyle then
        begin
          FCellHeader.DrawCell(ACanvas, Rect(LX, LY, LX + FCellHWidth,
            LY + FCellHHeight));
        end else
          DrawLine(LX, LY + FCellHHeight - 1,
             LX + FCellHWidth, LY + FCellHHeight - 1, FFrameWidth);

        if FCellHeader.VisibleText then
        begin
          LStr:= frxIntPad3Str(LIdx);
          ACanvas.Font:= Self.Font;
          ACanvas.Font.Height := - (ARect.Bottom - ARect.Top);
          if FScaleY > 2 then x:= 1 else x:= FScaleY;
          ACanvas.Font.Size:= Round(FFontSize * x);
          SetBkMode(ACanvas.Handle, Transparent);
          {$IFDEF Delphi12}
          GetTextExtentPoint32A(ACanvas.Handle, PAnsiChar(LStr), Length(LStr), Sz);
          ExtTextOutA(ACanvas.Handle, LX + (FCellHWidth - Sz.cx) div 2,
            LY + 1, ETO_CLIPPED, @ARect, PAnsiChar(LStr), 3, nil);
          {$ELSE}
          ExtTextOut(ACanvas.Handle, LX + (FCellHWidth - TextWidth(LStr)) div 2,
            LY + 1, ETO_CLIPPED, @ARect, PChar(LStr), 3, nil);
          {$ENDIF}
        end;
        LX:= LX + FCellHWidth;
        Inc(LIdx);
      until LX > ((ARect.Right - ARect.Left) + ARect.Left - FCellHWidth);
      DrawCell(ACanvas, Rect(ARect.Left, ARect.Top + FCellHHeight, ARect.Right,
        ARect.Bottom));
    end else
      DrawCell(ACanvas, Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom));
  end else
  begin
    if FCellHeader.Visible then
    begin
      repeat
        if FCellHeader.VisibleStyle then
        begin
           FCellHeader.DrawCell(ACanvas, Rect(LX, LY, LX + FCellHWidth,
            LY + FCellHHeight));
        end else
           DrawLine(LX + FCellHWidth - 1, LY, LX + FCellHWidth - 1,
             LY + FCellHHeight, FFrameWidth);

        if FCellHeader.VisibleText then
        begin
          LStr:= frxIntPad3Str(LIdx);
          ACanvas.Font:= Self.Font;
          ACanvas.Font.Height := - (ARect.Bottom - ARect.Top);
          if FScaleY > 2 then x:= 1 else x:= FScaleY;
          ACanvas.Font.Size:= Round(FFontSize * x);
          SetBkMode(ACanvas.Handle, Transparent);
          {$IFDEF Delphi12}
          GetTextExtentPoint32A(ACanvas.Handle, PAnsiChar(LStr), Length(LStr), Sz);
          ExtTextOutA(ACanvas.Handle, LX + (FCellHWidth - Sz.cx) div 2,
            LY + 1, ETO_CLIPPED, @ARect, PAnsiChar(LStr), 3, nil);
          {$ELSE}
          ExtTextOut(ACanvas.Handle, LX + (FCellHWidth - TextWidth(LStr)) div 2,
            LY + 1, ETO_CLIPPED, @ARect, PChar(LStr), 3, nil);
          {$ENDIF}
        end;
        LY:= LY + FCellHHeight;
        Inc(LIdx);
      until LY > ((ARect.Bottom - ARect.Top) + ARect.Top - FCellHHeight);
      DrawCell(ACanvas, Rect(ARect.Left + FCellHWidth, ARect.Top,
        ARect.Right, ARect.Bottom));
    end else
      DrawCell(ACanvas, Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom));
  end;
end;

procedure TfrxMarkNoItem.DrawStrip(ACanvas: TCanvas; ARect: TRect);
var LX, LY, LIdx: Integer;
begin
  if (FStripPosition = spNone) then exit;
  with ACanvas do
  begin
    if FOrientation = orHorizontal then
    begin
      LY:= ARect.Top;
      LIdx:= 1;
      repeat
        if (FStripPosition = spOdd) then
        begin
          if (LIdx mod 2) > 0 then
          begin
            Brush.Style:= bsSolid;
            Brush.Color:= FCell.StripColor;
            Pen.Style:= psSolid;
            Pen.Color:= FCell.StripColor;
          end else
          begin
            Brush.Style:= bsClear;
            Pen.Style:= psClear;
          end;
        end else
        begin
          if (LIdx mod 2) = 0 then
          begin
            Brush.Style:= bsSolid;
            Brush.Color:= FCell.StripColor;
            Pen.Style:= psSolid;
            Pen.Color:= FCell.StripColor;
          end else
          begin
            Brush.Style:= bsClear;
            Pen.Style:= psClear;
          end;
        end;
        Rectangle(ARect.Left + 1, LY, ARect.Right, LY + FCellHeight);

        LY:= LY + FCellHeight;
        Inc(LIdx);
      until LY > ((ARect.Bottom - ARect.Top) + ARect.Top - FCellHeight);
    end else
    begin
      LX:= ARect.Left;
      LIdx:= 1;
      repeat
        if (FStripPosition = spOdd) then
        begin
          if (LIdx mod 2) > 0 then
          begin
            Brush.Style:= bsSolid;
            Brush.Color:= FCell.StripColor;
            Pen.Style:= psSolid;
            Pen.Color:= FCell.StripColor;
          end else
          begin
            Brush.Style:= bsClear;
            Pen.Style:= psClear;
          end;
        end else
        begin
          if (LIdx mod 2) = 0 then
          begin
            Brush.Style:= bsSolid;
            Brush.Color:= FCell.StripColor;
            Pen.Style:= psSolid;
            Pen.Color:= FCell.StripColor;
          end else
          begin
            Brush.Style:= bsClear;
            Pen.Style:= psClear;
          end;
        end;
        Rectangle(LX, ARect.Top + 1, LX + FCellWidth, ARect.Bottom);

        LX:= LX + FCellWidth;
        Inc(LIdx);
      until LX > (((ARect.Right - ARect.Left)) + ARect.Left - FCellWidth);
    end;
  end;
end;

initialization
  frxObjects.RegisterObject1(TfrxMarkNoItem, nil, '', '', 0, 20);

finalization
  frxObjects.UnRegister(TfrxMarkNoItem);


end.
