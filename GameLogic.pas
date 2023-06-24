unit GameLogic;

Interface

  uses graphABC, PABCSystem;
  uses GlobalConstants, GlobalVariables, CommonFunctions;

  procedure displayGameStep;

Implementation

var
  // количество открытых ячеек
  fcount: integer;
  // нужны для подтверждения действия и нажатия на кнопки (выход в меню/переиграть/закрыть программу)
  xtemp, ytemp: integer;
  // переменные, отвечающие за время прохождения
  time0, time1, time: integer;

// кнопа вернуться в главное меню нажата
function checkMenuButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_WIDTH: integer): boolean;
  begin
    if (MOUSE_X in 39 * (FIELD_WIDTH + 3)..39 * (FIELD_WIDTH + 3) + 39 * 2) and (MOUSE_Y in 39 * 4..39 * 5) and (BUTTON_TYPE = 1) then checkMenuButtonClick := true;
  end;
// кнопка завершить программу нажата
function checkEndButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_HEIGHT, FIELD_WIDTH: integer): boolean;
  begin
    if (MOUSE_X in 39 * (FIELD_WIDTH + 3)..39 * (FIELD_WIDTH + 3) + 39 * 2) and (MOUSE_Y in 39 * FIELD_HEIGHT..39 * (FIELD_HEIGHT+1)) and (BUTTON_TYPE = 1) then checkEndButtonClick := true;
  end;
// кнопка переиграть нажата
function checkAgainButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_WIDTH: integer): boolean;
  begin
    if (MOUSE_X in (39 * (FIELD_WIDTH + 3))..(39 * (FIELD_WIDTH + 3) + 39 * 2)) and (MOUSE_Y in 39 * 1..39 * 1 + 39) and (BUTTON_TYPE = 1) then
      checkAgainButtonClick := true;
  end;

// заполнение поля минами
procedure fillField();
  begin
    var i, j, count: integer;
    count := 0;
    repeat
      begin
        i := random(FIELD_WIDTH) + 1;
        j := random(FIELD_HEIGHT) + 1;
        if (FIELD[i, j].mine = False) and (FIELD[i, j].opened = False) then
          begin
            FIELD[i, j].mine := True;
            count += 1;
            if DEBUG_MODE = true then
              // debug
              // отладочная строка для быстрой победы (видны все мины)
              DrawTextCentered(39 * i, 39 * j, 39 * i + WIDTH_CELL, 39 * j + WIDTH_CELL, 'M');
          end;
      end;
    until count = MINES_COUNT;
  end;

procedure setupField();
  begin
    var i, j, k: shortint;
    for i := 1 to FIELD_WIDTH do
      for j := 1 to FIELD_HEIGHT do
        if FIELD[i, j].mine = False then
        // если клетка без мины
        begin
          // левее выше мина
          if (i - 1 >= 1) and (j - 1 >= 1) and (FIELD[i - 1, j - 1].mine = True) then
            k := k + 1;
          // выше мина
          if (j - 1 >= 1) and (FIELD[i, j - 1].mine = True) then
            k := k + 1;
          // правее выше мина
          if (i + 1 <= FIELD_WIDTH) and (j - 1 >= 1) and (FIELD[i + 1, j - 1].mine = True) then
            k := k + 1;
          // левее мина
          if (i - 1 >= 1) and (FIELD[i - 1, j].mine = True) then
            k := k + 1;
          // правее мина
          if (i + 1 <= FIELD_WIDTH) and (FIELD[i + 1, j].mine = True) then
            k := k + 1;
          // ниже левее мина
          if (i - 1 >= 1) and (j + 1 <= FIELD_HEIGHT) and (FIELD[i - 1, j + 1].mine = True) then
            k := k + 1;
          // ниже мина
          if (j + 1 <= FIELD_HEIGHT) and (FIELD[i, j + 1].mine = True) then
            k := k + 1;
          // ниже правее мина
          if (i + 1 <= FIELD_WIDTH) and (j + 1 <= FIELD_HEIGHT) and (FIELD[i + 1, j + 1].mine = True) then
            k := k + 1;
          // количество мин возле клетки
          FIELD[i, j].nearbyMines := k;
          k := 0;
        end;     
  end;

