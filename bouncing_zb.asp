<%
  response.write "Hello"
%>
<!doctype html>
<html>
<!--
- bounding ball의 크기를 짝수로만 설정하도록 함. (찌그러진 공 방지)
- time stamp 기능 추가
- start button 추가 
- 게임 계속 가능 
- copyright 정보 추가 및 resize 대응.
- balls resize 대응
- Ball methods are moved to prototype
- 차례대로 지정되는 볼을 하나씩 없애야 한다.
- 선택 볼이 잘 보일 수 있도록 볼의 칼라 범위를 조절함. (선택 테두리가 잘 보이도록 함.)
- 1.5초 내에 없애지 못하면 선택할 볼이 변경됨.
- 없애는 볼의 배경색이 화면의 배경색으로 설정됨. (볼의 제거도 확인하면서 게임의 흥미를 높임 ) 
- 볼 제거 과정(볼 제거 간의 시간, 놓친 볼의 횟수 등)을 기록 
- 볼 개수를 최대~최소 범위에서 입력할 수 있게 함. (범위를 넘어서면 강제로 조정하는 기능 )
- 볼 제거 시, fadeOut 효과 적용 (ballsKilled 배열 활용)
- pause, resume easter egg 추가.
- 1/1000 -> 1/100 
- 놓친 볼들의 순서가 다시 재생되지 않도록 함.
- 윈도우 경계에서의 반사 정밀도 개선. (Ball.checkBoundary() 를 삭제하고 Balls.move()로 통합.)
- ballCount 역진 방지 기능. (최근에 한 개수보다 같거나 많게만 설정가능.)
- 게임 중 ball 추가 easter egg 추가. (역진 방지 유지)
- 게임 종료 후, game report 표시.
- 게임 시작~종료 기간 배경음악 추가 . (Sound library  Howler.min.js   음악: Lake Louise, 유키쿠라모토)
- 볼 제거 효과음 추가(spcvactub), 게임종료 시 효과음(gong) 배경음악 변경 (배경음악: PurpleRain)
- BGM 동작 개념 정리 완료.
- BGM, Penalty 스위치 동작 완료
- 모니터 해상도에 따라 볼의 시각적 크기가 달라지는 문제 해결. 
- Tool tip (ditip 속성) 기능 라이브러리 개발, 적용함.
- 게임 시작과 음악 맞추기 (바비킴 최면에 맞춘 버전 )
- 배경음악이 off인경우 게임이 사작되지 않는 오류 해결
- 버튼 동작, 볼 제거, 볼 생성, 게임 리포트 동작 효과음 제어용 버튼 추가 
- 배경음악(바비킴 최면)과 게임시작 후 준비과정 싱크 방식 변경.
- 윈도우 크기 변경에 따른 볼의 크기도 연동하여 변경하는 기능 추가. 
-->
  <head>
  <meta charset="UTF-8">
      <!-- ============================= --> 
    <style>
      div.bouncingball {
        border: 1px solid black;
        position: absolute;
        text-align: center;
        box-shadow: 3px 3px 2px #888888;
        z-index: 1;
      }
      div.button {
        width: 150px;
        height: 40px;
        border: 2px solid gray;
        position: center;
        background-color: yellow;
      }
      button {
        box-shadow: 2px 2px 2px grey;
      }
      button.control {
        width: 120px;
        font-family: Arial, Helvetica, sans-serif;
        font-size: 12pt;
      }
      div.copyright {
        position: absolute;
        text-align: right;
        font-size: 9pt;
        color: #999999;
        height: 16px;
        z-index: 2;
      }
      div.gameresult {
        position: absolute;
        left: 100px;
        top: 100px;
        width: 500px;
        border: 1px solid gray;
        box-shadow: 3px 3px 3px #555555;
        border-radius: 10px;
        font-size: 12pt;
      }
      .coltitle {
        text-align: right;
        width: 170px;
        font-size: 15pt;
      }
      .colvalue {
        text-align: left;
        padding-left: 5px;
        font-size: 15pt;
      }
    </style>
    <!-- ============================= --> 

    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
    <script src="dittooltip_1.2.js"></script>
    <!-- ============================= --> 
    <!-- ======[ audio library ]====== --> 
    <script src="howler.min.js"></script>
    <script>
        var soundBGM = new Howl({
          src: ['choimyun_bobbykim.mp3'],
          loop: true,
          volume: 0
        });
        var soundBallRemove = new Howl({
          src: ['spcvactub.mp3'],
          volume: 0.5
        });
        var soundGameOver = new Howl({
          src: ['notification.mp3'],
          volume: 0.5
        });
        var soundNewBall = new Howl({
          src: ['soundNewBall.wav']
        });
        var soundControlButton = new Howl({
          src: ['controlbtn.wav']
        });
    </script>
    <!-- ============================= --> 
    <script>
      var ballsMin = 10;
      var ballsMax = 50;
      var ballCount = 10;
      var ballSizeMax = 75;
      var ballSizeMin =10;   // 스크린 해상도 고려
      var balls = [];
      var ballsKilled = []; // 제거된 볼 저장
      var intervals = [];  // 볼 삭제 간격 기록 
      var missed = [];  // 볼 제거 전 놓친 횟수 
      var missedBalls = 0;
      var timeStarted, timeFinished, timeInterval, timeChecked;
      var timer;  // for timeInterval() handler
      var windows = []; // window size
      var soundIdBGM = null;
      var ballSpeed = 30;
      var timeToNext = 1500;  //
      var colorBallBorder = 'red';
      var addBallOnMissed = false;
      var soundEffect = true;
      var pWindowWidth, pWindowHeight;
      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // For color conversion:  colorname -> Hex
      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      var colorNameHex = [['aliceblue','antiquewhite','aqua','aquamarine','azure','beige','bisque','black','blanchedalmond','blue','blueviolet','brown','burlywood','cadetblue','chartreuse','chocolate','coral','cornflowerblue','cornsilk','crimson','cyan','darkblue','darkcyan','darkgoldenrod','darkgray','darkgrey','darkgreen','darkkhaki','darkmagenta','darkolivegreen','darkorange','darkorchid','darkred','darksalmon','darkseagreen','darkslateblue','darkslategray','darkslategrey','darkturquoise','darkviolet','deeppink','deepskyblue','dimgray','dimgrey','dodgerblue','firebrick','floralwhite','forestgreen','fuchsia','gainsboro','ghostwhite','gold','goldenrod','gray','grey','green','greenyellow','honeydew','hotpink','indianred ','indigo  ','ivory','khaki','lavender','lavenderblush','lawngreen','lemonchiffon','lightblue','lightcoral','lightcyan','lightgoldenrodyellow','lightgray','lightgrey','lightgreen','lightpink','lightsalmon','lightseagreen','lightskyblue','lightslategray','lightslategrey','lightsteelblue','lightyellow','lime','limegreen','linen','magenta','maroon','mediumaquamarine','mediumblue','mediumorchid','mediumpurple','mediumseagreen','mediumslateblue','mediumspringgreen','mediumturquoise','mediumvioletred','midnightblue','mintcream','mistyrose','moccasin','navajowhite','navy','oldlace','olive','olivedrab','orange','orangered','orchid','palegoldenrod','palegreen','paleturquoise','palevioletred','papayawhip','peachpuff','peru','pink','plum','powderblue','purple','rebeccapurple','red','rosybrown','royalblue','saddlebrown','salmon','sandybrown','seagreen','seashell','sienna','silver','skyblue','slateblue','slategray','slategrey','snow','springgreen','steelblue','tan','teal','thistle','tomato','turquoise','violet','wheat','white','whitesmoke','yellow','yellowgreen'],
   ['f0f8ff','faebd7','00ffff','7fffd4','f0ffff','f5f5dc','ffe4c4','000000','ffebcd','0000ff','8a2be2','a52a2a','deb887','5f9ea0','7fff00','d2691e','ff7f50','6495ed','fff8dc','dc143c','00ffff','00008b','008b8b','b8860b','a9a9a9','a9a9a9','006400','bdb76b','8b008b','556b2f','ff8c00','9932cc','8b0000','e9967a','8fbc8f','483d8b','2f4f4f','2f4f4f','00ced1','9400d3','ff1493','00bfff','696969','696969','1e90ff','b22222','fffaf0','228b22','ff00ff','dcdcdc','f8f8ff','ffd700','daa520','808080','808080','008000','adff2f','f0fff0','ff69b4','cd5c5c','4b0082','fffff0','f0e68c','e6e6fa','fff0f5','7cfc00','fffacd','add8e6','f08080','e0ffff','fafad2','d3d3d3','d3d3d3','90ee90','ffb6c1','ffa07a','20b2aa','87cefa','778899','778899','b0c4de','ffffe0','00ff00','32cd32','faf0e6','ff00ff','800000','66cdaa','0000cd','ba55d3','9370db','3cb371','7b68ee','00fa9a','48d1cc','c71585','191970','f5fffa','ffe4e1','ffe4b5','ffdead','000080','fdf5e6','808000','6b8e23','ffa500','ff4500','da70d6','eee8aa','98fb98','afeeee','db7093','ffefd5','ffdab9','cd853f','ffc0cb','dda0dd','b0e0e6','800080','663399','ff0000','bc8f8f','4169e1','8b4513','fa8072','f4a460','2e8b57','fff5ee','a0522d','c0c0c0','87ceeb','6a5acd','708090','708090','fffafa','00ff7f','4682b4','d2b48c','008080','d8bfd8','ff6347','40e0d0','ee82ee','f5deb3','ffffff','f5f5f5','ffff00','9acd32']];

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      //------------------------------------------------------------------------------------
      function colorReverse(cname) {
        if(cname.indexOf(',') < 0 ) {
          var i = colorNameHex[0].indexOf(cname);
          var r = 255-(parseInt('0x'+colorNameHex[1][i].slice(0,2)));
          var g = 255-(parseInt('0x'+colorNameHex[1][i].slice(2,4)));
          var b = 255-(parseInt('0x'+colorNameHex[1][i].slice(4)));
          var c = 'rgb('+r+','+g+','+b+')';
          // console.log('[1]' + cname + '->' + c);
          return c;
        } else {
          cname = cname.replace('rgb(','');
          cname = cname.replace(')','');
          var rgb = cname.split(',');
          var c = 'rgb(' + (255-1*rgb[0]) + ',' + (255-1*rgb[1]) + ',' + (255-1*rgb[2]) + ')';
          // console.log('[2]' + cname + '->' + c);
          return c;
        }
      }
      //------------------------------------------------------------------------------------
      function Game() {
        this.timeStart = timeStarted;
        this.timeFinish = timeFinished;
        this.timeInverval = timeFinished - timeStarted;
        this.ballTotal = ballCount;
        this.windowSize = windows[windows.length-1];
      }
      //------------------------------------------------------------------------------------
      function windowStamp() {
        var xy = [];
        xy.push(window.innerWidth);
        xy.push(window.innerHeight);
        windows.push(xy);
      }
      //------------------------------------------------------------------------------------
      function showGameReport() {
          $('#gameresult').slideDown();
          if(soundEffect)
            soundGameOver.play();

      }
      //------------------------------------------------------------------------------------
      var divOnMouseOver = function (t) {
        var found = -1;
        var timeKilled;
        for(var j in balls)
          if(balls[j].ball === t) {
            found = j;
            break;
          }
        if(found >= 0 && balls[found].selected)  // <------ for find and kill game
        {
          timeKilled = new Date();
          intervals.push(timeKilled - timeChecked);
          document.body.style.backgroundColor = balls[found].ball.style.backgroundColor;
          var bk = balls.splice(found,1);
          ballsKilled.unshift(bk);
          timeChecked = new Date();
          timeKilled = new Date();
          missed.push(missedBalls);
          for(var i=1; i <= missedBalls; i++)
            rotateBalls(0);
          missedBalls = 0;
        }
        else
          return;  // <---- for find and kill game.

        // document.body.removeChild(t);
        $(t).fadeOut(400);
        if(soundEffect)
          soundBallRemove.play();
        t = null;
        document.getElementById('ballsleft').innerHTML = balls.length;
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Game Over
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        if(balls.length <= 0) {

          $('#timefinish').html(getTimeStamp(2));
          timeInterval = timeFinished - timeStarted;
          // document.getElementById('timeinterval').innerHTML = getTimeStamp(3);
          clearInterval(timer);
          document.body.style.backgroundColor = 'white';  // 배경색 초기화.
          document.getElementById('control').style.visibility = 'visible';
          document.getElementById('control2').style.visibility = 'visible';
          ballsMin = ballCount;
          // for Game Report --------------------------- Start//
          $('#numberofballs').text(ballCount);
          $('#timetotal').text(timeInterval/1000);
          $('#timeavr').text(avrOf(intervals)/1000);
          $('#timeinterval').text(avrOf(intervals)/1000);
          $('#timemax').text(maxOf(intervals)/1000);
          $('#timemin').text(minOf(intervals)/1000);
          $('#missedballs').text(sumOf(missed));
          $('#windowsize').html(reportWindowSize());
          $('#reportfinishtime').text(timeFinished.toLocaleDateString() + ' ' + timeFinished.toLocaleTimeString());
          document.getElementById('timestart').innerHTML = '';
          document.getElementById('timefinish').innerHTML = '';
          document.getElementById('timeinterval').innerHTML = '?';          

          if($('#toggleBGM').text() == 'BGM ON') {
              soundBGM.fade(1,0,1000,soundIdBGM);
            // $('#toggleBGM').text('BGM OFF');
          }
          setTimeout(showGameReport, 2000);
          timeStarted = null;
          // for Game Report --------------------------- End//

          // for(var i in intervals) {
          //   console.log('['+addZero(i)+']:'+intervals[i]+' (missed '+ missed[i] + ')');
          // }
        }
        else{
          balls[0].myTurn();
          Ball.currentTurn = 0;
        }
      }
      //------------------------------------------------------------------------------------
      function reportWindowSize() {
        var length = windows.length;
        if(length == 1)
          return '<b>'+windows[0][0]+' x '+windows[0][1]+'</b> (not resized)';
        return '<b>'+windows[length-1][0]+' x '+windows[length-1][1]+'</b> (final size)';
      }
      //------------------------------------------------------------------------------------
      function maxOf(ar) {
        switch(ar.length) {
          case 0:
            alert('Error of function [maxOf()]: Empty array!');
            return null;
          case 1:
            return ar[0];
          default:
            var max = ar[0];
            for(var i=1; i<ar.length; i++)
              if(ar[i] > max)
                max = ar[i];
            return max;
        }
      }
      //------------------------------------------------------------------------------------
      function minOf(ar) {
        switch(ar.length) {
          case 0:
            alert('Error of function [minOf()]: Empty array!');
            return null;
          case 1:
            return ar[0];
          default:
            var min = ar[0];
            for(var i=1; i<ar.length; i++)
              if(ar[i] < min)
                min = ar[i];
            return min;
        }
      }
      //------------------------------------------------------------------------------------
      function avrOf(ar) {
        switch(ar.length) {
          case 0:
            alert('Error of function [avrOf()]: Empty array!');
            return null;
          case 1:
            return ar[0];
          default:
            var sum = 0;
            for(var i=0; i<ar.length; i++)
                sum += ar[i];
            return Math.floor(sum/ar.length);
        }
      }
      //------------------------------------------------------------------------------------
      function sumOf(ar) {
        switch(ar.length) {
          case 0:
            alert('Error of function [sumOf()]: Empty array!');
            return null;
          case 1:
            return ar[0];
          default:
            var sum = 0;
            for(var i=0; i<ar.length; i++)
                sum += ar[i];
            return sum;
        }
      }

      //------------------------------------------------------------------------------------
      var divOnMouseOut = function (t) {
        //t.style.borderColor = t.style.backgroundColor;
      }
      //------------------------------------------------------------------------------------
      var colorLibrary = { 
          yellows: ['gold','yellow','lightyellow','lemonchiffon','lightgoldenrodyellow','papayawhip','moccasin','peachpuff','palegoldenrod','khaki','darkkhaki'],
          pinks: ['pink', 'lightpink','hotpink','deeppink','palevioletred','mediumvioletred'],
          purples: ['lavender','thistle','plum','orchid','violet','fuchsia','magenta','mediumorchid','darkorchid','darkviolet', 'blueviolet', 'darkmagenta','purple','mediumpurple','mediumslateblue','slateblue','darkslateblue','rebeccapurple','indigo']
        };
      function randomColor() {
        var i;
        if(arguments.length == 0) {
                  var r = Math.floor(Math.random()*76)+175;
                  var g = Math.floor(Math.random()*76)+175;
                  var b = Math.floor(Math.random()*76)+175;
                  return 'rgb('+r+','+g+','+b+')';
        } else {
          switch(arguments[0].toLowerCase()) {
            case 'yellows','yellow':
                  i = colorLibrary.yellows.length;
                  colorBallBorder = 'blue';
                  i = Math.floor(Math.random()*i);
                  return colorLibrary.yellows[i];
            case 'purples','purple':
                  i = colorLibrary.purples.length;
                  colorBallBorder = 'gold';
                  i = Math.floor(Math.random()*i);
                  return colorLibrary.purples[i];
            case 'pinks','pink':
                  i = colorLibrary.pinks.length;
                  colorBallBorder = 'Aqua';
                  i = Math.floor(Math.random()*i);
                  return colorLibrary.pinks[i];

          }
        }
      }
      //------------------------------------------------------------------------------------
      function randomRadius(maxRadius, minRadius) {
        if(arguments.length == 0)
          maxRadius = 100;
        if(arguments.legnth ==1) {
          var r = Math.floor(Math.random()*maxRadius);
          return (r%2 > 0) ? r+1 : r;
        }
        else {
          r = Math.floor(Math.random()*maxRadius)+minRadius;
          return (r%2 > 0) ? r+1 : r;
        }
      }
      //------------------------------------------------------------------------------------
      function Ball() {
        this.selected = false;
        this.selectedTime = new Date();
        this.radius = randomRadius(ballSizeMax,ballSizeMin);
        this.vLeft = Math.floor(Math.random()*window.innerWidth);
        this.vTop = Math.floor(Math.random()*window.innerHeight); 
        this.vRight = this.vLeft + 2*this.radius - 1;
        this.vBottom = this.vTop  + 2*this.radius - 1;
        if((this.vRight) >= window.innerWidth){
          this.vLeft = window.innerWidth - (2*this.radius)-1;
          this.vRight = this.vLeft + 2*this.radius - 1;
        }
        if((this.vBottom) >= window.innerHeight){
          this.vTop = window.innerHeight - (2*this.radius)-1;
          this.vBottom = this.vTop  + 2*this.radius - 1;
        }


        this.moveX = Math.floor(Math.random()*8)-4;
        this.moveX = (this.moveX == 0) ? 4 : this.moveX;
        this.moveY = Math.floor(Math.random()*8)-4;
        this.moveY = (this.moveY == 0) ? -4 : this.moveY;
        this.ball = document.createElement('div');
        this.ball.setAttribute('class', 'bouncingball');
        this.ball.setAttribute('onmouseover','divOnMouseOver(this)');
        //this.ball.setAttribute('onmouseup','divOnMouseOut(this)');
        this.ball.style.left = this.vLeft + 'px';
        this.ball.style.top = this.vTop + 'px';

        var col = randomColor();
        this.ball.style.backgroundColor = col;
        // this.borderColor = colorReverse(col);
        this.borderColor = colorReverse($(this.ball).css('backgroundColor'));
        this.ball.style.borderColor = this.ball.style.backgroundColor;

        this.ball.style.width = 2*this.radius + 'px'
        this.ball.style.height = 2*this.radius + 'px'
        this.ball.style.borderRadius = Math.floor(this.radius)+'px';
        // this.ball.style.visibility = 'hidden';
        
      }
      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      Ball.prototype.currentTurn = 0;
      Ball.prototype.myTurn = function () {
        this.selected = true;
        this.selectedTime = new Date();
        // this.ball.style.borderColor = colorBallBorder;
        // this.ball.style.borderColor = this.borderColor;
        this.ball.style.borderColor = 'rgb(255,80,80)';
        this.ball.style.borderWidth = '3px';
        this.ball.style.borderStyle = 'dotted';
        // timeChecked = new Date();
      }
      Ball.prototype.imNot = function () {
        this.selected = false;
        this.ball.style.borderColor = this.ball.style.backgroundColor;
        this.ball.style.borderWidth = '1px';
        this.ball.style.borderStyle = 'solid';        
      }
      Ball.prototype.resizeBall = function () {
        var pRatio = pWindowWidth / pWindowHeight;
        var cRatio = window.innerWidth / window.innerHeight;
        if(pRatio > cRatio) {
          this.ball.style.width = (this.radius*2*window.innerWidth)/pWindowWidth + 'px';
          this.ball.style.height = (this.radius*2*window.innerWidth)/pWindowWidth+ 'px';
          this.ball.style.borderRadius = (this.radius*window.innerWidth)/pWindowWidth+ 'px';
        } else {
          this.ball.style.width = (this.radius*2*window.innerHeight)/pWindowHeight + 'px';
          this.ball.style.height = (this.radius*2*window.innerHeight)/pWindowHeight+ 'px';          
          this.ball.style.borderRadius = (this.radius*window.innerHeight)/pWindowHeight+ 'px';
        }
      }
      Ball.prototype.move = function () {
        this.vLeft += this.moveX;
        if(this.vLeft <= 0) {
          this.vLeft = 0;
          this.moveX *= -1; 
        }
        this.vTop += this.moveY;
        if(this.vTop <= 0) {
          this.vTop = 0;
          this.moveY *= -1;
        }

        this.vRight = this.vLeft + 2*this.radius - 1;
        this.vBottom = this.vTop  + 2*this.radius - 1;

        if((this.vRight) >= window.innerWidth){
          this.vLeft = window.innerWidth - (2*this.radius)-1;
          this.vRight = this.vLeft + 2*this.radius - 1;
          this.moveX *= -1;
        }
        if((this.vBottom) >= window.innerHeight){
          this.vTop = window.innerHeight - (2*this.radius)-1;
          this.vBottom = this.vTop  + 2*this.radius - 1;
          this.moveY *= -1;
        }

        this.ball.style.left = this.vLeft + 'px';
        this.ball.style.top = this.vTop + 'px';   
      };
      Ball.prototype.rePosition = function() {
        var changed = false;
        if((this.vLeft + this.radius) > window.innerWidth){
          this.vLeft = window.innerWidth - this.radius - 1;
          changed = true;
        }
        if((this.vTop + this.radius) > window.innerHeight){
          this.vTop = window.innerHeight - this.radius - 1;
          changed = true;
        }
        if(changed) {
          this.ball.style.left = this.vLeft + 'px';
          this.ball.style.top = this.vTop + 'px';   
        }
      }
      //------------------------------------------------------------------------------------

      function moveBalls() {
        var timeNow = new Date;  // <-- for game 1.5 second
        if((balls.length > 1) && balls[Ball.currentTurn].selected && ((timeNow-balls[Ball.currentTurn].selectedTime) >= timeToNext)) {
          missedBalls++;
          if(addBallOnMissed){
            addBall();
          }
          balls[Ball.currentTurn].imNot();
          if(Ball.currentTurn >= (balls.length-1)) {
            Ball.currentTurn = 0;
          } else {
            Ball.currentTurn++;            
          }      
          balls[Ball.currentTurn].myTurn();
        }
        for(var i in balls) 
          balls[i].move();
        
        if(intervals.length)
          $('#timeinterval').text(avrOf(intervals)/1000);
        $('#timefinish').html(getTimeStamp());
        
      }
      //------------------------------------------------------------------------------------
      function getTimeStamp(mode) {
        var d;
        if(arguments.length > 0) {
          if(mode == 1) {
            timeStarted = new Date();
            d = timeStarted;
            timeChecked = timeStarted;
          }
          if(mode == 2) {
            timeFinished = new Date();
            d = timeFinished
          }
          if(mode == 3) {
            timeInterval = timeFinished - timeStarted;
            return (timeInterval/1000);
          }
        } else {
          d = new Date();
        }

        var msg = '';
        msg += addZero(d.getHours()) + ':' + addZero(d.getMinutes()) + ':' + addZero(d.getSeconds()) + '.<span style="font-size:11pt; color:#444;">' + addZero(Math.floor(d.getMilliseconds()/10)) + '</span>';
        return msg;
      }
      //------------------------------------------------------------------------------------
      function addZero(i) {
         return (i < 10) ? "0" + i : i;
      }//------------------------------------------------------------------------------------
      function rotateBalls(dir) {
         if(dir == 0) 
          balls.push(balls.shift());
         else
          balls.unshift(balls.pop());
      }
      //------------------------------------------------------------------------------------
      function startGame() {
          document.getElementById('control').style.visibility = 'hidden';
          document.getElementById('control2').style.visibility = 'hidden';

          ballSizeMax = Math.floor(window.innerWidth*75/1920);
          ballSizeMin = Math.floor(window.innerWidth*10/1920);

          if(soundEffect)
            soundControlButton.play()

          $('#gameresult').slideUp();
          
          ballCount = document.getElementById('ballcount').value * 1;
          if(ballCount > ballsMax){
            ballCount = ballsMax;
            document.getElementById('ballcount').value = ballCount;
          }

          function makeGameBalls() {
            for(var i=1; i<=ballCount; i++) {
              setTimeout(make_a_ball, i*110);
            }
            ballsKilled = [];

            Ball.currentTurn = 0;
            missedBalls = 0;
            missed = [];
            intervals = [];
            windows = [];
            windowStamp();
          }

          function make_a_ball() {
                  var b = new Ball();
                  document.body.appendChild(b.ball);
                  $(b.ball).hide();
                  $(b.ball).fadeIn(150);
                  balls.push(b);            
          }

          function gameStarter() {
            timer = setInterval(moveBalls,ballSpeed);
            balls[Ball.currentTurn].myTurn();
            document.getElementById('timestart').innerHTML = getTimeStamp(1);
            document.getElementById('ballsleft').innerHTML = balls.length;
            document.getElementById('timefinish').innerHTML = '';
            document.getElementById('timeinterval').innerHTML = '?';
            document.getElementById('ballcount').value = ballCount;            
          }
          function soundBGMPlayer() {
              soundBGM.seek(0,soundIdBGM);
              soundBGM.fade(0,1,100,soundIdBGM);
          }

          if($('#toggleBGM').text() == 'BGM ON') {
              // soundBGM.fade(0,1,10,soundIdBGM);
              // setTimeout(soundBGMPlayer, ballCount*100+200);
              soundBGMPlayer();
              setTimeout(makeGameBalls, 2200);
              // setTimeout(soundBGMPlayer, ballCount*100+200);
              setTimeout(gameStarter, 13000);
          } else {
              makeGameBalls();
              setTimeout(gameStarter, ballCount*100+1000);            
          }
      }      
      //------------------------------------------------------------------------------------
      function addBall() {
        var b = new Ball();
        document.body.appendChild(b.ball);
        $(b.ball).hide();
        $(b.ball).slideDown(400);
        balls.push(b);
        ballCount++;
        ballsMin = ballCount;
        document.getElementById('ballsleft').innerHTML = balls.length;
        document.getElementById('ballcount').value = ballCount;

        if(soundEffect)
          soundNewBall.play();
      }
      //------------------------------------------------------------------------------------
      function pauseGame() {
        if(timer != null) {
          clearInterval(timer);
          timer = null;
        } else
          resumeGame();  
      }
      //------------------------------------------------------------------------------------
      function resumeGame() {
        if(timer == null) 
          timer = setInterval(moveBalls, ballSpeed);
        else
          pauseGame();  
      }
      //------------------------------------------------------------------------------------
      function correctBallsInput() {
        var bci = document.getElementById('ballcount');
        var bc = bci.value * 1;
        if (bc <= ballsMin) 
          bci.value = ballsMin;
        else if (bc > ballsMax)
          bci.value = ballsMax;
      }
      //------------------------------------------------------------------------------------
      function reAlignCopyright() {
        ballSizeMax = Math.floor(window.innerWidth*75/1920);
        ballSizeMin = Math.floor(window.innerWidth*10/1920);

        var dc = document.getElementById('copyright');
        var dcs = dc.style;
        dcs.top = (window.innerHeight - 20) + 'px';
        dcs.width = (window.innerWidth - 20) + 'px';

        for(var i in balls){
          balls[i].resizeBall();
          balls[i].rePosition();
        }

        windowStamp();
        reAlignGameResult();
      }
      //------------------------------------------------------------------------------------
      function controlAddBall() {
        if(addBallOnMissed) {
          addBallOnMissed = false;
          $('#togglePenalty').text('Penalty OFF');
          buttonControl('#togglePenalty', 'OFF');
        } else {
          addBallOnMissed = true;
          $('#togglePenalty').text('Penalty ON');          
          buttonControl('#togglePenalty', 'ON');
        }
        $('#togglePenalty').blur();
        if(soundEffect)
          soundControlButton.play()
      }
      //------------------------------------------------------------------------------------
      function buttonControl(btnid, sw) {
        if(sw.toLowerCase() == 'on') 
          $(btnid).css({'background-color': 'blue', 'color': 'yellow'});
        else
          $(btnid).css({'background-color': 'gray', 'color': 'white'});
      }
      //------------------------------------------------------------------------------------
      function controlBGM() {
        if(timeStarted == null) {
          if($('#toggleBGM').text() == 'BGM ON') {
            $('#toggleBGM').text('BGM OFF');
            buttonControl('#toggleBGM', 'OFF');
          } else {
            $('#toggleBGM').text('BGM ON');
            buttonControl('#toggleBGM', 'ON');
          }
        } else {
          if($('#toggleBGM').text() == 'BGM ON') {
            $('#toggleBGM').text('BGM OFF');
            soundBGM.fade(1,0,1000,soundIdBGM);
            buttonControl('#toggleBGM', 'OFF');
          } else {
            $('#toggleBGM').text('BGM ON');
            soundBGM.fade(0,1,1000,soundIdBGM);
            buttonControl('#toggleBGM', 'ON');
          }
        }
        if(soundEffect)
          soundControlButton.play()
        $('#toggleBGM').blur();
      }
      //------------------------------------------------------------------------------------
      function controlSFX() {
        if($('#toggleSFX').text() == 'SFX ON') {
          $('#toggleSFX').text('SFX OFF');
          buttonControl('#toggleSFX', 'OFF');
          soundEffect = false;
        } else {
          $('#toggleSFX').text('SFX ON');
          buttonControl('#toggleSFX', 'ON');
          soundEffect = true;
        }
        if(soundEffect)
          soundControlButton.play()
        $('#toggleSFX').blur();
      }
      //------------------------------------------------------------------------------------
      function reAlignGameResult() {
        var dc = document.getElementById('gameresult');
        var dcs = dc.style;
        dcs.left = Math.floor((window.innerWidth - 500) / 2) + 'px';
        dcs.top = '150 px';
      }
      //------------------------------------------------------------------------------------
      window.onload = function() {
        reAlignCopyright();
        soundIdBGM = soundBGM.play();
        //soundIdBGM = soundBGM.fade(0,0.3,1500);
        document.getElementById('ballcount').value = ballCount; 
        $('#gameresult').hide();
        buttonControl('#toggleBGM', 'ON');
        buttonControl('#toggleSFX', 'ON');
        buttonControl('#togglePenalty', 'OFF');

        //for version boundcing_za.html
        pWindowWidth = window.innerWidth;
        pWindowHeight = window.innerHeight;
      }
      //------------------------------------------------------------------------------------

    </script>
  </head>
  <body onresize="reAlignCopyright();">
      <!-- ====================================================================================================== -->
      <table style="width:100%;"> <tr>
      <td style="width: 160px; text-align: left;"><button  ditip='게임 시작.' id="control" style="font-size:12pt;" onclick='startGame();'>Start</button> <span id='control2'>with 
          <input ditip='표시된 수에서 최대 50개까지만 설정할 수 있습니다.' oninput='correctBallsInput();' type='text' id='ballcount' style="font-size: 12pt; text-align: right;" size='3'></span></td>
      <td style="width:120px;"><span onclick="addBall();">Balls</span>: <b><span style="width:180px; color: blue;" id=ballsleft></span></b> </td>
      <td style="width:140px;">Start:<b><span id=timestart onclick = "resumeGame();"></span></b></td>
      <td style="width:140px;"> Finish:<b><span id=timefinish onclick="pauseGame();"></span></b></td>
      <td> 
            <button ditip='테두리 공을 놓칠 때마다 새 공 생성하기를 제어합니다.' id='togglePenalty' class='control' onclick='controlAddBall();'>Penalty OFF</button>
            <button ditip='배경음악을 제어합니다.' id='toggleBGM' class='control' style='width: 100px;' onclick='controlBGM();'>BGM ON</button>
            <button ditip='효과음들을 제어합니다.' id='toggleSFX' class='control' style='width: 100px;' onclick='controlSFX();'>SFX ON</button>
      </td>
      <td ditip='공 제거에 걸린 평균 시간' style="text-align:right;">Avrg. speed:<b><span id='timeinterval' style="color: red; font-size: 12pt;">?</span></b> seconds.</td>
      </tr></table>

      <!-- ====================================================================================================== -->
      <div id='copyright' class='copyright'>Copyright (c) 2016 by Pongsik, Ho.  컴퓨터정보과, 동의과학대학교  </div>
      <!-- ====================================================================================================== -->
      <div class='gameresult' id='gameresult' style="text-align: center; width: 500px; background-color: MistyRose;">
          <table width=100%>
            <tr><td style="border-bottom-style: solid; border-bottom-width: 2px; border-bottom-color: gray;">
                <h1 style="color: MediumVioletRed; font-family: 'Arial'; font-style: 'bold'; text-shadow: 2px 2px 2px #AAAAAA; margin-bottom: 0px;" >Game Report</h1>
                <p style="font-family: Arial; font-size:7pt;"> version: [bouncing_za].2016.10.21.</p>
            </td></tr>
            <tr><td style="background-color: LemonChiffon;">
                <table id='gamereport' style="width:100%; border-style: solid; border-color: #AAAAAA; border-width: 0px; position: relative; margin: 5%;">
                  <tr>
                    <td class=coltitle># of game balls:</td>
                    <td class=colvalue><b><span  style='color: black;' id='numberofballs'>35</span></b></td>
                  </tr>
                  <tr>
                    <td class=coltitle># of missed balls:</td>
                    <td class=colvalue><b><span style='color:red;' id='missedballs'>1:00.00</span></b></td>
                  </tr>
                  <tr>
                    <td class=coltitle>Window size:</td>
                    <td class=colvalue><span id='windowsize'>35</span></td>
                  </tr>
                  <tr>
                    <td class=coltitle>Total game time:</td>
                    <td class=colvalue><b><span id='timetotal'>1:00.00</span></b> secs.</td>
                  </tr>
                  <tr>
                    <td class=coltitle>Average interval:</td>
                    <td class=colvalue><b><span style='color:blue;' id='timeavr'>1:00.00</span></b> secs.</td>
                  </tr>
                  <tr>
                    <td class=coltitle>Maximum interval:</td>
                    <td class=colvalue><b><span style='color: red;' id='timemax'>1:00.00</span></b> secs.</td>
                  </tr>
                  <tr>
                    <td class=coltitle>Mininum interval:</td>
                    <td class=colvalue><b><span  style='color: blue;' id='timemin'>1:00.00</span></b> secs.</td>
                  </tr>
                </table>
                <span id='reportfinishtime' style='font-size: 9pt;'>2016.10.15.</span>
            </td></tr>
            <tr><td style="border-top-style: solid; border-top-width: 2px; border-top-color: gray;">
                <p>Copyright (c) 2016 by Pongsik, Ho.  DIT</p>
            </td></tr>
          </table>
      </div>
      <!-- ====================================================================================================== -->
  </body>
</html>