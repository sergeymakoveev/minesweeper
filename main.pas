uses graphABC, PABCSystem;
uses GameConstants, GameVariables;
uses MyButtonsPressed, MyInput, FileWork;

var
  // переменные, отвечающие за время прохождения
  time0, time1, time: integer;
  // высота поля
  N: integer;
  // ширина поля
  M: integer;
  // число мин
  Nmines: integer;
  // отвечает за активное меню
  ProgramStep: string;
  // количество открытых ячеек
  fcount: integer;
  // отвечает за выбранный уровень 
  level: byte;
  // нужны для подтверждения действия и нажатия на кнопки (выход в меню/переиграть/закрыть программу)
  xtemp, ytemp: integer;
  
  // временная строка, отвечает за ввод данных
  // ss: string;

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
  Field: array [1..100, 1..100] of cell;

// мышь (нажатие)
procedure MouseDown(x, y, mb: integer);
  begin
    isMouseDown := true;
    mouseX := x;
    mouseY := y;
    button := mb;
  end;

// открытие клетки без мины (условие)
function notMine(i, j: integer): boolean;
  begin
    if (i in 1..M) and (j in 1..N) and (button = 1) and (Field[i, j].mine = False) and (Field[i, j].opened = False) and (Field[i, j].flag = false) then notMine := True;
  end;

// поставить флаг (условие)
function WantSetFlag(i, j: integer): boolean;
  begin
    if (i in 1..M) and (j in 1..N) and (button = 2) and (Field[i, j].flag = False) and (Field[i, j].opened = False) then WantSetFlag := True;
  end;

// убрать флаг (условие)
function WantDeleteFlag(i, j: integer): boolean;
  begin
    if (i in 1..M) and (j in 1..N) and (button = 2) and (Field[i, j].flag = True) and (Field[i, j].opened = False) then WantDeleteFlag := True;
  end;

// условие поражения
function lose(i, j: integer): boolean;
  begin
    if ((i in 1..M) and (j in 1..N) and (button = 1) and (Field[i, j].mine = True) and (Field[i, j].flag = False)) then lose := True;
  end;

// поле + очищение клеток от мин + состояния открытия + флагов на случай начала новой игры без перезапуска программы
procedure pole;
  begin
    var i, j: shortint;
    lockdrawing;
    setPenWidth(1);
    SetBrushColor(clLightGray);
    for i := 1 to M do
      begin
        for j := 1 to N do
          begin
            rectangle(width * i, width * j, width * i + width, width * j + width);
            Field[i, j].opened := False;
            Field[i, j].mine := False;
            Field[i, j].flag := False;
          end;
      end;
    redraw;
    unlockdrawing;
    SetBrushColor(clWhite);
  end;

// заполнение минами
procedure filling;
  begin
    var i, j, count: integer;
    count := 0;
    repeat
      begin
        i := random(M) + 1;
        j := random(N) + 1;
        if (Field[i, j].mine = False) and (Field[i, j].opened = False) then
          begin
            Field[i, j].mine := True;
            count += 1;
            // отладочная строка для быстрой победы (видны все мины)
            // DrawTextCentered(39 * i, 39 * j, 39 * i + width, 39 * j + width, 'M');
          end;
      end;
    until count = Nmines;
  end;

// количество мин возле клетки
procedure nearby;
  begin
    var i, j, k: shortint;
    for i := 1 to M do
      for j := 1 to N do
        if Field[i, j].mine = False then
        // если клетка без мины
        begin
          // левее выше мина
          if (i - 1 >= 1) and (j - 1 >= 1) and (Field[i - 1, j - 1].mine = True) then
            k := k + 1;
          // выше мина
          if (j - 1 >= 1) and (Field[i, j - 1].mine = True) then
            k := k + 1;
          // правее выше мина
          if (i + 1 <= M) and (j - 1 >= 1) and (Field[i + 1, j - 1].mine = True) then
            k := k + 1;
          // левее мина
          if (i - 1 >= 1) and (Field[i - 1, j].mine = True) then
            k := k + 1;
          // правее мина
          if (i + 1 <= M) and (Field[i + 1, j].mine = True) then
            k := k + 1;
          // ниже левее мина
          if (i - 1 >= 1) and (j + 1 <= N) and (Field[i - 1, j + 1].mine = True) then
            k := k + 1;
          // ниже мина
          if (j + 1 <= N) and (Field[i, j + 1].mine = True) then
            k := k + 1;
          // ниже правее мина
          if (i + 1 <= M) and (j + 1 <= N) and (Field[i + 1, j + 1].mine = True) then
            k := k + 1;
          Field[i, j].nearbyMines := k;
          k := 0;
        end;     
  end;