// открытие клетки
procedure openCell(i, j: shortint);
  begin
    FIELD[i, j].opened := True;
    // счётчик открытых клеток
    fcount += 1;
    // белый фон вместо серого
    FillRectangle(39 * i + 2, 39 * j + 2, 39 * i + WIDTH_CELL - 2, 39 * j + WIDTH_CELL - 2);
    case FIELD[i, j].nearbyMines of 
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
    if FIELD[i, j].nearbyMines <> 0 then DrawTextCentered(39 * i, 39 * j, 39 * i + WIDTH_CELL, 39 * j + WIDTH_CELL, FIELD[i, j].nearbyMines);
    SetFontColor(clBlack);
  end;

// открыть все соседние клетки для пустой клетки
procedure openEmptyCells(i, j, fcount: shortint);
  var ii,jj: shortint;
  begin
    openCell(i,j);
    for ii := -1 to 1 do
      begin
        for jj := -1 to 1 do
          begin
            // если не за пределами поля и закрыта
            if (i+ii in 1..FIELD_WIDTH) and (j+jj in 1..FIELD_HEIGHT) and (FIELD[i+ii,j+jj].opened = False) then
              begin
                // останавливаем открытие на клетке с цифрой
                if (FIELD[i+ii,j+jj].nearbyMines <> 0) and (FIELD[i+ii,j+jj].flag = False) then openCell(i+ii,j+jj)
                // если пустая - открываем дальше
                else  if (FIELD[i+ii,j+jj].nearbyMines = 0) and (FIELD[i+ii,j+jj].flag = False) then openEmptyCells(i+ii,j+jj,fcount);
              end;
          end;
      end;
  end;

// первое открытие клетки за игру
procedure openFirstCell(i, j: shortint);
  begin
    time0 := Milliseconds;
    time:=0;
    FIELD[i, j].opened := True;
    FIELD[i, j].mine := False;
    fillField();
    setupField();
    if FIELD[i,j].nearbyMines = 0 then openEmptyCells(i,j,fcount);
    FillRectangle(39 * i + 2, 39 * j + 2, 39 * i + WIDTH_CELL - 2, 39 * j + WIDTH_CELL - 2);
    case FIELD[i, j].nearbyMines of 
      1: SetFontColor(clGreen);
      2: SetFontColor(clBlue);
      3: SetFontColor(clViolet);
      4: SetFontColor(clDarkViolet);
      5: SetFontColor(clMediumVioletRed);
      6: SetFontColor(clRed);
      7: SetFontColor(clDarkRed);
      8: SetFontColor(clOrangeRed);
    end;
    if not (FIELD[i, j].nearbyMines = 0) then
      begin 
        DrawTextCentered(39 * i, 39 * j, 39 * i + WIDTH_CELL, 39 * j + WIDTH_CELL, FIELD[i, j].nearbyMines); 
        fcount += 1;
      end;
    SetFontColor(clBlack);
  end;

// поставили флаг
procedure setFlag(i, j: shortint);
  begin
    SetFontColor(clRed);
    DrawTextCentered(39 * i, 39 * j, 39 * i + WIDTH_CELL, 39 * j + WIDTH_CELL, 'F');
    SetFontColor(clBlack);
    FIELD[i, j].flag := True;
  end;

// убрали флаг
procedure deleteFlag(var i: shortint; j: shortint);
  begin
    FIELD[i, j].flag := False;
    SetBrushColor(clLightGray);
    FillRectangle(39 * i + 2, 39 * j + 2, 39 * i + WIDTH_CELL - 2, 39 * j + WIDTH_CELL - 2);
    SetBrushColor(clWhite);
    // после выполнения действия зануляем переменную (иначе приводит к ошибке)
    i:=0;
    j:=0;
  end;

