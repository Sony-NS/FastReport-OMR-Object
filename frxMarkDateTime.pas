
{******************************************}
{                                          }
{  MarkDateTime Add-In Object (FastReport) }
{                                          }
{            Copyright (c) 2017            }
{               by Sony NS,                }
{            CrossoverLab Inc.             }
{                                          }
{******************************************}

unit frxMarkDateTime;

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
  TfrxMarkDateTimeObject = class(TComponent)  // fake component
  end;

  TfrxMarkDateTime = class(TfrxView)
  private
    FCellHeader: TfrxCellHeader;
    FCell: TfrxCell;
    //Scale XY
    FCellHHeight: Integer;
    FCellHWidth: Integer;
    FCellHeight: Integer;
    FCellWidth: Integer;
    FDefaultValues: String;
    //FCellItems: String;
    FFontSize: Integer;
    FFontHeight: Integer;
    FOrientation: TfrxCellOrientation;
    FDateFormat: TfrxDateFormat;
    FStripPosition: TfrxStripPosition;
    //FStripColor: TColor;
    FStyle: String;
    FStripColor: TColor;
    procedure CalcSize;
    procedure DrawHeader(ACanvas: TCanvas; ARect: TRect);
    procedure DrawCell(ACanvas: TCanvas; ARect: TRect);
    procedure DrawStrip(ACanvas: TCanvas; ARect: TRect);
    procedure SetDateFormat(const Value: TfrxDateFormat);
    procedure SetCellHeader(const Value: TfrxCellHeader);
    procedure SetOrientation(const Value: TfrxCellOrientation);
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
    property DefaultValues: String read FDefaultValues write FDefaultValues;
    //property Color;
    //property Cursor;
    property DateFormat: TfrxDateFormat read FDateFormat write SetDateFormat default dfDDMMYY;
    property Font;
    property Frame;
    property Orientation: TfrxCellOrientation read FOrientation write SetOrientation;// default orVertical;
    property StripPosition: TfrxStripPosition read FStripPosition write FStripPosition default spOdd;
    property StripColor: TColor read FStripColor write SetStripColor;
  end;

implementation

uses frxMarkDateTimeRTTI, frxGraphicUtils, frxUtils, frxDsgnIntf, frxRes, frxXML;

procedure TfrxMarkDateTime.CalcSize;
begin
  if FOrientation = orVertical then
  begin
    case FDateFormat of
     dfDDMMYY: begin
         Height:= 11 * FCellHeight;
         Width:= 6 * FCellWidth;
       end;
     dfDDMMYYYY: begin
         Height:= 11 * FCellHeight;
         Width:= 8 * FCellWidth;
       end;
     dfMMDDYY: begin
         Height:= 11 * FCellHeight;
         Width:= 6 * FCellWidth;
       end;
     dfMMDDYYYY: begin
         Height:= 11 * FCellHeight;
         Width:= 8 * FCellWidth;
       end;
     dfDDMMYY_hhmmss: begin
         Height:= 11 * FCellHeight;
         Width:= 13 * FCellWidth;
       end;
    end;
  end else
  begin
    case FDateFormat of
     dfDDMMYY: begin
         Width:= 11 * FCellHeight;
         Height:= 6 * FCellWidth;
       end;
     dfDDMMYYYY: begin
         Width:= 11 * FCellHeight;
         Height:= 8 * FCellWidth;
       end;
     dfMMDDYY: begin
         Width:= 11 * FCellHeight;
         Height:= 6 * FCellWidth;
       end;
     dfMMDDYYYY: begin
         Width:= 11 * FCellHeight;
         Height:= 8 * FCellWidth;
       end;
     dfDDMMYY_hhmmss: begin
         Width:= 11 * FCellHeight;
         Height:= 13 * FCellWidth;
       end;
    end;
  end;
end;