// открытие клетки
procedure Step(i, j: shortint);
  begin
    Field[i, j].opened := True;
    // счётчик открытых клеток
    fcount += 1;
    // белый фон вместо серого
    FillRectangle(39 * i + 2, 39 * j + 2, 39 * i + width - 2, 39 * j + width - 2);
    case Field[i, j].nearbyMines of 
      1: SetFontColor(clGreen);
      2: SetFontColor(clBlue);
      3: SetFontColor(clViolet);
      4: SetFontColor(clDarkViolet);
      5: SetFontColor(clMediumVioletRed);
      6: SetFontColor(clRed);
      7: SetFontColor(clDarkRed);
      8: SetFontColor(clOrangeRed);
    end;
    // вывод кол-ва мин вокруг клетки
    if Field[i, j].nearbyMines <> 0 then DrawTextCentered(39 * i, 39 * j, 39 * i + width, 39 * j + width, Field[i, j].nearbyMines);
    SetFontColor(clBlack);
  end;

// открыть все соседние клетки для пустой клетки
procedure EmptyStep(i, j, fcount: shortint);
  var ii,jj: shortint;
  begin
    Step(i,j);
    for ii := -1 to 1 do
      begin
        for jj := -1 to 1 do
          begin
            // если не за пределами поля и закрыта
            if (i+ii in 1..M) and (j+jj in 1..N) and (Field[i+ii,j+jj].opened = False) then
              begin
                // останавливаем открытие на клетке с цифрой
                if (Field[i+ii,j+jj].nearbyMines <> 0) and (Field[i+ii,j+jj].flag = False) then Step(i+ii,j+jj)
                // если пустая - открываем дальше
                else  if (Field[i+ii,j+jj].nearbyMines = 0) and (Field[i+ii,j+jj].flag = False) then EmptyStep(i+ii,j+jj,fcount);
              end;
          end;
      end;
  end;

// первое открытие клетки за игру
procedure FirstStep(i, j: shortint);
  begin
    time0 := Milliseconds;
    time:=0;
    Field[i, j].opened := True;
    Field[i, j].mine := False;
    filling;
    nearby;
    if Field[i,j].nearbyMines = 0 then EmptyStep(i,j,fcount);
    FillRectangle(39 * i + 2, 39 * j + 2, 39 * i + width - 2, 39 * j + width - 2);
    case Field[i, j].nearbyMines of 
      1: SetFontColor(clGreen);
      2: SetFontColor(clBlue);
      3: SetFontColor(clViolet);
      4: SetFontColor(clDarkViolet);
      5: SetFontColor(clMediumVioletRed);
      6: SetFontColor(clRed);
      7: SetFontColor(clDarkRed);
      8: SetFontColor(clOrangeRed);
    end;
    if not (Field[i, j].nearbyMines = 0) then
      begin 
        DrawTextCentered(39 * i, 39 * j, 39 * i + width, 39 * j + width, Field[i, j].nearbyMines); 
        fcount += 1;
      end;
    SetFontColor(clBlack);
  end;

// поставили флаг
procedure flag(i, j: shortint);
  begin
    SetFontColor(clRed);
    DrawTextCentered(39 * i, 39 * j, 39 * i + width, 39 * j + width, 'F');
    SetFontColor(clBlack);
    Field[i, j].flag := True;
  end;

// убрали флаг
procedure deleteFlag(var i: shortint; j: shortint);
  begin
    Field[i, j].flag := False;
    SetBrushColor(clLightGray);
    FillRectangle(39 * i + 2, 39 * j + 2, 39 * i + width - 2, 39 * j + width - 2);
    SetBrushColor(clWhite);
    // после выполнения действия зануляем переменную (иначе приводит к ошибке)
    i:=0;
    j:=0;
  end;

// играть на сложности новичок
procedure noviceLevel;
  begin
    level := 0;
    N := 8;
    M := 8;
    Nmines := 10;
    SetWindowSize((N + 6) * Width, (N + 2) * Width);
    CenterWindow;
  end;