// проверка кнопок в окне во время игры на нажатие (которые требуют подтверждения)
procedure checkButtonsClick();
  begin
    // выход в меню
    if checkMenuButtonClick(xtemp, ytemp, BUTTON_TYPE, FIELD_WIDTH) then PROGRAM_STEP := 'MenuMainStep'
    // начинаем заново
    else if checkAgainButtonClick(xtemp, ytemp, BUTTON_TYPE, FIELD_WIDTH) then PROGRAM_STEP := 'GameStep'
    // выход из игры
    else if checkEndButtonClick(xtemp, ytemp, BUTTON_TYPE, FIELD_HEIGHT, FIELD_WIDTH) then closewindow();
  end;

// поражение
procedure youLose();
  begin
    var finishText: string;
    var i,j: shortint;
    
    xtemp:=0;
    ytemp:=0;
    
    // спрятать кнопку паузы
    fillrectangle(39 * (FIELD_WIDTH + 3), round(39*2.5), 39 * (FIELD_WIDTH + 3) + 39 * 2, round(39*2.5) + 39);
      
    time1 := Milliseconds;
    time := time + (time1 - time0) div 1000 + 1;
    finishText := 'Вы проиграли потратив ' + time + ' секунд(ы)...';
    for i := 1 to FIELD_WIDTH do
      for j := 1 to FIELD_HEIGHT do
        begin
          if FIELD[i, j].flag = True then
            begin
              SetBrushColor(clLightGray);
              FillRectangle(39 * i + 2, 39 * j + 2, 39 * i + WIDTH_CELL - 2, 39 * j + WIDTH_CELL - 2);
              SetBrushColor(clWhite);
            end;
          if FIELD[i, j].mine = True then DrawTextCentered(39 * i, 39 * j, 39 * i + WIDTH_CELL, 39 * j + WIDTH_CELL, 'FIELD_WIDTH');
        end;
    SetFontSize(10);
    TextOut(38,20,finishtext);
      
    repeat
      if IS_MOUSE_DOWN then
        begin
          IS_MOUSE_DOWN := false;
          // обязательно, так как иначе возможно неопределённое действие
          xtemp:=MOUSE_X;
          ytemp:=MOUSE_Y;
        end;
    until (checkEndButtonClick(xtemp, ytemp, BUTTON_TYPE, FIELD_HEIGHT, FIELD_WIDTH)) or (checkAgainButtonClick(xtemp, ytemp, BUTTON_TYPE, FIELD_WIDTH)) or (checkMenuButtonClick(xtemp, ytemp, BUTTON_TYPE, FIELD_WIDTH));
    checkButtonsClick();
  end;

// нажатие на клавиатуру (имя рекордсмена)
procedure onKeyPressName(ch: char);
  begin
    IS_INPUT_DONE := false;
    lockdrawing();
    fillrect(350,20,500,36);
    if ((ch in ('А'..'Я')) or (ch in ('а'..'я'))) and (length(ss)<15) then ss+=ch;
    textout(350,20,ss);
    // если нажали на Delete
    if ord(ch) = 8 then
      begin
        // удаление одного последнего символа по требованию
        delete(ss,length(ss),1);
        fillrect(350,20,500,36);
        textout(350,20,ss);
      end;
    unlockdrawing();
    redraw();
    // если нажали на Enter(конец проверки на событие)
    if ord(ch) = VK_Enter then
      begin
          onKeyPress:=Nil;
          IS_INPUT_DONE:=True;
      end;
  end;

