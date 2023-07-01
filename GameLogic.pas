unit GameLogic;

Interface

  uses graphABC, PABCSystem;
  uses GlobalConstants, GlobalVariables, CommonFunctions;

  procedure displayGameStep;

Implementation

const
  SYMBOL_MINE = '¤';
  SYMBOL_FLAG = '⚑';

var
  // количество открытых ячеек
  fcount: integer;
  // нужны для подтверждения действия и нажатия на кнопки (выход в меню/переиграть/закрыть программу)
  xtemp, ytemp: integer;
  // переменные, отвечающие за время прохождения
  time0, time1, time: integer;
  // ширина игрового поля
  windowWidth: integer;
  // высота игрового поля
  windowHeight: integer;
  // высота игрового поля по ширине
  windowCenterX: integer;
  // высота игрового поля по высоте
  windowCenterY: integer;

// отображение оверлея
procedure displayOverlay();
begin
  setBrushColor(ARGB(200,255,255,255));
  FillRect(0, 0, GraphBoxWidth, GraphBoxHeight);
end;

procedure alert(message: string := '');
  var verticalPadding := 0;

  // Проверка нажатия кнопки "Продолжить"
  function checkContinueButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_WIDTH: integer): boolean;
    begin
      if
        (MOUSE_X in windowCenterX - 100..windowCenterX + 100)
        and (MOUSE_Y in windowCenterY + verticalPadding - 20..windowCenterY + verticalPadding + 20)
        and (BUTTON_TYPE = 1)
      then
        checkContinueButtonClick := true;
    end;

  begin
    // сохраняем окно
    saveWindow('gamewindow');

    displayOverlay();

    if (length(message) > 0) then
      verticalPadding := 100;

    drawTextCentered(0, 0, GraphBoxWidth, GraphBoxHeight, message);
    drawButton(windowCenterX - 100, windowCenterY + verticalPadding - 20, windowCenterX + 100, windowCenterY + verticalPadding + 20, 'Продолжить', clLightGreen);

    repeat
      // Пауза в 1мс позволяет меньше грузить процессор при бесконечном цикле
      sleep(1);
      if IS_MOUSE_DOWN then
        IS_MOUSE_DOWN := false;
    until
      checkContinueButtonClick(MOUSE_X,MOUSE_Y,BUTTON_TYPE,FIELD_WIDTH);
    
    // рисуем окно заново
    loadwindow('gamewindow');

    // зануляем положение курсора чтобы
    // не открылась ячейка сразу после отрисовки игрового поля
    MOUSE_X:=0;
    MOUSE_Y:=0;
  end;

// подтверждение нажатия на кнопку Переиграть/Меню/Выйти
function confirmation(const message: string): boolean;

  // кнопка НЕТ в подтверждении действия нажата
  function checkNoButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if
        (MOUSE_X in (windowCenterX + 20)..(windowCenterX + 120))
        and (MOUSE_Y in (windowCenterY + 50)..(windowCenterY + 50 + 40))
        and (BUTTON_TYPE = 1)
      then
        checkNoButtonClick := true;
    end;
  // кнопка ДА в подтверждении действия нажата
  function checkYesButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if
        (MOUSE_X in (windowCenterX - 120)..(windowCenterX - 20))
        and (MOUSE_Y in (windowCenterY + 50)..(windowCenterY + 50 + 40))
        and (BUTTON_TYPE = 1)
      then
        checkYesButtonClick := true;
    end;

  begin
    saveWindow('gamewindow');

    displayOverlay();

    // для запоминания, какую кнопку хотел нажать игрок
    xtemp:=MOUSE_X;
    ytemp:=MOUSE_Y;
    
    setFontSize(25);
    drawTextCentered(0, 0, GraphBoxWidth, GraphBoxHeight, message);

    drawButton(windowCenterX - 120, windowCenterY + 50, windowCenterX - 20, windowCenterY + 50 + 40, 'Да', clLightGreen);
    drawButton(windowCenterX + 20, windowCenterY + 50, windowCenterX + 120, windowCenterY + 50 + 40, 'Нет', clIndianRed);
    
    repeat
      // Пауза в 1мс позволяет меньше грузить процессор при бесконечном цикле
      sleep(1);
      if IS_MOUSE_DOWN then
        IS_MOUSE_DOWN := false;
    until
      checkYesButtonClick(MOUSE_X,MOUSE_Y,BUTTON_TYPE) or
      checkNoButtonClick(MOUSE_X,MOUSE_Y,BUTTON_TYPE);
    
    if checkYesButtonClick(MOUSE_X,MOUSE_Y,BUTTON_TYPE)
      then confirmation := true
      else confirmation := false;

    // если пользователь не хочет переигрывать/выходить в меню/закрывать игру
    // то отрисовываем сохранённое окно с прохождением уровня
    if checkNoButtonClick(MOUSE_X,MOUSE_Y,BUTTON_TYPE)
      then loadwindow('gamewindow');
    
    // зануляем положение курсора чтобы
    // не открылась ячейка сразу после отрисовки игрового поля
    MOUSE_X:=0;
    MOUSE_Y:=0;
  end;