// играть на сложности любитель
procedure advansedLevel;
  begin
    level := 1;
    N := 16;
    M := 16;
    Nmines := 40;
    SetWindowSize((N + 6) * Width, (N + 2) * Width);
    CenterWindow;
  end;

// играть на сложности профессионал
procedure proLevel;
  begin
    level := 3;
    N := 19;
    M := 30;
    Nmines := 70;
    SetWindowSize((M + 6) * Width, (N + 2) * Width);
    CenterWindow
  end;

// главное меню
procedure startMenu;
  begin
    mouseX := 0;
    mouseY := 0;
    SetWindowSize(620, 700);
    
    CenterWindow;
    clearwindow;
    
    SetFontSize(70);
    textOut(145, 40, 'САПЁР');
    SetFontSize(10);
    DrawTextCentered(300, 660, 700, 680, 'Выполнил ст.гр. 243 Трынкин Михаил');
    
    SetFontSize(20);
    DrawButton(40,220,570,260,'ИГРАТЬ');
    DrawButton(40,280,570,320,'Правила игры');
    DrawButton(40,340,570,380,'Рекорды');
    DrawButton(40,540,570,580,'Выход');
    
    OnMouseDown := MouseDown;
    repeat
      if IsMouseDown then
        begin
          IsMouseDown := false;
        end;
    until playButtonPressed(mouseX, mouseY, button) or rulesButtonPressed(mouseX, mouseY, button) or  recordsButtonPressed(mouseX, mouseY, button) or exitButtonPressed(mouseX, mouseY, button);
    
    if playButtonPressed(mouseX, mouseY, button) then ProgramStep := 'difficultyChoice';
    if rulesButtonPressed(mouseX, mouseY, button) then ProgramStep := 'viewRules';
    if recordsButtonPressed(mouseX, mouseY, button) then ProgramStep := 'records';
    if exitButtonPressed(mouseX, mouseY, button) then closewindow;
  end;

// выбор уровня сложности
procedure difficultyChoice;
  begin
    clearwindow;
    mouseX := 0;
    mouseY := 0;
    SetWindowSize(620, 700);
    CenterWindow;
    
    SetFontSize(20);
    DrawTextCentered(40, 140, 570, 190, 'Выберите уровень сложности');
    DrawButton(40,220,570,260,'Новичок: поле 8х8, 10 мин');
    DrawButton(40,280,570,320,'Любитель: поле 16х16, 40 мин');
    DrawButton(40,340,570,380,'Профессионал: поле 19х30, 70 мин');
    DrawButton(40,400,570,440,'Пользовательская');
    DrawButton(40,540,570,580,'назад');

    
    // OnMouseDown := MouseDown;
    repeat
      if IsMouseDown then
        begin
          IsMouseDown := false;
        end;
    until 
      novicePressed(mouseX, mouseY, button) or
      advansedPressed(mouseX, mouseY, button) or
      proPressed(mouseX, mouseY, button) or
      customPressed(mouseX, mouseY, button) or
      backButtonPressed(mouseX, mouseY, button);
    
    if novicePressed(mouseX, mouseY, button) then noviceLevel
    else if advansedPressed(mouseX, mouseY, button) then advansedLevel
    else if proPressed(mouseX, mouseY, button) then proLevel;

    if customPressed(mouseX, mouseY, button) then ProgramStep := 'customLevel'
    else if backButtonPressed(mouseX, mouseY, button) then ProgramStep := 'startMenu'
    else ProgramStep := 'game';
  end;

// проверка кнопок в окне во время игры на нажатие (которые требуют подтверждения)
procedure IngameButtonsPressed;
  begin
    // xtemp:=mouseX;
    // ytemp:=mouseY;
    
    // выход в меню
    if menuButtonPressed(xtemp, ytemp, button, M) then ProgramStep := 'startMenu'
    // начинаем заново
    else if againButtonPressed(xtemp, ytemp, button, M) then ProgramStep := 'game'
    // выход из игры
    else if endButtonPressed(xtemp, ytemp, button, N, M) then closewindow;
  end;

