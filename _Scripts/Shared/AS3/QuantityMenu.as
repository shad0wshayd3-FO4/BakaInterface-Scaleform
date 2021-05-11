package Shared.AS3
{
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import Shared.AS3.Events.CustomEvent;
	import Shared.AS3.QuantityScrollbar;
	import Shared.GlobalFunc;

	public class QuantityMenu extends MovieClip
	{
		private static const LabelBufferX = 3;

		public static const INV_MAX_NUM_BEFORE_QUANTITY_MENU: uint = 5;
		public static const QUANTITY_MODIFIED:String = "QuantityMenu::quantityModified";

		public var Label_tf: TextField;
		public var Value_tf: TextField;
		public var TotalValue_tf: TextField;
		public var CapsLabel_tf: TextField;
		public var Scrollbar_mc: QuantityScrollbar;
		public var QuantityBracketHolder_mc: MovieClip;
		
		protected var iQuantity: int;
		protected var iMaxQuantity: int;
		protected var bOpened: Boolean;
		protected var prevFocusObj: InteractiveObject;
		protected var uiItemValue: uint = 0;

		public function QuantityMenu()
		{
			super();
			
			this.iQuantity = 1;
			this.iMaxQuantity = 1;
			this.bOpened = false;
			
			addEventListener(BSSlider.VALUE_CHANGED, this.onValueChange);
		}

		public function get opened(): Boolean
		{
			return this.bOpened;
		}

		public function get quantity(): int
		{
			return this.iQuantity;
		}

		public function get prevFocus(): InteractiveObject
		{
			return this.prevFocusObj;
		}

		public function OpenMenu(aiQuantity: int, aPrevFocusObj: InteractiveObject, asLabelText: String = "", auiItemValue: * = 0): *
		{
			this.iMaxQuantity = aiQuantity;
			this.iQuantity = aiQuantity;
			
			this.Scrollbar_mc.minValue = 0;
			this.Scrollbar_mc.maxValue = aiQuantity;
			this.Scrollbar_mc.value = aiQuantity;
			
			this.uiItemValue = auiItemValue;
			if (asLabelText.length)
			{
				GlobalFunc.SetText(this.Label_tf, asLabelText, false);
			}
			
			this.FitBrackets();
			this.RefreshText();
			
			this.prevFocusObj = aPrevFocusObj;
			this.alpha = 1;
			this.bOpened = true;
		}

		public function CloseMenu(): *
		{
			this.prevFocusObj = null;
			this.alpha = 0;
			this.bOpened = false;
		}

		private function FitBrackets(): *
		{
		}

		private function RefreshText(): *
		{
			GlobalFunc.SetText(this.Value_tf, this.iQuantity.toString(), false);

			if (this.TotalValue_tf != null)
			{
				var uiTotalValue: uint = this.iQuantity * this.uiItemValue;
				GlobalFunc.SetText(this.TotalValue_tf, uiTotalValue.toString(), false);
			}
		}

		public function onValueChange(e: Event): void
		{
			this.iQuantity = this.Scrollbar_mc.value;
			this.RefreshText();
			dispatchEvent(new CustomEvent(QUANTITY_MODIFIED, this.iQuantity, true, true));
		}

		public function ProcessUserEvent(asEvent: String, bData: Boolean): Boolean
		{
			return this.Scrollbar_mc.ProcessUserEvent(asEvent, bData);
		}
	}
}