// кнопа вернуться в главное меню нажата
function checkMenuButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_WIDTH: integer): boolean;
  begin
    if
      (MOUSE_X in windowWidth - 150..windowWidth - 50)
      and (MOUSE_Y in WIDTH_CELL * 5..WIDTH_CELL * 6)
      and (BUTTON_TYPE = 1)
    then checkMenuButtonClick := true;
  end;
// кнопка завершить программу нажата
function checkExitButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_HEIGHT, FIELD_WIDTH: integer): boolean;
  begin
    if
      (MOUSE_X in windowWidth - 150..windowWidth - 50)
      and (MOUSE_Y in WIDTH_CELL * 7..WIDTH_CELL * 8)
      and (BUTTON_TYPE = 1) then checkExitButtonClick := true;
  end;
// кнопка переиграть нажата
function checkRestartButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_WIDTH: integer): boolean;
  begin
    if
      (MOUSE_X in windowWidth - 150..windowWidth - 50)
      and (MOUSE_Y in WIDTH_CELL * 1..WIDTH_CELL * 2)
      and (BUTTON_TYPE = 1)
    then
      checkRestartButtonClick := true;
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
              DrawTextCentered(39 * i, 39 * j, 39 * i + WIDTH_CELL, 39 * j + WIDTH_CELL, SYMBOL_MINE);
          end;
      end;
    until count = FIELD_MINES_COUNT;
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
    DrawTextCentered(39 * i, 39 * j, 39 * i + WIDTH_CELL, 39 * j + WIDTH_CELL, SYMBOL_FLAG);
    SetFontColor(clBlack);
    FIELD[i, j].flag := True;
  end;

// убрали флаг
procedure deleteFlag(var i: shortint; j: shortint);
  begin
    FIELD[i, j].flag := False;
    setBrushColor(clLightGray);
    FillRectangle(39 * i + 2, 39 * j + 2, 39 * i + WIDTH_CELL - 2, 39 * j + WIDTH_CELL - 2);
    setBrushColor(clWhite);
    // после выполнения действия зануляем переменную (иначе приводит к ошибке)
    i:=0;
    j:=0;
  end;

// проверка кнопок в окне во время игры на нажатие (которые требуют подтверждения)
procedure checkButtonsClick();
  begin
    // выход в меню
    if
      checkMenuButtonClick(xtemp, ytemp, BUTTON_TYPE, FIELD_WIDTH)
    then
      PROGRAM_STEP := 'MenuMainStep'
    // начинаем заново
    else if
      checkRestartButtonClick(xtemp, ytemp, BUTTON_TYPE, FIELD_WIDTH)
    then
      PROGRAM_STEP := 'GameStep'
    // выход из игры
    else if
      checkExitButtonClick(xtemp, ytemp, BUTTON_TYPE, FIELD_HEIGHT, FIELD_WIDTH)
    then
      closewindow();
  end;

