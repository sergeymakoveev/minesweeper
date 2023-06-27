﻿unit GameLevelForm;

Interface

  uses GraphABC;
  uses GlobalConstants, GlobalVariables, CommonFunctions;

  procedure inputInteger(ch: char);
  procedure displayGameLevelForm(var GAME_LEVEL: byte; var FIELD_WIDTH,FIELD_HEIGHT: integer; var FIELD_MINES_COUNT: integer; var PROGRAM_STEP: string);
  
Implementation
 
var 
  // координаты отображения поля для ввода
  outX,outY: integer;

// отображения поля для ввода
procedure diaplayInputField(const title: string; var fieldParam: integer; const fieldRange: IntRange);
  var
    userInput: string;
    err: integer;

  const
    // сообщение об ошибке ввода
    errorText = 'Недопустимое значение. Повторите ввод.';

  begin
    SetBrushColor(ARGB(255,255,255,255));
    FillRect(0, outY - 20, 350 - 20, outY + 20 + 20);
    // вывод заголовка поля ввода
    TextOut(TEXT_PADDING, outY, title);
    // задаем обработчик событий нажатия клавиатуры
    onKeyPress:=inputInteger;
    // сохраняем пользовательский ввод во временную переменную
    repeat userInput:=USER_INPUT until IS_USER_INPUT_DONE;
    IS_USER_INPUT_DONE:=False;
    val(userInput, fieldParam, err);
    while fieldParam not in fieldRange do
      begin
        SetFontSize(9);
        // вывод сообщения об ошибке
        textout(TEXT_PADDING, outY+23, errorText);
        sleep(1500);
        // закрасить место, где было выведено сообщение об ошибке
        FillRect(0, outY + 20, 350 - 20, outY + 20 + 20);
        SetFontSize(15);
        onKeyPress:=inputInteger;
        repeat userInput:=USER_INPUT until IS_USER_INPUT_DONE;
        IS_USER_INPUT_DONE:=False;
        val(userInput, fieldParam, err);
      end;
  end;

// Процедура пользовательского ввода целого числа
procedure inputInteger(ch: char);
  begin
    lockdrawing();
    SetBrushColor(RGB(255,255,255));
    fillrect(outX, outY, outX+30, outY+20);
    // нажата клавиша 0...9 и введено менее 2х символов
    if (ch in ('0'..'9')) and (length(USER_INPUT)<2)
      // накапливаем пользовательский ввод
      then USER_INPUT+=ch;
    // нажата клавиша Delete
    if ord(ch) = VK_Back then
      begin
        // удаляем из пользовательского ввода последний символ
        delete(USER_INPUT,length(USER_INPUT),1);
        fillrect(outX, outY, outX+30, outY+20);
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
    GAME_LEVEL := 3;

    clearwindow();
    Window.load('./GameBackground.png');

    drawTitle(0, 20, 270, 60, 'Настройки уровня:');

    SetBrushColor(ARGB(230,255,255,255));
    FillRect(0, 80, 350, 340);
    SetBrushColor(ARGB(0,255,255,255));
    SetFontSize(15);

    outX:=260;
    outY:=120;
    diaplayInputField('Ширина поля (max 34):', FIELD_WIDTH, 1..maxFieldWidth);
    outY:=200;
    diaplayInputField('Высота поля (5...19):', FIELD_HEIGHT, 5..maxFieldHeight);
    outY:=280;
    diaplayInputField('Количество мин:', FIELD_MINES_COUNT, 1..(FIELD_WIDTH * FIELD_HEIGHT - 1));

    // обратный отсчёт на 3 секунды
    setFontSize(30);
    for i: byte := 3 downto 1 do
      begin
        DrawTextCentered(0, 0, 600, 400, i);
        sleep(1000);
        SetFontColor(RGB(255,255,255));
        DrawTextCentered(0, 0, 600, 400, i);
        SetFontColor(RGB(0,0,0));
      end;
    
    SetWindowSize((FIELD_WIDTH + 6) * WIDTH_CELL, (FIELD_HEIGHT + 2) * WIDTH_CELL);
    CenterWindow;
    
    PROGRAM_STEP := 'GameStep';
  end;

begin 
end.
 