Program P;
Uses CRT,Graph,F_Mouse;
Const
     KStars = 200;
     RStar  = 5;

     ScreenY = 350;
     ScreenX = 640;

     StageSize   = ScreenY*10;
     SpeedScreen = 4;
     ScreenFast  = 40;

     KStarsWay      = 70;
     HeightStarsWay = 50;
     WidthStarsWay  = 20;
     KoefSW         = 10;

     KMeteors          = 70;
     RadiusDeathMeteor = 5;

     MaxMouseX = 15;
     MaxMouseY = 10;

     StartFireRadius = 10;
     MaxFireRadius   = 50;
     KFirePoints     = 500;
     KoefFP          = 0.3;
     MaxFireTime     = 10;

     MaxXDeathSam     = 20;
     MaxYDeathSam     = 40;
     SamXR            = 10;
     MaxPointsSamFire = ScreenY;
     MaxTimeSamFire   = 7;
     HeightFireWay    = 40;
     WidthFireWay     = 80;
     KPointsFireWay   = 50;
Type
    TStar=record
                 X:integer;
                 Y:real;
                 Z:real;
                 C:byte;
    end;

    TStarsWay=record
                    Y :real;
                    XR:real;
                    R :real;
                    C :byte;
    end;

    TMeteor=record
                  X    :integer;
                  Y    :integer;
                  Death:Boolean;
    end;

    TFirePoints=record
                      Angle :real;
                      Radius:real;
    end;

    TFireSamPoints=record
                         X:integer;
                         Y:integer;
    end;
Var
   Star          :array [1..KStars]           of TStar;
   StarsWay      :array [1..KStarsWay]        of TStarsWay;
   Meteor        :array [1..KMeteors]         of TMeteor;
   FirePoint     :array [1..KFirePoints]      of TFirePoints;
   FireSamPoint  :array [1..MaxPointsSamFire] of TFireSamPoints;

   EndProgram     :Boolean;
   PB             :Boolean;
   IsGameOver     :Boolean;
   IsFire         :Boolean;
   IsSamFire      :Boolean;
   ScreenPos      :integer;
   SamX           :integer;
   FireX          :integer;
   FireY          :integer;
   FireTime       :integer;
   TimeSamFire    :integer;
   KPointsSamFire :integer;
   SamY           :integer;

procedure Init;
var
   GD,GM:integer;
begin
     GD:=3;
     GM:=1;
     initgraph(GD,GM,'');
     if GraphResult<>0 then begin
        write('Can''t load BGI-driver');
        readln;
        Halt;
     end;
end;

procedure Pages;
begin
     SetActivePage(ord(PB));
     SetVisualPage(ord(not(PB)));
     ClearViewPort;
     PB:=not(PB);
end;

procedure CloseProgram;
begin
     CloseGraph;
     Halt;
end;

procedure SetDataStars;
var
   N:integer;
begin
     Randomize;
     for N:=1 to KStars do begin
         Star[N].X:=random(ScreenX);
         Star[N].Y:=random(ScreenY);
         Star[N].Z:=random;
         Star[N].C:=random(16);
     end;
end;

procedure SetDataGame;
begin
     ScreenPos:=StageSize;
     InitMouse;
     {ShowMouse;}
     MouseWindow(320-MaxMouseX,175-MaxMouseY,320+MaxMouseX,175+MaxMouseY);
     MouseGotoXY(320,175);
     SamX:=trunc(ScreenX/2);
     IsGameOver:=False;
     SamY:=ScreenY-40;
end;

procedure SetDataStarsWay;
var
   N:integer;
begin
     Randomize;
     for N:=1 to KStarsWay do begin
         StarsWay[N].Y :=random(HeightStarsWay);
         StarsWay[N].XR:=(random(100)*0.01)-0.5;
         StarsWay[N].R :=random;
         StarsWay[N].C :=random(8);
     end;
end;

procedure SetDataMeteors;
var
   N:integer;
begin
     Randomize;
     for N:=1 to KMeteors do begin
         Meteor[N].X:=Random(ScreenX);
         Meteor[N].Y:=Random(StageSize);
         Meteor[N].Death:=False;
     end;