constructor TfrxMarkDateTime.Create(AOwner: TComponent);
begin
  inherited;
  FCellHeader:= TfrxCellHeader.Create;
  FCellHeader.VisibleStyle:= True;
  FCellHeader.VisibleText:= True;
  FCellHeader.Visible:= True;
  FCell:= TfrxCell.Create;
  FStripColor:= FCell.StripColor;
  //FDefaultValues:= '';
  FFontSize:= 8;
  FOrientation:= orVertical;
  FDateFormat:= dfDDMMYY;
  FStripPosition:= spOdd;
  
  Frame.Color:= clRed;
  Frame.Typ:= [ftLeft, ftRight, ftTop, ftBottom];

  FCellHHeight:= FCellHeader.Height;
  FCellHWidth:= FCellHeader.Width;
  FCellHeight:= FCell.Height;
  FCellWidth:= FCell.Width;

  CalcSize;
end;

class function TfrxMarkDateTime.GetDescription: String;
begin
  Result := 'Mark DateTime';//frxResources.Get('obMarkDateTime');
end;

procedure TfrxMarkDateTime.SetCellHeader(const Value: TfrxCellHeader);
begin
  FCellHeader.Assign(Value);
end;

procedure TfrxMarkDateTime.SetDateFormat(const Value: TfrxDateFormat);
begin
  if Value <> FDateFormat then
  begin
    FDateFormat:= Value;
    CalcSize;
  end;
end;

procedure TfrxMarkDateTime.SetOrientation(const Value: TfrxCellOrientation);
begin
  if Value <> FOrientation then
  begin
    FOrientation:= Value;
    CalcSize;
  end;
end;

procedure TfrxMarkDateTime.SetStripColor(const Value: TColor);
begin
  if FStripColor <> Value then
  begin
    FStripColor := Value;
    FCell.StripColor:= FStripColor;
  end;
end;

destructor TfrxMarkDateTime.Destroy;
begin
  FCellHeader.Free;
  FCell.Free;
  inherited;
end;

function TfrxMarkDateTime.Diff(AComponent: TfrxComponent): String;
begin
  Result := inherited Diff(AComponent);

  if FDateFormat <> TfrxMarkDateTime(AComponent).FDateFormat then
    Result := Result + ' DateFormat="' + frxValueToXML(FDateFormat) + '"';
  if FDefaultValues <> TfrxMarkDateTime(AComponent).FDefaultValues then
    Result := Result + ' DefaultValues="' + frxValueToXML(FDefaultValues) + '"';
  if FOrientation <> TfrxMarkDateTime(AComponent).FOrientation then
    Result := Result + ' Orientation="' + frxValueToXML(FOrientation) + '"';
  if FStripPosition <> TfrxMarkDateTime(AComponent).FStripPosition then
    Result := Result + ' StripPosition="' + frxValueToXML(FStripPosition) + '"';
end;

procedure TfrxMarkDateTime.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
begin
  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);

  DrawBackground;

  FCellHHeight:= Round(FCellHeader.Height * FScaleY);
  FCellHWidth:= Round(FCellHeader.Width * FScaleX);
  FCellHeight:= Round(FCell.Height * FScaleY);
  FCellWidth:= Round(FCell.Width * FScaleX);

  DrawHeader(FCanvas, Rect(FX, FY, FX1, FY1));

  DrawFrame;
end;

