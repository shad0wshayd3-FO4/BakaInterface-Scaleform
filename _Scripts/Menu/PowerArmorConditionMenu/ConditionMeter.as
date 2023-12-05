package Menu.PowerArmorConditionMenu
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public class ConditionMeter extends MovieClip
	{
		public var Bracket_mc:MovieClip;
		public var Label_tf:TextField;
		public var Meter_mc:MeterBar;
		
		public function ConditionMeter()
		{
			super();
			this.__SetProp_MeterBar();
		}
	
		public function SetCount(param1:uint):void
		{
			this.Label_tf.text = param1.toString();
		}

		public function SetPercent(param1:Number):void
		{
			this.MeterBar_mc.Percent = (param1 / 100.0);
		}
	
		internal function __SetProp_MeterBar():void
		{
			this.MeterBar_mc.BarAlpha = 1;
			this.MeterBar_mc.Justification = "left";
			this.MeterBar_mc.Percent = 0;
		}
	}
}
