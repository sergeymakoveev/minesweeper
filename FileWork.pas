unit FileWork;

Interface

uses graphABC;
uses GameConstants, GameVariables, CommonFunctions;
uses MyButtonsPressed, MyInput;

procedure KeyPressName(ch: char);
procedure displayRulesStep(var programStep: string);
procedure records(var programStep: string);
  
  
Implementation
 
var 
  // отвечает за конец события OnKeyPress (True когда закончилось)
  InputDone: boolean;
  // отвечают за то, в из какой точки выводить введённые пользователем параметры поля
  outX,outY: integer;
  
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


// рекорды
procedure records(var programStep: string);
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
      until backButtonPressed(mouseX, mouseY, button);
      
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
    until backButtonPressed(mouseX, mouseY, button);
    
    programStep := 'MenuMainStep';
  end;

begin 
end.
 