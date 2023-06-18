unit FileWork;

Interface

uses graphABC;
uses GameConstants, GameVariables;
uses MyButtonsPressed, MyInput;

procedure KeyPressName(ch: char);
procedure viewRules(var ProgramStep: string);
procedure records(var programStep: string);
procedure isBest(time: integer; level: byte);
  
  
Implementation
 
var 
  // временная переменная для ввода данных
  ss: string;
  // отвечает за конец события OnKeyPress (True когда закончилось)
  InputDone: boolean;
  // отвечают за то, в из какой точки выводить введённые пользователем параметры поля
  outX,outY: integer;
  
// мышь (нажатие)
procedure MouseDown(x, y, mb: integer);
  begin
    isMouseDown := true;
    mouseX := x;
    mouseY := y;
    button := mb;
  end;

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

// проверка на лучшее время и изменение рекорда
procedure isBest(time: integer; level: byte);
  type 
    highScore = record
      name: string;
      score: integer;
    end;
  begin
    var players: array [0..2] of highscore;
    var i: byte;
    var f,f2: text;
    var s: string;
    
    i:=0;
    InputDone:=False;

    // открытие файла рекордов
    assign(f,'records.txt');
    reset(f);
    
    // запись содержимого в переменные
    while (not eof(f)) do
    begin
      readln(f,players[i].name);
      readln(f,players[i].score);
      i+=1;
    end;
    
    reset(f);
    
    i:=0;
    
    // если побил рекорд или поставил новый, то ввод имени
    if (players[level].score=0) or (time < players[level].score)  then
    begin
      textout(38,20,'Новый рекорд! Введите ваше имя (затем Enter):');
      assign(f2,'temprecords.txt');
      rewrite(f2);
      while not eof(f) do
      begin
        i+=1;
        readln(f,s);
        if (i<>(2*level+2)) and (i<>(2*level+1)) then writeln(f2,s)
        else if i=(2*level+2) then writeln(f2,time)
        else
          begin
            ss:='';
            onKeyPress:=KeyPressName;
            repeat i:=i+0 until InputDone;
            writeln(f2,ss);
          end;
      end;
      close(f);
      close(f2);
      erase(f);
      rename(f2,'records.txt');
    end
    // иначе закрываем файл рекордов
    else close(f);
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
      
      ProgramStep:='MenuMain';
    
  end;

// вывод правил игры
procedure viewRules(var ProgramStep: string);
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
    
    ProgramStep := 'MenuMain';
  end;

begin 
end.
 