end;

procedure DrawPixel(X,Y,Color,Value,MaxValue:integer);
begin
     PutPixel(X,Y,Color+8);
     if (Value<MaxValue*0.25) then begin
        PutPixel(X+1,Y  ,Color);
        PutPixel(X  ,Y+1,Color);
        PutPixel(X-1,Y  ,Color);
        PutPixel(X  ,Y-1,Color);
     end;

     if (Value>=MaxValue*0.25)
     and (Value<MaxValue*0.50) then begin
         PutPixel(X  ,Y+1,Color);
         PutPixel(X-1,Y  ,Color);
         PutPixel(X  ,Y-1,Color);
     end;

     if (Value>=MaxValue*0.50)
     and (Value<MaxValue*0.75) then begin
         PutPixel(X,Y+1,Color);
         PutPixel(X,Y-1,Color);
     end;

     if (Value>=MaxValue*0.75)
     and (Value<MaxValue*0.90) then
         PutPixel(X,Y-1,Color);
     (**)
end;

procedure StartFire(XF,YF:integer);
var
   N:integer;
begin
     FireX   :=XF;
     FireY   :=YF;
     IsFire  :=True;
     FireTime:=0;
     Randomize;
     for N:=1 to KFirePoints do begin
         FirePoint[N].Angle :=random(360)*(pi/180);
         FirePoint[N].Radius:=random*StartFireRadius;
     end;
end;

procedure Fire;
var
   N,XX,YY:integer;
begin
     for N:=1 to KFirePoints do begin
         FirePoint[N].Radius:=FirePoint[N].Radius+FirePoint[N].Radius*KoefFP;
         XX:=trunc(FirePoint[N].Radius*cos(FirePoint[N].Angle));
         YY:=trunc(FirePoint[N].Radius*sin(FirePoint[N].Angle));

         DrawPixel((XX+FireX),YY+FireY,Red,trunc(FirePoint[N].Radius),MaxFireRadius);

     end;
     FireTime:=FireTime+1;
     if FireTime>MaxFireTime then IsFire:=False;
end;

procedure StartSamFire(X,Y:integer);
var
   N:integer;
begin
     IsSamFire:=True;
     TimeSamFire:=0;
     if (Y+1)>MaxPointsSamFire then KPointsSamFire:=MaxPointsSamFire
     else KPointsSamFire:=Y+1;
     for N:=KPointsSamFire downto 0 do begin
         FireSamPoint[N+1].X:=X;
         FireSamPoint[N+1].Y:=N;
     end;
end;

procedure SamFire;
var
   N:integer;
begin
     if TimeSamFire>MaxTimeSamFire then IsSamFire:=False
     else begin
          Randomize;
          for N:=1 to KPointsSamFire do begin
              with FireSamPoint[N] do begin
                   X:=X+random(3)-1;
                   Y:=Y+random(3)-1;

                   DrawPixel(X,Y,Blue,TimeSamFire,MaxTimeSamFire);
              end;
          end;
          TimeSamFire:=TimeSamFire+1;
     end;
end;

procedure Keys;
var
   Ch :Char;
   X,Y,MKey:integer;
begin
     if Keypressed then begin
        Ch:=(UpCase(ReadKey));
        Case Ch of
             'Q' :  CloseProgram;
             'W' :  ScreenPos:=ScreenPos+40;
             'F' :  StartFire(320,175);
             'A' :  SamX:=SamX-SamXR;
             'D' :  SamX:=SamX+SamXR;
             ' ' :  StartSamFire(SamX,SamY);
        End;
        while KeyPressed do ReadKey;
     end;

     GetMouseState(MKey,X,Y);

     X:=X-320;
     Y:=Y-175;
     SamX:=SamX+X;
     SamY:=SamY+Y;
     MouseGotoXY(320,175);
     if (MKey=1) and not(IsSamFire) or (MKey=3) then StartSamFire(SamX,SamY);
     if (MKey=2)                    or (MKey=3) then ScreenPos:=ScreenPos+ScreenFast;

     if SamX>ScreenX                then SamX:=ScreenX;
     if SamY>(ScreenY-MaxYDeathSam) then SamY:=(ScreenY-MaxYDeathSam);
     if SamX<0                      then SamX:=0;
     if SamY<0                      then SamY:=0;
