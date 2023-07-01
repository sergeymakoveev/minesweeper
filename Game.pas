uses graphABC, PABCSystem;
uses GlobalConstants, GlobalVariables, CommonFunctions;
uses GameLogic;
uses GameLevelForm;

// главное меню
procedure displayMenuMainStep;

  // кнопка играть нажата
  function checkPlayButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 0..200) and (MOUSE_Y in 100..140) and (BUTTON_TYPE = 1) then checkPlayButtonClick := true;
    end;

  // кнопка правила нажата
  function checkRulesButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 0..200) and (MOUSE_Y in 160..200) and (BUTTON_TYPE = 1) then checkRulesButtonClick := true;
    end;

  // кнопка рекордов нажата
  function checkRecordsButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 0..200) and (MOUSE_Y in 220..260) and (BUTTON_TYPE = 1) then checkRecordsButtonClick := true;
    end;

  // кнопка выхода из главного меню
  function checkExitButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 0..200) and (MOUSE_Y in 280..320) and (BUTTON_TYPE = 1) then checkExitButtonClick := true;
    end;

  begin
    MOUSE_X := 0;
    MOUSE_Y := 0;

    SetWindowSize(600, 400);
    CenterWindow();
    clearwindow();
    Window.load(BACKGROUND_SRC);

    setFontSize(20);
    SetFontStyle(fsBold);
    setBrushColor(ARGB(200,255,255,255));
    FillRect(0, 20, 250, 60);
    DrawTextCentered(0, 20, 250, 60, 'Игра ¤ Сапёр ⚑');
    
    setFontSize(18);
    SetFontStyle(fsNormal);
    drawButton(0,100,200,140,'Игра');
    drawButton(0,160,200,200,'Правила');
    drawButton(0,220,200,260,'Рекорды');
    drawButton(0,280,200,320,'Выход');
    
    setFontSize(10);
    TextOut(0, 360, '   © Николаев Максим, группа 243   ');
    
    repeat
      // Пауза в 1мс позволяет меньше грузить процессор при бесконечном цикле
      sleep(1);
      if IS_MOUSE_DOWN then
        IS_MOUSE_DOWN := false;
    until
      checkPlayButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) or
      checkRulesButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) or
      checkRecordsButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) or
      checkExitButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE);
    
    if checkPlayButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) then PROGRAM_STEP := 'MenuGameStep';
    if checkRulesButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) then PROGRAM_STEP := 'RulesStep';
    if checkRecordsButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) then PROGRAM_STEP := 'RecordsStep';
    if checkExitButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) then closewindow;
  end;

// Меню игры
procedure displayMenuGameStep;

  // проверка клика по кнопке: уровень "легкий"
  function checkEasyLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 0..200) and (MOUSE_Y in 100..140) and (BUTTON_TYPE = 1) then checkEasyLevelButtonClick := true;
    end;

  // проверка клика по кнопке: уровень "нормальный"
  function checkNormalLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 0..200) and (MOUSE_Y in 160..200) and (BUTTON_TYPE = 1) then checkNormalLevelButtonClick := true;
    end;

  // проверка клика по кнопке: уровень "сложный"
  function checkHardLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 0..200) and (MOUSE_Y in 220..260) and (BUTTON_TYPE = 1) then checkHardLevelButtonClick := true;
    end;

  // проверка клика по кнопке: уровень "свой"
  function checkCustomLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 0..200) and (MOUSE_Y in 280..320) and (BUTTON_TYPE = 1) then checkCustomLevelButtonClick := true;
    end;

  // проверка клика по кнопке: "назад"
  function checkBackButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 0..200) and (MOUSE_Y in 340..380) and (BUTTON_TYPE = 1) then checkBackButtonClick := true;
    end;

  // настройка уровня игры
  procedure configureGameLevel(gameLevel: byte; fieldWidth, fieldHeight, minesCount: integer);
    begin
      GAME_LEVEL := gameLevel;
      FIELD_WIDTH := fieldWidth;
      FIELD_HEIGHT := fieldHeight;
      FIELD_MINES_COUNT := minesCount;
      SetWindowSize((FIELD_HEIGHT + 6) * WIDTH_CELL, (FIELD_HEIGHT + 2) * WIDTH_CELL);
      CenterWindow;
    end;

  begin
    MOUSE_X := 0;
    MOUSE_Y := 0;

    clearwindow();
    Window.load(BACKGROUND_SRC);
    
    drawTitle(0, 20, 270, 60, 'Уровень:');
    drawButton(0,100,200,140,'Легкий');
    drawButton(0,160,200,200,'Нормальный');
    drawButton(0,220,200,260,'Сложный');
    drawButton(0,280,200,320,'Свой');
    drawButton(0,340,200,380,'Назад');

    repeat
      // Пауза в 1мс позволяет меньше грузить процессор при бесконечном цикле
      sleep(1);
      if IS_MOUSE_DOWN then
        IS_MOUSE_DOWN := false;
    until 
      checkEasyLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) or
      checkNormalLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) or
      checkHardLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) or
      checkCustomLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) or
      checkBackButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE);
    
    if checkEasyLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) then configureGameLevel(0, 8, 8, 10)
    else if checkNormalLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) then configureGameLevel(1, 16, 16, 40)
    else if checkHardLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) then configureGameLevel(2, 30, 19, 70);

    if checkCustomLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) then PROGRAM_STEP := 'GameLevelFormStep'
    else if checkBackButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE) then PROGRAM_STEP := 'MenuMainStep'
    else PROGRAM_STEP := 'GameStep';
  end;

