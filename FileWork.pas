unit FileWork;

Interface

uses graphABC;
uses GameConstants, GameVariables, CommonFunctions;
uses MyButtonsPressed;

procedure KeyPressName(ch: char);
  
Implementation

// нажатие на клавиатуру (имя рекордсмена)
procedure KeyPressName(ch: char);
  begin
    InputDone := false;
    lockdrawing;
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
    unlockdrawing;
    redraw;
    // если нажали на Enter(конец проверки на событие)
    if ord(ch) = VK_Enter then
      begin
          onKeyPress:=Nil;
          InputDone:=True;
      end;
  end;

begin 
end.
 