
{******************************************}
{                                          }
{    MarkItem Add-In Object (FastReport)   }
{                                          }
{            Copyright (c) 2017            }
{               by Sony NS,                }
{              CrossoverLab.               }
{                                          }
{******************************************}

unit frxMarkItem;

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
  TfrxMarkItemObject = class(TComponent)  // fake component
  end;

  TfrxMarkItem = class(TfrxView)
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
    FCellLineItems: TStrings;
    FDefaultValues: String;
    FFontSize: Integer;
    FFontHeight: Integer;
    FOrientation: TfrxCellOrientation;
    FStripPosition: TfrxStripPosition;
    FStyle: String;
    FItemChanged: Boolean;
    FStripColor: TColor;

    procedure CalcCellSize;
    procedure CalcItemCell;
    procedure CalcOrientationCell;
    procedure CalcSize;

    procedure SetCellItem(AValue: String);
    procedure DrawHeader(ACanvas: TCanvas; ARect: TRect);
    procedure DrawCell(ACanvas: TCanvas; ARect: TRect);
    procedure DrawStrip(ACanvas: TCanvas; ARect: TRect);
    procedure SetOrientation(const Value: TfrxCellOrientation);
    procedure SetCellHeader(const Value: TfrxCellHeader);
    procedure SetCellLineItems(const Value: TStrings);
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
    property CellLineItems: TStrings read FCellLineItems write SetCellLineItems;
    property DefaultValues: String read FDefaultValues write FDefaultValues;
    //property Color;
    //property Cursor;
    property Font;
    property Frame;
    property Orientation: TfrxCellOrientation read FOrientation write SetOrientation;// default orVertical;
    property StripPosition: TfrxStripPosition read FStripPosition write FStripPosition default spOdd;
    property StripColor: TColor read FStripColor write SetStripColor;
  end;

implementation

uses frxMarkItemRTTI, frxGraphicUtils, frxUtils, frxDsgnIntf, frxRes, frxXML,
  frxMarkEditor;

procedure TfrxMarkItem.CalcSize;
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

procedure TfrxMarkItem.CalcCellSize;
begin
  FCellHHeight:= FCellHeader.Height;
  FCellHWidth:= FCellHeader.Width;
  FCellHeight:= FCell.Height;
  FCellWidth:= FCell.Width;
end;

procedure TfrxMarkItem.CalcItemCell;
var LStr: TStrings;
    x: Integer;
begin
  CalcCellSize;
  LStr:= TStringList.Create;
  try
    x:= 0;
    LStr.Delimiter:= ':';
    LStr.DelimitedText:= FCellItems;

    if (FOrientation = orVertical) then
    begin
      if FItemChanged then
      begin
        x:= Round(Height / FCellHeight);
        if (x > (LStr.Count + 1)) then
           FCalcVerticalSize:= LStr.Count + 1
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
        if x > (LStr.Count + 1) then
           FCalcVerticalSize:= LStr.Count + 1
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
  finally
    LStr.Free;
    CalcSize;
  end;
end;

procedure TfrxMarkItem.CalcOrientationCell;
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

constructor TfrxMarkItem.Create(AOwner: TComponent);
begin
  inherited;

  FCellHeader:= TfrxCellHeader.Create;
  FCellHeader.VisibleStyle:= True;
  FCellHeader.VisibleText:= True;
  FCellHeader.Visible:= True;
  FCell:= TfrxCell.Create;
  FStripColor:= FCell.StripColor;
  FCellLineItems:= TStringList.Create;
  FFontSize:= 8;
  FOrientation:= orVertical;
  FCellItems:= 'A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z';
  FItemChanged:= True;//False;
  //FDefaultValues:= '';
  Frame.Color:= clRed;
  Frame.Typ:= [ftLeft, ftRight, ftTop, ftBottom];

  FCellHHeight:= FCellHeader.Height;
  FCellHWidth:= FCellHeader.Width;
  FCellHeight:= FCell.Height;
  FCellWidth:= FCell.Width;

  FCalcVerticalSize:= 27;
  FCalcHorizontalSize:= 10;

  CalcSize;
end;

class function TfrxMarkItem.GetDescription: String;
begin
  Result := 'Mark Item';//frxResources.Get('obMarkItem');
end;

