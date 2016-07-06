package;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import kha.Scheduler;

class Clock
{	
	public inline static var STOPPED:Int = 0;
	public inline static var POMODORO:Int = 1;
	public inline static var SHORT_BREAK:Int = 2;
	public inline static var LONG_BREAK:Int = 3;
	
	inline static var TEXT_SIZE:Int = 52;
	public inline static var heighBg:Int = 85;
	
	var pos:Vector2;
	var text:String;
	var time:Float;
	
	var pomodoroTime:Float;
	var shortPauseTime:Float;
	var longPauseTime:Float;
		
	var idTimeTask:Int;
	var stopCallback:Void->Void;
	
	public function new(stopCallback:Void->Void):Void
	{
		text = '00:00';		
		idTimeTask = -1;
		this.stopCallback = stopCallback;
		
		pomodoroTime = 25 * 60 * 1000;
		shortPauseTime = 4 * 60 * 1000;
		longPauseTime = 14 * 60 * 1000;
		
		var halfTextWidth = Std.int(Assets.fonts.Vera.width(TEXT_SIZE, text) / 2);
		var halfTextHeight = Std.int(Assets.fonts.Vera.height(TEXT_SIZE) / 2);
		
		pos = new Vector2(Project.halfWinSize.x - halfTextWidth, (heighBg / 2) - halfTextHeight);		
	}
	
	public function start(type:Int):Void
	{				
		switch(type)
		{
			case POMODORO: time = pomodoroTime;
			case SHORT_BREAK: time = shortPauseTime;
			case LONG_BREAK: time = longPauseTime;
		}		
		
		idTimeTask = Scheduler.addTimeTask(updateTimer, 0, 1, time / 1000);
	}
	
	public function stop(useCallback:Bool = true):Void
	{
		time = 0;
		text = '00:00';
		Scheduler.removeTimeTask(idTimeTask);
		
		if (useCallback)
			stopCallback();
	}	
	
	public function updateTimer():Void
	{
		time -= 1000;
		var timeParsed = DateTools.parse(time);
		text = formatZero(timeParsed.minutes) + ':' + formatZero(timeParsed.seconds);
		
		if (time <= 0)
			stop();
	}
	
	function formatZero(value:Float):String
	{
		if (value < 10)
			return '0' + value;
		else
			return Std.string(value);
	}
	
	public function render(g2:Graphics):Void
	{
		g2.color = Color.White;
		g2.fontSize = TEXT_SIZE;
		g2.drawString(text, pos.x, pos.y);
	}	
}