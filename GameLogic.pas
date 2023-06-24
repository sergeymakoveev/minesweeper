unit GameLogic;

Interface

  uses graphABC, PABCSystem;
  uses GlobalConstants, GlobalVariables, CommonFunctions;
  uses UserLevelForm;

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
function checkMenuButtonClick(mouseX, mouseY, button, M: integer): boolean;
  begin
    if (mouseX in 39 * (M + 3)..39 * (M + 3) + 39 * 2) and (mouseY in 39 * 4..39 * 5) and (button = 1) then checkMenuButtonClick := true;
  end;
// кнопка завершить программу нажата
function checkEndButtonClick(mouseX, mouseY, button, N, M: integer): boolean;
  begin
    if (mouseX in 39 * (M + 3)..39 * (M + 3) + 39 * 2) and (mouseY in 39 * N..39 * (N+1)) and (button = 1) then checkEndButtonClick := true;
  end;
// кнопка переиграть нажата
function checkAgainButtonClick(mouseX, mouseY, button, M: integer): boolean;
  begin
    if (mouseX in (39 * (M + 3))..(39 * (M + 3) + 39 * 2)) and (mouseY in 39 * 1..39 * 1 + 39) and (button = 1) then
      checkAgainButtonClick := true;
  end;

// заполнение поля минами
procedure fillField();
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
          // количество мин возле клетки
          Field[i, j].nearbyMines := k;
          k := 0;
        end;     
  end;

// открытие клетки
procedure openCell(i, j: shortint);
  begin
    Field[i, j].opened := True;
    // счётчик открытых клеток
    fcount += 1;
    // белый фон вместо серого
    FillRectangle(39 * i + 2, 39 * j + 2, 39 * i + WIDTH_CELL - 2, 39 * j + WIDTH_CELL - 2);
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
    if Field[i, j].nearbyMines <> 0 then DrawTextCentered(39 * i, 39 * j, 39 * i + WIDTH_CELL, 39 * j + WIDTH_CELL, Field[i, j].nearbyMines);
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
            if (i+ii in 1..M) and (j+jj in 1..N) and (Field[i+ii,j+jj].opened = False) then
              begin
                // останавливаем открытие на клетке с цифрой
                if (Field[i+ii,j+jj].nearbyMines <> 0) and (Field[i+ii,j+jj].flag = False) then openCell(i+ii,j+jj)
                // если пустая - открываем дальше
                else  if (Field[i+ii,j+jj].nearbyMines = 0) and (Field[i+ii,j+jj].flag = False) then openEmptyCells(i+ii,j+jj,fcount);
              end;
          end;
      end;
  end;

// первое открытие клетки за игру
procedure openFirstCell(i, j: shortint);
  begin
    time0 := Milliseconds;
    time:=0;
    Field[i, j].opened := True;
    Field[i, j].mine := False;
    fillField();
    setupField();
    if Field[i,j].nearbyMines = 0 then openEmptyCells(i,j,fcount);
    FillRectangle(39 * i + 2, 39 * j + 2, 39 * i + WIDTH_CELL - 2, 39 * j + WIDTH_CELL - 2);
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
        DrawTextCentered(39 * i, 39 * j, 39 * i + WIDTH_CELL, 39 * j + WIDTH_CELL, Field[i, j].nearbyMines); 
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
    Field[i, j].flag := True;
  end;

// убрали флаг
procedure deleteFlag(var i: shortint; j: shortint);
  begin
    Field[i, j].flag := False;
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
    if checkMenuButtonClick(xtemp, ytemp, button, M) then PROGRAM_STEP := 'MenuMainStep'
    // начинаем заново
    else if checkAgainButtonClick(xtemp, ytemp, button, M) then PROGRAM_STEP := 'GameStep'
    // выход из игры
    else if checkEndButtonClick(xtemp, ytemp, button, N, M) then closewindow();
  end;

