package Shared.AS3
{
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;	
	import flash.text.TextField;
	import flash.ui.Keyboard;
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
		
		protected var _iQuantity: int;
		protected var _iMaxQuantity: int;
		protected var _bOpened: Boolean;
		protected var _prevFocusObj: InteractiveObject;
		protected var _uiItemValue: uint = 0;

		public function QuantityMenu()
		{
			super();
			
			this._iQuantity = 1;
			this._iMaxQuantity = 1;
			this._bOpened = false;
			
			addEventListener(BSSlider.VALUE_CHANGED, this.onValueChange);
		}

		public function get bOpened(): Boolean
		{
			return this._bOpened;
		}

		public function get iQuantity(): int
		{
			return this._iQuantity;
		}

		public function get prevFocus(): InteractiveObject
		{
			return this._prevFocusObj;
		}

		public function OpenMenu(aiQuantity: int, aPrevFocusObj: InteractiveObject, asLabelText: String = "", auiItemValue: * = 0): *
		{
			this._iMaxQuantity = aiQuantity;
			this._iQuantity = aiQuantity;
			
			this.Scrollbar_mc.minValue = 0;
			this.Scrollbar_mc.maxValue = aiQuantity;
			this.Scrollbar_mc.value = aiQuantity;
			
			this._uiItemValue = auiItemValue;
			if (asLabelText.length > 0)
			{
				GlobalFunc.SetText(this.Label_tf, asLabelText, false);
			}
			
			this.FitBrackets();
			this.RefreshText();
			
			addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			this._prevFocusObj = aPrevFocusObj;
			this._bOpened = true;
			this.alpha = 1.0;
		}

		public function CloseMenu(): *
		{
			removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			this._prevFocusObj = null;
			this._bOpened = false;
			this.alpha = 0.0;
		}

		private function FitBrackets(): *
		{
		}

		private function RefreshText(): *
		{
			GlobalFunc.SetText(this.Value_tf, this._iQuantity.toString(), false);

			if (this.TotalValue_tf != null)
			{
				var uiTotalValue: uint = this._iQuantity * this._uiItemValue;
				GlobalFunc.SetText(this.TotalValue_tf, uiTotalValue.toString(), false);
			}
		}

		public function onValueChange(e: Event): void
		{
			this._iQuantity = this.Scrollbar_mc.value;
			this.RefreshText();
			dispatchEvent(new CustomEvent(QUANTITY_MODIFIED, this._iQuantity, true, true));
		}
		
		public function onKeyDown(param1:KeyboardEvent):*
        {
			switch (param1.keyCode)
			{
				case Keyboard.A:
				case Keyboard.LEFT:
					this.Scrollbar_mc.valueJump(-1);
					param1.stopPropagation();
					break;
				
				case Keyboard.D:
				case Keyboard.RIGHT:
					this.Scrollbar_mc.valueJump(1);
					param1.stopPropagation();
					break;
			}
        }
	}
}