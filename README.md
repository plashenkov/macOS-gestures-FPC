# macOS Gestures for FreePascal

Convenient FreePascal classes for handling macOS gestures.

Currently only magnification gesture is implemented, but other ones can be implemented easily
in a similar way.

## Usage Example

Let's assume your scalable control has a `Scale` property and you want to allow
an end user to scale it by using typical trackpad gesture. Here is the code:

```pascal
uses
  Gestures;

type
  TForm_Main = class(TForm)
  private
    Gesture: TMagnificationGesture;
    InitialScale: Double;
  end;

procedure TForm_Main.FormCreate(Sender: TObject);
begin
  Gesture := TMagnificationGesture.Create(Self);
  Gesture.Control := MyScalableControl;
  Gesture.OnGesture := @MagnificationGestureGesture;
end;

procedure TForm_Main.MagnificationGestureGesture(Sender: TMagnificationGesture;
  State: TGestureState; Magnification: Double);
begin
  case State of
    gsBegan:
      InitialScale := MyScalableControl.Scale;
    gsChanged:
      MyScalableControl.Scale := InitialScale * (1 + Magnification);
  end;
end;
```

## Credits

- [Yuri Plashenkov](https://github.com/plashenkov)

## License

This package is licensed under the [MIT license](LICENSE.md).
