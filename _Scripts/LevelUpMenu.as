package
{
    import Shared.AS3.BSButtonHintBar;
    import Shared.AS3.BSButtonHintData;
    import Shared.GlobalFunc;
    import Shared.IMenu;
    import Shared.PlatformChangeEvent;
    import flash.display.MovieClip;
	import flash.text.TextField;
    import Scaleform.GFX.Extensions;
    import Scaleform.GFX.TextFieldEx;

    public class LevelUpMenu extends IMenu
    {
		public var Placeholder_tf:TextField;
		
        public var ButtonHintBar_mc:BSButtonHintBar;

        private var AcceptButton:BSButtonHintData;
        private var CancelButton:BSButtonHintData;
        private var PrevPerkButton:BSButtonHintData;
        private var NextPerkButton:BSButtonHintData;

        public var BGSCodeObj:Object;

        public function LevelUpMenu()
        {
            this.AcceptButton = new BSButtonHintData("$ACCEPT", "Enter", "PSN_A", "Xenon_A", 1, this.onAcceptPressed);
            this.CancelButton = new BSButtonHintData("$CLOSE", "Tab", "PSN_B", "Xenon_B", 1, this.onCancelPressed);
            this.PrevPerkButton = new BSButtonHintData("$PREV PERK", "Ctrl", "PSN_L1", "Xenon_L1", 1, this.onPrevPerk);
            this.NextPerkButton = new BSButtonHintData("$NEXT PERK", "Alt", "PSN_R1", "Xenon_R1", 1, this.onNextPerk);

            super();

            this.BGSCodeObj = new Object();
            this.PopulateButtonBar();
            this.SetButtons();

            Extensions.enabled = true;
            // this.__setProp_ButtonHintBar_mc_MenuObj_ButtonHintBar_mc_0();
        }

        private function PopulateButtonBar():void
        {
            var _loc1_:Vector.<BSButtonHintData> = new Vector.<BSButtonHintData>();
            _loc1_.push(this.AcceptButton);
            _loc1_.push(this.CancelButton);
            _loc1_.push(this.PrevPerkButton);
            _loc1_.push(this.NextPerkButton);
            this.ButtonHintBar_mc.SetButtonHintData(_loc1_);
        }

        public function onCodeObjCreate():*
        {
        }

        public function onCodeObjDestruction():*
        {
            this.BGSCodeObj = null;
        }
		
		public function setPlaceHolderText(param1:String):*
		{
			this.Placeholder_tf.text = param1;
		}

        public function ProcessUserEvent(param1:String, param2:Boolean):Boolean
        {
            return false;
        }

        private function SetButtons():*
        {
        }

        private function onAcceptPressed():Boolean
        {
        }

        private function onCancelPressed():Boolean
        {
            this.BGSCodeObj.CloseMenu();
        }

        private function onPrevPerk():*
        {
        }

        private function onNextPerk():*
        {
        }

/*
        function __setProp_ButtonHintBar_mc_MenuObj_ButtonHintBar_mc_0():*
        {
            try
            {
                this.ButtonHintBar_mc["componentInspectorSetting"] = true;
            }
            catch (e:Error)
            {
            }
            this.ButtonHintBar_mc.BackgroundAlpha = 0.75;
            this.ButtonHintBar_mc.BackgroundColor = 3355443;
            this.ButtonHintBar_mc.bracketCornerLength = 6;
            this.ButtonHintBar_mc.bracketLineWidth = 1.5;
            this.ButtonHintBar_mc.BracketStyle = "horizontal";
            this.ButtonHintBar_mc.bRedirectToButtonBarMenu = false;
            this.ButtonHintBar_mc.bShowBrackets = true;
            this.ButtonHintBar_mc.bUseShadedBackground = true;
            this.ButtonHintBar_mc.ShadedBackgroundMethod = "Flash";
            this.ButtonHintBar_mc.ShadedBackgroundType = "normal";
            try
            {
                this.ButtonHintBar_mc["componentInspectorSetting"] = false;
                return;
            }
            catch (e:Error)
            {
                return;
            }
        }
*/
    }
}