procedure TfrxMarkDateTime.DrawCell(ACanvas: TCanvas; ARect: TRect);
var LX, LY, LX1, LY1, LIdy: Integer;
    {$IFDEF Delphi12}
    Sz: TSize;
    LStr, LStrD, LStrT: AnsiString;
    {$ELSE}
    LStr, LStrD, LStrT: String;
    {$ENDIF}

    procedure DrawCellItem(ALeft, ATop, ARight, ABottom, AStart, AEnd: Integer;
      AStrD: String);
    var x: Extended;
    begin
      with FCanvas do
      begin
        Pen.Style:= psSolid;
        LStrD:= '';
        if FOrientation = orVertical then
        begin
          repeat
            LStr:= IntToStr(AStart);
            if LStr = AStrD then
            begin
              LStrD:= AStrD;
              AStrD:= '';
            end;

            if Trim(LStrD) <> '' then
            begin
              Brush.Style:= bsSolid;
              Brush.Color:= clBlack;
              Pen.Color:= clBlack;
            end else
            begin
              Brush.Style:= bsClear;
              Pen.Color:= FCell.Color;
            end;

            case FCell.CellStyle of
             ckBubble:
               Ellipse(Aleft + FCell.HorizontalSpace * Round(FScaleX),
                 ATop + FCell.VerticalSpace * Round(FScaleY),
                 ARight - FCell.HorizontalSpace * Round(FScaleX),
                 ATop + FCellHeight - FCell.VerticalSpace * Round(FScaleY));
             ckEllipse:
               Ellipse(ALeft + FCell.HorizontalSpace * Round(FScaleX),
                 ATop + 3 + FCell.VerticalSpace * Round(FScaleY),
                 ARight - FCell.HorizontalSpace * Round(FScaleX),
                 ATop + FCellHeight - FCell.VerticalSpace - 2 * Round(FScaleY));
             ckRectangle:
               Rectangle(ALeft + FCell.HorizontalSpace * Round(FScaleX),
                 ATop + FCell.VerticalSpace * Round(FScaleY),
                 ARight - FCell.HorizontalSpace + 1 * Round(FScaleX),
                 ATop + FCellHeight - FCell.VerticalSpace + 1 * Round(FScaleY));
            end;

            if Trim(LStrD) = '' then
            begin
              Font:= Self.Font;
              Font.Height := - (ABottom - ATop);
              if FScaleY > 2 then x:= 1 else x:= FScaleY;
              Font.Size:= Round(FFontSize * x);
              SetBkMode(Handle, Transparent);
              {$IFDEF Delphi12}
              GetTextExtentPoint32A(Handle, PAnsiChar(LStr), Length(LStr), Sz);
              ExtTextOutA(Handle, ALeft + (ARight - ALeft - Sz.cx) div 2,
                Round(ATop + 3 * FScaleY), ETO_CLIPPED, @ARect, PAnsiChar(LStr), 1, nil);
              {$ELSE}
              ExtTextOut(Handle, ALeft + (FCellWidth - TextWidth(LStr)) div 2,
                Round(ATop + 3 * FScaleY), ETO_CLIPPED, @ARect, PChar(LStr), 1, nil);
              {$ENDIF}
            end;

            LStrD:= '';
            ATop:= ATop + FCellHeight;
            Inc(AStart);
          until AStart > AEnd;
        end else
        begin
          repeat
            LStr:= IntToStr(AStart);
            if LStr = AStrD then
            begin
              LStrD:= AStrD;
              AStrD:= '';
            end;

            if Trim(LStrD) <> '' then
            begin
              Brush.Style:= bsSolid;
              Brush.Color:= clBlack;
              Pen.Color:= clBlack;
            end else
            begin
              Brush.Style:= bsClear;
              Pen.Color:= FCell.Color;
            end;

            case FCell.CellStyle of
             ckBubble:
               Ellipse(ALeft + FCell.HorizontalSpace * Round(FScaleX),
                 ATop + FCell.VerticalSpace * Round(FScaleY),
                 ALeft + FCellWidth - FCell.HorizontalSpace * Round(FScaleX),
                 ABottom - FCell.VerticalSpace * Round(FScaleY));
             ckEllipse:
               Ellipse(ALeft + FCell.HorizontalSpace * Round(FScaleX),
                 ATop + 3 + FCell.VerticalSpace * Round(FScaleY),
                 ALeft + FCellWidth - FCell.HorizontalSpace * Round(FScaleX),
                 ABottom - FCell.VerticalSpace - 2 * Round(FScaleY));
             ckRectangle:
               Rectangle(ALeft + FCell.HorizontalSpace * Round(FScaleX),
                 ATop + FCell.VerticalSpace * Round(FScaleY),
                 ALeft + FCellWidth - FCell.HorizontalSpace + 1 * Round(FScaleX),
                 ABottom - FCell.VerticalSpace + 1 * Round(FScaleY));
            end;

            if Trim(LStrD) = '' then
            begin
              Font:= Self.Font;
              Font.Height := - (ABottom - ATop);
              if FScaleY > 2 then x:= 1 else x:= FScaleY;
              Font.Size:= Round(FFontSize * x);
              SetBkMode(Handle, Transparent);
              {$IFDEF Delphi12}
              GetTextExtentPoint32A(Handle, PAnsiChar(LStr), Length(LStr), Sz);
              ExtTextOutA(Handle, ALeft + (FCellWidth - Sz.cx) div 2,
                ATop + 3, ETO_CLIPPED, @ARect, PAnsiChar(LStr), 1, nil);
              {$ELSE}
              ExtTextOut(Handle, ALeft + (FCellWidth - TextWidth(LStr)) div 2,
                ATop + 3, ETO_CLIPPED, @ARect, PChar(LStr), 1, nil);
              {$ENDIF}
            end;

            LStrD:= '';
            ALeft:= ALeft + FCellWidth;
            Inc(AStart);
          until AStart > AEnd;
        end;
      end;

    end;

