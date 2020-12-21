package
{
    import Components.ItemCard;
    import Shared.AS3.BSButtonHintBar;
    import Shared.AS3.BSButtonHintData;
    import Shared.AS3.BSScrollingList;
    import Shared.AS3.QuantityMenu;
    import Shared.CustomEvent;
    import Shared.GlobalFunc;
    import Shared.IMenu;
    import Shared.PlatformChangeEvent;
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

    public class ContainerMenu extends IMenu
    {
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
        public var ItemCard_mc:ItemCard;
        public var PickpocketInfo_mc:MovieClip;
        public var QuantityMenu_mc:MovieClip;
        public var PlayerHasJunk:Boolean = false;
        public var BGSCodeObj:Object;

        private var PlayFocusSounds:Boolean = true;
        private var FilterInfoA:Array;
        private var uiPlayerFilterIndex:uint;
        private var uiContainerFilterIndex:uint;
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
            this.AcceptButton = new BSButtonHintData("$STORE", "Enter", "PSN_A", "Xenon_A", 1, this.onAccept);
            this.TakeAllButton = new BSButtonHintData("$TAKE ALL", "R", "PSN_X", "Xenon_X", 1, this.onTakeAll);
            this.EquipOrStoreButton = new BSButtonHintData("$EQUIP", "T", "PSN_Y", "Xenon_Y", 1, this.onEquipOrStore);
            this.SortButton = new BSButtonHintData("$SORT", "Z", "PSN_L3", "Xenon_L3", 1, this.requestSort);
            this.InspectButton = new BSButtonHintData("$INSPECT", "X", "PSN_R3", "Xenon_R3", 1, this.onInspect);
            this.ExitButton = new BSButtonHintData("$EXIT", "TAB", "PSN_B", "Xenon_B", 1, this.onExitMenu);
            this.QuantityAcceptButton = new BSButtonHintData("$ACCEPT", "E", "PSN_A", "Xenon_A", 1, this.onQuantityAccepted);
            this.QuantityCancelButton = new BSButtonHintData("$CANCEL", "TAB", "PSN_B", "Xenon_B", 1, this.onQuantityCanceled);

            super();

            this.BGSCodeObj = new Object();
            this.PopulateButtonBar();
            stage.stageFocusRect = false;

            this.PlayerInventory_mc.PlayerSwitchButton_tf.visible = false;
            this.ContainerInventory_mc.ContainerSwitchButton_tf.visible = false;

            this.FilterInfoA = new Array();
            this.FilterInfoA.push({"text": "$INVENTORY",
                    "flag": 4294967295});
            this.FilterInfoA.push({"text": "$InventoryCategoryWeapons",
                    "flag": 1 << 1});
            this.FilterInfoA.push({"text": "$InventoryCategoryApparel",
                    "flag": 1 << 2});
            this.FilterInfoA.push({"text": "$InventoryCategoryAid",
                    "flag": 1 << 3});
            this.FilterInfoA.push({"text": "$InventoryCategoryMisc",
                    "flag": 1 << 9});
            this.FilterInfoA.push({"text": "$InventoryCategoryJunk",
                    "flag": 1 << 10});
            this.FilterInfoA.push({"text": "$InventoryCategoryMods",
                    "flag": 1 << 11});
            this.FilterInfoA.push({"text": "$InventoryCategoryAmmo",
                    "flag": 1 << 12});

            this.uiPlayerFilterIndex = 0;
            this.uiContainerFilterIndex = 0;
            addEventListener(FocusEvent.FOCUS_OUT, this.onFocusChange);
            addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
            addEventListener(BSScrollingList.ITEM_PRESS, this.onItemPress);
            addEventListener(BSScrollingList.SELECTION_CHANGE, this.onSelectionChange);
            addEventListener(ItemList.MOUSE_OVER, this.onListMouseOver);
            addEventListener(QuantityMenu.CONFIRM, this.onQuantityConfirm);

            this.SwitchToContainerList(false);
            this.UpdateButtonHints();
            this.UpdateHeaderText(this.PlayerInventory_mc.PlayerList_mc);
            this.UpdateHeaderText(this.ContainerList_mc);

            if (this.PickpocketInfo_mc != null)
            {
                this.PickpocketInfo_mc.Caption_tf.visible = false;
                this.PickpocketInfo_mc.Percent_tf.visible = false;
            }

            this.__setProp_ContainerList_mc_MenuObj_ContainerList_0();
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

        public function onIntroAnimComplete():*
        {
            this.BGSCodeObj.onIntroAnimComplete();
        }

        protected function get AcceptButtonText():String
        {
            var bjunkJet:* = this.uiMode == CM_JUNK_JET_RELOAD;
            var bcontainerListIsFocus:* = stage.focus == this.ContainerList_mc;
            if (bjunkJet)
            {
                return !!bcontainerListIsFocus ? "$UNLOAD" : "$LOAD";
            }
            return !!bcontainerListIsFocus ? this.uiMode == CM_PICKPOCKET || this.uiMode == CM_STEALING_FROM_CONTAINER ? "$STEAL" : "$TAKE" : this.uiMode == CM_PICKPOCKET ? "$PLACE" : "$STORE";
        }

        protected function get TakeAllText():String
        {
            var bjunkJet:* = this.uiMode == CM_JUNK_JET_RELOAD;
            return !!bjunkJet ? "$UNLOAD ALL" : "$TAKE ALL";
        }

        protected function UpdateButtonHints():void
        {
            var index:int = 0;
            var inContainer:* = false;
            var currentItemList:ItemList = null;
            var bcurrentListIsEmpty:* = undefined;
            var quantityMenuIsActive:* = stage.focus == this.QuantityMenu_mc;
            var modalMenuIsActive:Boolean = quantityMenuIsActive || this.MessageBoxIsActive;
            this.SwitchToPlayerButton.ButtonVisible = stage.focus == this.ContainerList_mc && this.PlayerInventory_mc.PlayerList_mc.itemsShown && uiPlatform != PlatformChangeEvent.PLATFORM_PC_KB_MOUSE;
            this.SwitchToContainerButton.ButtonVisible = stage.focus == this.PlayerInventory_mc.PlayerList_mc && this.ContainerList_mc.itemsShown && uiPlatform != PlatformChangeEvent.PLATFORM_PC_KB_MOUSE;
            this.EquipOrStoreButton.ButtonVisible = this.uiMode == CM_TEAMMATE && stage.focus != this.PlayerInventory_mc.PlayerList_mc;
            if (this.EquipOrStoreButton.ButtonVisible && !modalMenuIsActive)
            {
                index = (stage.focus as ItemList).selectedIndex;
                inContainer = stage.focus == this.ContainerList_mc;
                this.EquipOrStoreButton.ButtonVisible = this.BGSCodeObj.getSelectedItemEquippable(index, inContainer);
                this.EquipOrStoreButton.ButtonText = !!this.BGSCodeObj.getSelectedItemEquipped(index, inContainer) ? "$UNEQUIP" : "$EQUIP";
            }
            else if (this.uiMode == CM_WORKBENCH)
            {
                this.EquipOrStoreButton.ButtonVisible = true;
                this.EquipOrStoreButton.ButtonText = "$StoreAllJunk";
                this.EquipOrStoreButton.ButtonDisabled = !this.PlayerHasJunk;
            }
            this.QuantityAcceptButton.ButtonVisible = quantityMenuIsActive;
            this.QuantityCancelButton.ButtonVisible = quantityMenuIsActive;
            this.AcceptButton.ButtonVisible = !modalMenuIsActive;
            this.TakeAllButton.ButtonVisible = !modalMenuIsActive;
            this.EquipOrStoreButton.ButtonVisible = this.EquipOrStoreButton.ButtonVisible && !modalMenuIsActive;
            this.ExitButton.ButtonVisible = !modalMenuIsActive;
            this.InspectButton.ButtonVisible = !modalMenuIsActive;
            this.SortButton.ButtonVisible = !modalMenuIsActive;
            if (!modalMenuIsActive)
            {
                currentItemList = stage.focus as ItemList;
                bcurrentListIsEmpty = !currentItemList || currentItemList.entryList.length == 0;
                this.AcceptButton.ButtonText = this.AcceptButtonText;
                this.AcceptButton.ButtonDisabled = bcurrentListIsEmpty;
                this.TakeAllButton.ButtonText = this.TakeAllText;
                this.TakeAllButton.ButtonDisabled = bcurrentListIsEmpty;
                this.InspectButton.ButtonDisabled = bcurrentListIsEmpty;
            }
        }

        public function SetContainerInfo(strName:String, auiMode:uint):*
        {
            this.uiMode = auiMode;
            this.FilterInfoA[0].containerText = strName.toUpperCase();
            this.UpdateHeaderText(this.ContainerList_mc);
            this.SwitchToContainerButton.ButtonText = this.FilterInfoA[this.uiContainerFilterIndex].containerText.toUpperCase();
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
            this.UpdateItemDisplay(stage.focus as ItemList, false);
            this.ValidateListHighlight();
            if (this.PlayerInventory_mc.PlayerListHeader.headerText.length == 0)
            {
                this.UpdateHeaderText(this.PlayerInventory_mc.PlayerList_mc);
                this.UpdateHeaderText(this.ContainerList_mc);
            }
            this.UpdateButtonHints();
        }

        private function ValidateListHighlight():*
        {
            var itemList:ItemList = null;
            if (this.PlayerInventory_mc.PlayerList_mc.itemsShown == 0 && this.ContainerList_mc.itemsShown == 0)
            {
                this.PlayerInventory_mc.PlayerList_mc.selectedIndex = -1;
                this.ContainerList_mc.selectedIndex = -1;
                this.PlayerInventory_mc.PlayerSwitchButton_tf.visible = false;
                this.ContainerInventory_mc.ContainerSwitchButton_tf.visible = false;
            }
            else if (this.ContainerList_mc.itemsShown == 0 && stage.focus == this.ContainerList_mc || this.PlayerInventory_mc.PlayerList_mc.itemsShown == 0 && stage.focus == this.PlayerInventory_mc.PlayerList_mc)
            {
                itemList = stage.focus as ItemList;
                if (itemList.entryList.length > 0)
                {
                    this.changeItemFilter(itemList, 1);
                }
                else
                {
                    if (itemList == this.ContainerList_mc)
                    {
                        this.uiContainerFilterIndex = 0;
                        this.SwitchToPlayerList(!this.InitialValidation);
                        this.ContainerInventory_mc.ContainerSwitchButton_tf.visible = false;
                    }
                    else
                    {
                        this.uiPlayerFilterIndex = 0;
                        this.SwitchToContainerList(!this.InitialValidation);
                        this.PlayerInventory_mc.PlayerSwitchButton_tf.visible = false;
                    }
                    itemList.filterer.itemFilter = this.FilterInfoA[0].flag;
                    this.UpdateHeaderText(itemList);
                }
            }
            else if (stage.focus == null)
            {
                if (this.ContainerList_mc.itemsShown == 0)
                {
                    this.SwitchToPlayerList(!this.InitialValidation);
                }
                else
                {
                    this.SwitchToContainerList(!this.InitialValidation);
                }
            }
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
                this.BGSCodeObj.updateSortButtonLabel(true, this.uiContainerFilterIndex);
            }
            return bres;
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
                this.BGSCodeObj.updateSortButtonLabel(false, this.uiPlayerFilterIndex);
            }
            return bres;
        }

        protected function OpenQuantityMenu(aiCount:int, aiItemValue:int = 0):*
        {
            this.BGSCodeObj.show3D(-1, false);
            this.QuantityMenu_mc.OpenMenu(aiCount, stage.focus, "", aiItemValue);
            addEventListener(QuantityMenu.QUANTITY_CHANGED, this.onQuantityModified);
            stage.focus = this.QuantityMenu_mc;
            this.PlayerInventory_mc.PlayerList_mc.disableInput = true;
            this.PlayerInventory_mc.PlayerList_mc.disableSelection = true;
            this.ContainerList_mc.disableInput = true;
            this.ContainerList_mc.disableSelection = true;
            this.ItemCard_mc.visible = false;
            this.UpdateButtonHints();
        }

        protected function CloseQuantityMenu():*
        {
            this.PlayerInventory_mc.PlayerList_mc.disableInput = false;
            this.PlayerInventory_mc.PlayerList_mc.disableSelection = false;
            this.ContainerList_mc.disableInput = false;
            this.ContainerList_mc.disableSelection = false;
            stage.focus = this.QuantityMenu_mc.prevFocus;
            this.QuantityMenu_mc.CloseMenu();
            removeEventListener(QuantityMenu.QUANTITY_CHANGED, this.onQuantityModified);
            this.UpdateItemDisplay(stage.focus as ItemList, false);
            this.ItemCard_mc.visible = true;
            this.UpdateButtonHints();
        }

        private function SwitchLists(fromList:ItemList, toList:ItemList):Boolean
        {
            var bsuccess:Boolean = false;
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
            return bsuccess;
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
                    this.BGSCodeObj.updateSortButtonLabel(false, this.uiPlayerFilterIndex);
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
                    this.BGSCodeObj.updateSortButtonLabel(true, this.uiContainerFilterIndex);
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
                    this.BGSCodeObj.updateSortButtonLabel(false, this.uiPlayerFilterIndex);
                }
                else if (event.target == this.ContainerList_mc && stage.focus != this.ContainerList_mc)
                {
                    stage.focus = this.ContainerList_mc;
                    this.PlayerInventory_mc.PlayerList_mc.selectedIndex = -1;
                    this.UpdateButtonHints();
                    this.RepositionUpperBracketBars();
                    this.BGSCodeObj.updateSortButtonLabel(true, this.uiContainerFilterIndex);
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
            var iitemCount:int = 0;
            var iitemValue:* = undefined;
            if (visible)
            {
                if (this.InspectingFeaturedItem)
                {
                    this.InspectingFeaturedItem = false;
                }
                else
                {
                    iitemCount = (event.target as ItemList).selectedEntry.count;
                    if ((event.target as ItemList).selectedEntry.suppressQuantityMenu == true)
                    {
                        this.BGSCodeObj.transferItem((event.target as ItemList).selectedIndex, iitemCount, event.target == this.ContainerList_mc);
                        this.BlockNextListFocusSound = true;
                        this.onTransferItem(stage.focus == this.PlayerInventory_mc.PlayerList_mc ? this.ContainerList_mc : this.PlayerInventory_mc.PlayerList_mc);
                    }
                    else if (iitemCount <= QuantityMenu.INV_MAX_NUM_BEFORE_QUANTITY_MENU)
                    {
                        this.BGSCodeObj.transferItem((event.target as ItemList).selectedIndex, 1, event.target == this.ContainerList_mc);
                        this.BlockNextListFocusSound = true;
                        this.onTransferItem(stage.focus == this.PlayerInventory_mc.PlayerList_mc ? this.ContainerList_mc : this.PlayerInventory_mc.PlayerList_mc);
                    }
                    else
                    {
                        iitemValue = this.BGSCodeObj.getItemValue((event.target as ItemList).selectedIndex, event.target == this.ContainerList_mc);
                        this.OpenQuantityMenu(iitemCount, iitemValue);
                    }
                }
            }
        }

        public function onQuantityConfirm(event:Event):*
        {
            this.CloseQuantityMenu();
            this.BGSCodeObj.transferItem((stage.focus as ItemList).selectedIndex, this.QuantityMenu_mc.quantity, stage.focus == this.ContainerList_mc);
            this.onTransferItem(stage.focus == this.PlayerInventory_mc.PlayerList_mc ? this.ContainerList_mc : this.PlayerInventory_mc.PlayerList_mc);
        }

        public function onAccept():*
        {
            (stage.focus as ItemList).dispatchEvent(new Event(BSScrollingList.ITEM_PRESS, true, true));
        }

        public function onQuantityAccepted():*
        {
            dispatchEvent(new Event(QuantityMenu.CONFIRM, true, true));
        }

        public function onTakeAll():*
        {
            this.BGSCodeObj.takeAllItems();
        }

        public function onEquipOrStore():*
        {
            this.BGSCodeObj.sendYButton();
        }

        public function onExitMenu():*
        {
            this.BGSCodeObj.exitMenu();
        }

        public function onQuantityCanceled():*
        {
            this.CloseQuantityMenu();
        }

        public function onInspect():*
        {
            if (this.InspectButton.ButtonVisible)
            {
                (stage.focus as ItemList).disableInput = true;
                this.BGSCodeObj.inspectItem();
            }
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
                    this.changeItemFilter(stage.focus as ItemList, -1);
                }
                else if (event.keyCode == Keyboard.RIGHT)
                {
                    this.changeItemFilter(stage.focus as ItemList, 1);
                }
            }
        }

        private function changeItemFilter(arItemList:ItemList, aiDelta:int):*
        {
            var uiprevFilter:uint = arItemList == this.PlayerInventory_mc.PlayerList_mc ? uint(this.uiPlayerFilterIndex) : uint(this.uiContainerFilterIndex);
            var uinewFilter:uint = uiprevFilter;
            do
            {
                if (uinewFilter == 0 && aiDelta < 0)
                {
                    uinewFilter = NUM_FILTERS - 1;
                }
                else if (uinewFilter == NUM_FILTERS - 1 && aiDelta > 0)
                {
                    uinewFilter = 0;
                }
                else
                {
                    uinewFilter = uinewFilter + aiDelta;
                }
            } while (uinewFilter != uiprevFilter && arItemList.filterer.IsFilterEmpty(this.FilterInfoA[uinewFilter].flag));

            arItemList.filterer.itemFilter = this.FilterInfoA[uinewFilter].flag;
            var isPlayerInv:* = arItemList == this.PlayerInventory_mc.PlayerList_mc;
            if (isPlayerInv)
            {
                this.uiPlayerFilterIndex = uinewFilter;
            }
            else
            {
                this.uiContainerFilterIndex = uinewFilter;
            }
            if (uinewFilter != uiprevFilter)
            {
                this.BGSCodeObj.PlaySound(aiDelta > 0 ? "UIBarterHorizontalRight" : "UIBarterHorizontalLeft");
                this.BGSCodeObj.sortItems(!isPlayerInv, uinewFilter, false);
                this.BGSCodeObj.updateSortButtonLabel(!isPlayerInv, uinewFilter);
                this.UpdateHeaderText(arItemList);
                arItemList.InvalidateData();
                if (uiPlatform != PlatformChangeEvent.PLATFORM_PC_KB_MOUSE && arItemList.selectedClipIndex == -1 && !arItemList.filterer.IsFilterEmpty(this.FilterInfoA[uinewFilter].flag))
                {
                    arItemList.selectedClipIndex = 0;
                }
            }
        }

        private function UpdateHeaderText(arItemList:ItemList):*
        {
            if (arItemList == this.PlayerInventory_mc.PlayerList_mc)
            {
                this.PlayerInventory_mc.PlayerListHeader.headerText = this.FilterInfoA[this.uiPlayerFilterIndex].text + "Mine";
            }
            else if (arItemList == this.ContainerList_mc)
            {
                if (this.uiContainerFilterIndex == 0)
                {
                    this.ContainerInventory_mc.ContainerListHeader.headerText = this.FilterInfoA[this.uiContainerFilterIndex].containerText;
                }
                else
                {
                    this.ContainerInventory_mc.ContainerListHeader.headerText = this.FilterInfoA[this.uiContainerFilterIndex].text;
                }
            }
            this.RepositionUpperBracketBars();
        }

        public function ProcessUserEvent(strEventName:String, abPressed:Boolean):Boolean
        {
            var bhandled:Boolean = false;
            if (visible && !abPressed)
            {
                if (strEventName == "Cancel" && this.QuantityMenu_mc.opened)
                {
                    this.CloseQuantityMenu();
                    bhandled = true;
                }
                if (!bhandled)
                {
                    if (this.QuantityMenu_mc.opened)
                    {
                        bhandled = this.QuantityMenu_mc.ProcessUserEvent(strEventName, abPressed);
                    }
                    if (!bhandled)
                    {
                        if (strEventName == "RTrigger")
                        {
                            this.SwitchToContainerList();
                            bhandled = true;
                        }
                        else if (strEventName == "LTrigger")
                        {
                            this.SwitchToPlayerList();
                            bhandled = true;
                        }
                    }
                }
            }
            return bhandled;
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
            this.BGSCodeObj.PlaySound("UIMenuQuantity");
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

        public function requestSort():*
        {
            if (this.SortButton.ButtonVisible)
            {
                if (stage.focus == this.ContainerList_mc)
                {
                    this.BGSCodeObj.sortItems(true, this.uiContainerFilterIndex, true);
                    this.BGSCodeObj.updateSortButtonLabel(true, this.uiContainerFilterIndex);
                }
                else
                {
                    this.BGSCodeObj.sortItems(false, this.uiPlayerFilterIndex, true);
                    this.BGSCodeObj.updateSortButtonLabel(false, this.uiPlayerFilterIndex);
                }
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

        function __setProp_ContainerList_mc_MenuObj_ContainerList_0():*
        {
            this.ContainerList_mc.listEntryClass = "Menu.ContainerMenu.ContainerListEntry";
            this.ContainerList_mc.numListItems = 16;
            this.ContainerList_mc.restoreListIndex = true;
            this.ContainerList_mc.textOption = BSScrollingList.TEXT_OPTION_SHRINK_TO_FIT;
            this.ContainerList_mc.verticalSpacing = -2;
        }
    }
}
