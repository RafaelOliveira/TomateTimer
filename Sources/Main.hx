package;

import kha.System;

class Main 
{
	public static function main() 
	{
		System.init({ title: 'Tomate Timer', width: 320, height: 226 }, function () {
			new Project();
		});
	}
}