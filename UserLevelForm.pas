unit UserLevelForm;

Interface

  uses graphABC;
  uses GlobalConstants, GlobalVariables;

  procedure inputInteger(ch: char);
  procedure displayUserLevelForm(var GAME_LEVEL: byte; var M,N: integer; var Nmines: integer; var programStep: string);
  
Implementation
 
var 
  // отвечают за то, в из какой точки выводить введённые пользователем параметры поля
  outX,outY: integer;

// Процедура пользовательского ввода целого числа
procedure inputInteger(ch: char);
  begin
    lockdrawing;
    fillrect(outX,outY,2000,outY+20);
    if (ch in ('0'..'9')) and (length(ss)<3) then ss+=ch;
    textout(outX,outY,ss);
    // если нажал на Delete
    if ord(ch) = 8 then
      begin
        delete(ss,length(ss),1);
        fillrect(outX,outY,600,outY+20);
        textout(outX,outY,ss);
      end;
    unlockdrawing;
    redraw;
    if ord(ch) = VK_Enter then
      begin 
        onKeyPress:=Nil;
        isInputDone:=True;
        delete(ss,1,length(ss));
      end;
  end;

// играть на пользовательской сложности
procedure displayUserLevelForm(var GAME_LEVEL: byte; var M,N: integer; var Nmines: integer; var programStep: string);

  const
    // максимальная ширина минного поля
    maxFieldWidth = 34;
    // максимальная высота минного поля
    maxFieldHeight = 19;

  begin
    ClearWindow;
    SetFontSize(15);
    var s: string;
    var err: integer;
    
    GAME_LEVEL := 3;
    
    textout(10,10,'Введите ширину поля (поддерживается не более 34):');
    outX:=520;
    outY:=10;
    onKeyPress:=inputInteger;
    repeat s:=ss until isInputDone;
    isInputDone:=False;
    val(s,M,err);
    while M not in 1..maxFieldWidth do
      begin
        SetFontSize(9);
        textout(50,35,'Недопустимое значение. Повторите ввод');
        SetFontSize(15);
        sleep(1500);
        textout(50,35,' '*100);// закрасить место, где было выведено предыдущее сообщение
        onKeyPress:=inputInteger;
        repeat s:=ss until isInputDone;
        isInputDone:=False;
        val(s,M,err);
      end;
    outX:=500;
    outY:=50;
    textout(10,50,'Введите высоту поля (поддерживается от 5 до 19):');
    onKeyPress:=inputInteger;
    repeat s:=ss until isInputDone;
    isInputDone:=False;
    val(s,N,err);
    while N not in 5..maxFieldHeight do
      begin
        SetFontSize(9);
        textout(50,75,'Недопустимое значение. Повторите ввод');
        SetFontSize(15);
        sleep(1500);
        textout(50,75,' '*100);
        onKeyPress:=inputInteger;
        repeat s:=ss until isInputDone;
        isInputDone:=False;
        SetFontSize(15);
        val(s,N,err);
      end;
    outX:=510;
    outY:=90;
    textout(10,90,'Введите количество мин (зависит от размера поля):');
    onKeyPress:=inputInteger;
    repeat s:=ss until isInputDone;
    isInputDone:=False;
    val(s,Nmines,err);
    while Nmines not in 1..(M * N - 1) do
      begin
        SetFontSize(9);
        textout(50,115,'Недопустимое значение. Повторите ввод');
        SetFontSize(15);
        sleep(1500);
        textout(50,115,' '*100);
        onKeyPress:=inputInteger;
        repeat s:=ss until isInputDone;
        isInputDone:=False;
        SetFontSize(15);
        val(s,Nmines,err);
      end;

    // обратный отсчёт на 3 секунды
    setFontSize(30);
    for i: byte := 3 downto 1 do
      begin
        textout(300,150,i);
        sleep(1000);
      end;
    
    SetWindowSize((M + 6) * WIDTH_CELL, (N + 2) * WIDTH_CELL);
    CenterWindow;
    
    programStep := 'GameStep';
  end;

begin 
end.
 