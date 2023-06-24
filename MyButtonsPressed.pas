unit MyButtonsPressed;

Interface
  uses graphABC;
  function againButtonPressed(mouseX, mouseY, button, M: integer): boolean;
  function unpauseButtonPressed(mouseX, mouseY, button, M: integer): boolean;
  function yesButtonPressed(mouseX, mouseY, button: integer): boolean;
  function noButtonPressed(mouseX, mouseY, button: integer): boolean;
  
Implementation
// кнопка снять с паузы нажата
function unpauseButtonPressed(mouseX, mouseY, button, M: integer): boolean;
  begin
    if (mouseX in GraphBoxWidth div 2 - 100..GraphBoxWidth div 2 + 100) and (mouseY in GraphBoxHeight div 2 - 50..GraphBoxHeight div 2 + 40) and (button = 1) then unpauseButtonPressed := true;
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
 