unit CommonFunctions;

Interface

  uses graphABC;
  uses GlobalVariables;
  procedure DrawButton(x0,y0,x,y: integer; text: string);
  procedure MouseDown(x, y, mb: integer);

Implementation

// мышь (нажатие)
procedure MouseDown(x, y, mb: integer);
  begin
    IS_MOUSE_DOWN := true;
    mouseX := x;
    mouseY := y;
    BUTTON_TYPE := mb;
  end;

// универсальная отрисовка кнопок
procedure DrawButton(x0,y0,x,y: integer; text: string);
  begin
    rectangle(x0, y0, x, y);
    DrawTextCentered(x0, y0, x, y, text);
  end;

begin 
end.
