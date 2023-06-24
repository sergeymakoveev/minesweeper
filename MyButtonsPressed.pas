unit MyButtonsPressed;

Interface
  uses graphABC;
  function yesButtonPressed(mouseX, mouseY, button: integer): boolean;
  function noButtonPressed(mouseX, mouseY, button: integer): boolean;
  
Implementation


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
 