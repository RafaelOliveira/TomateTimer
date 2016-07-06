package;

import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.math.Vector2;
import kha.math.Vector2i;
import kha.input.Mouse;

class Project 
{
	// colors
	public inline static var COLOR_LIGHT_RED:Int = 0xffbc0000;
	public inline static var COLOR_DARK_RED:Int = 0xff840000;
	public inline static var COLOR_BT_OVER:Int = 0xff0088aa;
	public inline static var COLOR_BT_DISABLED:Int = 0xffde8787;
	
	inline static var TEXT_INFO_SIZE:Int = 16;
	
	// buttom positions
	public inline static var BT_HEIGHT:Int = 36;
	public inline static var BT_Y_AREA:Int = 124;
	
	// window size
	public static var winSize:Vector2i;
	public static var halfWinSize:Vector2i;
	
	var clock:Clock;
	var buttons:Map<String, Button>;	
	var status:Int;
	
	// info
	var textInfo:String;
	var posTextInfo:Vector2;
	
	// counters
	var totalPomodoros:Int;
	var longBreakCounter:Int;	
	
	public function new()
	{
		Assets.loadEverything(assetsLoaded);
	}
	
	function assetsLoaded():Void
	{
		winSize = new Vector2i(System.windowWidth(), System.windowHeight());		
		halfWinSize = new Vector2i(Std.int(winSize.x / 2), Std.int(winSize.y / 2));
		
		setupButtons();
		clock = new Clock(configAfterStop);		
		status = Clock.STOPPED;
		
		textInfo = '';
		posTextInfo = new Vector2(0, 0);
		
		totalPomodoros = 0;
		longBreakCounter = 0;		
		
		Mouse.get().notify(mouseDown, null, mouseMove, null);
		
		System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);		
	}
	
	inline function setupButtons():Void
	{
		buttons = new Map<String, Button>();
		
		// position of the first and second buttons
		var firstBtYPos = BT_Y_AREA + 10;
		var secBtYPos = firstBtYPos + BT_HEIGHT + 10;
		
		buttons.set('start', new Button('start pomodoro', 10, firstBtYPos, winSize.x - 20, BT_HEIGHT, true, startPomodoro));
		buttons.set('stop', new Button('stop', 10, firstBtYPos, winSize.x - 20, BT_HEIGHT, false, stopTimer));
		buttons.set('short_break', new Button('start short break', 10, firstBtYPos, winSize.x - 20, BT_HEIGHT, false, startShortPause));
		buttons.set('long_break', new Button('start long break', 10, firstBtYPos, winSize.x - 20, BT_HEIGHT, false, startLongPause));
		buttons.set('restart', new Button('restart timer', 10, secBtYPos, winSize.x - 20, BT_HEIGHT, true, restartTimer, true));		
	}

	function update():Void
	{
		
	}
	
	function mouseDown(button:Int, x:Int, y:Int):Void
	{
		for (button in buttons)
		{
			if (button.visible && !button.disabled)
			{				
				if (button.click(x, y))
					return;
			}
		}
	}
	
	function mouseMove(x:Int, y:Int, movementX:Int, movementY:Int):Void
	{
		for (button in buttons)
		{
			if (button.visible && !button.disabled)
				button.mouseMove(x, y);
		}
	}
	
	function startPomodoro():Void
	{
		totalPomodoros++;
		longBreakCounter++;
		status = Clock.POMODORO;
		setTextInfo(totalPomodoros + '° pomodoro');
		
		buttons.get('start').visible = false;
		buttons.get('stop').visible = true;
		
		if (totalPomodoros == 1)
			buttons.get('restart').disabled = false;
		
		clock.start(Clock.POMODORO);
	}	
	
	function stopTimer():Void
	{
		if (status != Clock.STOPPED)
			clock.stop();
	}
	
	function startShortPause():Void
	{
		status = Clock.SHORT_BREAK;
		setTextInfo('short break');
		
		buttons.get('short_break').visible = false;
		buttons.get('stop').visible = true;
		
		clock.start(Clock.SHORT_BREAK);
	}
	
	function startLongPause():Void
	{
		status = Clock.LONG_BREAK;
		setTextInfo('long break');
		
		buttons.get('long_break').visible = false;
		buttons.get('stop').visible = true;
		
		clock.start(Clock.LONG_BREAK);
	}
	
	function restartTimer():Void
	{
		clock.stop(false);
		status = Clock.STOPPED;
		textInfo = '';
		totalPomodoros = 0;
		longBreakCounter = 0;
		
		buttons.get('start').visible = true;
		buttons.get('stop').visible = false;
		buttons.get('short_break').visible = false;
		buttons.get('long_break').visible = false;
		buttons.get('restart').disabled = true;
	}
	
	function setTextInfo(text:String):Void
	{
		textInfo = text;
		
		if (textInfo.length > 0)
		{
			var halfTextWidth = Std.int(Assets.fonts.Vera.width(TEXT_INFO_SIZE, textInfo) / 2);
			var halfTextHeight = Std.int(Assets.fonts.Vera.height(TEXT_INFO_SIZE) / 2);
			
			posTextInfo.x = halfWinSize.x - halfTextWidth;
			posTextInfo.y = 99 + (25 / 2) - halfTextHeight;
			
			//if (status == Clock.POMODORO || status == Clock.LONG_BREAK)
				posTextInfo.y -= 1;
		}		
	}
	
	function configAfterStop():Void
	{
		switch(status)
		{
			case Clock.POMODORO:
				if (longBreakCounter == 4)
				{					
					longBreakCounter = 0;
					buttons.get('long_break').visible = true;					
				}
				else
					buttons.get('short_break').visible = true;
			
			case Clock.SHORT_BREAK, Clock.LONG_BREAK:
				buttons.get('start').visible = true;
		}
		
		buttons.get('stop').visible = false;
		status = Clock.STOPPED;
		
		// clear the text without set the position
		textInfo = '';
	}

	function render(fb:Framebuffer):Void
	{
		fb.g2.begin(true, Color.White);
		fb.g2.font = Assets.fonts.Vera;
		
		// clock background
		fb.g2.color = COLOR_LIGHT_RED;
		fb.g2.fillRect(0, 0, winSize.x, Clock.heighBg);
		fb.g2.fillRect(0, 88, winSize.x, 11);
		
		// info background
		fb.g2.color = COLOR_DARK_RED;
		fb.g2.fillRect(0, 99, winSize.x, 25);
		
		// info text
		if (textInfo.length > 0)
		{
			fb.g2.color = Color.White;
			fb.g2.fontSize = TEXT_INFO_SIZE;
			fb.g2.drawString(textInfo, posTextInfo.x, posTextInfo.y);
		}
		
		// clock text
		clock.render(fb.g2);
		
		// buttons
		for (button in buttons)
		{
			if (button.visible)
				button.render(fb.g2);
		}
		
		fb.g2.end();
	}
}