// проверка на лучшее время и изменение рекорда
procedure checkIsBest(time: integer; GAME_LEVEL: byte);
  type 
    highScore = record
      name: string;
      score: integer;
    end;
  begin
    var players: array [0..2] of highscore;
    var i: byte;
    var f,f2: text;
    var s: string;
    
    i:=0;
    IS_INPUT_DONE:=False;

    // открытие файла рекордов
    assign(f,'records.txt');
    reset(f);
    
    // запись содержимого в переменные
    while (not eof(f)) do
    begin
      readln(f,players[i].name);
      readln(f,players[i].score);
      i+=1;
    end;
    
    reset(f);
    
    i:=0;
    
    // если побил рекорд или поставил новый, то ввод имени
    if (players[GAME_LEVEL].score=0) or (time < players[GAME_LEVEL].score)  then
    begin
      textout(38,20,'Новый рекорд! Введите ваше имя (затем Enter):');
      assign(f2,'temprecords.txt');
      rewrite(f2);
      while not eof(f) do
      begin
        i+=1;
        readln(f,s);
        if (i<>(2*GAME_LEVEL+2)) and (i<>(2*GAME_LEVEL+1)) then writeln(f2,s)
        else if i=(2*GAME_LEVEL+2) then writeln(f2,time)
        else
          begin
            ss:='';
            onKeyPress:=onKeyPressName;
            repeat i:=i+0 until IS_INPUT_DONE;
            writeln(f2,ss);
          end;
      end;
      close(f);
      close(f2);
      erase(f);
      rename(f2,'records.txt');
    end
    // иначе закрываем файл рекордов
    else close(f);
  end;

// победа
procedure displayWin();
  begin
    var finishText: string;  
    // записываем время
    time1 := Milliseconds;
    // считаем суммарное время прохождения уровня
    time := time + (time1 - time0) div 1000 + 1;
    
    fillrectangle(39 * (FIELD_WIDTH + 3), round(39*2.5), 39 * (FIELD_WIDTH + 3) + 39 * 2, round(39*2.5) + 39);// убрать кнопку паузы
    
    finishText := 'Вы победили! Секунд затрачено: ' + time;
    SetFontSize(10);
    TextOut(38,0,finishtext);
    
    // отключаем мышь на время записи рекорда
    OnMouseDown:=Nil;
    
    // если не на пользовательском уровне, то проверяем время на рекорд
    if GAME_LEVEL <> 3 then checkIsBest(time,GAME_LEVEL);
    
    OnMouseDown:=MouseDown;
    repeat
      if IS_MOUSE_DOWN then
        begin
          IS_MOUSE_DOWN := false;
        end;
    until (checkEndButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_HEIGHT, FIELD_WIDTH)) or (checkAgainButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_WIDTH)) or (checkMenuButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_WIDTH));
    xtemp:=MOUSE_X;
    ytemp:=MOUSE_Y;
    checkButtonsClick();
  end;

// подтверждение нажатия на кнопку Переиграть/в меню/выйти
function AreYouSure(): boolean;

  // кнопка НЕТ в подтверждении действия нажата
  function checkNoButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in (GraphBoxWidth div 2 - 200)..(GraphBoxWidth div 2 - 100)) and (MOUSE_Y in (GraphBoxHeight div 2)..(GraphBoxHeight div 2 + 40)) and (BUTTON_TYPE = 1) then
        checkNoButtonClick := true;
    end;
  // кнопка ДА в подтверждении действия нажата
  function checkYesButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in (GraphBoxWidth div 2 + 100)..(GraphBoxWidth div 2 + 200)) and (MOUSE_Y in (GraphBoxHeight div 2)..(GraphBoxHeight div 2 + 40)) and (BUTTON_TYPE = 1) then
        checkYesButtonClick := true;
    end;

  begin
    SaveWindow('gamewindow');
    clearwindow;
    
    // для запоминания, какую кнопку хотел нажать игрок
    xtemp:=MOUSE_X;
    ytemp:=MOUSE_Y;
    
    drawTextCentered(GraphBoxWidth div 2 - 200,GraphBoxHeight div 2 - 100,GraphBoxWidth div 2 + 200,GraphBoxHeight div 2 - 50,'Вы уверены? Прогресс будет утерян!');
    
    SetBrushColor(clIndianRed);
    DrawButton(GraphBoxWidth div 2 + 100,GraphBoxHeight div 2,GraphBoxWidth div 2 + 200,GraphBoxHeight div 2 + 40,'да');
    
    setBrushColor(clLightGreen);
    DrawButton(GraphBoxWidth div 2 - 200,GraphBoxHeight div 2,GraphBoxWidth div 2 - 100,GraphBoxHeight div 2 + 40,'нет');
    
    SetBrushColor(clWhite);
    
    repeat
      IS_MOUSE_DOWN := false;
    until
      checkYesButtonClick(MOUSE_X,MOUSE_Y,BUTTON_TYPE) or checkNoButtonClick(MOUSE_X,MOUSE_Y,BUTTON_TYPE);
    
    if checkYesButtonClick(MOUSE_X,MOUSE_Y,BUTTON_TYPE) then AreYouSure:=true
    else AreYouSure:=false;
    
    // если пользователь не хочет переигрывать/выходить в меню/закрывать игру
    // то отрисовываем сохранённое окно с прохождением уровня
    if checkNoButtonClick(MOUSE_X,MOUSE_Y,BUTTON_TYPE) then loadwindow('gamewindow');
    
    // зануляем положение курсора чтобы
    // не открылась ячейка сразу после отрисовки игрового поля
    MOUSE_X:=0;
    MOUSE_Y:=0;
  end;