// нажатие на клавиатуру (имя рекордсмена)
procedure onKeyPressName(ch: char);
  begin
    IS_USER_INPUT_DONE := false;
    lockdrawing();
    fillrect(350,20,500,36);
    if ((ch in ('А'..'Я')) or (ch in ('а'..'я'))) and (length(USER_INPUT)<15) then USER_INPUT+=ch;
    textout(350,20,USER_INPUT);
    // если нажали на Delete
    if ord(ch) = 8 then
      begin
        // удаление одного последнего символа по требованию
        delete(USER_INPUT,length(USER_INPUT),1);
        fillrect(350,20,500,36);
        textout(350,20,USER_INPUT);
      end;
    unlockdrawing();
    redraw();
    // если нажали на Enter(конец проверки на событие)
    if ord(ch) = VK_Enter then
      begin
          onKeyPress:=Nil;
          IS_USER_INPUT_DONE:=True;
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
    IS_USER_INPUT_DONE:=False;

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
    if (players[GAME_LEVEL].score = 0) or (time < players[GAME_LEVEL].score)  then
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
            USER_INPUT:='';
            onKeyPress:=onKeyPressName;
            repeat i:=i+0 until IS_USER_INPUT_DONE;
            writeln(f2,USER_INPUT);
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
    
    if GAME_LEVEL <> 3 
      // проверка на рекорд для остальных уровней сложности
      then checkIsBest(time, GAME_LEVEL)
      // для пользовательского уровня выводим время прохождения
      else
        begin
          alert('Победа! Время прохождения: ' + time + ' сек.');
          PROGRAM_STEP := 'MenuMainStep';
        end;
  end;

// пауза
procedure pause();

  begin
    // приостанавливаем отсчёт времени
    time1 := milliseconds;
    // записываем, сколько пользователь уже играл (секунд)
    time := (time1 - time0) div 1000 + 1;
    
    alert();

    // возобновляем отсчёт времени
    time0 := milliseconds;
  end;

