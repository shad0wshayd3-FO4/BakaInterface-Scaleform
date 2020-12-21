package
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.utils.getTimer;
    import Menu.PluginExplorerMenu.*;
    import scaleform.gfx.Extensions;
    import scaleform.gfx.TextFieldEx;
    import Shared.AS3.BSButtonHintBar;
    import Shared.AS3.BSButtonHintData;
    import Shared.AS3.BSScrollingList;
    import Shared.AS3.BSScrollingScrollList;
    import Shared.AS3.LabelItem;
    import Shared.AS3.LabelSelector;
    import Shared.CustomEvent;
    import Shared.GlobalFunc;
    import Shared.IMenu;
    import Shared.PlatformChangeEvent;

    public class PluginExplorerMenu extends IMenu
    {
        public var ButtonHintBar_mc:BSButtonHintBar;
        public var PluginList_mc:PluginList;
        public var ItemList_mc:ItemList;
        public var CategoryBar_mc:LabelSelector;

        private var CancelButton:BSButtonHintData;
        private var PrevCategoryButton:BSButtonHintData;
        private var NextCategoryButton:BSButtonHintData;
        private var SelectButton:BSButtonHintData;

        private var uiMenuDepth:uint;
        private var uiMenuIndex:uint;
        private var uiCachedPluginIndex:int;

        public var BGSCodeObj:Object;

        public function PluginExplorerMenu()
        {
            this.CancelButton = new BSButtonHintData("$CLOSE", "Tab", "PSN_B", "Xenon_B", 1, this.onCancelPressed);
            this.PrevCategoryButton = new BSButtonHintData("$PREV CATEGORY", "Ctrl", "PSN_L1", "Xenon_L1", 1, this.onPrevCategory);
            this.NextCategoryButton = new BSButtonHintData("$NEXT CATEGORY", "Alt", "PSN_R1", "Xenon_R1", 1, this.onNextCategory);
            this.SelectButton = new BSButtonHintData("$SELECT", "Enter", "PSN_A", "Xenon_A", 1, this.onSelectPressed);

            super();

            this.BGSCodeObj = new Object();

            this.uiMenuDepth = 0;
            this.uiMenuIndex = 0;
            this.uiCachedPluginIndex = 0;

            this.CategoryBar_mc.forceUppercase = false;
            this.CategoryBar_mc.labelWidthScale = 1.35;

            this.PopulateButtonBar();
            this.PopulateCategoryBar();
            this.UpdateDisplay();

            Extensions.enabled = true;

            addEventListener(BSScrollingList.SELECTION_CHANGE, this.onListSelectionChange);
            addEventListener(BSScrollingList.ITEM_PRESS, this.onListItemSelected);
            addEventListener(BSScrollingScrollList.MOUSE_OVER, this.onListMouseOver);
            addEventListener(LabelSelector.LABEL_MOUSE_SELECTION_EVENT, this.OnLabelMouseSelection);

            this.__setProp_PluginList_mc();
            this.__setProp_ItemList_mc();
        }

        private function PopulateButtonBar():void
        {
            var _loc1_:Vector.<BSButtonHintData> = new Vector.<BSButtonHintData>();
            _loc1_.push(this.CancelButton);
            _loc1_.push(this.PrevCategoryButton);
            _loc1_.push(this.NextCategoryButton);
            _loc1_.push(this.SelectButton);
            this.ButtonHintBar_mc.SetButtonHintData(_loc1_);
        }

        private function PopulateCategoryBar():void
        {
            this.CategoryBar_mc.Clear();
            this.CategoryBar_mc.maxVisible = 8;
            this.CategoryBar_mc.AddLabel("Weapons", 0, true);
            this.CategoryBar_mc.AddLabel("Armor", 1, true);
            this.CategoryBar_mc.AddLabel("Aid", 2, true);
            this.CategoryBar_mc.AddLabel("Misc", 3, true);
            this.CategoryBar_mc.AddLabel("Holotapes", 4, true);
            this.CategoryBar_mc.AddLabel("Notes", 5, true);
            this.CategoryBar_mc.AddLabel("Keys", 6, true);
            this.CategoryBar_mc.AddLabel("Ammo", 7, true);
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

        public function ProcessUserEvent(a_event:String, a_keyPressed:Boolean):Boolean
        {
            if (!a_keyPressed)
            {
                switch (a_event)
                {
                    case "Cancel":
                        this.onCancelPressed();
                        return true;

                    case "PrevPerk":
                    case "LShoulder":
                        this.onPrevCategory();
                        return true;

                    case "NextPerk":
                    case "RShoulder":
                        this.onNextCategory();
                        return true;

                    case "DISABLED":
                        return false;

                    default:
                        trace(a_event);
                        break;
                }
            }

            return false;
        }

        private function SetButtons():*
        {
            this.PrevCategoryButton.ButtonEnabled = (this.uiMenuIndex > 0);
            this.NextCategoryButton.ButtonEnabled = (this.uiMenuIndex < 7);

            switch (this.uiMenuDepth)
            {
                case 0:
                    this.CancelButton.ButtonText = "$CLOSE";
                    break;

                case 1:
                    this.CancelButton.ButtonText = "$BACK";
                    break;
            }
        }

        private function onCancelPressed():Boolean
        {
            if (this.CancelButton.ButtonEnabled && this.CancelButton.ButtonVisible)
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

        private function onPrevCategory():Boolean
        {
            if (this.PrevCategoryButton.ButtonEnabled && this.PrevCategoryButton.ButtonVisible)
            {
                this.uiMenuIndex = GlobalFunc.Clamp(this.uiMenuIndex - 1, 0, 7);
                this.CategoryBar_mc.SelectPrevious();
                // this.BGSCodeObj.PlaySound("UIMenuPrevNext");
                this.UpdateItemList();
            }
        }

        private function onNextCategory():Boolean
        {
            if (this.NextCategoryButton.ButtonEnabled && this.NextCategoryButton.ButtonVisible)
            {
                this.uiMenuIndex = GlobalFunc.Clamp(this.uiMenuIndex + 1, 0, 7);
                this.CategoryBar_mc.SelectNext();
                // this.BGSCodeObj.PlaySound("UIMenuPrevNext");
                this.UpdateItemList();
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

        public function OnLabelMouseSelection(param1:Event):void
        {
            var _loc2_:uint = 0;
            if ((param1 as CustomEvent).params.Source == this.CategoryBar_mc)
            {
                _loc2_ = (param1 as CustomEvent).params.id;
                this.uiMenuIndex = this.CategoryBar_mc.GetLabelIndex(_loc2_);
                this.CategoryBar_mc.SelectedID = _loc2_;
                this.UpdateItemList();
            }
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

            var newList:Array = null;
            switch (this.uiMenuIndex)
            {
                case 0:
                    newList = selectedEntry.contents.WEAP;
                    break;

                case 1:
                    newList = selectedEntry.contents.ARMO;
                    break;

                case 2:
                    newList = selectedEntry.contents.ALCH;
                    break;

                case 3:
                    newList = selectedEntry.contents.MISC;
                    break;

                case 4:
                    newList = selectedEntry.contents.KEYS;
                    break;

                case 5:
                    newList = selectedEntry.contents.HOLO;
                    break;

                case 6:
                    newList = selectedEntry.contents.BOOK;
                    break;

                case 7:
                    newList = selectedEntry.contents.AMMO;
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

        function __setProp_PluginList_mc():*
        {
            this.PluginList_mc.listEntryClass = "Menu.PluginExplorerMenu.PluginListEntry";
            this.PluginList_mc.numListItems = 17;
            this.PluginList_mc.restoreListIndex = false;
            this.PluginList_mc.textOption = BSScrollingList.TEXT_OPTION_SHRINK_TO_FIT;
            this.PluginList_mc.verticalSpacing = 0;
        }

        function __setProp_ItemList_mc():*
        {
            this.ItemList_mc.listEntryClass = "Menu.PluginExplorerMenu.ItemListEntry";
            this.ItemList_mc.numListItems = 17;
            this.ItemList_mc.restoreListIndex = false;
            this.ItemList_mc.textOption = BSScrollingList.TEXT_OPTION_SHRINK_TO_FIT;
            this.ItemList_mc.verticalSpacing = 0;
        }
    }
}