end;

procedure DrawMeteor(var XM,YM:integer);
var
   N,XX,YY:integer;
begin
     for N:=1 to KStarsWay do
         with StarsWay[N] do begin
              Y:=Y+Y/KoefSW;
              if Y>HeightStarsWay then Y:=Y-HeightStarsWay;
              YY:=-trunc(Y);
              XX:=trunc(sqrt(Y*WidthStarsWay)*XR);
              PutPixel(XX+XM,YY+YM,StarsWay[N].C+8);
              DrawPixel(XX+XM,YY+YM,StarsWay[N].C,trunc(Y),HeightStarsWay);
         end;
     (**)
end;

procedure Samolet(X,Y:integer);
var
   YY,XX,N:integer;
begin
     SetColor(Green);
     {Rectangle(X-MaxXDeathSam,SamY,X+MaxXDeathSam,SamY-MaxYDeathSam);}
     MoveTo(X,Y);
     LineRel(-25,0);
     LineRel(20,-30);
     LineRel(0,-5);
     LineRel(5,-7);
     LineRel(5,7);
     LineRel(0,5);
     LineRel(20,30);
     LineRel(-25,0);
     SetFillStyle(1,8);
     FloodFill(X,Y-10,Green);
     Line(X-5,Y-30,X,Y-27);
     Line(X,Y-27,X+5,Y-30);
     SetFillStyle(1,Blue+8);
     FloodFill(X,Y-35,Green);
     Line(X,Y-5,X,Y-27);
     Line(X-25,Y,X,Y-5);
     Line(X+25,Y,X,Y-5);

     Randomize;
     for N:=1 to KPointsFireWay do begin
         YY:=random(HeightFireWay);
         XX:=trunc(sqrt(YY*WidthFireWay)*(Random-0.5));
         DrawPixel(XX+X,YY+Y,Red,YY,HeightFireWay);
     end;
end;

procedure NextFrame;
var
   N,YY:integer;
begin
                {Stars}
     for N:=1 to KStars do begin
         PutPixel(Star[N].X,trunc(Star[N].Y),Star[N].C);
         Star[N].Y:=Star[N].Y+RStar*Star[N].Z;
         if Star[N].Y>ScreenY then Star[N].Y:=0;
     end;

     if not(IsGameOver) then Samolet(SamX,SamY);

                {Meteors}
     for N:=1 to KMeteors do begin
         YY:=ScreenPos-Meteor[N].Y;
         if not(Meteor[N].Death) and (YY>=-HeightStarsWay) and (YY<ScreenY+HeightStarsWay) then begin
            DrawMeteor(Meteor[N].X,YY);

            if  (Meteor[N].X>(SamX-MaxXDeathSam)) and (Meteor[N].X<(SamX+MaxXDeathSam))
            and (YY>(SamY-MaxYDeathSam)) and (YY<SamY) and not(IsGameOver) then begin
                IsGameOver:=true;
                StartFire(SamX,trunc(SamY-MaxYDeathSam/2));
            end;

            if (IsSamFire) and (abs(SamX-Meteor[N].X)<=RadiusDeathMeteor) and (TimeSamFire<=1) then begin
               StartFire(Meteor[N].X,YY);
               Meteor[N].Death:=True;
            end;;
         end;
     end;

     if IsFire    then Fire;
     if IsSamFire then SamFire;
end;

procedure Process;
begin
     Repeat
           if not(IsGameOver) then Keys;
           Pages;
           NextFrame;
           ScreenPos:=ScreenPos+SpeedScreen;
           if ScreenPos>StageSize then ScreenPos:=0;
           if IsGameOver and not(IsFire) then EndProgram:=true;
     Until EndProgram;
     CloseProgram;
end;

Begin
     Init;
     Pages;
     SetDataStars;
     SetDataStarsWay;
     SetDataMeteors;
     SetDataGame;
     EndProgram:=False;
     Process;
End.