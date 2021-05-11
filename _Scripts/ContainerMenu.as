package
{
    import Components.ItemCard;
    import flash.display.InteractiveObject;
    import flash.display.LineScaleMode;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.ui.Keyboard;
    import Menu.ContainerMenu.*
	import Shared.AS3.BSButtonHintBar;
    import Shared.AS3.BSButtonHintData;
    import Shared.AS3.BSScrollingList;
	import Shared.AS3.Events.CustomEvent;
	import Shared.AS3.Events.PlatformChangeEvent;
    import Shared.AS3.IMenu;
	import Shared.AS3.LabelSelector;
	import Shared.AS3.QuantityMenu;
	import Shared.AS3.StyleSheet;
	import Shared.GlobalFunc;

    public class ContainerMenu extends IMenu
    {
		private static const MAX_INDEX = 12;
        private static const NUM_FILTERS:uint = 8;

        private static const CM_LOOT = 0;
        private static const CM_STEALING_FROM_CONTAINER = 1;
        private static const CM_PICKPOCKET = 2;
        private static const CM_TEAMMATE = 3;
        private static const CM_POWER_ARMOR = 4;
        private static const CM_JUNK_JET_RELOAD = 5;
        private static const CM_WORKBENCH = 6;

        public var ButtonHintBar_mc:BSButtonHintBar;
        public var ContainerInventory_mc:ContainerInventory;
        public var ContainerList_mc:ContainerList;
        public var PlayerInventory_mc:PlayerInventory;
		public var CategoryBar_mc:LabelSelector;
        public var ItemCard_mc:ItemCard;
        public var PickpocketInfo_mc:MovieClip;
        public var QuantityMenu_mc:QuantityMenu;
        public var PlayerHasJunk:Boolean = false;
        public var BGSCodeObj:Object;

		private var strContainerName:String = "Container";
		private var FilterFlags:Array;
        private var bCancelPressed:Boolean;

        private var PlayFocusSounds:Boolean = true;
        private var uiUpperBracketPlayerLineMaxX:uint;
        private var uiUpperBracketContainerLineMaxX:uint;
        private var uiMode:uint = 0;
        private var InspectingFeaturedItem:Boolean = false;
        private var BlockNextListFocusSound:Boolean = false;
        private var InitialValidation = true;

        protected var SwitchToPlayerButton:BSButtonHintData;
        protected var SwitchToContainerButton:BSButtonHintData;
        protected var AcceptButton:BSButtonHintData;
        protected var TakeAllButton:BSButtonHintData;
        protected var EquipOrStoreButton:BSButtonHintData;
        protected var SortButton:BSButtonHintData;
        protected var InspectButton:BSButtonHintData;
        protected var ExitButton:BSButtonHintData;
        protected var QuantityAcceptButton:BSButtonHintData;
        protected var QuantityCancelButton:BSButtonHintData;
        protected var MessageBoxIsActive = false;

        public function ContainerMenu()
        {
            this.SwitchToPlayerButton = new BSButtonHintData("$TransferPlayerLabel", "LT", "PSN_L2_Alt", "Xenon_L2_Alt", 1, this.SwitchToPlayerList);
            this.SwitchToContainerButton = new BSButtonHintData("$TransferContainerLabel", "RT", "PSN_R2_Alt", "Xenon_R2_Alt", 1, this.SwitchToContainerList);
            this.AcceptButton = new BSButtonHintData("$STORE", "Enter", "PSN_A", "Xenon_A", 1, this.onAcceptPressed);
            this.TakeAllButton = new BSButtonHintData("$TAKE ALL", "R", "PSN_X", "Xenon_X", 1, this.onTakeAllPressed);
            this.EquipOrStoreButton = new BSButtonHintData("$EQUIP", "T", "PSN_Y", "Xenon_Y", 1, this.onEquipOrStorePressed);
            this.SortButton = new BSButtonHintData("$SORT", "Q", "PSN_L3", "Xenon_L3", 1, this.onSortPressed);
            this.InspectButton = new BSButtonHintData("$INSPECT", "X", "PSN_R3", "Xenon_R3", 1, this.onInspectPressed);
            this.ExitButton = new BSButtonHintData("$EXIT", "TAB", "PSN_B", "Xenon_B", 1, this.onExitPressed);
            this.QuantityAcceptButton = new BSButtonHintData("$ACCEPT", "Enter", "PSN_A", "Xenon_A", 1, this.onQuantityAccepted);
            this.QuantityCancelButton = new BSButtonHintData("$CANCEL", "TAB", "PSN_B", "Xenon_B", 1, this.onQuantityCanceled);

            super();

            this.BGSCodeObj = new Object();

			StyleSheet.apply(this.PlayerInventory_mc.PlayerList_mc, false, Menu.ContainerMenu.PlayerListStyle);
			StyleSheet.apply(this.ContainerList_mc, false, Menu.ContainerMenu.ContainerListStyle);
            this.bCancelPressed = false;

            this.PopulateButtonBar();
			this.PopulateCategoryBar();
            stage.stageFocusRect = false;

            this.PlayerInventory_mc.PlayerSwitchButton_tf.visible = false;
            this.ContainerInventory_mc.ContainerSwitchButton_tf.visible = false;

            addEventListener(FocusEvent.FOCUS_OUT, this.onFocusChange);
            addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
            addEventListener(BSScrollingList.ITEM_PRESS, this.onItemPress);
            addEventListener(BSScrollingList.SELECTION_CHANGE, this.onSelectionChange);
			addEventListener(BSScrollingList.MOUSE_OVER, this.onListMouseOver);

            if (this.PickpocketInfo_mc != null)
            {
                this.PickpocketInfo_mc.Caption_tf.visible = false;
                this.PickpocketInfo_mc.Percent_tf.visible = false;
            }
			
			this.UpdateButtonHints();
        }

        public function get containerIsSelected():Boolean
        {
            return stage.focus == this.ContainerList_mc;
        }

        public function get selectedIndex():int
        {
            return !!stage.focus ? int((stage.focus as ItemList).selectedIndex) : -1;
        }

        public function set inspectingFeaturedItem(aValue:Boolean):*
        {
            this.InspectingFeaturedItem = aValue;
            if (aValue == false)
            {
                (stage.focus as ItemList).disableInput = false;
            }
        }

        public function set playFocusSounds(aValue:Boolean):*
        {
            this.PlayFocusSounds = aValue;
        }

        public function set playerHasJunk(aValue:Boolean):*
        {
            this.PlayerHasJunk = aValue;
            this.UpdateButtonHints();
        }

        protected function PopulateButtonBar():void
        {
            var buttonHintDataV:Vector.<BSButtonHintData> = new Vector.<BSButtonHintData>();
            buttonHintDataV.push(this.SwitchToPlayerButton);
            buttonHintDataV.push(this.SwitchToContainerButton);
            buttonHintDataV.push(this.AcceptButton);
            buttonHintDataV.push(this.TakeAllButton);
            if (this.uiMode != CM_POWER_ARMOR && this.uiMode != CM_JUNK_JET_RELOAD)
            {
                buttonHintDataV.push(this.EquipOrStoreButton);
            }
            buttonHintDataV.push(this.InspectButton);
            buttonHintDataV.push(this.ExitButton);
            buttonHintDataV.push(this.QuantityAcceptButton);
            buttonHintDataV.push(this.QuantityCancelButton);
            buttonHintDataV.push(this.SortButton);
            this.ButtonHintBar_mc.SetButtonHintData(buttonHintDataV);
        }

		public function PopulateCategoryBar():void
		{
			this.FilterFlags = new Array(0xFFFFFFFF, 0x2, 0x4, 0x8, 0x200, 0x400, 0x800, 0x10, 0x20, 0x40, 0x1000);

			this.CategoryBar_mc.Clear();
			this.CategoryBar_mc.maxVisible = MAX_INDEX + 1;
			this.CategoryBar_mc.AddLabel("$INVENTORY", 0, true);
			this.CategoryBar_mc.AddLabel("$InventoryCategoryWeapons", 1, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryApparel", 2, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryAid", 3, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryMisc", 4, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryJunk", 5, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryMods", 6, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryHolo", 7, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryNote", 8, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryKeys", 9, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryAmmo", 10, true);

            this.CategoryBar_mc.Finalize();
            this.CategoryBar_mc.SetSelection(0, true, false);
		}

        public function onIntroAnimComplete():*
        {
            this.BGSCodeObj.onIntroAnimComplete();
        }

        protected function get AcceptButtonText():String
        {
			var bContainerListIsFocus:* = stage.focus == this.ContainerList_mc;
			switch (this.uiMode)
			{
				case CM_STEALING_FROM_CONTAINER:
				case CM_PICKPOCKET:
					return !!bContainerListIsFocus ? "$STEAL" : "$PLACE";
				case CM_JUNK_JET_RELOAD:
					return !!bContainerListIsFocus ? "$UNLOAD" : "$LOAD";
				default:
					break;
			}

			return !!bContainerListIsFocus ? "$TAKE" : "$STORE";
        }

        protected function get TakeAllText():String
        {
            var bJunkJet:* = this.uiMode == CM_JUNK_JET_RELOAD;
            return !!bJunkJet ? "$UNLOAD ALL" : "$TAKE ALL";
        }

        protected function UpdateButtonHints():void
		{
			var bPlayerListIsFocus:Boolean = (stage.focus == this.PlayerInventory_mc.PlayerList);
			var bQuantityMenuIsActive:Boolean = (stage.focus == this.QuantityMenu_mc);
			var bModalMenuIsActive:Boolean = (bQuantityMenuIsActive || this.MessageBoxIsActive);
			var bIsController:Boolean = (uiPlatform != PlatformChangeEvent.PLATFORM_PC_KB_MOUSE);

			this.SwitchToPlayerButton.ButtonVisible = bIsController && !bPlayerListIsFocus && (this.PlayerInventory_mc.PlayerList_mc.itemsShown > 0);
			this.SwitchToContainerButton.ButtonVisible = bIsController && bPlayerListIsFocus && (this.ContainerList_mc.itemsShown > 0);
			this.EquipOrStoreButton.ButtonVisible = !bPlayerListIsFocus && (this.uiMode == CM_TEAMMATE);

			if (this.EquipOrStoreButton.ButtonVisible && !bModalMenuIsActive)
			{
				var index:int = (stage.focus as ItemList).selectedIndex;
				var inContainer:Boolean = stage.focus == this.ContainerList_mc;
				this.EquipOrStoreButton.ButtonVisible = this.BGSCodeObj.getSelectedItemEquippable(index, inContainer);
				this.EquipOrStoreButton.ButtonText = !!this.BGSCodeObj.getSelectedItemEquipped(index, inContainer) ? "$UNEQUIP" : "$EQUIP";
			}
			else if (this.uiMode == CM_WORKBENCH)
			{
				this.EquipOrStoreButton.ButtonVisible = true;
				this.EquipOrStoreButton.ButtonText = "$StoreAllJunk";
				this.EquipOrStoreButton.ButtonDisabled = !this.PlayerHasJunk;
			}

			this.QuantityAcceptButton.ButtonVisible = bQuantityMenuIsActive;
			this.QuantityCancelButton.ButtonVisible = bQuantityMenuIsActive;
			this.AcceptButton.ButtonVisible = !bModalMenuIsActive;
			this.TakeAllButton.ButtonVisible = !bModalMenuIsActive;
			this.EquipOrStoreButton.ButtonVisible = this.EquipOrStoreButton.ButtonVisible && !bModalMenuIsActive;
			this.ExitButton.ButtonVisible = !bModalMenuIsActive;
			this.InspectButton.ButtonVisible = !bModalMenuIsActive;
			this.SortButton.ButtonVisible = !bModalMenuIsActive;

			if (!bModalMenuIsActive)
			{
				var currentItemList:ItemList = stage.focus as ItemList;
				var bCurrentListIsEmpty:Boolean = !currentItemList || currentItemList.entryList.length == 0;
				this.AcceptButton.ButtonText = this.AcceptButtonText;
				this.AcceptButton.ButtonDisabled = bCurrentListIsEmpty;
				this.TakeAllButton.ButtonText = this.TakeAllText;
				this.TakeAllButton.ButtonDisabled = bCurrentListIsEmpty;
				this.InspectButton.ButtonDisabled = bCurrentListIsEmpty;
			}
		}

        public function SetContainerInfo(strName:String, auiMode:uint):*
        {
            this.uiMode = auiMode;
			this.strContainerName = strName.toUpperCase();
			this.UpdateHeaderText();
            this.SwitchToContainerButton.ButtonText = this.strContainerName;
        }

        public function get playerListArray():Array
        {
            return this.PlayerInventory_mc.PlayerList_mc.entryList;
        }

        public function get containerListArray():Array
        {
            return this.ContainerList_mc.entryList;
        }

        public function InvalidateLists():*
        {
            this.PlayerInventory_mc.PlayerList_mc.InvalidateData();
            this.ContainerList_mc.InvalidateData();
			
			if (stage.focus == null)
			{
				this.SwitchToContainerList(false);
			}
			
            this.UpdateItemDisplay(stage.focus as ItemList, false);
            this.ValidateListHighlight();
            this.UpdateButtonHints();
        }

		private function AreFiltersEmpty(aiFilter:int):Boolean
		{
			return (this.PlayerInventory_mc.PlayerList_mc.filterer.IsFilterEmpty(aiFilter) && this.ContainerList_mc.filterer.IsFilterEmpty(aiFilter));
		}

        private function ValidateListHighlight():*
        {
			this.CategoryBar_mc.SetSelectable(0, !AreFiltersEmpty(this.FilterFlags[0]));
			this.CategoryBar_mc.SetSelectable(1, !AreFiltersEmpty(this.FilterFlags[1]));
			this.CategoryBar_mc.SetSelectable(2, !AreFiltersEmpty(this.FilterFlags[2]));
			this.CategoryBar_mc.SetSelectable(3, !AreFiltersEmpty(this.FilterFlags[3]));
			this.CategoryBar_mc.SetSelectable(4, !AreFiltersEmpty(this.FilterFlags[4]));
			this.CategoryBar_mc.SetSelectable(5, !AreFiltersEmpty(this.FilterFlags[5]));
			this.CategoryBar_mc.SetSelectable(6, !AreFiltersEmpty(this.FilterFlags[6]));
			this.CategoryBar_mc.SetSelectable(7, !AreFiltersEmpty(this.FilterFlags[7]));
			this.CategoryBar_mc.SetSelectable(8, !AreFiltersEmpty(this.FilterFlags[8]));
			this.CategoryBar_mc.SetSelectable(9, !AreFiltersEmpty(this.FilterFlags[9]));
			this.CategoryBar_mc.SetSelectable(10, !AreFiltersEmpty(this.FilterFlags[10]));

            this.InitialValidation = false;
        }

        private function UpdateItemCard():*
        {
            var currEntry:Object = null;
            if (stage.focus is ItemList)
            {
                currEntry = (stage.focus as ItemList).selectedEntry;
                if (currEntry != null)
                {
                    this.ItemCard_mc.InfoObj = currEntry.ItemCardInfoList;
                    this.ItemCard_mc.onDataChange();
                }
            }
        }

        public function SwitchToContainerList(aPlaySound:Boolean = true):Boolean
        {
            var bres:Boolean = this.SwitchLists(this.PlayerInventory_mc.PlayerList_mc, this.ContainerList_mc);
            if (bres)
            {
                if (uiPlatform != PlatformChangeEvent.PLATFORM_PC_KB_MOUSE)
                {
                    this.PlayerInventory_mc.PlayerSwitchButton_tf.visible = true;
                }
                this.ContainerInventory_mc.ContainerSwitchButton_tf.visible = false;
                this.UpdateButtonHints();
                this.RepositionUpperBracketBars();
                if (aPlaySound)
                {
                    this.BGSCodeObj.PlaySound("UIBarterHorizontalRight");
                }
                this.BGSCodeObj.updateSortButtonLabel(this.CategoryBar_mc.selectedIndex);
            }
            return bres;
        }

		protected function SwitchToPlayerList(aPlaySound:Boolean = true):Boolean
        {
            var bres:Boolean = this.SwitchLists(this.ContainerList_mc, this.PlayerInventory_mc.PlayerList_mc);
            if (bres)
            {
                if (uiPlatform != PlatformChangeEvent.PLATFORM_PC_KB_MOUSE)
                {
                    this.ContainerInventory_mc.ContainerSwitchButton_tf.visible = true;
                }
                this.PlayerInventory_mc.PlayerSwitchButton_tf.visible = false;
                this.UpdateButtonHints();
                this.RepositionUpperBracketBars();
                if (aPlaySound)
                {
                    this.BGSCodeObj.PlaySound("UIBarterHorizontalLeft");
                }
                this.BGSCodeObj.updateSortButtonLabel(this.CategoryBar_mc.selectedIndex);
            }
            return bres;
        }
		
		private function SwitchLists(fromList:ItemList, toList:ItemList):Boolean
        {
            var bSuccess:Boolean = false;
            if (stage.focus != toList && toList.itemsShown > 0 && !this.QuantityMenu_mc.opened)
            {
                stage.focus = toList;
                if (fromList.selectedEntry == null)
                {
                    toList.selectedIndex = toList.GetEntryFromClipIndex(0);
                }
                else
                {
                    toList.selectedIndex = toList.GetEntryFromClipIndex(fromList.selectedEntry.clipIndex);
                }
                fromList.selectedIndex = -1;
                bsuccess = true;
            }
            return bSuccess;
        }

        protected function RepositionUpperBracketBars():*
        {
            var lines:Shape = null;

            for (var i:uint = 0; i < this.PlayerInventory_mc.numChildren; i++)
            {
                var child:* = this.PlayerInventory_mc.getChildAt(i);
                if (child.name == "lines")
                {
                    this.PlayerInventory_mc.removeChild(child);
                    break;
                }
            }

			for (var i:uint = 0; i < this.ContainerInventory_mc.numChildren; i++)
            {
                var child:* = this.ContainerInventory_mc.getChildAt(i);
                if (child.name == "lines")
                {
                    this.ContainerInventory_mc.removeChild(child);
                    break;
                }
            }

            lines = new Shape();
            lines.name = "lines";
            lines.graphics.lineStyle(2, 0xFFFFFF, 1.0, true, LineScaleMode.NONE);
            lines.graphics.moveTo(-3, 4);
            lines.graphics.lineTo(-3, 0);
            lines.graphics.lineTo(this.PlayerInventory_mc.PlayerListHeader.x - 5, 0);
            lines.graphics.moveTo(this.PlayerInventory_mc.PlayerListHeader.x + this.PlayerInventory_mc.PlayerListHeader.headerWidth, 0);
            lines.graphics.lineTo(this.PlayerInventory_mc.PlayerSwitchButton_tf.x, 0);
            lines.graphics.lineTo(this.PlayerInventory_mc.PlayerBracketBackground_mc.x + this.PlayerInventory_mc.PlayerBracketBackground_mc.width, 0);
            lines.graphics.lineTo(this.PlayerInventory_mc.PlayerBracketBackground_mc.x + this.PlayerInventory_mc.PlayerBracketBackground_mc.width, 4);
            lines.graphics.moveTo(-3, this.PlayerInventory_mc.PlayerBracketBackground_mc.y + this.PlayerInventory_mc.PlayerBracketBackground_mc.height - 4);
            lines.graphics.lineTo(-3, this.PlayerInventory_mc.PlayerBracketBackground_mc.y + this.PlayerInventory_mc.PlayerBracketBackground_mc.height);
            lines.graphics.lineTo(this.PlayerInventory_mc.PlayerBracketBackground_mc.x + this.PlayerInventory_mc.PlayerBracketBackground_mc.width, this.PlayerInventory_mc.PlayerBracketBackground_mc.y + this.PlayerInventory_mc.PlayerBracketBackground_mc.height);
            lines.graphics.lineTo(this.PlayerInventory_mc.PlayerBracketBackground_mc.x + this.PlayerInventory_mc.PlayerBracketBackground_mc.width, this.PlayerInventory_mc.PlayerBracketBackground_mc.y + this.PlayerInventory_mc.PlayerBracketBackground_mc.height - 4);
            this.PlayerInventory_mc.addChild(lines);

            lines = new Shape();
            lines.name = "lines";
            lines.graphics.lineStyle(2, 0xFFFFFF, 1.0, true, LineScaleMode.NONE);
            lines.graphics.moveTo(-3, 4);
            lines.graphics.lineTo(-3, 0);
            lines.graphics.lineTo(this.ContainerInventory_mc.ContainerListHeader.x - 5, 0);
            lines.graphics.moveTo(this.ContainerInventory_mc.ContainerListHeader.x + this.ContainerInventory_mc.ContainerListHeader.headerWidth, 0);
            lines.graphics.lineTo(this.ContainerInventory_mc.ContainerSwitchButton_tf.x, 0);
            lines.graphics.lineTo(this.ContainerInventory_mc.ContainerBracketBackground_mc.x + this.ContainerInventory_mc.ContainerBracketBackground_mc.width, 0);
            lines.graphics.lineTo(this.ContainerInventory_mc.ContainerBracketBackground_mc.x + this.ContainerInventory_mc.ContainerBracketBackground_mc.width, 4);
            lines.graphics.moveTo(-3, this.ContainerInventory_mc.ContainerBracketBackground_mc.y + this.ContainerInventory_mc.ContainerBracketBackground_mc.height - 4);
            lines.graphics.lineTo(-3, this.ContainerInventory_mc.ContainerBracketBackground_mc.y + this.ContainerInventory_mc.ContainerBracketBackground_mc.height);
            lines.graphics.lineTo(this.ContainerInventory_mc.ContainerBracketBackground_mc.x + this.ContainerInventory_mc.ContainerBracketBackground_mc.width, this.ContainerInventory_mc.ContainerBracketBackground_mc.y + this.ContainerInventory_mc.ContainerBracketBackground_mc.height);
            lines.graphics.lineTo(this.ContainerInventory_mc.ContainerBracketBackground_mc.x + this.ContainerInventory_mc.ContainerBracketBackground_mc.width, this.ContainerInventory_mc.ContainerBracketBackground_mc.y + this.ContainerInventory_mc.ContainerBracketBackground_mc.height - 4);
            this.ContainerInventory_mc.addChild(lines);
        }

        protected function OpenQuantityMenu(aiCount:int, aiItemValue:int = 0):*
        {
            this.BGSCodeObj.show3D(-1, false);
			addEventListener(QuantityMenu.QUANTITY_MODIFIED, this.onQuantityModified);
            this.QuantityMenu_mc.OpenMenu(aiCount, stage.focus, "", aiItemValue);
            stage.focus = this.QuantityMenu_mc;

			this.PlayerInventory_mc.PlayerList_mc.disableInput_Inspectable = true;
			this.PlayerInventory_mc.PlayerList_mc.disableSelection_Inspectable = true;
            this.ContainerList_mc.disableInput_Inspectable = true;
            this.ContainerList_mc.disableSelection_Inspectable = true;
            this.ItemCard_mc.visible = false;

            this.UpdateButtonHints();
        }

        protected function CloseQuantityMenu():*
        {
			removeEventListener(QuantityMenu.QUANTITY_MODIFIED, this.onQuantityModified);
			stage.focus = this.QuantityMenu_mc.prevFocus;
			this.QuantityMenu_mc.CloseMenu();

            this.PlayerInventory_mc.PlayerList_mc.disableInput_Inspectable = false;
            this.PlayerInventory_mc.PlayerList_mc.disableSelection_Inspectable = false;
            this.ContainerList_mc.disableInput_Inspectable = false;
            this.ContainerList_mc.disableSelection_Inspectable = false;
            this.UpdateItemDisplay(stage.focus as ItemList, false);
			this.ItemCard_mc.visible = true;

            this.UpdateButtonHints();
        }

        private function onMouseOverPlayerHeader(mouseEvent:MouseEvent):*
        {
            if (!this.QuantityMenu_mc.opened)
            {
                if (stage.focus != this.PlayerInventory_mc.PlayerList_mc)
                {
                    stage.focus = this.PlayerInventory_mc.PlayerList_mc;
                    this.PlayerInventory_mc.PlayerList_mc.selectedIndex = 0;
                    this.ContainerList_mc.selectedIndex = -1;
                    this.UpdateButtonHints();
                    this.RepositionUpperBracketBars();
                    this.BGSCodeObj.updateSortButtonLabel(this.CategoryBar_mc.selectedIndex);
                }
            }
        }

        private function onMouseOverContainerHeader(mouseEvent:MouseEvent):*
        {
            if (!this.QuantityMenu_mc.opened)
            {
                if (stage.focus != this.ContainerList_mc)
                {
                    stage.focus = this.ContainerList_mc;
                    this.ContainerList_mc.selectedIndex = 0;
                    this.PlayerInventory_mc.PlayerList_mc.selectedIndex = -1;
                    this.UpdateButtonHints();
                    this.RepositionUpperBracketBars();
                    this.BGSCodeObj.updateSortButtonLabel(this.CategoryBar_mc.selectedIndex);
                }
            }
        }

        private function onListMouseOver(event:Event):*
        {
            if (!this.QuantityMenu_mc.opened)
            {
                if (event.target == this.PlayerInventory_mc.PlayerList_mc && stage.focus != this.PlayerInventory_mc.PlayerList_mc)
                {
                    stage.focus = this.PlayerInventory_mc.PlayerList_mc;
                    this.ContainerList_mc.selectedIndex = -1;
                    this.UpdateButtonHints();
                    this.RepositionUpperBracketBars();
                    this.BGSCodeObj.updateSortButtonLabel(this.CategoryBar_mc.selectedIndex);
                }
                else if (event.target == this.ContainerList_mc && stage.focus != this.ContainerList_mc)
                {
                    stage.focus = this.ContainerList_mc;
                    this.PlayerInventory_mc.PlayerList_mc.selectedIndex = -1;
                    this.UpdateButtonHints();
                    this.RepositionUpperBracketBars();
                    this.BGSCodeObj.updateSortButtonLabel(this.CategoryBar_mc.selectedIndex);
                }
            }
        }

        private function onFocusChange(event:FocusEvent):*
        {
            if (event.relatedObject != this.PlayerInventory_mc.PlayerList_mc && event.relatedObject != this.ContainerList_mc && event.relatedObject != this.QuantityMenu_mc)
            {
                stage.focus = event.target as InteractiveObject;
            }
        }

        private function onItemPress(event:Event):*
        {
            var iItemCount:int = 0;
            var iItemValue:* = undefined;
            if (visible)
            {
                if (this.InspectingFeaturedItem)
                {
                    this.InspectingFeaturedItem = false;
                }
                else
                {
                    iItemCount = (event.target as ItemList).selectedEntry.count;
                    if ((event.target as ItemList).selectedEntry.suppressQuantityMenu == true)
                    {
                        this.BGSCodeObj.transferItem((event.target as ItemList).selectedIndex, iItemCount, event.target == this.ContainerList_mc);
                        this.BlockNextListFocusSound = true;
                        this.onTransferItem(stage.focus == this.PlayerInventory_mc.PlayerList_mc ? this.ContainerList_mc : this.PlayerInventory_mc.PlayerList_mc);
                    }
                    else if (iItemCount <= QuantityMenu.INV_MAX_NUM_BEFORE_QUANTITY_MENU)
                    {
                        this.BGSCodeObj.transferItem((event.target as ItemList).selectedIndex, 1, event.target == this.ContainerList_mc);
                        this.BlockNextListFocusSound = true;
                        this.onTransferItem(stage.focus == this.PlayerInventory_mc.PlayerList_mc ? this.ContainerList_mc : this.PlayerInventory_mc.PlayerList_mc);
                    }
                    else
                    {
                        iItemValue = this.BGSCodeObj.getItemValue((event.target as ItemList).selectedIndex, event.target == this.ContainerList_mc);
                        this.OpenQuantityMenu(iItemCount, iItemValue);
                    }
                }
            }
        }

        public function onAcceptPressed():*
        {
			if (this.QuantityAcceptButton.ButtonEnabled && this.QuantityAcceptButton.ButtonVisible)
			{
				if (stage.focus == this.QuantityMenu_mc)
				{
					this.onQuantityAccepted();
					return;
				}
			}
			
			if (this.AcceptButton.ButtonEnabled && this.AcceptButton.ButtonVisible)
			{
				(stage.focus as ItemList).dispatchEvent(new Event(BSScrollingList.ITEM_PRESS, true, true));
			}
        }
		
		public function onTakeAllPressed():*
        {
			if (this.TakeAllButton.ButtonEnabled && this.TakeAllButton.ButtonVisible)
			{
				this.BGSCodeObj.takeAllItems();
			}
        }
		
		public function onEquipOrStorePressed():*
        {
			if (this.EquipOrStoreButton.ButtonEnabled && this.EquipOrStoreButton.ButtonVisible)
			{
				this.BGSCodeObj.sendYButton();
			}
        }
		
		public function onSortPressed():*
        {
            if (this.SortButton.ButtonEnabled && this.SortButton.ButtonVisible)
            {
				this.BGSCodeObj.sortItems(this.CategoryBar_mc.selectedIndex, true);
				this.BGSCodeObj.updateSortButtonLabel(this.CategoryBar_mc.selectedIndex);
            }
        }
		
		public function onInspectPressed():*
        {
            if (this.InspectButton.ButtonEnabled && this.InspectButton.ButtonVisible)
            {
                (stage.focus as ItemList).disableInput = true;
                this.BGSCodeObj.inspectItem();
            }
        }
		
		public function onExitPressed():*
        {
			if (this.QuantityCancelButton.ButtonEnabled && this.QuantityCancelButton.ButtonVisible)
			{
				if (stage.focus == this.QuantityMenu_mc)
				{
					this.onQuantityCanceled();
					return;
				}
			}
			
			if (this.ExitButton.ButtonEnabled && this.ExitButton.ButtonVisible)
            {
				if (this.bCancelPressed)
				{
					this.BGSCodeObj.exitMenu();
				}
			}
			
			this.bCancelPressed = false;
        }

		private function onPrevCategory():*
        {
			this.UpdateItemFilter(false);
        }

        private function onNextCategory():*
        {
            this.UpdateItemFilter(true);
        }
		
        public function onQuantityAccepted():*
        {
			this.CloseQuantityMenu();
            this.BGSCodeObj.transferItem((stage.focus as ItemList).selectedIndex, this.QuantityMenu_mc.quantity, stage.focus == this.ContainerList_mc);
            this.onTransferItem(stage.focus == this.PlayerInventory_mc.PlayerList_mc ? this.ContainerList_mc : this.PlayerInventory_mc.PlayerList_mc);
        }

        public function onQuantityCanceled():*
        {
            this.CloseQuantityMenu();
        }

        public function onEndInspect():*
        {
            (stage.focus as ItemList).disableInput = false;
        }

        private function onSelectionChange(event:Event):*
        {
            this.UpdateItemDisplay(stage.focus as ItemList, !this.BlockNextListFocusSound);
            this.BlockNextListFocusSound = false;
            this.UpdateButtonHints();
        }

        private function onTransferItem(toList:Object):*
        {
            if (toList == this.ContainerList_mc && stage.focus == this.PlayerInventory_mc.PlayerList_mc)
            {
                if (this.ContainerInventory_mc.ContainerSwitchButton_tf.visible == false && uiPlatform != PlatformChangeEvent.PLATFORM_PC_KB_MOUSE)
                {
                    this.ContainerInventory_mc.ContainerSwitchButton_tf.visible = true;
                    this.UpdateButtonHints();
                    this.RepositionUpperBracketBars();
                }
            }
            else if (toList == this.PlayerInventory_mc.PlayerList_mc && stage.focus == this.ContainerList_mc)
            {
                if (this.PlayerInventory_mc.PlayerSwitchButton_tf.visible == false && uiPlatform != PlatformChangeEvent.PLATFORM_PC_KB_MOUSE)
                {
                    this.PlayerInventory_mc.PlayerSwitchButton_tf.visible = true;
                    this.UpdateButtonHints();
                    this.RepositionUpperBracketBars();
                }
            }
        }

        private function UpdateItemDisplay(TargetItemList:ItemList, aPlaySound:Boolean = true):*
        {
            this.UpdateItemCard();
            if (TargetItemList != null)
            {
                this.BGSCodeObj.show3D(TargetItemList.selectedIndex, TargetItemList == this.ContainerList_mc);
                this.BGSCodeObj.updateItemPickpocketInfo(TargetItemList.selectedIndex, TargetItemList == this.ContainerList_mc, -1);
                if (this.PlayFocusSounds && aPlaySound)
                {
                    this.BGSCodeObj.PlaySound("UIMenuFocus");
                }
            }
        }

        public function onKeyUp(event:KeyboardEvent):void
        {
            if (visible && this.uiMode != CM_JUNK_JET_RELOAD && !event.isDefaultPrevented() && !this.QuantityMenu_mc.opened)
            {
                if (event.keyCode == Keyboard.LEFT)
                {
                    this.UpdateItemFilter(false);
                }
                else if (event.keyCode == Keyboard.RIGHT)
                {
					this.UpdateItemFilter(true);
                }
            }
        }

        private function UpdateItemFilter(doNext:Boolean):*
        {
			var uiOldFilter = this.CategoryBar_mc.selectedIndex;
			if (doNext)
			{
				this.CategoryBar_mc.SelectNext();
			}
			else
			{
				this.CategoryBar_mc.SelectPrevious();
			}

			if (this.CategoryBar_mc.selectedIndex != uiOldFilter)
			{
				this.PlayerInventory_mc.PlayerList_mc.filterer.itemFilter = this.FilterFlags[this.CategoryBar_mc.selectedIndex];
				this.ContainerList_mc.filterer.itemFilter = this.FilterFlags[this.CategoryBar_mc.selectedIndex];

				this.BGSCodeObj.PlaySound(doNext ? "UIBarterHorizontalRight" : "UIBarterHorizontalLeft");
				this.BGSCodeObj.sortItems(this.CategoryBar_mc.selectedIndex, false);
				this.BGSCodeObj.updateSortButtonLabel(this.CategoryBar_mc.selectedIndex);
			}
        }

        private function UpdateHeaderText():*
        {
            this.PlayerInventory_mc.PlayerListHeader.headerText = "$INVENTORYMine";
            this.ContainerInventory_mc.ContainerListHeader.headerText = this.strContainerName;
            this.RepositionUpperBracketBars();
        }

        public function ProcessUserEvent(a_event:String, a_keyPressed:Boolean):Boolean
        {
            if (!a_keyPressed)
            {
                switch (a_event)
                {
                    case "Cancel":
                        this.onExitPressed();
                        return true;

                    case "Accept":
						this.onAcceptPressed();
                        return true;

                    case "Prev":
                        this.onPrevCategory();
                        return true;

                    case "Next":
                        this.onNextCategory();
                        return true;

                    case "LTrigger":
						if (stage.focus == this.QuantityMenu_mc)
						{
							return this.QuantityMenu_mc.ProcessUserEvent(a_event, a_keyPressed);
						}
						this.SwitchToPlayerList();
                        return true;

                    case "RTrigger":
						if (stage.focus == this.QuantityMenu_mc)
						{
							return this.QuantityMenu_mc.ProcessUserEvent(a_event, a_keyPressed);
						}
						this.SwitchToContainerList();
                        return true;

                    case "Sort":
						this.onSortPressed();
                        return true;

                    case "TakeAll":
						this.onTakeAllPressed();
                        return true;

                    case "Equip":
						this.onEquipOrStorePressed();
                        return true;

                    case "Inspect":
						this.onInspectPressed();
                        return true;
                }
            }
            else
            {
                switch (a_event)
                {
                    case "Cancel":
                        this.bCancelPressed = true;
                        break;
                }
            }

            return false;
        }

        public function UpdateEncumbranceAndCaps(aContainer:Boolean, aCurrWeight:uint, aMaxWeight:uint, aCaps:uint, aIncomingCaps:int):*
        {
            var incomingCapsString:* = "";
            if (aIncomingCaps)
            {
                incomingCapsString = " (";
                if (aIncomingCaps > 0)
                {
                    incomingCapsString = incomingCapsString + "+";
                }
                incomingCapsString = incomingCapsString + aIncomingCaps.toString();
                incomingCapsString = incomingCapsString + ")";
            }
            if (aContainer)
            {
                if (this.ContainerInventory_mc.ContainerCaps_tf != null)
                {
                    GlobalFunc.SetText(this.ContainerInventory_mc.ContainerCaps_tf, aCaps.toString() + incomingCapsString, false);
                }
            }
            else
            {
                if (this.PlayerInventory_mc.PlayerWeight_tf != null)
                {
                    GlobalFunc.SetText(this.PlayerInventory_mc.PlayerWeight_tf, aCurrWeight.toString() + "/" + aMaxWeight.toString(), false);
                }
                if (this.PlayerInventory_mc.PlayerCaps_tf != null)
                {
                    GlobalFunc.SetText(this.PlayerInventory_mc.PlayerCaps_tf, aCaps.toString() + incomingCapsString, false);
                }
            }
        }

        public function UpdatePickpocketInfo(aShow:Boolean, aTaking:Boolean, aSuccessPercent:uint):*
        {
            var totalTextWidth:* = undefined;
            this.PickpocketInfo_mc.Caption_tf.visible = aShow;
            this.PickpocketInfo_mc.Percent_tf.visible = aShow;
            if (aShow)
            {
                GlobalFunc.SetText(this.PickpocketInfo_mc.Percent_tf, aSuccessPercent.toString() + "% ", false);
                GlobalFunc.SetText(this.PickpocketInfo_mc.Caption_tf, !!aTaking ? "$TO STEAL" : "$TO PLACE", false);
                this.PickpocketInfo_mc.Caption_tf.x = this.PickpocketInfo_mc.Percent_tf.textWidth;
                totalTextWidth = this.PickpocketInfo_mc.Caption_tf.textWidth + this.PickpocketInfo_mc.Percent_tf.textWidth;
                this.PickpocketInfo_mc.x = (stage.stageWidth - totalTextWidth) / 2;
            }
        }

        override public function SetPlatform(auiPlatform:uint, abPS3Switch:Boolean):*
        {
            super.SetPlatform(auiPlatform, abPS3Switch);
            GlobalFunc.SetText(this.PlayerInventory_mc.PlayerSwitchButton_tf, uiPlatform == PlatformChangeEvent.PLATFORM_PS4 ? "y" : "Y", false);
            GlobalFunc.SetText(this.ContainerInventory_mc.ContainerSwitchButton_tf, uiPlatform == PlatformChangeEvent.PLATFORM_PS4 ? "x" : "X", false);
        }

        public function onQuantityModified(aEvent:Event):*
        {
            var itemList:BSScrollingList = this.QuantityMenu_mc.prevFocus as BSScrollingList;
            var count:int = (aEvent as CustomEvent).params as int;
            this.BGSCodeObj.updateItemPickpocketInfo(itemList.selectedIndex, itemList == this.ContainerList_mc, count);
            // this.BGSCodeObj.PlaySound("UIMenuQuantity");
        }

        public function onToggleEquip():*
        {
            var index:int = 0;
            var inContainer:* = false;
            if (this.EquipOrStoreButton.ButtonVisible)
            {
                index = (stage.focus as ItemList).selectedIndex;
                inContainer = stage.focus == this.ContainerList_mc;
                this.BGSCodeObj.toggleSelectedItemEquipped(index, inContainer);
            }
        }

        public function set sortButtonLabel(aStr:String):*
        {
            this.SortButton.ButtonText = aStr;
        }

        public function set messageBoxIsActive(aActive:Boolean):*
        {
            this.MessageBoxIsActive = aActive;
            this.UpdateButtonHints();
        }
    }
}
