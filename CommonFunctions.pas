unit CommonFunctions;

Interface

  uses GraphABC;
  uses GlobalVariables;
  procedure drawButton(x0,y0,x,y: integer; text: string);
  procedure handleMouseDown(x, y, mb: integer);

Implementation

// мышь (нажатие)
procedure handleMouseDown(x, y, mb: integer);
  begin
    IS_MOUSE_DOWN := true;
    MOUSE_X := x;
    MOUSE_Y := y;
    BUTTON_TYPE := mb;
  end;

// универсальная отрисовка кнопок
procedure drawButton(x0,y0,x,y: integer; text: string);
  begin
    SetBrushColor(ARGB(200,255,255,255));
    Rectangle(x0, y0, x, y);
    DrawTextCentered(x0, y0, x, y, text);
  end;

begin 
end.
