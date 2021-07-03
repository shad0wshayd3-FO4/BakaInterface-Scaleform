package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextLineMetrics
	import Menu.BarterMenu.*
	import Menu.ContainerMenu.*
	import Shared.AS3.BSButtonHintData;
	import Shared.AS3.QuantityMenu;
	import Shared.GlobalFunc;

	public dynamic class BarterMenu extends ContainerMenu
	{
		public var bIsValidTrade: Boolean;
		public var bIsResetTrade: Boolean;
		public var CapsTransferInfo_mc: MovieClip;
		
		private var AcceptTradeButton: BSButtonHintData;
		private var ResetTradeButton: BSButtonHintData;
		private var InvestButton: BSButtonHintData;
		private var bCanInvest: Boolean;

		public function BarterMenu()
		{
			this.AcceptTradeButton = new BSButtonHintData("$ACCEPT", "R", "PSN_X", "Xenon_X", 1, this.onAcceptTrade);
			this.ResetTradeButton = new BSButtonHintData("$RESET", "T", "PSN_Y", "Xenon_Y", 1, this.onResetTrade);
			this.InvestButton = new BSButtonHintData("$INVEST", "V", "PSN_Select", "Xenon_Select", 1, this.onInvest);
			
			super();
			
			this.PlayerInventory_mc.PlayerList_mc.filterer = new BarterListFilterer();
			this.ContainerList_mc.filterer = new BarterListFilterer();
			
			this.bIsValidTrade = this.bIsResetTrade = false;
		}

		public function get isValidTrade(): Boolean
		{
			return this.bIsValidTrade;
		}

		public function set canInvest(param1: Boolean): *
		{
			this.InvestButton.ButtonEnabled = this.bCanInvest = param1;
		}

		public function get canInvest(): Boolean
		{
			return this.bCanInvest;
		}
		
		override protected function PopulateButtonBar(): void
		{
			var buttonHintDataV: Vector.<BSButtonHintData> = new Vector.<BSButtonHintData>();
			buttonHintDataV.push(this.SwitchToPlayerButton);
			buttonHintDataV.push(this.SwitchToContainerButton);
			buttonHintDataV.push(this.AcceptButton);
			buttonHintDataV.push(this.AcceptTradeButton);
			buttonHintDataV.push(this.ResetTradeButton);
			buttonHintDataV.push(this.InspectButton);
			buttonHintDataV.push(this.InvestButton);
			buttonHintDataV.push(this.ExitButton);
			buttonHintDataV.push(this.QuantityAcceptButton);
			buttonHintDataV.push(this.QuantityCancelButton);
			buttonHintDataV.push(this.SortButton);
			this.ButtonHintBar_mc.SetButtonHintData(buttonHintDataV);
		}
		
		override protected function UpdateButtonHints(): void
		{
			super.UpdateButtonHints();
			
			var bQuantityMenuIsActive: Boolean = this.QuantityMenu_mc.bOpened;
			var bModalMenuIsActive: Boolean = (bQuantityMenuIsActive || this.MessageBoxIsActive);
			
			this.TakeAllButton.ButtonVisible = false;
			this.AcceptTradeButton.ButtonVisible = !bModalMenuIsActive;
			this.ResetTradeButton.ButtonVisible = !bModalMenuIsActive;
			this.InvestButton.ButtonVisible = !bModalMenuIsActive;
			
			if (!bModalMenuIsActive)
			{
				this.AcceptTradeButton.ButtonEnabled = this.bIsValidTrade;
				this.ResetTradeButton.ButtonEnabled = this.bIsResetTrade;
				this.InvestButton.ButtonEnabled = this.bCanInvest;
			}
		}
		
		override public function ProcessUserEvent(a_event: String, a_keyPressed: Boolean): Boolean
		{
			var result: Boolean = super.ProcessUserEvent(a_event, a_keyPressed);
			if (!result)
			{
				if (!a_keyPressed)
				{
					switch (a_event)
					{
						case "TradeAccept":
							this.onAcceptTrade();
							return true;
						
						case "TradeReset":
							this.onResetTrade();
							return true;
						
						case "Invest":
							this.onInvest();
							return true;
					}
				}
			}
			
			return result;
		}

		override protected function get AcceptButtonText(): String
		{
			return (stage.focus == this.ContainerList_mc) ? "$BUY" : "$SELL";
		}

		private function onItemPress(event: Event): *
		{
			var SelectedEntry: Object = (event.target as ItemList).selectedEntry;
			if (SelectedEntry != null)
			{
				var iItemCount: int = SelectedEntry.count;
				if (SelectedEntry.hasOwnProperty("barterCount"))
				{
					iItemCount -= SelectedEntry.barterCount;
				}
			
				if (iItemCount > 0)
				{
					if (iItemCount <= QuantityMenu.INV_MAX_NUM_BEFORE_QUANTITY_MENU)
					{
						this.BGSCodeObj.transferItem((event.target as ItemList).selectedIndex, 1, event.target == ContainerList_mc);
					}
					else
					{
						var iItemValue: int = BGSCodeObj.getItemValue((event.target as ItemList).selectedIndex, event.target == ContainerList_mc);
						this.OpenQuantityMenu(iItemCount, iItemValue);
					}

					this.UpdateButtonHints();
				}
			}
		}

		public function onAcceptTrade(): void
		{
			if (this.AcceptTradeButton.ButtonVisible && this.AcceptTradeButton.ButtonEnabled)
			{
				this.BGSCodeObj.TradeAccept();
			}
		}

		public function onResetTrade(): void
		{
			if (this.ResetTradeButton.ButtonVisible && this.ResetTradeButton.ButtonEnabled)
			{
				this.BGSCodeObj.TradeReset();
			}
		}

		public function onInvest(): void
		{
			if (this.InvestButton.ButtonVisible && this.InvestButton.ButtonEnabled)
			{
				this.BGSCodeObj.confirmInvest();
			}
		}

		public function UpdateTransferCaps(iValue: int, iPlayerCaps: uint, iVendorCaps: uint, bVisible: Boolean): *
		{
			this.CapsTransferInfo_mc.TransferCaps_tf.visible = bVisible;
			this.CapsTransferInfo_mc.TransferCapsIcon_mc.visible = bVisible;
			this.CapsTransferInfo_mc.Background_mc.visible = bVisible;
			
			this.bIsValidTrade = this.bIsResetTrade = false;
			this.CapsTransferInfo_mc.CapsArrowLeft_mc.visible = false;
			this.CapsTransferInfo_mc.CapsArrowRight_mc.visible = false;
			
			if (bVisible)
			{
				var iAbsValue: int = Math.abs(iValue);
				var iCmpValue: int = (iValue >= 0) ? iPlayerCaps : iVendorCaps;

				var fAlpha: Number = (iCmpValue < iAbsValue) ? GlobalFunc.PIPBOY_GREY_OUT_ALPHA : 1.0;
				this.CapsTransferInfo_mc.TransferCaps_tf.alpha = fAlpha;
				this.CapsTransferInfo_mc.TransferCapsIcon_mc.alpha = fAlpha;
				this.CapsTransferInfo_mc.CapsArrowLeft_mc.alpha = fAlpha;
				this.CapsTransferInfo_mc.CapsArrowRight_mc.alpha = fAlpha;

				this.bIsResetTrade = true;
				this.bIsValidTrade = (iValue >= 0) ? (iCmpValue > iAbsValue) : true;
				this.CapsTransferInfo_mc.CapsArrowLeft_mc.visible = (iValue < 0);
				this.CapsTransferInfo_mc.CapsArrowRight_mc.visible = (iValue >= 0);

				GlobalFunc.SetText(this.CapsTransferInfo_mc.TransferCaps_tf, iAbsValue.toString());
				
				var metrics: TextLineMetrics = this.CapsTransferInfo_mc.TransferCaps_tf.getLineMetrics(0);
				var whSpace: Number = ((this.CapsTransferInfo_mc.TransferCaps_tf.width - metrics.width) / 2.0) - 20.0;
				this.CapsTransferInfo_mc.TransferCapsIcon_mc.x = this.CapsTransferInfo_mc.TransferCaps_tf.x + whSpace;
			}

			this.UpdateButtonHints();
		}

		public function GetItemObject(param1: Boolean, param2: uint, param3: uint): Object
		{
			var _loc4_: * = undefined;
			var _loc5_: * = undefined;
			var _loc6_: * = undefined;
			var _loc8_: * = undefined;
			var _loc7_: * = null;
			if (param1)
			{
				_loc4_ = playerListArray;
			}
			else
			{
				_loc4_ = containerListArray;
			}
			for (_loc5_ in _loc4_)
			{
				if (_loc4_[_loc5_].handle == param2 && _loc4_[_loc5_].stackArray != undefined)
				{
					_loc8_ = 0;
					while (_loc8_ < _loc4_[_loc5_].stackArray.length)
					{
						if (_loc4_[_loc5_].stackArray[_loc8_] == param3)
						{
							_loc7_ = _loc4_[_loc5_];
							break;
						}
						_loc8_++;
					}
				}
				if (_loc7_ != null)
				{
					break;
				}
			}
			return _loc7_;
		}
	}
}