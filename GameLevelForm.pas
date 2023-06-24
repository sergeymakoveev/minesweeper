unit GameLevelForm;

Interface

  uses graphABC;
  uses GlobalConstants, GlobalVariables;

  procedure inputInteger(ch: char);
  procedure displayGameLevelForm(var GAME_LEVEL: byte; var FIELD_WIDTH,FIELD_HEIGHT: integer; var FIELD_MINES_COUNT: integer; var PROGRAM_STEP: string);
  
Implementation
 
var 
  // отвечают за то, в из какой точки выводить введённые пользователем параметры поля
  outX,outY: integer;

// Процедура пользовательского ввода целого числа
procedure inputInteger(ch: char);
  begin
    lockdrawing();
    fillrect(outX,outY,2000,outY+20);
    // нажата клавиша 0...9 и введено менее 2х символов
    if (ch in ('0'..'9')) and (length(USER_INPUT)<2)
      // накапливаем пользовательский ввод
      then USER_INPUT+=ch;
    // нажата клавиша Delete
    if ord(ch) = VK_Back then
      begin
        // удаляем из пользовательского ввода последний символ
        delete(USER_INPUT,length(USER_INPUT),1);
        fillrect(outX,outY,600,outY+20);
      end;
    textout(outX,outY,USER_INPUT);
    unlockdrawing();
    redraw();
    // нажата клавиша Enter
    if ord(ch) = VK_Enter then
      begin 
        onKeyPress:=Nil;
        IS_USER_INPUT_DONE:=True;
        // очищаем пользовательский ввод
        delete(USER_INPUT,1,length(USER_INPUT));
      end;
  end;

// форма настройки уровня игры
procedure displayGameLevelForm(var GAME_LEVEL: byte; var FIELD_WIDTH,FIELD_HEIGHT: integer; var FIELD_MINES_COUNT: integer; var PROGRAM_STEP: string);

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
    repeat s:=USER_INPUT until IS_USER_INPUT_DONE;
    IS_USER_INPUT_DONE:=False;
    val(s,FIELD_WIDTH,err);
    while FIELD_WIDTH not in 1..maxFieldWidth do
      begin
        SetFontSize(9);
        textout(50,35,'Недопустимое значение. Повторите ввод');
        SetFontSize(15);
        sleep(1500);
        // закрасить место, где было выведено предыдущее сообщение
        textout(50,35,' '*100);
        onKeyPress:=inputInteger;
        repeat s:=USER_INPUT until IS_USER_INPUT_DONE;
        IS_USER_INPUT_DONE:=False;
        val(s,FIELD_WIDTH,err);
      end;
    outX:=500;
    outY:=50;
    textout(10,50,'Введите высоту поля (поддерживается от 5 до 19):');
    onKeyPress:=inputInteger;
    repeat s:=USER_INPUT until IS_USER_INPUT_DONE;
    IS_USER_INPUT_DONE:=False;
    val(s,FIELD_HEIGHT,err);
    while FIELD_HEIGHT not in 5..maxFieldHeight do
      begin
        SetFontSize(9);
        textout(50,75,'Недопустимое значение. Повторите ввод');
        SetFontSize(15);
        sleep(1500);
        textout(50,75,' '*100);
        onKeyPress:=inputInteger;
        repeat s:=USER_INPUT until IS_USER_INPUT_DONE;
        IS_USER_INPUT_DONE:=False;
        SetFontSize(15);
        val(s,FIELD_HEIGHT,err);
      end;
    outX:=510;
    outY:=90;
    textout(10,90,'Введите количество мин (зависит от размера поля):');
    onKeyPress:=inputInteger;
    repeat s:=USER_INPUT until IS_USER_INPUT_DONE;
    IS_USER_INPUT_DONE:=False;
    val(s,FIELD_MINES_COUNT,err);
    while FIELD_MINES_COUNT not in 1..(FIELD_WIDTH * FIELD_HEIGHT - 1) do
      begin
        SetFontSize(9);
        textout(50,115,'Недопустимое значение. Повторите ввод');
        SetFontSize(15);
        sleep(1500);
        textout(50,115,' '*100);
        onKeyPress:=inputInteger;
        repeat s:=USER_INPUT until IS_USER_INPUT_DONE;
        IS_USER_INPUT_DONE:=False;
        SetFontSize(15);
        val(s,FIELD_MINES_COUNT,err);
      end;

    // обратный отсчёт на 3 секунды
    setFontSize(30);
    for i: byte := 3 downto 1 do
      begin
        textout(300,150,i);
        sleep(1000);
      end;
    
    SetWindowSize((FIELD_WIDTH + 6) * WIDTH_CELL, (FIELD_HEIGHT + 2) * WIDTH_CELL);
    CenterWindow;
    
    PROGRAM_STEP := 'GameStep';
  end;

begin 
end.
 