// пауза
procedure pause();

  // кнопка снять с паузы нажата
  function checkUnpauseButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_WIDTH: integer): boolean;
    begin
      if (MOUSE_X in GraphBoxWidth div 2 - 100..GraphBoxWidth div 2 + 100) and (MOUSE_Y in GraphBoxHeight div 2 - 50..GraphBoxHeight div 2 + 40) and (BUTTON_TYPE = 1) then checkUnpauseButtonClick := true;
    end;

  begin
    // приостанавливаем отсчёт времени
    time1 := milliseconds;
    // записываем, сколько пользователь уже играл (секунд)
    time := (time1 - time0) div 1000 + 1;
    
    // сохраняем окно
    SaveWindow('gamewindow');
    // очищаем окно
    clearWindow();
    
    setBrushColor(clLightGreen);
    DrawButton(GraphBoxWidth div 2 - 100,GraphBoxHeight div 2 - 50,GraphBoxWidth div 2 + 100,GraphBoxHeight div 2 + 40,'продолжить');
    SetBrushColor(clWhite);
    
    repeat
      IS_MOUSE_DOWN := false;
    until
      checkUnpauseButtonClick(MOUSE_X,MOUSE_Y,BUTTON_TYPE,FIELD_WIDTH);
    
    // возобновляем отсчёт времени
    time0 := milliseconds;
    
    // рисуем окно заново
    loadwindow('gamewindow');
    
    // зануляем положение курсора чтобы
    // не открылась ячейка сразу после отрисовки игрового поля
    MOUSE_X:=0;
    MOUSE_Y:=0;
  end;

