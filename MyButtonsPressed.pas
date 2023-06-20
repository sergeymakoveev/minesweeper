﻿unit MyButtonsPressed;

Interface
  uses graphABC;
  function playButtonPressed(mouseX, mouseY, button: integer): boolean;
  function rulesButtonPressed(mouseX, mouseY, button: integer): boolean;
  function recordsButtonPressed(mouseX, mouseY, button: integer): boolean;
  function exitButtonPressed(mouseX, mouseY, button: integer): boolean;
  function menuButtonPressed(mouseX, mouseY, button, M: integer): boolean;
  function endButtonPressed(mouseX, mouseY, button, N, M: integer): boolean;
  function againButtonPressed(mouseX, mouseY, button, M: integer): boolean;
  function pauseButtonPressed(mouseX, mouseY, button, M: integer): boolean;
  function unpauseButtonPressed(mouseX, mouseY, button, M: integer): boolean;
  function yesButtonPressed(mouseX, mouseY, button: integer): boolean;
  function noButtonPressed(mouseX, mouseY, button: integer): boolean;
  
Implementation

// кнопка играть нажата
function playButtonPressed(mouseX, mouseY, button: integer): boolean;
  begin
    if (mouseX in 40..570) and (mouseY in 220..260) and (button = 1) then playButtonPressed := true;
  end;

// кнопка правила нажата
function rulesButtonPressed(mouseX, mouseY, button: integer): boolean;
  begin
    if (mouseX in 40..570) and (mouseY in 280..320) and (button = 1) then rulesButtonPressed := true;
  end;

// кнопка рекордов нажата
function recordsButtonPressed(mouseX, mouseY, button: integer): boolean;
  begin
    if (mouseX in 40..570) and (mouseY in 340..380) and (button = 1) then recordsButtonPressed := true;
  end;

// кнопка выхода из главного меню
function exitButtonPressed(mouseX, mouseY, button: integer): boolean;
  begin
    if (mouseX in 40..570) and (mouseY in 540..580) and (button = 1) then exitButtonPressed := true;
  end;

// кнопка паузы нажата
function pauseButtonPressed(mouseX, mouseY, button, M: integer): boolean;
  begin
    if (mouseX in 39 * (M + 3)..39 * (M + 3) + 39 * 2) and (mouseY in round(39*2.5)..round(39*2.5) + 39) and (button = 1) then pauseButtonPressed := true;
  end;

// кнопка снять с паузы нажата
function unpauseButtonPressed(mouseX, mouseY, button, M: integer): boolean;
  begin
    if (mouseX in GraphBoxWidth div 2 - 100..GraphBoxWidth div 2 + 100) and (mouseY in GraphBoxHeight div 2 - 50..GraphBoxHeight div 2 + 40) and (button = 1) then unpauseButtonPressed := true;
  end;

// кнопа вернуться в главное меню нажата
function menuButtonPressed(mouseX, mouseY, button, M: integer): boolean;
  begin
    if (mouseX in 39 * (M + 3)..39 * (M + 3) + 39 * 2) and (mouseY in 39 * 4..39 * 5) and (button = 1) then menuButtonPressed := true;
  end;

// кнопка завершить программу нажата
function endButtonPressed(mouseX, mouseY, button, N, M: integer): boolean;
  begin
    if (mouseX in 39 * (M + 3)..39 * (M + 3) + 39 * 2) and (mouseY in 39 * N..39 * (N+1)) and (button = 1) then endButtonPressed := true;
  end;

// кнопка переиграть нажата
function againButtonPressed(mouseX, mouseY, button, M: integer): boolean;
  begin
    if (mouseX in (39 * (M + 3))..(39 * (M + 3) + 39 * 2)) and (mouseY in 39 * 1..39 * 1 + 39) and (button = 1) then
      againButtonPressed := true;
  end;

// кнопка ДА в подтверждении действия нажата
function yesButtonPressed(mouseX, mouseY, button: integer): boolean;
  begin
    if (mouseX in (GraphBoxWidth div 2 + 100)..(GraphBoxWidth div 2 + 200)) and (mouseY in (GraphBoxHeight div 2)..(GraphBoxHeight div 2 + 40)) and (button = 1) then
      yesButtonPressed := true;
  end;

// кнопка НЕТ в подтверждении действия нажата
function noButtonPressed(mouseX, mouseY, button: integer): boolean;
  begin
    if (mouseX in (GraphBoxWidth div 2 - 200)..(GraphBoxWidth div 2 - 100)) and (mouseY in (GraphBoxHeight div 2)..(GraphBoxHeight div 2 + 40)) and (button = 1) then
      noButtonPressed := true;
  end;

begin 
end.
 