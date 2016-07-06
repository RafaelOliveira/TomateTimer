package;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import kha.math.Vector2i;

class Button
{
	inline static var TEXT_SIZE:Int = 16;
	
	public var pos:Vector2;
	public var size:Vector2i;
	public var visible:Bool;
	var text:String;
	var textPos:Vector2;
	var funcCallback:Void->Void;
	var isMouseOver:Bool;
	public var disabled:Bool;
	
	public function new(text:String, x:Float, y:Float, w:Int, h:Int, visible:Bool, funcCallback:Void->Void, disabled:Bool = false):Void
	{
		this.text = text;
		this.visible = visible;
		this.funcCallback = funcCallback;		
		this.disabled = disabled;
		
		pos = new Vector2(x, y);
		size = new Vector2i(w, h);		
		isMouseOver = false;
		
		var halfTextWidth = Std.int(Assets.fonts.Vera.width(TEXT_SIZE, text) / 2);
		var halfTextHeight = Std.int(Assets.fonts.Vera.height(TEXT_SIZE) / 2);
		
		textPos = new Vector2(x + (w / 2) - halfTextWidth, y + (h / 2) - halfTextHeight);
	}
	
	public function click(px:Float, py:Float):Bool
	{
		if (pointInside(px, py))
		{			
			funcCallback();
			return true;
		}
		
		return false;
	}
	
	public function mouseMove(px:Float, py:Float):Void
	{
		if (pointInside(px, py))
			isMouseOver = true;
		else
			isMouseOver = false;
	}
	
	inline function pointInside(px:Float, py:Float):Bool
	{
		return (px >= pos.x && px <= (pos.x + size.x) && py >= pos.y && py <= (pos.y + size.y));
	}
	
	public function render(g2:Graphics):Void
	{
		if (disabled)
			g2.color = Project.COLOR_BT_DISABLED;
		else
		{
			if (isMouseOver)
				g2.color = Project.COLOR_BT_OVER;
			else
				g2.color = Project.COLOR_LIGHT_RED;	
		}
		
		g2.fillRect(pos.x, pos.y, size.x, size.y);
		g2.color = Color.White;
		g2.fontSize = TEXT_SIZE;		
		g2.drawString(text, textPos.x, textPos.y);
	}
}