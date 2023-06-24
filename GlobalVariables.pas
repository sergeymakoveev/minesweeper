unit GlobalVariables;

type
  // тип данных КЛЕТКА (ячейка)
  cell = record
    // есть ли мина
    mine: boolean;
    // есть ли флаг
    flag: boolean;
    // число мин вокруг
    nearbyMines: integer;
    // открыта ли
    opened: boolean;
  end;

var
  // игровое поле (матрица клеток)
  FIELD: array [1..100, 1..100] of cell;
  // высота поля
  FIELD_HEIGHT: integer;
  // ширина поля
  FIELD_WIDTH: integer;
  // положение курсора в окне
  MOUSE_X, MOUSE_Y: integer;
  // нажата ли кнопка мыши
  IS_MOUSE_DOWN: boolean;
  // тип нажатой кнопки мыши (левая/правая)
  BUTTON_TYPE: integer;
  // число мин
  MINES_COUNT: integer;
  // шаг программы для отображения
  PROGRAM_STEP: string;
  // выбранный уровень сложности
  GAME_LEVEL: byte;
  // Флаг завершения пользовательского ввода
  IS_INPUT_DONE: boolean;
  // временная переменная для ввода данных
  ss: string;

begin 
end.
