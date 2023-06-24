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
  // положение курсора в окне
  mouseX, mouseY: integer;
  // нажата ли кнопка мыши
  isMouseDown: boolean;
  // тип нажатой кнопки мыши (левая/правая)
  button: integer;
  // высота поля
  N: integer;
  // ширина поля
  M: integer;
  // игровое поле (матрица клеток)
  Field: array [1..100, 1..100] of cell;
  // число мин
  Nmines: integer;
  // отвечает за активное меню
  PROGRAM_STEP: string;
  // отвечает за выбранный уровень 
  GAME_LEVEL: byte;
  // Флаг завершения пользовательского ввода
  isInputDone: boolean;
  // временная переменная для ввода данных
  ss: string;

begin 
end.
