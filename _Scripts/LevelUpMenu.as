package
{
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextLineMetrics;
    import flash.ui.Keyboard;
    import Menu.LevelUpMenu.*;
    import scaleform.gfx.Extensions;
    import scaleform.gfx.TextFieldEx;
    import Shared.AS3.BSButtonHintBar;
    import Shared.AS3.BSButtonHintData;
    import Shared.AS3.BSScrollingList;
    import Shared.GlobalFunc;
    import Shared.IMenu;
    import Shared.PlatformChangeEvent;

    public class LevelUpMenu extends IMenu
    {
        public var BorderText_tf:TextField;
        public var BorderTrim_mc:MovieClip;
        public var ButtonHintBar_mc:BSButtonHintBar;
        public var Description_tf:TextField;
        public var PerkCount_tf:TextField;
        public var PerkList_mc:PerkList;
        public var RankStarHolder_mc:MovieClip;
        public var SearchBox_mc:SearchBox;
        public var VBHolder_mc:MovieClip;

        private var CancelButton:BSButtonHintData;
        private var SearchButton:BSButtonHintData;
        private var ResetButton:BSButtonHintData;
        private var SelectButton:BSButtonHintData;
        private var PrevPerkButton:BSButtonHintData;
        private var NextPerkButton:BSButtonHintData;
        private var ConfirmButton:BSButtonHintData;

        private var uiPerkBase:uint;
        private var uiPerkCount:uint;
        private var uiViewingCount:uint;
        private var uiViewingIndex:uint;
        private var cachedVBPath:String;
        private var cancelPressed:Boolean;
        private var searchEnabled:Boolean;
        private var searchFilter:SearchFilter;

        private var _VBLoader:Loader;

        public var BGSCodeObj:Object;

        public function LevelUpMenu()
        {
            this.CancelButton = new BSButtonHintData("$CLOSE", "Tab", "PSN_B", "Xenon_B", 1, this.onCancelPressed);
            this.SearchButton = new BSButtonHintData("$SEARCH", "Z", "PSN_L3", "Xenon_L3", 1, this.onSearchPressed);
            this.ResetButton = new BSButtonHintData("$RESET", "T", "PSN_Y", "Xenon_Y", 1, this.onResetPressed);
            this.SelectButton = new BSButtonHintData("$SELECT", "Enter", "PSN_A", "Xenon_A", 1, this.onSelectPressed);
            this.PrevPerkButton = new BSButtonHintData("$PREV PERK", "Ctrl", "PSN_L1", "Xenon_L1", 1, this.onPrevPerk);
            this.NextPerkButton = new BSButtonHintData("$NEXT PERK", "Alt", "PSN_R1", "Xenon_R1", 1, this.onNextPerk);
            this.ConfirmButton = new BSButtonHintData("$CONFIRM", "X", "PSN_X", "Xenon_X", 1, this.onConfirmPressed);

            super();

            this.BGSCodeObj = new Object();
            this._VBLoader = new Loader();

            this.searchFilter = new SearchFilter();
            this.PerkList_mc.filterer = this.searchFilter;

            this.uiPerkBase = 0;
            this.uiPerkCount = 0;
            this.uiViewingCount = -1;
            this.uiViewingIndex = -1;
            this.cancelPressed = false;
            this.searchEnabled = false;

            this.PopulateButtonBar();
            this.UpdateDisplay();

            Extensions.enabled = true;

            addEventListener(BSScrollingList.SELECTION_CHANGE, this.onListSelectionChange);
            addEventListener(BSScrollingList.ITEM_PRESS, this.onListItemSelected);

            this.PerkList_mc.addEventListener(MouseEvent.MOUSE_OVER, this.onListMouseOver);

            this.SearchBox_mc.addEventListener(MouseEvent.MOUSE_UP, this.onSearchClicked);
            this.SearchBox_mc.SearchText_tf.addEventListener(Event.CHANGE, this.onSearchBoxChanged);

            this.__setProp_PerkList_mc();
        }

        private function PopulateButtonBar():void
        {
            var _loc1_:Vector.<BSButtonHintData> = new Vector.<BSButtonHintData>();
            _loc1_.push(this.CancelButton);
            _loc1_.push(this.SearchButton);
            _loc1_.push(this.ResetButton);
            _loc1_.push(this.SelectButton);
            _loc1_.push(this.PrevPerkButton);
            _loc1_.push(this.NextPerkButton);
            _loc1_.push(this.ConfirmButton);
            this.ButtonHintBar_mc.SetButtonHintData(_loc1_);
        }

        public function onCodeObjCreate():*
        {
            this.BGSCodeObj.InitPerkList();
            this.BGSCodeObj.GetPerkCount();
            this.BGSCodeObj.UpdateHeader();
        }

        public function onCodeObjDestruction():*
        {
            this.BGSCodeObj = null;
        }

        public function get perkCount():uint
        {
            return this.uiPerkCount;
        }

        public function set perkCount(param1:uint):void
        {
            this.uiPerkCount = param1;
            this.PerkCount_tf.text = this.uiPerkCount.toString();
        }

        public function SetPerkList(param1:Array):*
        {
            param1.sortOn(["IsAvailable", "PerkLevel", "text"], [Array.NUMERIC | Array.DESCENDING, Array.NUMERIC, Array.CASEINSENSITIVE]);
            this.PerkList_mc.entryList = param1;
            this.PerkList_mc.InvalidateData();
            this.PerkList_mc.selectedIndex = 0;
            this.onListSelectionChange(null);
        }

        public function SetPerkCount(param1:uint):*
        {
            this.perkCount = param1;
            this.uiPerkBase = this.perkCount;
        }

        public function SetHeader(param1:String):*
        {
            GlobalFunc.SetText(this.BorderText_tf, param1, true, true);
            this.UpdateHeader();
        }

        public function ProcessUserEvent(a_event:String, a_keyPressed:Boolean):Boolean
        {
            var Handled:Boolean = false;
            if (!a_keyPressed)
            {
                if (a_event == "Cancel")
                {
                    if (this.cancelPressed)
                    {
                        this.onCancelPressed();
                        Handled = true;
                    }
                    this.cancelPressed = false;
                }
                else if (a_event == "Accept" || a_event == "Activate")
                {
                    this.onSelectPressed();
                    Handled = true;
                }
                else if (a_event == "PrevPerk")
                {
                    this.onPrevPerk();
                    Handled = true;
                }
                else if (a_event == "NextPerk")
                {
                    this.onNextPerk();
                    Handled = true;
                }
                else if (a_event == "Forward" || a_event == "Up")
                {
                    this.PerkList_mc.moveSelectionUp();
                    Handled = true;
                }
                else if (a_event == "Back" || a_event == "Down")
                {
                    this.PerkList_mc.moveSelectionDown();
                    Handled = true;
                }
                else if (a_event == "XButton" || a_event == "R3")
                {
                    this.onConfirmPressed();
                    Handled = true;
                }
                else if (a_event == "YButton")
                {
                    this.onResetPressed();
                    Handled = true;
                }
                else if (a_event == "L3")
                {
                    this.onSearchPressed();
                    Handled = true;
                }
            }
            else
            {
                if (a_event == "Cancel")
                {
                    this.cancelPressed = true;
                }
            }

            return Handled;
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

        private function SetButtons():*
        {
            this.ResetButton.ButtonVisible = !this.searchEnabled;
            this.SearchButton.ButtonVisible = !this.searchEnabled;
            this.SelectButton.ButtonVisible = !this.searchEnabled;
            this.ConfirmButton.ButtonVisible = !this.searchEnabled;
            this.PrevPerkButton.ButtonVisible = !this.searchEnabled;
            this.NextPerkButton.ButtonVisible = !this.searchEnabled;

            this.SelectButton.ButtonEnabled = false;
            this.PrevPerkButton.ButtonEnabled = this.uiViewingIndex > 0;
            this.NextPerkButton.ButtonEnabled = this.uiViewingCount > this.uiViewingIndex;
            this.ResetButton.ButtonEnabled = this.perkCount != this.uiPerkBase;
            this.ConfirmButton.ButtonEnabled = this.perkCount != this.uiPerkBase;

            this.CancelButton.ButtonText = this.searchEnabled ? "$CANCEL" : "$CLOSE";

            var selectedEntry:Object = this.PerkList_mc.selectedEntry;
            if (selectedEntry != null)
            {
                this.SelectButton.ButtonEnabled = ((selectedEntry.IsAvailable) && (selectedEntry.IsSelected || this.perkCount > 0));
            }
        }

        private function onCancelPressed():Boolean
        {
            if (this.CancelButton.ButtonEnabled && this.CancelButton.ButtonVisible)
            {
                if (this.searchEnabled)
                {
                    this.onSearchPressed();
                }
                else
                {
                    this.BGSCodeObj.CloseMenu();
                }
            }
        }

        private function onSearchPressed():Boolean
        {
            var searchText:TextField = this.SearchBox_mc.SearchText_tf;
            if (!this.searchEnabled)
            {
                addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
                stage.focus = searchText;
                searchText.type = TextFieldType.INPUT;
                this.PerkList_mc.disableInput = true;
                this.BGSCodeObj.SetTextEntry(true);
                this.searchEnabled = true;
            }
            else
            {
                removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
                stage.focus = this.PerkList_mc;
                searchText.type = TextFieldType.DYNAMIC;
                this.PerkList_mc.disableInput = false;
                this.BGSCodeObj.SetTextEntry(false);
                this.searchEnabled = false;
            }

            this.SetButtons();
        }

        private function onSearchClicked():Boolean
        {
            if (!this.searchEnabled)
            {
                this.onSearchPressed();
            }
            else
            {
                this.SearchBox_mc.SearchText_tf.setSelection(0, int.MAX_VALUE);
            }
        }

        private function onResetPressed():Boolean
        {
            if (this.ResetButton.ButtonEnabled && this.ResetButton.ButtonVisible)
            {
                this.BGSCodeObj.PlaySound("UIMenuPopUpGeneric");
                for (var i:uint = 0; i < this.PerkList_mc.entryList.length; i++)
                {
                    var entry:Object = this.PerkList_mc.entryList[i];
                    if (entry != null && entry.IsSelected)
                    {
                        entry.IsSelected = false;
                        this.PerkList_mc.UpdateEntry(entry);
                        this.perkCount = this.perkCount + 1;
                    }
                }

                this.SetButtons();
            }
        }

        private function onSelectPressed():Boolean
        {
            if (this.SelectButton.ButtonEnabled && this.SelectButton.ButtonVisible)
            {
                if (this.PerkList_mc.selectedEntry.IsSelected)
                {
                    this.BGSCodeObj.PlaySound("UIMenuCancel");
                    this.PerkList_mc.selectedEntry.IsSelected = false;
                    this.perkCount = this.perkCount + 1;
                }
                else
                {
                    this.BGSCodeObj.PlaySound("UIMenuOK");
                    this.PerkList_mc.selectedEntry.IsSelected = true;
                    this.perkCount = this.perkCount - 1;
                }

                this.uiViewingIndex = this.PerkList_mc.selectedEntry.RankIndex;

                this.PerkList_mc.UpdateSelectedEntry();
                this.UpdateDisplay();
            }
        }

        private function onPrevPerk():*
        {
            if (this.PrevPerkButton.ButtonEnabled && this.PrevPerkButton.ButtonVisible)
            {
                this.BGSCodeObj.PlaySound("UIMenuPrevNext");
                this.uiViewingIndex -= 1;
                this.UpdateDisplay();
            }
        }

        private function onNextPerk():*
        {
            if (this.NextPerkButton.ButtonEnabled && this.NextPerkButton.ButtonVisible)
            {
                this.BGSCodeObj.PlaySound("UIMenuPrevNext");
                this.uiViewingIndex += 1;
                this.UpdateDisplay();
            }
        }

        private function onConfirmPressed():Boolean
        {
            if (this.ConfirmButton.ButtonEnabled && this.ConfirmButton.ButtonVisible)
            {
                this.BGSCodeObj.PlaySound("UIMenuOK");
                for (var i:uint = 0; i < this.PerkList_mc.entryList.length; i++)
                {
                    var entry:Object = this.PerkList_mc.entryList[i];
                    if (entry != null && entry.IsSelected)
                    {
                        this.BGSCodeObj.AddPerk(entry.FormID);
                    }
                }

                this.uiPerkBase = this.perkCount;
                if (this.uiPerkBase > 0)
                {
                    this.BGSCodeObj.InitPerkList();

                }
                else
                {
                    this.BGSCodeObj.CloseMenu();
                }
            }
        }

        private function onListSelectionChange(param1:Event)
        {
            var selectedEntry:Object = this.PerkList_mc.selectedEntry;
            this.uiViewingCount = (selectedEntry == null) ? -1 : selectedEntry.RankCount - 1;
            this.uiViewingIndex = (selectedEntry == null) ? -1 : selectedEntry.RankIndex;

            while (this.RankStarHolder_mc.numChildren > 0)
            {
                this.RankStarHolder_mc.removeChildAt(0);
            }

            if (selectedEntry != null)
            {
                var maxRank:uint = Math.min(selectedEntry.RankCount, 10);
                for (var i:uint = 0; i < maxRank; i++)
                {
                    var rankStar:RankStar = new RankStar();
                    this.RankStarHolder_mc.addChild(rankStar);
                    rankStar.x = rankStar.width * i;
                }
            }

            this.BGSCodeObj.PlaySound("UIMenuFocus");
            this.UpdateDisplay();
        }

        private function onListItemSelected(param1:Event)
        {
            this.onSelectPressed();
        }

        private function onListMouseOver(param1:MouseEvent)
        {
            if (this.searchEnabled)
            {
                this.onCancelPressed();
            }
        }

        private function onSearchBoxChanged(param1:Event)
        {
            this.searchFilter.filterString = this.SearchBox_mc.SearchText_tf.text;
        }

        private function UpdateHeader():*
        {
            var metrics:TextLineMetrics = this.BorderText_tf.getLineMetrics(0);
            var diff:Number = (this.BorderText_tf.x + metrics.width + 12) - this.BorderTrim_mc.x;
            this.BorderTrim_mc.x = this.BorderTrim_mc.x + diff;
            this.BorderTrim_mc.width = this.BorderTrim_mc.width - diff;
        }

        private function UpdateDisplay():*
        {
            var selectedEntry:Object = this.PerkList_mc.selectedEntry;
            if (selectedEntry != null)
            {
                GlobalFunc.SetText(this.Description_tf, selectedEntry.RankDescs[this.uiViewingIndex], true);

                var tempVBPath:String = selectedEntry.IconPaths[this.uiViewingIndex];
                if (this.cachedVBPath != tempVBPath)
                {
                    this.cachedVBPath = tempVBPath;
                    var request:URLRequest = new URLRequest(this.cachedVBPath);
                    var loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
                    this._VBLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onVBLoadComplete);
                    this._VBLoader.load(request, loaderContext);
                }

                for (var i:uint = 0; i < this.RankStarHolder_mc.numChildren; i++)
                {
                    var rankStar:RankStar = this.RankStarHolder_mc.getChildAt(i);
                    rankStar.gotoAndStop("Empty");

                    if (selectedEntry.RankIndex > i)
                    {
                        rankStar.gotoAndStop("Full");
                    }

                    if (this.uiViewingIndex == i)
                    {
                        rankStar.gotoAndStop("Available");
                    }
                }
            }
            else
            {
                GlobalFunc.SetText(this.Description_tf, "", true);
                this.clearVBHolder();
            }

            this.SetButtons();
        }

        private function onVBLoadComplete(param1:Event):*
        {
            this._VBLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onVBLoadComplete);
            this.clearVBHolder();

            this.VBHolder_mc.addChild(param1.target.content);
        }

        private function clearVBHolder():*
        {
            while (this.VBHolder_mc.numChildren > 0)
            {
                this.VBHolder_mc.removeChildAt(0);
            }
        }

        function __setProp_PerkList_mc():*
        {
            this.PerkList_mc.listEntryClass = "Menu.LevelUpMenu.PerkListEntry";
            this.PerkList_mc.numListItems = 16;
            this.PerkList_mc.restoreListIndex = false;
            this.PerkList_mc.textOption = BSScrollingList.TEXT_OPTION_SHRINK_TO_FIT;
            this.PerkList_mc.verticalSpacing = 1;
        }
    }
}
