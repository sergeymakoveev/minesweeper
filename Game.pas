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
    Window.load('./GameBackground.png');

    SetFontSize(20);
    SetFontStyle(fsBold);
    SetBrushColor(ARGB(200,255,255,255));
    FillRect(0, 20, 250, 60);
    DrawTextCentered(0, 20, 250, 60, 'Игра ¤ Сапёр ⚑');
    
    SetFontSize(18);
    SetFontStyle(fsNormal);
    drawButton(0,100,200,140,'Игра');
    drawButton(0,160,200,200,'Правила');
    drawButton(0,220,200,260,'Рекорды');
    drawButton(0,280,200,320,'Выход');
    
    SetFontSize(10);
    TextOut(0, 360, '   © Николаев Максим, группа 243   ');
    
    OnMouseDown := handleMouseDown;
    repeat
      if IS_MOUSE_DOWN then
        begin
          IS_MOUSE_DOWN := false;
        end;
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

// кнопка назад (в окне с правилами) нажата
function checkBackButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
  begin
    if (MOUSE_X in 40..570) and (MOUSE_Y in 540..580) and (BUTTON_TYPE = 1) then checkBackButtonClick := true;
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
    SetWindowSize(600, 400);
    CenterWindow();
    clearwindow();
    Window.load('./GameBackground.png');
    
    SetFontSize(20);
    SetFontStyle(fsBold);
    SetBrushColor(ARGB(200,255,255,255));
    FillRect(0, 20, 270, 60);
    DrawTextCentered(0, 20, 270, 60, 'Уровень:');
    SetFontSize(18);
    SetFontStyle(fsNormal);
    drawButton(0,100,200,140,'Легкий');
    drawButton(0,160,200,200,'Нормальный');
    drawButton(0,220,200,260,'Сложный');
    drawButton(0,280,200,320,'Свой');
    drawButton(0,340,200,380,'Назад');

    repeat
      if IS_MOUSE_DOWN then
        begin
          IS_MOUSE_DOWN := false;
        end;
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
procedure displayRecordsStep;
  type 
    highScore = record
      name: string;
      score: integer;
    end;

  begin
    var players: array [0..2] of highscore;
    var i: byte;
    var f: text;
    var output: string;
    
    MOUSE_X:=-1;
    MOUSE_Y:=-1;
    
    clearWindow;
    
    i:=0;

    drawButton(40, 540, 570, 580, 'назад');

    assign(f,'records.txt');
    // открытие файла
    reset(f);
    
    // запись содержимого в переменные
    while (not eof(f)) do
    begin
      readln(f,players[i].name);
      readln(f,players[i].score);
      i+=1;
    end;
    
    SetFontSize(50);
    drawTextCentered(0,0,600,100,'Лучшее время');
    SetFontSize(20);
    
    for i:=0 to 2 do
    begin
      case i of
        0: output:='Новичок: ';
        1: output:='Любитель: ';
        2: output:='Профессионал: ';
      end;
      if not (players[i].score = 0) then output += players[i].name + ' ' + players[i].score + 'с'
        else output += 'рекорда нет';
      drawTextCentered(0,100+50*(i+1),0+620,130+50*(i+1),output);
    end;
    
    close(f);
    IS_MOUSE_DOWN := false;
    OnMouseDown := handleMouseDown;

    repeat
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
    Window.load('./GameBackground.png');

    SetBrushColor(ARGB(200,255,255,255));
    FillRect(0, 20, 250, 60);
    SetFontSize(20);
    SetFontStyle(fsBold);
    DrawTextCentered(0, 20, 250, 60, 'Правила игры:');


    Assign(input, 'Rules.txt');
    var rules := input.ReadToEnd();
    CloseFile(input);

    SetBrushColor(ARGB(230,255,255,255));
    FillRect(0, 80, 560, 320);
    SetBrushColor(ARGB(0,255,255,255));
    SetFontSize(10);
    SetFontStyle(fsNormal);
    TextOut(40, 120, rules);

    SetFontSize(18);
    SetBrushColor(ARGB(200,255,255,255));
    drawButton(0, 340, 200, 380, 'Назад');
    
    OnMouseDown := handleMouseDown;
    repeat
      if IS_MOUSE_DOWN then
        begin
          IS_MOUSE_DOWN := false;
        end;
    until checkBackButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE);
    
    PROGRAM_STEP := 'MenuMainStep';
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
  
  PROGRAM_STEP := 'MenuMainStep';
  
  // Отрисовка текущего окна
  repeat
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