begin
  DrawStrip(ACanvas, ARect);

  case FDateFormat of
    dfDDMMYY: begin
      if FOrientation = orVertical then
      begin
        LX:= ARect.Left;
        LY:= ARect.Top;
        LX1:= LX + FCellWidth;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 1);
        DrawCellItem(LX, LY, LX1, LY1, 0, 3, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 2);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 3);
        DrawCellItem(LX, LY, LX1, LY1, 0, 1, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 4);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 5);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 6);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
      end else
      begin
        LX:= ARect.Left;
        LY:= ARect.Top;
        LX1:= LX + FCellWidth;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 1);
        DrawCellItem(LX, LY, LX1, LY1, 0, 3, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 2);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 3);
        DrawCellItem(LX, LY, LX1, LY1, 0, 1, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 4);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 5);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 6);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
      end;
    end;
    dfDDMMYYYY: begin
      if FOrientation = orVertical then
      begin
        LX:= ARect.Left;
        LY:= ARect.Top;
        LX1:= LX + FCellWidth;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 1);
        DrawCellItem(LX, LY, LX1, LY1, 0, 3, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 2);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 3);
        DrawCellItem(LX, LY, LX1, LY1, 0, 1, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 4);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 5);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 6);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 7);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 8);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
      end else
      begin
        LX:= ARect.Left;
        LY:= ARect.Top;
        LX1:= LX + FCellWidth;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 1);
        DrawCellItem(LX, LY, LX1, LY1, 0, 3, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 2);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 3);
        DrawCellItem(LX, LY, LX1, LY1, 0, 1, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 4);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 5);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 6);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 7);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 8);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
      end;
    end;
    dfMMDDYY: begin
      if FOrientation = orVertical then
      begin
        LX:= ARect.Left;
        LY:= ARect.Top;
        LX1:= LX + FCellWidth;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 1);
        DrawCellItem(LX, LY, LX1, LY1, 0, 1, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 2);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 3);
        DrawCellItem(LX, LY, LX1, LY1, 0, 3, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 4);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 5);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 6);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
      end else
      begin
        LX:= ARect.Left;
        LY:= ARect.Top;
        LX1:= LX + FCellWidth;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 1);
        DrawCellItem(LX, LY, LX1, LY1, 0, 1, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 2);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 3);
        DrawCellItem(LX, LY, LX1, LY1, 0, 3, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 4);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 5);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 6);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
      end;
    end;
    dfMMDDYYYY: begin
      if FOrientation = orVertical then
      begin
        LX:= ARect.Left;
        LY:= ARect.Top;
        LX1:= LX + FCellWidth;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 1);
        DrawCellItem(LX, LY, LX1, LY1, 0, 1, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 2);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 3);
        DrawCellItem(LX, LY, LX1, LY1, 0, 3, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 4);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 5);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 6);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 7);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 8);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
      end else
      begin
        LX:= ARect.Left;
        LY:= ARect.Top;
        LX1:= LX + FCellWidth;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 1);
        DrawCellItem(LX, LY, LX1, LY1, 0, 1, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 2);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 3);
        DrawCellItem(LX, LY, LX1, LY1, 0, 3, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 4);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 5);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 6);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 7);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 8);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
      end;
    end;
    dfDDMMYY_hhmmss: begin
      if FOrientation = orVertical then
      begin
        LX:= ARect.Left;
        LY:= ARect.Top;
        LX1:= LX + FCellWidth;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 1);
        DrawCellItem(LX, LY, LX1, LY1, 0, 3, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 2);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 3);
        DrawCellItem(LX, LY, LX1, LY1, 0, 1, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 4);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 5);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 6);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        //
        LX:= LX1;
        LX1:= LX + FCellWidth;
        //DrawCellItem(LX, LY, LX1, LY1, 0, 0, LStrT);
        //
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 8);
        DrawCellItem(LX, LY, LX1, LY1, 0, 2, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 9);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 10);
        DrawCellItem(LX, LY, LX1, LY1, 0, 6, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 11);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 12);
        DrawCellItem(LX, LY, LX1, LY1, 0, 6, LStrT);
        LX:= LX1;
        LX1:= LX + FCellWidth;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 13);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
      end else
      begin
        LX:= ARect.Left;
        LY:= ARect.Top;
        LX1:= LX + FCellWidth;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 1);
        DrawCellItem(LX, LY, LX1, LY1, 0, 3, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 2);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 3);
        DrawCellItem(LX, LY, LX1, LY1, 0, 1, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 4);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 5);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 6);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        //
        LY:= LY1;
        LY1:= LY + FCellHeight;
        //DrawCellItem(LX, LY, LX1, LY1, 0, 0);
        //
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 8);
        DrawCellItem(LX, LY, LX1, LY1, 0, 2, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 9);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 10);
        DrawCellItem(LX, LY, LX1, LY1, 0, 6, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 11);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 12);
        DrawCellItem(LX, LY, LX1, LY1, 0, 6, LStrT);
        LY:= LY1;
        LY1:= LY + FCellHeight;
        LStrT:= frxRemoveStrByByte(FDefaultValues, ':', 13);
        DrawCellItem(LX, LY, LX1, LY1, 0, 9, LStrT);
      end;
    end;
  end;