// поражение
procedure youLose;
  begin
    var finishText: string;
    var i,j: shortint;
    
    xtemp:=0;
    ytemp:=0;
    
    // спрятать кнопку паузы
    fillrectangle(39 * (M + 3), round(39*2.5), 39 * (M + 3) + 39 * 2, round(39*2.5) + 39);
      
    time1 := Milliseconds;
    time := time + (time1 - time0) div 1000 + 1;
    finishText := 'Вы проиграли потратив ' + time + ' секунд(ы)...';
    for i := 1 to M do
      for j := 1 to N do
        begin
          if Field[i, j].flag = True then
            begin
              SetBrushColor(clLightGray);
              FillRectangle(39 * i + 2, 39 * j + 2, 39 * i + width - 2, 39 * j + width - 2);
              SetBrushColor(clWhite);
            end;
          if Field[i, j].mine = True then DrawTextCentered(39 * i, 39 * j, 39 * i + width, 39 * j + width, 'M');
        end;
    SetFontSize(10);
    TextOut(38,20,finishtext);
      
    repeat
      if IsMouseDown then
        begin
          IsMouseDown := false;
          // обязательно, так как иначе возможно неопределённое действие
          xtemp:=mouseX;
          ytemp:=mouseY;
        end;
    until (endButtonPressed(xtemp, ytemp, button, N, M)) or (againButtonPressed(xtemp, ytemp, button, M)) or (menuButtonPressed(xtemp, ytemp, button, M));
    IngameButtonsPressed;
  end;

// победа
procedure youWin;
  begin
    var finishText: string;  
    // записываем время
    time1 := Milliseconds;
    // считаем суммарное время прохождения уровня
    time := time + (time1 - time0) div 1000 + 1;
    
    fillrectangle(39 * (M + 3), round(39*2.5), 39 * (M + 3) + 39 * 2, round(39*2.5) + 39);// убрать кнопку паузы
    
    finishText := 'Вы победили! Секунд затрачено: ' + time;
    SetFontSize(10);
    TextOut(38,0,finishtext);
    
    // отключаем мышь на время записи рекорда
    OnMouseDown:=Nil;
    
    // если не на пользовательском уровне, то проверяем время на рекорд
    if level <> 3 then isBest(time,level);
    
    OnMouseDown:=MouseDown;
    repeat
      if IsMouseDown then
        begin
          IsMouseDown := false;
        end;
    until (endButtonPressed(mouseX, mouseY, button, N, M)) or (againButtonPressed(mouseX, mouseY, button, M)) or (menuButtonPressed(mouseX, mouseY, button, M));
    xtemp:=mouseX;
    ytemp:=mouseY;
    IngameButtonsPressed;
  end;
  
// подтверждение нажатия на кнопку Переиграть/в меню/выйти
Function AreYouSure: boolean;
  begin
    SaveWindow('gamewindow');
    clearwindow;
    
    // для запоминания, какую кнопку хотел нажать игрок
    xtemp:=mouseX;
    ytemp:=mouseY;
    
    drawTextCentered(GraphBoxWidth div 2 - 200,GraphBoxHeight div 2 - 100,GraphBoxWidth div 2 + 200,GraphBoxHeight div 2 - 50,'Вы уверены? Прогресс будет утерян!');
    
    SetBrushColor(clIndianRed);
    DrawButton(GraphBoxWidth div 2 + 100,GraphBoxHeight div 2,GraphBoxWidth div 2 + 200,GraphBoxHeight div 2 + 40,'да');
    
    setBrushColor(clLightGreen);
    DrawButton(GraphBoxWidth div 2 - 200,GraphBoxHeight div 2,GraphBoxWidth div 2 - 100,GraphBoxHeight div 2 + 40,'нет');
    
    SetBrushColor(clWhite);
    
    repeat
      IsMouseDown := false;
    until yesButtonPressed(mouseX,mouseY,button) or noButtonPressed(mouseX,mouseY,button);
    
    if yesButtonPressed(mouseX,mouseY,button) then AreYouSure:=true
    else AreYouSure:=false;
    
    // если пользователь не хочет переигрывать/выходить в меню/закрывать игру
    // то отрисовываем сохранённое окно с прохождением уровня
    if noButtonPressed(mouseX,mouseY,button) then loadwindow('gamewindow');
    
    // зануляем положение курсора чтобы
    // не открылась ячейка сразу после отрисовки игрового поля
    mouseX:=0;
    mouseY:=0;
  end;