// поражение
procedure youLose();
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
              FillRectangle(39 * i + 2, 39 * j + 2, 39 * i + WIDTH_CELL - 2, 39 * j + WIDTH_CELL - 2);
              SetBrushColor(clWhite);
            end;
          if Field[i, j].mine = True then DrawTextCentered(39 * i, 39 * j, 39 * i + WIDTH_CELL, 39 * j + WIDTH_CELL, 'M');
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
    until (checkEndButtonClick(xtemp, ytemp, button, N, M)) or (checkAgainButtonClick(xtemp, ytemp, button, M)) or (checkMenuButtonClick(xtemp, ytemp, button, M));
    checkButtonsClick();
  end;

// нажатие на клавиатуру (имя рекордсмена)
procedure onKeyPressName(ch: char);
  begin
    isInputDone := false;
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
          isInputDone:=True;
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
    isInputDone:=False;

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
            repeat i:=i+0 until isInputDone;
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
    
    fillrectangle(39 * (M + 3), round(39*2.5), 39 * (M + 3) + 39 * 2, round(39*2.5) + 39);// убрать кнопку паузы
    
    finishText := 'Вы победили! Секунд затрачено: ' + time;
    SetFontSize(10);
    TextOut(38,0,finishtext);
    
    // отключаем мышь на время записи рекорда
    OnMouseDown:=Nil;
    
    // если не на пользовательском уровне, то проверяем время на рекорд
    if GAME_LEVEL <> 3 then checkIsBest(time,GAME_LEVEL);
    
    OnMouseDown:=MouseDown;
    repeat
      if IsMouseDown then
        begin
          IsMouseDown := false;
        end;
    until (checkEndButtonClick(mouseX, mouseY, button, N, M)) or (checkAgainButtonClick(mouseX, mouseY, button, M)) or (checkMenuButtonClick(mouseX, mouseY, button, M));
    xtemp:=mouseX;
    ytemp:=mouseY;
    checkButtonsClick();
  end;

// подтверждение нажатия на кнопку Переиграть/в меню/выйти
function AreYouSure(): boolean;

  // кнопка НЕТ в подтверждении действия нажата
  function checkNoButtonClick(mouseX, mouseY, button: integer): boolean;
    begin
      if (mouseX in (GraphBoxWidth div 2 - 200)..(GraphBoxWidth div 2 - 100)) and (mouseY in (GraphBoxHeight div 2)..(GraphBoxHeight div 2 + 40)) and (button = 1) then
        checkNoButtonClick := true;
    end;
  // кнопка ДА в подтверждении действия нажата
  function checkYesButtonClick(mouseX, mouseY, button: integer): boolean;
    begin
      if (mouseX in (GraphBoxWidth div 2 + 100)..(GraphBoxWidth div 2 + 200)) and (mouseY in (GraphBoxHeight div 2)..(GraphBoxHeight div 2 + 40)) and (button = 1) then
        checkYesButtonClick := true;
    end;

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
    until
      checkYesButtonClick(mouseX,mouseY,button) or checkNoButtonClick(mouseX,mouseY,button);
    
    if checkYesButtonClick(mouseX,mouseY,button) then AreYouSure:=true
    else AreYouSure:=false;
    
    // если пользователь не хочет переигрывать/выходить в меню/закрывать игру
    // то отрисовываем сохранённое окно с прохождением уровня
    if checkNoButtonClick(mouseX,mouseY,button) then loadwindow('gamewindow');
    
    // зануляем положение курсора чтобы
    // не открылась ячейка сразу после отрисовки игрового поля
    mouseX:=0;
    mouseY:=0;
  end;