end;

procedure TfrxMarkDateTime.DrawHeader(ACanvas: TCanvas; ARect: TRect);
var LX, LY, LIdx: Integer;
    {$IFDEF Delphi12}
    Sz: TSize;
    LStr: AnsiString;
    {$ELSE}
    LStr: String;
    {$ENDIF}
    x: Extended;
begin
  with ACanvas do
  begin
    Brush.Style:= bsClear;
    Pen.Color:= FCellHeader.Color;
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
            case FCellHeader.HeaderStyle of
             ckBubble:
               Ellipse(LX + FCellHeader.HorizontalSpace,
                 LY + FCellHeader.VerticalSpace,
                 LX + FCellHWidth - FCellHeader.HorizontalSpace,
                 LY + FCellHHeight - FCellHeader.VerticalSpace);
             ckEllipse:
               Ellipse(LX + FCellHeader.HorizontalSpace,
                 LY + 3 + FCellHeader.VerticalSpace,
                 LX + FCellHWidth - FCellHeader.HorizontalSpace,
                 LY + FCellHHeight - FCellHeader.VerticalSpace - 2);
             ckRectangle:
               Rectangle(LX + FCellHeader.HorizontalSpace,
                 LY + FCellHeader.VerticalSpace,
                 LX + FCellHWidth - FCellHeader.HorizontalSpace + 1,
                 LY + FCellHHeight - FCellHeader.VerticalSpace + 1);
            end;
          end else
             DrawLine(LX, LY + FCellHHeight - 1,
               LX + FCellHWidth, LY + FCellHHeight - 1, FFrameWidth);

          if FCellHeader.VisibleText then
          begin
            LStr:= frxRemoveStrByByte(FDefaultValues, ':', LIdx);
            if Trim(LStr) <> '' then
            begin
              Font:= Self.Font;
              Font.Height := - (ARect.Bottom - ARect.Top);
              if FScaleY > 2 then x:= 1 else x:= FScaleY;
              Font.Size:= Round(FFontSize * x);
              SetBkMode(Handle, Transparent);
              {$IFDEF Delphi12}
              GetTextExtentPoint32A(Handle, PAnsiChar(LStr), Length(LStr), Sz);
              ExtTextOutA(Handle, LX + (FCellHWidth - Sz.cx) div 2,
                LY + 1, ETO_CLIPPED, @ARect, PAnsiChar(LStr), 3, nil);
              {$ELSE}
              ExtTextOut(Handle, LX + (FCellHWidth - TextWidth(LStr)) div 2,
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
            case FCellHeader.HeaderStyle of
             ckBubble:
               Ellipse(LX + FCellHeader.HorizontalSpace,
                 LY + FCellHeader.VerticalSpace,
                 LX + FCellHWidth - FCellHeader.HorizontalSpace,
                 LY + FCellHHeight - FCellHeader.VerticalSpace);
             ckEllipse:
               Ellipse(LX + FCellHeader.HorizontalSpace,
                 LY + 3 + FCellHeader.VerticalSpace,
                 LX + FCellHWidth - FCellHeader.HorizontalSpace,
                 LY + FCellHHeight - FCellHeader.VerticalSpace - 2);
             ckRectangle:
               Rectangle(LX + FCellHeader.HorizontalSpace,
                 LY + FCellHeader.VerticalSpace,
                 LX + FCellHWidth - FCellHeader.HorizontalSpace + 1,
                 LY + FCellHHeight - FCellHeader.VerticalSpace + 1)
             end;
          end else
             DrawLine(LX + FCellHWidth - 1, LY, LX + FCellHWidth - 1,
               LY + FCellHHeight, FFrameWidth);

          if FCellHeader.VisibleText then
          begin
            LStr:= frxRemoveStrByByte(FDefaultValues, ':', LIdx);
            if Trim(LStr) <> '' then
            begin
              Font:= Self.Font;
              Font.Height := - (ARect.Bottom - ARect.Top);
              if FScaleY > 2 then x:= 1 else x:= FScaleY;
              Font.Size:= Round(FFontSize * x);
              SetBkMode(Handle, Transparent);
              {$IFDEF Delphi12}
              GetTextExtentPoint32A(Handle, PAnsiChar(LStr), Length(LStr), Sz);
              ExtTextOutA(Handle, LX + (FCellHWidth - Sz.cx) div 2,
                LY + 1, ETO_CLIPPED, @ARect, PAnsiChar(LStr), 3, nil);
              {$ELSE}
              ExtTextOut(Handle, LX + (FCellHWidth - TextWidth(LStr)) div 2,
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
end;

procedure TfrxMarkDateTime.DrawStrip(ACanvas: TCanvas; ARect: TRect);
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
  frxObjects.RegisterObject1(TfrxMarkDateTime, nil, '', '', 0, 20);

finalization
  frxObjects.UnRegister(TfrxMarkDateTime);

end.