// Вывод таблицы рекордов
procedure displayRecordsStep();
  type 
    highScore = record
      name: string;
      score: integer;
    end;

  function checkBackButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 0..200) and (MOUSE_Y in 340..380) and (BUTTON_TYPE = 1) then checkBackButtonClick := true;
    end;

  begin
    var players: array [0..2] of highscore;
    var i: byte;
    var f: text;
    var output: string;
    
    MOUSE_X:=-1;
    MOUSE_Y:=-1;
    
    clearWindow();
    Window.load(BACKGROUND_SRC);
    
    drawTitle(0, 20, 250, 60, 'Рекорды:');

    setBrushColor(ARGB(230,255,255,255));
    FillRect(0, 80, 560, 320);
    setBrushColor(ARGB(0,255,255,255));
    setFontSize(18);

    i:=0;

    assign(f,'records.txt');
    // открытие файла с рекордами
    reset(f);
    // запись содержимого в переменные
    while (not eof(f)) do
    begin
      readln(f,players[i].name);
      readln(f,players[i].score);
      i+=1;
    end;
    // закрытие файла с рекордами
    close(f);
    
    for i:=0 to 2 do
    begin
      case i of
        0: output:='Новичок: ';
        1: output:='Любитель: ';
        2: output:='Профессионал: ';
      end;
      
      if not (players[i].score = 0)
        then output += players[i].name + ' ' + players[i].score + 'сек.'
        else output += 'рекорда нет';
      
      TextOut(40, 120 + i*60, output);
    end;

    setFontSize(18);
    setBrushColor(ARGB(200, 255, 255, 255));
    drawButton(0, 340, 200, 380, 'Назад');

    repeat
      // Пауза в 1мс позволяет меньше грузить процессор при бесконечном цикле
      sleep(1);
      if IS_MOUSE_DOWN then
        IS_MOUSE_DOWN := false;
    until
      checkBackButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE);
      
    PROGRAM_STEP:='MenuMainStep';

  end;

// вывод правил игры
procedure displayRulesStep(var PROGRAM_STEP: string);

  function checkBackButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 0..200) and (MOUSE_Y in 340..380) and (BUTTON_TYPE = 1) then checkBackButtonClick := true;
    end;

  begin
    MOUSE_X:=-1;
    MOUSE_Y:=-1;
    
    clearwindow();
    Window.load(BACKGROUND_SRC);

    drawTitle(0, 20, 250, 60, 'Правила игры:');

    Assign(input, 'Rules.txt');
    var rules := input.ReadToEnd();
    CloseFile(input);

    setBrushColor(ARGB(230,255,255,255));
    FillRect(0, 80, 560, 320);
    setBrushColor(ARGB(0,255,255,255));
    setFontSize(10);
    TextOut(40, 120, rules);

    drawButton(0, 340, 200, 380, 'Назад');
    
    repeat
      // Пауза в 1мс позволяет меньше грузить процессор при бесконечном цикле
      sleep(1);
      if IS_MOUSE_DOWN then
        IS_MOUSE_DOWN := false;
    until checkBackButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE);
    
    PROGRAM_STEP := 'MenuMainStep';
  end;

// Запуск игры
begin
  
  // Устанавливаем заголовок окна
  SetWindowCaption('Игра "Сапёр"');
  SetWindowIsFixedSize(true);

  // Задаем глобальный обработчик нажатия клавиш мыши
  // для обработки кликов по элементам интерфейса.
  // Действует постоянно в течении всего времени работы программы.
  OnMouseDown := handleMouseDown;

  
  if not (fileexists('rules.txt') and fileexists('records.txt')) then
    begin
      setFontSize(20);
      textout(0,0,'Ошибка! Отсутствуют необходимые файлы');
      sleep(4000);
      closewindow;
    end;
  
  PROGRAM_STEP := 'MenuMainStep';
  
  // Отрисовка текущего шага игры
  repeat
    // Пауза в 1мс позволяет меньше грузить процессор при бесконечном цикле
    sleep(1);
    case PROGRAM_STEP of
      'MenuGameStep': displayMenuGameStep();
      'GameStep': displayGameStep();
      'MenuMainStep': displayMenuMainStep();
      'RulesStep': displayRulesStep(PROGRAM_STEP);
      'GameLevelFormStep': displayGameLevelForm(GAME_LEVEL,FIELD_WIDTH,FIELD_HEIGHT,FIELD_MINES_COUNT,PROGRAM_STEP);
      'RecordsStep': displayRecordsStep();
    end;
  // игра закрывается из окна startmenu или game
  until false;
  
end.