// пауза
procedure pause();

  // кнопка снять с паузы нажата
  function checkUnpauseButtonClick(mouseX, mouseY, button, M: integer): boolean;
    begin
      if (mouseX in GraphBoxWidth div 2 - 100..GraphBoxWidth div 2 + 100) and (mouseY in GraphBoxHeight div 2 - 50..GraphBoxHeight div 2 + 40) and (button = 1) then checkUnpauseButtonClick := true;
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
      IsMouseDown := false;
    until
      checkUnpauseButtonClick(mouseX,mouseY,button,M);
    
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
procedure displayGameStep;

  // поле + очищение клеток от мин + состояния открытия + флагов на случай начала новой игры без перезапуска программы
  procedure drawField;
    begin
      var i, j: shortint;
      lockdrawing();
      setPenWidth(1);
      SetBrushColor(clLightGray);
      for i := 1 to M do
        begin
          for j := 1 to N do
            begin
              rectangle(WIDTH_CELL * i, WIDTH_CELL * j, WIDTH_CELL * i + WIDTH_CELL, WIDTH_CELL * j + WIDTH_CELL);
              Field[i, j].opened := False;
              Field[i, j].mine := False;
              Field[i, j].flag := False;
            end;
        end;
      redraw();
      unlockdrawing();
      SetBrushColor(clWhite);
    end;

  // кнопка паузы нажата
  function checkPauseButtonClick(mouseX, mouseY, button, M: integer): boolean;
    begin
      if (mouseX in 39 * (M + 3)..39 * (M + 3) + 39 * 2) and (mouseY in round(39*2.5)..round(39*2.5) + 39) and (button = 1) then checkPauseButtonClick := true;
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
    drawField();
    
    // рисуем кнопки
    DrawButton(39 * (M + 3), 39 * 1, 39 * (M + 3) + 39 * 2, 39 * 1 + 39, 'переиграть');
    DrawButton(39 * (M + 3), round(39*2.5), 39 * (M + 3) + 39 * 2, round(39*2.5) + 39, 'пауза');
    DrawButton(39 * (M + 3), 39 * 4, 39 * (M + 3) + 39 * 2, 39 * 5, 'назад в меню');
    DrawButton(39 * (M + 3), 39 * N, 39 * (M + 3) + 39 * 2, 39 * (N+1), 'выход из игры');
    
    redraw();
    unlockdrawing();
    
    repeat
      if IsMouseDown then
        begin
          IsMouseDown := false;
          i := mouseX div WIDTH_CELL;
          j := mouseY div WIDTH_CELL;
          SetFontSize(15);
          // безопасное первое открытие клетки + заполнение поля минами
          if (i in 1..M) and (j in 1..N) and (button = 1) and (fcount = 0) then openFirstCell(i, j)
          else if checkPauseButtonClick(mouseX,mouseY,button,M) then pause()
          // нажали на клетку без мины
          else if notMine(i, j) then
            begin
                // открыли клетку без мины с минами вокруг
                if (Field[i,j].nearbyMines <> 0) then openCell(i, j)
                // открыли клетку без мины без мин вокруг
                else openEmptyCells(i,j,fcount);
            end
          // поставили флаг
          else if WantSetFlag(i, j) then setFlag(i, j)
          // убрали флаг
          else if WantDeleteFlag(i, j) then deleteFlag(i, j)
          // хотим нажать на кнопку выхода/в меню/заново
          else if (checkAgainButtonClick(mouseX, mouseY, button, M)) or (checkMenuButtonClick(mouseX, mouseY, button, M)) or (checkEndButtonClick(mouseX, mouseY, button, N, M)) then
              sure := AreYouSure;
        end;
    // завершение процесса игры при одном из трёх условий
    until sure or (fcount = M * N - MINES_COUNT) or lose(i, j);
    
    // если выполнилось условие проигрыша, то проиграл
    if lose(i,j) then youLose();
    
    // если открыл все поля без мин, то победил
    if fcount = int(M * N) - MINES_COUNT then displayWin();
    
    // последний исход завершения процесса игры - нажата кнопка меню/выход/переиграть
    checkButtonsClick();
  end;

begin 
end.
