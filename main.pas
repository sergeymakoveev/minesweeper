uses graphABC, PABCSystem;
uses GameConstants, GameVariables, CommonFunctions;
uses GameLogic;
uses UserLevelForm;
uses MyButtonsPressed;

// играть на сложности новичок
procedure setEasyLevel;
  begin
    level := 0;
    N := 8;
    M := 8;
    Nmines := 10;
    SetWindowSize((N + 6) * Width, (N + 2) * Width);
    CenterWindow;
  end;

// играть на сложности любитель
procedure setNormalLevel;
  begin
    level := 1;
    N := 16;
    M := 16;
    Nmines := 40;
    SetWindowSize((N + 6) * Width, (N + 2) * Width);
    CenterWindow;
  end;

// играть на сложности профессионал
procedure setHardLevel;
  begin
    level := 3;
    N := 19;
    M := 30;
    Nmines := 70;
    SetWindowSize((M + 6) * Width, (N + 2) * Width);
    CenterWindow
  end;

// проверка клика по кнопке: уровень "легкий"
function isEasyLevelClick(mouseX, mouseY, button: integer): boolean;
  begin
    if (mouseX in 40..570) and (mouseY in 220..260) and (button = 1) then isEasyLevelClick := true;
  end;

// проверка клика по кнопке: уровень "нормальный"
function isNormalLevelClick(mouseX, mouseY, button: integer): boolean;
  begin
    if (mouseX in 40..570) and (mouseY in 280..320) and (button = 1) then isNormalLevelClick := true;
  end;

// проверка клика по кнопке: уровень "сложный"
function isHardLevelClick(mouseX, mouseY, button: integer): boolean;
  begin
    if (mouseX in 40..570) and (mouseY in 340..380) and (button = 1) then isHardLevelClick := true;
  end;

// проверка клика по кнопке: уровень "пользовательский"
function isCustomLevelClick(mouseX, mouseY, button: integer): boolean;
  begin
    if (mouseX in 40..570) and (mouseY in 400..440) and (button = 1) then isCustomLevelClick := true;
  end;

// кнопка назад (в окне с правилами) нажата
function isBackClick(mouseX, mouseY, button: integer): boolean;
  begin
    if (mouseX in 40..570) and (mouseY in 540..580) and (button = 1) then isBackClick := true;
  end;

// главное меню
procedure displayMenuMainStep;
  begin
    mouseX := 0;
    mouseY := 0;
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
      if isMouseDown then
        begin
          isMouseDown := false;
        end;
    until
      playButtonPressed(mouseX, mouseY, button) or
      rulesButtonPressed(mouseX, mouseY, button) or
      recordsButtonPressed(mouseX, mouseY, button) or
      exitButtonPressed(mouseX, mouseY, button);
    
    if playButtonPressed(mouseX, mouseY, button) then programStep := 'MenuGameStep';
    if rulesButtonPressed(mouseX, mouseY, button) then programStep := 'RulesStep';
    if recordsButtonPressed(mouseX, mouseY, button) then programStep := 'RecordsStep';
    if exitButtonPressed(mouseX, mouseY, button) then closewindow;
  end;

// Меню игры
procedure displayMenuGameStep;
  begin
    clearwindow;
    mouseX := 0;
    mouseY := 0;
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
      if isMouseDown then
        begin
          isMouseDown := false;
        end;
    until 
      isEasyLevelClick(mouseX, mouseY, button) or
      isNormalLevelClick(mouseX, mouseY, button) or
      isHardLevelClick(mouseX, mouseY, button) or
      isCustomLevelClick(mouseX, mouseY, button) or
      isBackClick(mouseX, mouseY, button);
    
    if isEasyLevelClick(mouseX, mouseY, button) then setEasyLevel
    else if isNormalLevelClick(mouseX, mouseY, button) then setNormalLevel
    else if isHardLevelClick(mouseX, mouseY, button) then setHardLevel;

    if isCustomLevelClick(mouseX, mouseY, button) then programStep := 'UserLevelStep'
    else if isBackClick(mouseX, mouseY, button) then programStep := 'MenuMainStep'
    else programStep := 'GameStep';
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
    
    mouseX:=-1;
    mouseY:=-1;
    
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
    IsMouseDown := false;
    OnMouseDown := MouseDown;
      repeat
        if IsMouseDown then
          IsMouseDown := false;
      until isBackClick(mouseX, mouseY, button);
      
      programStep:='MenuMainStep';

  end;

// вывод правил игры
procedure displayRulesStep(var programStep: string);
  begin
    mouseX:=-1;
    mouseY:=-1;
    
    clearwindow;
    SetFontSize(20);
    Assign(input, 'Rules.txt');
    var rules := ReadString;
    DrawTextCentered(40, 20, 570, 450, rules);
    
    DrawButton(40, 540, 570, 580, 'назад');
    
    OnMouseDown := MouseDown;
    repeat
      if IsMouseDown then
      begin
        IsMouseDown := false;
      end;
    until isBackClick(mouseX, mouseY, button);
    
    programStep := 'MenuMainStep';
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
  
  programStep := 'MenuMainStep';
  
  // Отрисовка текущего окна
  repeat
    case programStep of
      'MenuGameStep': displayMenuGameStep;
      'GameStep': displayGameStep;
      'MenuMainStep': displayMenuMainStep;
      'RulesStep': displayRulesStep(programStep);
      'UserLevelStep': displayUserLevelForm(level,M,N,Nmines,programStep);
      'RecordsStep': displayRecordsStep;
    end;
  // игру закрывается из окна startmenu или game
  until false;
  
end.