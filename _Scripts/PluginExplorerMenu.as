package
{
    import Components.ItemCard;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.ui.Keyboard;
    import flash.utils.getTimer;
    import Menu.PluginExplorerMenu.*;
    import Shared.AS3.BSButtonHintBar;
    import Shared.AS3.BSButtonHintData;
    import Shared.AS3.BSScrollingList;
    import Shared.AS3.Events.CustomEvent;
    import Shared.AS3.Events.PlatformChangeEvent;
    import Shared.AS3.IMenu;
    import Shared.AS3.LabelItem;
    import Shared.AS3.LabelSelector;
    import Shared.AS3.StyleSheet;
    import Shared.GlobalFunc;

    public class PluginExplorerMenu extends IMenu
    {
        public static const MAX_INDEX = 9;

        public var ButtonHintBar_mc:BSButtonHintBar;
        public var CategoryBar_mc:LabelSelector;
        public var ItemList_mc:ItemList;
        public var ItemSearch_mc:ItemListSearch;
        public var PluginList_mc:PluginList;
        public var PluginSearch_mc:PluginListSearch;
        public var ItemCard_mc:ItemCard;

        private var CancelButton:BSButtonHintData;
        private var SearchButton:BSButtonHintData;
        private var SelectButton:BSButtonHintData;

        private var uiMenuDepth:uint;
        private var uiMenuIndex:uint;
        private var uiCachedPluginIndex:int;
        private var bRefreshCategoryBar:Boolean;
        private var bDonePrevious:Boolean;
        private var bSearchEnabled:Boolean;
        private var bCancelPressed:Boolean;

        private var itemFilter:FormFilter;
        private var pluginFilter:FormFilter;

        public var BGSCodeObj:Object;

        public function PluginExplorerMenu()
        {
            this.CancelButton = new BSButtonHintData("$CLOSE", "Tab", "PSN_B", "Xenon_B", 1, this.onCancelPressed);
            this.SearchButton = new BSButtonHintData("$SEARCH", "Q", "PSN_L3", "Xenon_L3", 1, this.onSearchPressed);
            this.SelectButton = new BSButtonHintData("$SELECT", "Enter", "PSN_A", "Xenon_A", 1, this.onSelectPressed);

            super();

            this.BGSCodeObj = new Object();

            this.uiMenuDepth = 0;
            this.uiMenuIndex = 0;
            this.uiCachedPluginIndex = 0;
            this.bRefreshCategoryBar = true;
            this.bDonePrevious = false;
            this.bSearchEnabled = false;
            this.bCancelPressed = false;

            StyleSheet.apply(this.ItemList_mc, false, Menu.PluginExplorerMenu.ItemListStyle);
            this.itemFilter = new FormFilter();
            this.ItemList_mc.filterer = this.itemFilter;

            StyleSheet.apply(this.PluginList_mc, false, Menu.PluginExplorerMenu.PluginListStyle);
            this.pluginFilter = new FormFilter();
            this.PluginList_mc.filterer = this.pluginFilter;

            this.CategoryBar_mc.forceUppercase = false;
            this.CategoryBar_mc.labelWidthScale = 1.10;

            this.PopulateButtonBar();
            this.PopulateCategoryBar();
            this.UpdateDisplay();

            addEventListener(BSScrollingList.SELECTION_CHANGE, this.onListSelectionChange);
            addEventListener(BSScrollingList.ITEM_PRESS, this.onListItemSelected);
            addEventListener(BSScrollingList.MOUSE_OVER, this.onListMouseOver);
            addEventListener(LabelSelector.LABEL_MOUSE_SELECTION_EVENT, this.onLabelMouseSelection);
            this.ItemSearch_mc.addEventListener(MouseEvent.MOUSE_UP, this.onItemSearchClicked);
            this.ItemSearch_mc.SearchText_tf.addEventListener(Event.CHANGE, this.onItemSearchBoxChanged);
            this.PluginSearch_mc.addEventListener(MouseEvent.MOUSE_UP, this.onPluginSearchClicked);
            this.PluginSearch_mc.SearchText_tf.addEventListener(Event.CHANGE, this.onPluginSearchBoxChanged);
        }

        private function PopulateButtonBar():void
        {
            var _loc1_:Vector.<BSButtonHintData> = new Vector.<BSButtonHintData>();
            _loc1_.push(this.CancelButton);
            _loc1_.push(this.SearchButton);
            _loc1_.push(this.SelectButton);
            this.ButtonHintBar_mc.SetButtonHintData(_loc1_);
        }

        private function PopulateCategoryBar():void
        {
            this.CategoryBar_mc.Clear();
            this.CategoryBar_mc.maxVisible = MAX_INDEX + 1;
            this.CategoryBar_mc.AddLabel("$InventoryCategoryWeapons", 0, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryApparel", 1, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryAid", 2, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryMisc", 3, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryJunk", 4, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryMods", 5, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryHolo", 6, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryNote", 7, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryKeys", 8, true);
            this.CategoryBar_mc.AddLabel("$InventoryCategoryAmmo", 9, true);
            this.CategoryBar_mc.Finalize();
            this.CategoryBar_mc.SetSelection(this.uiMenuIndex, true, false);
        }

        public function onCodeObjCreate():*
        {
            this.CategoryBar_mc.SetCodeObj(this.BGSCodeObj);
            this.BGSCodeObj.NotifyLoaded();
        }

        public function onCodeObjDestruction():*
        {
            this.CategoryBar_mc.onCodeObjDestruction();
            this.BGSCodeObj = null;
        }

        public function RefreshDisplay():*
        {
            this.BGSCodeObj.InitPluginList();
        }

        public function SetPluginList(param1:Array):*
        {
            this.PluginList_mc.entryList = param1;
            this.PluginList_mc.InvalidateData();
            this.PluginList_mc.selectedIndex = 0;
            this.UpdateItemList();
        }

        public function onUpdateItemCardInfoList(param1:Array):*
        {
            this.ItemCard_mc.InfoObj = param1;
            this.ItemCard_mc.onDataChange();
        }

        public function onKeyDown(param1:KeyboardEvent):*
        {
            switch (param1.keyCode)
            {
                case Keyboard.TAB:
                case Keyboard.ESCAPE:
                {
                    this.BGSCodeObj.PlaySound("UIMenuCancel");
                    this.onCancelPressed();
                    break;
                }
                default:
                    break;
            }
        }

        public function ProcessUserEvent(a_event:String, a_keyPressed:Boolean):Boolean
        {
            if (!a_keyPressed)
            {
                switch (a_event)
                {
                    case "Cancel":
                        this.onCancelPressed();
                        return true;

                    case "Accept":
                        return true;

                    case "Prev":
                        this.onPrevCategory();
                        return true;

                    case "Next":
                        this.onNextCategory();
                        return true;

                    case "Search":
                        this.onSearchPressed();
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

        private function SetButtons():*
        {
            this.SearchButton.ButtonVisible = !this.bSearchEnabled;
            this.SelectButton.ButtonVisible = !this.bSearchEnabled;

            switch (this.uiMenuDepth)
            {
                case 0:
                    this.CancelButton.ButtonText = this.bSearchEnabled ? "$CANCEL" : "$CLOSE";
                    break;

                case 1:
                    this.CancelButton.ButtonText = this.bSearchEnabled ? "$CANCEL" : "$BACK";
                    break;
            }
        }

        private function onCancelPressed():Boolean
        {
            if (this.CancelButton.ButtonEnabled && this.CancelButton.ButtonVisible)
            {
                if (this.bSearchEnabled)
                {
                    this.onSearchPressed();
                }
                else if (this.bCancelPressed)
                {
                    switch (this.uiMenuDepth)
                    {
                        case 0:
                            this.BGSCodeObj.CloseMenu();
                            break;

                        case 1:
                            this.SwitchToPluginList();
                            break;
                    }
                }
            }

            this.bCancelPressed = false;
        }

        private function onPrevCategory():Boolean
        {
            this.CategoryBar_mc.SelectPrevious();
            // this.BGSCodeObj.PlaySound("UIMenuPrevNext");
            this.uiMenuIndex = this.CategoryBar_mc.selectedIndex;
            this.UpdateItemList();

        }

        private function onNextCategory():Boolean
        {
            this.CategoryBar_mc.SelectNext();
            // this.BGSCodeObj.PlaySound("UIMenuPrevNext");
            this.uiMenuIndex = this.CategoryBar_mc.selectedIndex;
            this.UpdateItemList();
        }

        private function onSearchPressed():Boolean
        {
            switch (this.uiMenuDepth)
            {
                case 0:
                    this.onPluginSearchPressed();
                    break;

                case 1:
                    this.onItemSearchPressed();
                    break;
            }
        }

        private function onSelectPressed():Boolean
        {
            if (this.SelectButton.ButtonEnabled && this.SelectButton.ButtonVisible)
            {
                switch (this.uiMenuDepth)
                {
                    case 0:
                        this.uiCachedPluginIndex = this.PluginList_mc.selectedIndex;
                        this.bRefreshCategoryBar = true;
                        this.UpdateItemList();
                        break;

                    case 1:
                        break;
                }
            }
        }

        private function onListSelectionChange(param1:Event)
        {
            switch (this.uiMenuDepth)
            {
                case 0:
                    break;

                case 1:
                    if (this.uiMenuIndex == 9 && this.ItemList_mc.selectedEntry != null)
                    {
                        this.BGSCodeObj.TestItemCardInfoList(this.ItemList_mc.selectedEntry.FormID);
                    }
                    break;
            }

            this.BGSCodeObj.PlaySound("UIMenuFocus");
            this.UpdateDisplay();
        }

        private function onListItemSelected(param1:Event)
        {
            this.onSelectPressed();
        }

        private function onListMouseOver(event:Event):*
        {
            if (event.target == this.PluginList_mc && stage.focus != this.PluginList_mc)
            {
                stage.focus = this.PluginList_mc;
                this.ItemList_mc.selectedIndex = -1;
                this.uiMenuDepth = 0;
                this.SetButtons();
            }
            else if (event.target == this.ItemList_mc && stage.focus != this.ItemList_mc)
            {
                stage.focus = this.ItemList_mc;
                this.PluginList_mc.selectedIndex = this.uiCachedPluginIndex;
                this.uiMenuDepth = 1;
                this.SetButtons();
            }
        }

        private function onLabelMouseSelection(param1:Event):void
        {
            var customEvent:CustomEvent = param1 as CustomEvent;
            this.CategoryBar_mc.SelectedID = customEvent.params.id;
            this.uiMenuIndex = this.CategoryBar_mc.selectedIndex;
            this.UpdateItemList();
        }

        private function onPluginSearchClicked():Boolean
        {
            if (!this.bSearchEnabled)
            {
                this.onPluginSearchPressed();
            }
            else
            {
                this.PluginSearch_mc.SearchText_tf.setSelection(0, int.MAX_VALUE);
            }
        }

        private function onPluginSearchPressed():Boolean
        {
            var searchText:TextField = this.PluginSearch_mc.SearchText_tf;
            if (!this.bSearchEnabled)
            {
                addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
                stage.focus = searchText;
                searchText.type = TextFieldType.INPUT;
                this.PluginList_mc.disableInput_Inspectable = true
                this.ItemList_mc.disableInput_Inspectable = true;
                this.CategoryBar_mc.enabled = false;
                this.ItemSearch_mc.enabled = false;
                this.BGSCodeObj.SetTextEntry(true);
                this.bSearchEnabled = true;
            }
            else
            {
                removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
                stage.focus = this.PluginList_mc;
                searchText.type = TextFieldType.DYNAMIC;
                this.PluginList_mc.disableInput_Inspectable = false;
                this.ItemList_mc.disableInput_Inspectable = false;
                this.CategoryBar_mc.enabled = true;
                this.ItemSearch_mc.enabled = true;
                this.BGSCodeObj.SetTextEntry(false);
                this.bSearchEnabled = false;
            }

            this.SetButtons();
        }

        private function onPluginSearchBoxChanged(param1:Event)
        {
            this.pluginFilter.filterString = this.PluginSearch_mc.SearchText_tf.text;
        }

        private function onItemSearchClicked():Boolean
        {
            if (!this.bSearchEnabled)
            {
                this.onItemSearchPressed();
            }
            else
            {
                this.ItemSearch_mc.SearchText_tf.setSelection(0, int.MAX_VALUE);
            }
        }

        private function onItemSearchPressed():Boolean
        {
            var searchText:TextField = this.ItemSearch_mc.SearchText_tf;
            if (!this.bSearchEnabled)
            {
                addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
                stage.focus = searchText;
                searchText.type = TextFieldType.INPUT;
                this.PluginList_mc.disableInput_Inspectable = true
                this.ItemList_mc.disableInput_Inspectable = true;
                this.CategoryBar_mc.enabled = false;
                this.PluginSearch_mc.enabled = false;
                this.BGSCodeObj.SetTextEntry(true);
                this.bSearchEnabled = true;
            }
            else
            {
                removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
                stage.focus = this.ItemList_mc;
                searchText.type = TextFieldType.DYNAMIC;
                this.PluginList_mc.disableInput_Inspectable = false;
                this.ItemList_mc.disableInput_Inspectable = false;
                this.CategoryBar_mc.enabled = true;
                this.PluginSearch_mc.enabled = true;
                this.BGSCodeObj.SetTextEntry(false);
                this.bSearchEnabled = false;
            }

            this.SetButtons();
        }

        private function onItemSearchBoxChanged(param1:Event)
        {
            this.itemFilter.filterString = this.ItemSearch_mc.SearchText_tf.text;
        }

        private function UpdateDisplay()
        {
            this.SetButtons();
        }

        private function UpdateItemList()
        {
            var selectedEntry:Object = this.PluginList_mc.entryList[this.uiCachedPluginIndex];
            if (selectedEntry == null)
            {
                return;
            }

            if (this.bRefreshCategoryBar)
            {
                this.CategoryBar_mc.SetSelectable(0, selectedEntry.WEAP.length > 0);
                this.CategoryBar_mc.SetSelectable(1, selectedEntry.ARMO.length > 0);
                this.CategoryBar_mc.SetSelectable(2, selectedEntry.ALCH.length > 0);
                this.CategoryBar_mc.SetSelectable(3, selectedEntry.MISC.length > 0);
                this.CategoryBar_mc.SetSelectable(4, selectedEntry.JUNK.length > 0);
                this.CategoryBar_mc.SetSelectable(5, selectedEntry.MODS.length > 0);
                this.CategoryBar_mc.SetSelectable(6, selectedEntry.HOLO.length > 0);
                this.CategoryBar_mc.SetSelectable(7, selectedEntry.BOOK.length > 0);
                this.CategoryBar_mc.SetSelectable(8, selectedEntry.KEYS.length > 0);
                this.CategoryBar_mc.SetSelectable(9, selectedEntry.AMMO.length > 0);

                if (!this.CategoryBar_mc.GetLabel(this.uiMenuIndex).selectable)
                {
                    if (!bDonePrevious)
                    {
                        this.bDonePrevious = true;
                        this.onPrevCategory();
                    }
                    else
                    {
                        this.onNextCategory();
                    }

                    return;
                }

                this.bRefreshCategoryBar = false;
                this.bDonePrevious = false;
            }

            var newList:Array = null;
            switch (this.uiMenuIndex)
            {
                case 0:
                    newList = selectedEntry.WEAP;
                    break;

                case 1:
                    newList = selectedEntry.ARMO;
                    break;

                case 2:
                    newList = selectedEntry.ALCH;
                    break;

                case 3:
                    newList = selectedEntry.MISC;
                    break;

                case 4:
                    newList = selectedEntry.JUNK;
                    break;

                case 5:
                    newList = selectedEntry.MODS;
                    break;

                case 6:
                    newList = selectedEntry.HOLO;
                    break;

                case 7:
                    newList = selectedEntry.BOOK;
                    break;

                case 8:
                    newList = selectedEntry.KEYS;
                    break;

                case 9:
                    newList = selectedEntry.AMMO;
                    break;
            }

            newList.sortOn("text");
            this.ItemList_mc.entryList = newList;
            this.ItemList_mc.InvalidateData();
            this.ItemList_mc.selectedIndex = 0;

            this.SwitchToItemList();
            this.UpdateDisplay();
        }

        private function SwitchLists(fromList:BSScrollingList, toList:BSScrollingList):Boolean
        {
            var result:Boolean = false;
            if (stage.focus != toList && toList.itemsShown > 0)
            {
                stage.focus = toList;
                result = true;
            }

            return result;
        }

        private function SwitchToPluginList()
        {
            var Switched:Boolean = this.SwitchLists(this.ItemList_mc, this.PluginList_mc);
            if (Switched)
            {
                this.ItemList_mc.selectedIndex = -1;
                this.uiMenuDepth = 0;
                this.UpdateDisplay();
            }
        }

        private function SwitchToItemList()
        {
            var Switched:Boolean = this.SwitchLists(this.PluginList_mc, this.ItemList_mc);
            if (Switched)
            {
                this.PluginList_mc.selectedIndex = this.uiCachedPluginIndex;
                this.uiMenuDepth = 1;
                this.UpdateDisplay();
            }
        }
    }
}