// пауза
procedure pause;
  begin
    // приостанавливаем отсчёт времени
    time1 := milliseconds;
    // записываем, сколько пользователь уже играл (секунд)
    time := (time1 - time0) div 1000 + 1;
    
    // сохраняем окно
    SaveWindow('gamewindow');
    // очищаем окно
    clearWindow;
    
    setBrushColor(clLightGreen);
    DrawButton(GraphBoxWidth div 2 - 100,GraphBoxHeight div 2 - 50,GraphBoxWidth div 2 + 100,GraphBoxHeight div 2 + 40,'продолжить');
    SetBrushColor(clWhite);
    
    repeat
      IsMouseDown := false;
    until unpauseButtonPressed(mouseX,mouseY,button,M);
    
    // возобновляем отсчёт времени
    time0 := milliseconds;
    
    // рисуем окно заново
    loadwindow('gamewindow');
    
    // зануляем положение курсора чтобы
    // не открылась ячейка сразу после отрисовки игрового поля
    mouseX:=0;
    mouseY:=0;
  end;

// процесс игры
procedure game;
  begin
    var  i, j: shortint;
    var sure: boolean;
    clearwindow;
    lockDrawing;
    SetFontSize(10);
    
    // обнуляем переменные
    fcount := 0;
    i := 0;
    j := 0;
    mouseX := 0;
    mouseY := 0;
    xtemp:=0;
    ytemp:=0;
    
    // рисуем поле
    pole;
    
    // рисуем кнопки
    DrawButton(39 * (M + 3), 39 * 1, 39 * (M + 3) + 39 * 2, 39 * 1 + 39, 'переиграть');
    DrawButton(39 * (M + 3), round(39*2.5), 39 * (M + 3) + 39 * 2, round(39*2.5) + 39, 'пауза');
    DrawButton(39 * (M + 3), 39 * 4, 39 * (M + 3) + 39 * 2, 39 * 5, 'назад в меню');
    DrawButton(39 * (M + 3), 39 * N, 39 * (M + 3) + 39 * 2, 39 * (N+1), 'выход из игры');
    
    redraw;
    unlockdrawing;
    
    repeat
      if IsMouseDown then
        begin
          IsMouseDown := false;
          i := mouseX div width;
          j := mouseY div width;
          SetFontSize(15);
          // безопасное первое открытие клетки + заполнение поля минами
          if (i in 1..M) and (j in 1..N) and (button = 1) and (fcount = 0) then FirstStep(i, j)
          else if pauseButtonPressed(mouseX,mouseY,button,M) then pause
          // нажали на клетку без мины
          else if notMine(i, j) then
            begin
                // открыли клетку без мины с минами вокруг
                if (Field[i,j].nearbyMines <> 0) then Step(i, j)
                // открыли клетку без мины без мин вокруг
                else Emptystep(i,j,fcount);
            end
          // поставили флаг
          else if WantSetFlag(i, j) then flag(i, j)
          // убрали флаг
          else if WantDeleteFlag(i, j) then deleteFlag(i, j)
          // хотим нажать на кнопку выхода/в меню/заново
          else if (againButtonPressed(mouseX, mouseY, button, M)) or (menuButtonPressed(mouseX, mouseY, button, M)) or (endButtonPressed(mouseX, mouseY, button, N, M)) then
              sure := AreYouSure;
        end;
    // завершение процесса игры при одном из трёх условий
    until sure or (fcount = M * N - Nmines) or lose(i, j);
    
    // если выполнилось условие проигрыша, то проиграл
    if lose(i,j) then youLose;
    
    // если открыл все поля без мин, то победил
    if fcount = int(M * N) - Nmines then youWin;
    
    // последний исход завершения процесса игры - нажата кнопка меню/выход/переиграть
    IngameButtonsPressed;
  end;

// Запуск игры
begin
  
  SetWindowCaption('Игра "Сапёр"');
  SetWindowIsFixedSize(true);
  
  if not (fileexists('rules.txt') and fileexists('records.txt')) then
    begin
      SetFontSize(20);
      textout(0,0,'Ошибка! Отсутствуют необходимые файлы');
      sleep(4000);
      closewindow;
    end;
  
  ProgramStep := 'startMenu';
  
  // повторяем показ различных окон
  repeat
    case ProgramStep of
      'difficultyChoice': difficultyChoice;
      'game': game;
      'startMenu': startmenu;
      'viewRules': viewRules(programStep);
      'customLevel': customLevel(level,M,N,Nmines,programStep);
      'records': records(programStep);
    end;
  // игру закрывается из окна startmenu или game
  until false;
  
end.