procedure TfrxMarkItem.SetCellLineItems(const Value: TStrings);
begin
  FCellLineItems := Value;
end;

procedure TfrxMarkItem.SetCellHeader(const Value: TfrxCellHeader);
begin
  FCellHeader.Assign(Value);
end;

procedure TfrxMarkItem.SetCellItem(AValue: String);
var LStr: TStrings;
    x: Integer;
begin
  if (AValue <> FCellItems) then
  begin
    FCellItems:= AValue;
    FItemChanged:= True;
    CalcItemCell;
  end;
end;

procedure TfrxMarkItem.SetOrientation(const Value: TfrxCellOrientation);
begin
  if Value <> FOrientation then
  begin
    FOrientation:= Value;
    CalcOrientationCell;
  end;
end;

procedure TfrxMarkItem.SetStripColor(const Value: TColor);
begin
  if FStripColor <> Value then
  begin
    FStripColor := Value;
    FCell.StripColor:= FStripColor;
  end;
end;

destructor TfrxMarkItem.Destroy;
begin
  FCellHeader.Free;
  FCell.Free;
  FCellLineItems.Free;
  inherited;
end;

function TfrxMarkItem.Diff(AComponent: TfrxComponent): String;
begin
  Result := inherited Diff(AComponent);

  if FCellItems <> TfrxMarkItem(AComponent).FCellItems then
    Result := Result + ' CellItems="' + frxValueToXML(FCellItems) + '"';
  if FCellLineItems <> TfrxMarkItem(AComponent).FCellLineItems then
    Result := Result + ' CellLineItems="' + frxValueToXML(FCellLineItems.Text) + '"';
  if FDefaultValues <> TfrxMarkItem(AComponent).FDefaultValues then
    Result := Result + ' DefaultValues="' + frxValueToXML(FDefaultValues) + '"';
  if FOrientation <> TfrxMarkItem(AComponent).FOrientation then
    Result := Result + ' Orientation="' + frxValueToXML(FOrientation) + '"';
  if FStripPosition <> TfrxMarkItem(AComponent).FStripPosition then
    Result := Result + ' StripPosition="' + frxValueToXML(FStripPosition) + '"';
end;

procedure TfrxMarkItem.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
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

procedure TfrxMarkItem.DrawCell(ACanvas: TCanvas; ARect: TRect);
var LX, LY, LIdx, LIdy: Integer;
    {$IFDEF Delphi12}
    Sz: TSize;
    LStr: AnsiString;
    LStrD, LStrT: AnsiString;
    {$ELSE}
    LStr: String;
    LStrD, LStrT: String;
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
          if (FCellLineItems.Count = 0) then
            LStr:= frxRemoveStrByByte(FCellItems, ':', LIdx)
          else
          if (LIdy <= FCellLineItems.Count) then
            LStr:= frxRemoveStrByByte(FCellLineItems[LIdy-1], ':', LIdx)
          else
            LStr:= '';

          if LStr = LStrT then
          begin
            LStrD:= LStrT;
            LStrT:= '';
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
          if (FCellLineItems.Count = 0) then
            LStr:= frxRemoveStrByByte(FCellItems, ':', LIdx)
          else
          if (LIdy <= FCellLineItems.Count) then
            LStr:= frxRemoveStrByByte(FCellLineItems[LIdy-1], ':', LIdx)
          else
            LStr:= '';

          if LStr = LStrT then
          begin
            LStrD:= LStrT;
            LStrT:= '';
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

procedure TfrxMarkItem.DrawHeader(ACanvas: TCanvas; ARect: TRect);
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
  LIdx:= 1;//FStartNumber;

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
          LStr:= frxRemoveStrByByte(FDefaultValues, ':', LIdx);
          if Trim(LStr) <> '' then
          begin
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
          LStr:= frxRemoveStrByByte(FDefaultValues, ':', LIdx);
          if Trim(LStr) <> '' then
          begin
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

procedure TfrxMarkItem.DrawStrip(ACanvas: TCanvas; ARect: TRect);
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
      until LX > ((ARect.Right - ARect.Left) + ARect.Left - FCellWidth);
    end;
  end;
end;

initialization
  frxObjects.RegisterObject1(TfrxMarkItem, nil, '', '', 0, 20);

finalization
  frxObjects.UnRegister(TfrxMarkItem);


end.
