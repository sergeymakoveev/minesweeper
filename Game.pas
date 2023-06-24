uses graphABC, PABCSystem;
uses GlobalConstants, GlobalVariables, CommonFunctions;
uses GameLogic;
uses GameLevelForm;

// главное меню
procedure displayMenuMainStep;

  // кнопка играть нажата
  function checkPlayButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 40..570) and (MOUSE_Y in 220..260) and (BUTTON_TYPE = 1) then checkPlayButtonClick := true;
    end;

  // кнопка правила нажата
  function checkRulesButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 40..570) and (MOUSE_Y in 280..320) and (BUTTON_TYPE = 1) then checkRulesButtonClick := true;
    end;

  // кнопка рекордов нажата
  function checkRecordsButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 40..570) and (MOUSE_Y in 340..380) and (BUTTON_TYPE = 1) then checkRecordsButtonClick := true;
    end;

  // кнопка выхода из главного меню
  function checkExitButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 40..570) and (MOUSE_Y in 540..580) and (BUTTON_TYPE = 1) then checkExitButtonClick := true;
    end;

  begin
    MOUSE_X := 0;
    MOUSE_Y := 0;
    SetWindowSize(620, 700);
    
    CenterWindow;
    clearwindow;
    
    SetFontSize(65);
    textOut(40, 40, 'Игра "Сапёр"');
    SetFontSize(10);
    TextOut(40, 660, 'Николаев Максим, группа 243');
    
    SetFontSize(20);
    DrawButton(40,220,570,260,'Играть');
    DrawButton(40,280,570,320,'Правила');
    DrawButton(40,340,570,380,'Рекорды');
    DrawButton(40,540,570,580,'Выход');
    
    OnMouseDown := MouseDown;
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
      if (MOUSE_X in 40..570) and (MOUSE_Y in 220..260) and (BUTTON_TYPE = 1) then checkEasyLevelButtonClick := true;
    end;

  // проверка клика по кнопке: уровень "нормальный"
  function checkNormalLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 40..570) and (MOUSE_Y in 280..320) and (BUTTON_TYPE = 1) then checkNormalLevelButtonClick := true;
    end;

  // проверка клика по кнопке: уровень "сложный"
  function checkHardLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 40..570) and (MOUSE_Y in 340..380) and (BUTTON_TYPE = 1) then checkHardLevelButtonClick := true;
    end;

  // проверка клика по кнопке: уровень "пользовательский"
  function checkCustomLevelButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE: integer): boolean;
    begin
      if (MOUSE_X in 40..570) and (MOUSE_Y in 400..440) and (BUTTON_TYPE = 1) then checkCustomLevelButtonClick := true;
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
    clearwindow;
    MOUSE_X := 0;
    MOUSE_Y := 0;
    SetWindowSize(620, 700);
    CenterWindow;
    
    SetFontSize(20);
    DrawTextCentered(40, 140, 570, 190, 'Выберите уровень:');
    DrawButton(40,220,570,260,'Легкий: поле 8х8, 10 мин');
    DrawButton(40,280,570,320,'Нормальный: поле 16х16, 40 мин');
    DrawButton(40,340,570,380,'Сложный: поле 19х30, 70 мин');
    DrawButton(40,400,570,440,'Пользовательский');
    DrawButton(40,540,570,580,'Назад');

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

    DrawButton(40, 540, 570, 580, 'назад');

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
    OnMouseDown := MouseDown;

    repeat
      if IS_MOUSE_DOWN then
        IS_MOUSE_DOWN := false;
    until
      checkBackButtonClick(MOUSE_X, MOUSE_Y, BUTTON_TYPE);
      
    PROGRAM_STEP:='MenuMainStep';

  end;

// вывод правил игры
procedure displayRulesStep(var PROGRAM_STEP: string);
  begin
    MOUSE_X:=-1;
    MOUSE_Y:=-1;
    
    clearwindow;
    SetFontSize(20);
    Assign(input, 'Rules.txt');
    var rules := ReadString;
    DrawTextCentered(40, 20, 570, 450, rules);
    
    DrawButton(40, 540, 570, 580, 'назад');
    
    OnMouseDown := MouseDown;
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