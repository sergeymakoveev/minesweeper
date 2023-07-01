unit CommonFunctions;

Interface

  uses GraphABC;
  uses GlobalVariables;
  procedure drawButton(x0,y0,x,y: integer; text: string; color: Color := ARGB(200,255,255,255));
  procedure drawTitle(x0,y0,x,y: integer; text: string);
  procedure handleMouseDown(x, y, mb: integer);

Implementation

// Процедура обработки нажатия клавиш мыши
// для обработки кликов по элементам интерфейса.
// Анализ клика заключается в определении попадания в диапазон точек,
// где расположен тот или иной элемент интерфейса
procedure handleMouseDown(x, y, mb: integer);
  begin
    // устанавливаем флаг нажатия клавиши мыши
    IS_MOUSE_DOWN := true;
    // сохраняем X-координату клика мышью
    MOUSE_X := x;
    // сохраняем Y-координату клика мышью
    MOUSE_Y := y;
    // сохраняем код нажатой клавиши мыши
    // 0 - правая клавиша (клики по клеткам игрового поля)
    // 1 - левая клавиша (клики по клеткам игрового поля и кнопкам интерфейса)
    BUTTON_TYPE := mb;
  end;

// отрисовка кнопок
procedure drawButton(x0,y0,x,y: integer; text: string; color: Color);
  begin
    var currentColor := BrushColor();
    setBrushColor(color);
    Rectangle(x0, y0, x, y);
    setFontSize(18);
    setFontStyle(fsNormal);
    DrawTextCentered(x0, y0, x, y, text);
    setBrushColor(currentColor);
  end;

// отрисовка кнопок
procedure drawTitle(x0,y0,x,y: integer; text: string);
  begin
    setBrushColor(ARGB(200,255,255,255));
    FillRect(x0, y0, x, y);
    setFontSize(20);
    SetFontStyle(fsBold);
    DrawTextCentered(x0, y0, x, y, text);
    SetFontStyle(fsNormal);
  end;

begin 
end.