// процесс игры
procedure displayGameStep();

  // поле + очищение клеток от мин + состояния открытия + флагов на случай начала новой игры без перезапуска программы
  procedure drawField();
    begin
      var i, j: shortint;
      lockdrawing();
      setPenWidth(1);
      setBrushColor(clLightGray);
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
      setBrushColor(clWhite);
    end;

  // кнопка паузы нажата
  function checkPauseButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_WIDTH: integer): boolean;
    begin
      if
        (MOUSE_X in windowWidth - 150..windowWidth - 50)
        and (MOUSE_Y in WIDTH_CELL * 3..WIDTH_CELL * 4)
        and (BUTTON_TYPE = 1)
      then
        checkPauseButtonClick := true;
    end;

  // открытие клетки без мины (условие)
  function checkMine(i, j: integer): boolean;
    begin
      if
        (i in 1..FIELD_WIDTH)
        and (j in 1..FIELD_HEIGHT)
        and (BUTTON_TYPE = 1)
        and (FIELD[i, j].mine = False)
        and (FIELD[i, j].opened = False)
        and (FIELD[i, j].flag = false)
      then
        checkMine := True;
    end;

  // поставить флаг (условие)
  function checkSetFlag(i, j: integer): boolean;
    begin
      if
        (i in 1..FIELD_WIDTH)
        and (j in 1..FIELD_HEIGHT)
        and (BUTTON_TYPE = 2)
        and (FIELD[i, j].flag = False)
        and (FIELD[i, j].opened = False)
      then
        checkSetFlag := True;
    end;

  // убрать флаг (условие)
  function checkDeleteFlag(i, j: integer): boolean;
    begin
      if
        (i in 1..FIELD_WIDTH)
        and (j in 1..FIELD_HEIGHT)
        and (BUTTON_TYPE = 2)
        and (FIELD[i, j].flag = True)
        and (FIELD[i, j].opened = False)
      then
        checkDeleteFlag := True;
    end;

  // условие поражения
  function checkIsLose(i, j: integer): boolean;
    begin
      if
        ((i in 1..FIELD_WIDTH)
        and (j in 1..FIELD_HEIGHT)
        and (BUTTON_TYPE = 1)
        and (FIELD[i, j].mine = True)
        and (FIELD[i, j].flag = False))
      then
        checkIsLose := True;
    end;

  // поражение
  procedure displayLose();
    begin
      time1 := Milliseconds;
      time := time + (time1 - time0) div 1000 + 1;
      setFontSize(15);
      alert('Вы проиграли потратив ' + time + ' секунд(ы)...');
      PROGRAM_STEP := 'MenuMainStep';
    end;

  begin
    var i, j: shortint;
    var isConfirmed: boolean;

    // ширина игрового поля
    windowWidth := FIELD_WIDTH * WIDTH_CELL + 240;
    // высота игрового поля
    windowHeight := FIELD_HEIGHT * WIDTH_CELL + TEXT_PADDING*2;
    // центр окна по ширине
    windowCenterX := GraphBoxWidth div 2;
    // центр окна по высоте
    windowCenterY := GraphBoxHeight div 2;

    if(BACKGROUND_WIDTH > windowWidth)
      then windowWidth := BACKGROUND_WIDTH;
    if(BACKGROUND_HEIGHT > windowHeight)
      then windowHeight := BACKGROUND_HEIGHT;

    clearWindow();
    setWindowSize(windowWidth, windowHeight);
    centerWindow();
    var background := Picture.Create(BACKGROUND_SRC);
    background.SetSize(windowWidth, windowHeight);
    background.Draw(0, 0);

    lockDrawing();
    setFontSize(10);
    
    // обнуляем переменные
    fcount := 0;
    i := 0;
    j := 0;
    MOUSE_X := 0;
    MOUSE_Y := 0;
    xtemp := 0;
    ytemp := 0;
    
    // рисуем поле
    drawField();
    
    // рисуем кнопки
    drawButton(windowWidth - 150, WIDTH_CELL * 1, windowWidth - 50, WIDTH_CELL * 2, 'Рестарт');
    drawButton(windowWidth - 150, WIDTH_CELL * 3, windowWidth - 50, WIDTH_CELL * 4, 'Пауза');
    drawButton(windowWidth - 150, WIDTH_CELL * 5, windowWidth - 50, WIDTH_CELL * 6, 'Меню');
    drawButton(windowWidth - 150, WIDTH_CELL * 7, windowWidth - 50, WIDTH_CELL * 8, 'Выход');
    
    redraw();
    unlockdrawing();
    
    repeat
      if IS_MOUSE_DOWN then
        begin
          // Пауза в 1мс позволяет меньше грузить процессор при бесконечном цикле
          sleep(1);
          IS_MOUSE_DOWN := false;
          i := MOUSE_X div WIDTH_CELL;
          j := MOUSE_Y div WIDTH_CELL;
          setFontSize(15);
          // безопасное первое открытие клетки + заполнение поля минами
          if (i in 1..FIELD_WIDTH) and (j in 1..FIELD_HEIGHT) and (BUTTON_TYPE = 1) and (fcount = 0)
            then openFirstCell(i, j)
            else if checkPauseButtonClick(MOUSE_X,MOUSE_Y,BUTTON_TYPE,FIELD_WIDTH)
              then pause()
              // нажали на клетку без мины
              else if checkMine(i, j) then
                begin
                    // открыли клетку без мины с минами вокруг
                    if (FIELD[i,j].nearbyMines <> 0) then openCell(i, j)
                    // открыли клетку без мины без мин вокруг
                    else openEmptyCells(i,j,fcount);
                end
              // поставили флаг
              else if checkSetFlag(i, j) then setFlag(i, j)
              // Убран флаг
              else if checkDeleteFlag(i, j) then deleteFlag(i, j)
              // Нажата кнопка выход/меню/рестарт
              else if checkRestartButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_WIDTH)
                then isConfirmed := confirmation('Начать игру заново?')
              else if checkMenuButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_WIDTH)
                then isConfirmed := confirmation('Выйти в меню?')
              else if (checkExitButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE, FIELD_HEIGHT, FIELD_WIDTH))
                then isConfirmed := confirmation('Выйти из игры?')
        end;
    // завершение процесса игры при одном из трёх условий
    until isConfirmed or (fcount = FIELD_WIDTH * FIELD_HEIGHT - FIELD_MINES_COUNT) or checkIsLose(i, j);

    // Отладка: отображение выигрыша при проигрыше
    // if checkIsLose(i,j) then displayWin();

    // если выполнилось условие проигрыша, то проиграл
    if checkIsLose(i,j) then displayLose();
    
    // если открыл все поля без мин, то победил
    if fcount = int(FIELD_WIDTH * FIELD_HEIGHT) - FIELD_MINES_COUNT then displayWin();
    
    // последний исход завершения процесса игры - нажата кнопка меню/выход/переиграть
    checkButtonsClick();
  end;

begin 
end.