// процесс игры
procedure displayGameStep;

  // поле + очищение клеток от мин + состояния открытия + флагов на случай начала новой игры без перезапуска программы
  procedure drawField;
    begin
      var i, j: shortint;
      lockdrawing();
      setPenWidth(1);
      SetBrushColor(clLightGray);
      for i := 1 to FIELD_WIDTH do
        begin
          for j := 1 to FIELD_HEIGHT do
            begin
              rectangle(WIDTH_CELL * i, WIDTH_CELL * j, WIDTH_CELL * i + WIDTH_CELL, WIDTH_CELL * j + WIDTH_CELL);
              FIELD[i, j].opened := False;
              FIELD[i, j].mine := False;
              FIELD[i, j].flag := False;
            end;
        end;
      redraw();
      unlockdrawing();
      SetBrushColor(clWhite);
    end;

  // кнопка паузы нажата
  function checkPauseButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_WIDTH: integer): boolean;
    begin
      if (MOUSE_X in 39 * (FIELD_WIDTH + 3)..39 * (FIELD_WIDTH + 3) + 39 * 2) and (MOUSE_Y in round(39*2.5)..round(39*2.5) + 39) and (BUTTON_TYPE = 1) then checkPauseButtonClick := true;
    end;

  // открытие клетки без мины (условие)
  function notMine(i, j: integer): boolean;
    begin
      if (i in 1..FIELD_WIDTH) and (j in 1..FIELD_HEIGHT) and (BUTTON_TYPE = 1) and (FIELD[i, j].mine = False) and (FIELD[i, j].opened = False) and (FIELD[i, j].flag = false) then notMine := True;
    end;

  // поставить флаг (условие)
  function WantSetFlag(i, j: integer): boolean;
    begin
      if (i in 1..FIELD_WIDTH) and (j in 1..FIELD_HEIGHT) and (BUTTON_TYPE = 2) and (FIELD[i, j].flag = False) and (FIELD[i, j].opened = False) then WantSetFlag := True;
    end;

  // убрать флаг (условие)
  function WantDeleteFlag(i, j: integer): boolean;
    begin
      if (i in 1..FIELD_WIDTH) and (j in 1..FIELD_HEIGHT) and (BUTTON_TYPE = 2) and (FIELD[i, j].flag = True) and (FIELD[i, j].opened = False) then WantDeleteFlag := True;
    end;

  // условие поражения
  function lose(i, j: integer): boolean;
    begin
      if ((i in 1..FIELD_WIDTH) and (j in 1..FIELD_HEIGHT) and (BUTTON_TYPE = 1) and (FIELD[i, j].mine = True) and (FIELD[i, j].flag = False)) then lose := True;
    end;

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
    MOUSE_X := 0;
    MOUSE_Y := 0;
    xtemp:=0;
    ytemp:=0;
    
    // рисуем поле
    drawField();
    
    // рисуем кнопки
    DrawButton(39 * (FIELD_WIDTH + 3), 39 * 1, 39 * (FIELD_WIDTH + 3) + 39 * 2, 39 * 1 + 39, 'переиграть');
    DrawButton(39 * (FIELD_WIDTH + 3), round(39*2.5), 39 * (FIELD_WIDTH + 3) + 39 * 2, round(39*2.5) + 39, 'пауза');
    DrawButton(39 * (FIELD_WIDTH + 3), 39 * 4, 39 * (FIELD_WIDTH + 3) + 39 * 2, 39 * 5, 'назад в меню');
    DrawButton(39 * (FIELD_WIDTH + 3), 39 * FIELD_HEIGHT, 39 * (FIELD_WIDTH + 3) + 39 * 2, 39 * (FIELD_HEIGHT+1), 'выход из игры');
    
    redraw();
    unlockdrawing();
    
    repeat
      if IS_MOUSE_DOWN then
        begin
          IS_MOUSE_DOWN := false;
          i := MOUSE_X div WIDTH_CELL;
          j := MOUSE_Y div WIDTH_CELL;
          SetFontSize(15);
          // безопасное первое открытие клетки + заполнение поля минами
          if (i in 1..FIELD_WIDTH) and (j in 1..FIELD_HEIGHT) and (BUTTON_TYPE = 1) and (fcount = 0) then openFirstCell(i, j)
          else if checkPauseButtonClick(MOUSE_X,MOUSE_Y,BUTTON_TYPE,FIELD_WIDTH) then pause()
          // нажали на клетку без мины
          else if notMine(i, j) then
            begin
                // открыли клетку без мины с минами вокруг
                if (FIELD[i,j].nearbyMines <> 0) then openCell(i, j)
                // открыли клетку без мины без мин вокруг
                else openEmptyCells(i,j,fcount);
            end
          // поставили флаг
          else if WantSetFlag(i, j) then setFlag(i, j)
          // убрали флаг
          else if WantDeleteFlag(i, j) then deleteFlag(i, j)
          // хотим нажать на кнопку выхода/в меню/заново
          else if (checkAgainButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_WIDTH)) or (checkMenuButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_WIDTH)) or (checkEndButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_HEIGHT, FIELD_WIDTH)) then
              sure := AreYouSure;
        end;
    // завершение процесса игры при одном из трёх условий
    until sure or (fcount = FIELD_WIDTH * FIELD_HEIGHT - MINES_COUNT) or lose(i, j);
    
    // если выполнилось условие проигрыша, то проиграл
    if lose(i,j) then youLose();
    
    // если открыл все поля без мин, то победил
    if fcount = int(FIELD_WIDTH * FIELD_HEIGHT) - MINES_COUNT then displayWin();
    
    // последний исход завершения процесса игры - нажата кнопка меню/выход/переиграть
    checkButtonsClick();
  end;

begin 
end.
