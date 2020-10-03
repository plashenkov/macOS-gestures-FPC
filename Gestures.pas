{*
 * macOS Gestures for FreePascal
 *
 * Copyright (c) 2020 Yuri Plashenkov
 *
 * MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *}

unit Gestures;

{$mode objfpc}{$H+}
{$modeswitch objectivec2}

interface

uses
  Classes, Controls, CocoaAll;

type
  { TGesture }

  TGestureState = (gsPossible, gsBegan, gsChanged, gsEnded, gsCancelled, gsFailed);

  TGesture = class(TComponent)
  private
    FCocoaGesture: NSGestureRecognizer;
    FControl: TWinControl;
    procedure SetControl(AControl: TWinControl);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  published
    property Control: TWinControl read FControl write SetControl;
  end;

  { TCocoaMagnificationGesture }

  TMagnificationGesture = class;

  TCocoaMagnificationGesture = objcclass(NSMagnificationGestureRecognizer)
  public
    FLCLGesture: TMagnificationGesture;
    procedure HandleGesture; message 'handleGesture';
  end;

  { TMagnificationGesture }

  TMagnificationGestureEvent = procedure(Sender: TMagnificationGesture;
    State: TGestureState; Magnification: Double) of object;

  TMagnificationGesture = class(TGesture)
  private
    FOnGesture: TMagnificationGestureEvent;
    function GetCocoaGesture: TCocoaMagnificationGesture;
  public
    constructor Create(AOwner: TComponent); override;
    property CocoaGesture: TCocoaMagnificationGesture read GetCocoaGesture;
  published
    property OnGesture: TMagnificationGestureEvent read FOnGesture write FOnGesture;
  end;

implementation

{ TGesture }

procedure TGesture.SetControl(AControl: TWinControl);
begin
  if FControl = AControl then Exit;

  if Assigned(FControl) then
  begin
    FControl.RemoveFreeNotification(Self);
    NSView(FControl.Handle).removeGestureRecognizer(FCocoaGesture);
  end;

  FControl := AControl;
  FControl.FreeNotification(Self);
  NSView(FControl.Handle).addGestureRecognizer(FCocoaGesture);
end;

procedure TGesture.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FControl) then
    FControl := nil;
end;

{ TCocoaMagnificationGesture }

procedure TCocoaMagnificationGesture.HandleGesture;
begin
  if Assigned(FLCLGesture.OnGesture) then
    FLCLGesture.OnGesture(FLCLGesture, TGestureState(state), magnification);
end;

{ TMagnificationGesture }

function TMagnificationGesture.GetCocoaGesture: TCocoaMagnificationGesture;
begin
  Result := TCocoaMagnificationGesture(FCocoaGesture);
end;

constructor TMagnificationGesture.Create(AOwner: TComponent);
begin
  inherited;
  FCocoaGesture := TCocoaMagnificationGesture.alloc.init.autorelease;
  FCocoaGesture.setTarget(FCocoaGesture);
  FCocoaGesture.setAction(objcselector('handleGesture'));
  TCocoaMagnificationGesture(FCocoaGesture).FLCLGesture := Self;
end;

end.
