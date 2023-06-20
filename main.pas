uses graphABC, PABCSystem;
uses GameConstants, GameVariables, CommonFunctions;
uses GameLogic;
uses MyButtonsPressed, MyInput, FileWork;

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
      if IsMouseDown then
        begin
          IsMouseDown := false;
        end;
    until
      playButtonPressed(mouseX, mouseY, button) or
      rulesButtonPressed(mouseX, mouseY, button) or
      recordsButtonPressed(mouseX, mouseY, button) or
      exitButtonPressed(mouseX, mouseY, button);
    
    if playButtonPressed(mouseX, mouseY, button) then programStep := 'MenuGameStep';
    if rulesButtonPressed(mouseX, mouseY, button) then programStep := 'RulesStep';
    if recordsButtonPressed(mouseX, mouseY, button) then programStep := 'records';
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
    DrawTextCentered(40, 140, 570, 190, 'Выберите уровень сложности');
    DrawButton(40,220,570,260,'Новичок: поле 8х8, 10 мин');
    DrawButton(40,280,570,320,'Любитель: поле 16х16, 40 мин');
    DrawButton(40,340,570,380,'Профессионал: поле 19х30, 70 мин');
    DrawButton(40,400,570,440,'Пользовательская');
    DrawButton(40,540,570,580,'Назад');

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

    if customPressed(mouseX, mouseY, button) then programStep := 'customLevel'
    else if backButtonPressed(mouseX, mouseY, button) then programStep := 'MenuMainStep'
    else programStep := 'GameStep';
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
      'customLevel': customLevel(level,M,N,Nmines,programStep);
      'records': records(programStep);
    end;
  // игру закрывается из окна startmenu или game
  until false;
  
end.