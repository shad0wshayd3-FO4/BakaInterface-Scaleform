package Shared.AS3
{
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.utils.getDefinitionByName;
    import Shared.AS3.BGSExternalInterface;
    import Shared.AS3.BSButtonHintBar;
    import Shared.AS3.BSButtonHintData;
    import Shared.AS3.BSUIComponent;
    import Shared.AS3.Events.CustomEvent;
    import Shared.GlobalFunc;

    public class LabelSelector extends BSUIComponent
    {
        public static const LABEL_SELECTED_EVENT:String = "LabelSelectedEvent";
        public static const LABEL_MOUSE_SELECTION_EVENT:String = "LabelMouseSelectionEvent";
        public static const LABEL_SELECTOR_FINALIZED_EVENT:String = "LabelSelectorFinalizedEvent";

        public var Slider_mc:MovieClip;
        public var Selector_mc:MovieClip;
        public var SelectorGray_mc:MovieClip;
        public var ButtonLeft_mc:BSButtonHintBar;
        public var ButtonRight_mc:BSButtonHintBar;
        public var BGSCodeObj:Object;
        public var BackerBar_mc:MovieClip;

        private var LabelsA:Vector.<LabelItem>;
        private var LeftIndex:int = 0;
        private var SelectedIndex:uint = 4.294967295E9;
        private var LabelClass:Class;
        private var TotalWidth:Number = 0.0;
        private var MaxDisplayWidth:Number = 0.0;
        private var m_MaxVisible:uint = 9;
        private var ButtonHintDataLeftV:Vector.<BSButtonHintData>;
        private var ButtonHintDataRightV:Vector.<BSButtonHintData>;
        private var LBButtonData:BSButtonHintData;
        private var RBButtonData:BSButtonHintData;
        private var LastSliderX = 0;
        private var TargetSliderX = 0;
        private var LastSelectorX = 0;
        private var TargetSelectorX = 0;
        private var AnimationFramesLeftSelector:Number = 0;
        private var AnimationFramesLeftSlider:Number = 0;
        private var m_LabelWidthScale:Number = 1;
        private var m_ForceUppercase:Boolean = true;
        private var MaxStringWidth = 0;
        private var ShowDirectionalArrows:Boolean = true;
        private var Enabled = true;
        private var FoundSelection:Boolean = false;
        private const AnimFrameCount:Number = 5;
        private var AnimFrameMoveAmount:Array;
        private var m_CenterPointOffset:Number = 640;

        public function LabelSelector()
        {
            this.LabelClass = LabelItem;
            this.LBButtonData = new BSButtonHintData("", "Z", "PSN_L1", "Xenon_L1", 1, null);
            this.RBButtonData = new BSButtonHintData("", "C", "PSN_R1", "Xenon_R1", 1, null);
            super();
            this.m_CenterPointOffset = this.BackerBar_mc.width / 2;
            this.Slider_mc = new MovieClip();
            addChild(this.Slider_mc);
            this.Slider_mc.addChild(this.Selector_mc);
            if (this.SelectorGray_mc != null)
            {
                this.Slider_mc.addChild(this.SelectorGray_mc);
            }
            this.LabelsA = new Vector.<LabelItem>();
            if (this.SelectorGray_mc != null)
            {
                this.SelectorGray_mc.visible = false;
            }
            this.ButtonHintDataLeftV = new Vector.<BSButtonHintData>();
            this.ButtonHintDataLeftV.push(this.LBButtonData);
            this.ButtonLeft_mc.SetButtonHintData(this.ButtonHintDataLeftV);
            this.ButtonLeft_mc.useBackground = false;
            this.ButtonHintDataRightV = new Vector.<BSButtonHintData>();
            this.ButtonHintDataRightV.push(this.RBButtonData);
            this.ButtonRight_mc.SetButtonHintData(this.ButtonHintDataRightV);
            this.ButtonRight_mc.useBackground = false;
            this.AnimFrameMoveAmount = new Array(0.343588, 0.248381, 0.175842, 0.127915, 0.104275);
        }

        public function get lButtonData():BSButtonHintData
        {
            return this.LBButtonData;
        }

        public function get rButtonData():BSButtonHintData
        {
            return this.RBButtonData;
        }

        public function set LabelClassOverride(param1:String):void
        {
            this.LabelClass = getDefinitionByName(param1) as Class;
        }

        public function set maxVisible(param1:uint):void
        {
            this.m_MaxVisible = param1;
        }

        public function get maxVisible():uint
        {
            return this.m_MaxVisible;
        }

        public function get labelWidthScale():Number
        {
            return this.m_LabelWidthScale;
        }

        public function set labelWidthScale(param1:Number):*
        {
            this.m_LabelWidthScale = param1;
        }

        public function get forceUppercase():Boolean
        {
            return this.m_ForceUppercase;
        }

        public function set forceUppercase(param1:Boolean):*
        {
            this.m_ForceUppercase = param1;
        }

        public function set showDirectionalArrows(param1:Boolean):*
        {
            this.ShowDirectionalArrows = param1;
        }

        public function onLabelDataUpdate(param1:Object):*
        {
            var _loc4_:* = undefined;
            this.Clear();
            var _loc2_:* = param1.labelsA.length;
            var _loc3_:* = 0;
            while (_loc3_ < _loc2_)
            {
                _loc4_ = param1.labelsA[_loc3_];
                this.AddLabel(_loc4_.displayName, _loc4_.id, _loc4_.selectable);
                _loc3_++;
            }
            if (_loc2_ > 0)
            {
                this.Finalize();
            }
            this.SelectedID = param1.initialSelection;
        }

        public function set showAsEnabled(param1:Boolean):*
        {
            this.Enabled = param1;
            var _loc2_:* = 0;
            while (_loc2_ < this.LabelsA.length)
            {
                this.LabelsA[_loc2_].showAsEnabled = param1;
                this.Selector_mc.visible = param1 && this.FoundSelection;
                if (this.SelectorGray_mc != null)
                {
                    this.SelectorGray_mc.visible = !param1 && this.FoundSelection;
                }
                _loc2_++;
            }
            this.LBButtonData.ButtonEnabled = this.RBButtonData.ButtonEnabled = param1;
        }

        public function Clear():void
        {
            while (this.Slider_mc.numChildren > 0)
            {
                this.Slider_mc.removeChildAt(0);
            }
            this.Slider_mc.addChild(this.Selector_mc);
            if (this.SelectorGray_mc != null)
            {
                this.Slider_mc.addChild(this.SelectorGray_mc);
            }
            this.LabelsA.splice(0, this.LabelsA.length);
            this.SelectedIndex = 0;
            SetIsDirty();
        }

        public function SetCodeObj(param1:Object):*
        {
            this.BGSCodeObj = param1;
        }

        public function set maxStringWidth(param1:Number):*
        {
            this.MaxStringWidth = param1;
        }

        public function get maxStringWidth():Number
        {
            return this.MaxStringWidth;
        }

        public function onCodeObjDestruction():void
        {
            this.BGSCodeObj = null;
        }

        public function AddLabel(param1:String, param2:uint, param3:Boolean):*
        {
            var _loc4_:* = new this.LabelClass(param1, param2, this.m_ForceUppercase) as LabelItem;
            this.Slider_mc.addChild(_loc4_);
            _loc4_.selectable = param3;
            _loc4_.addEventListener(MouseEvent.CLICK, this.OnLabelPressed);
            this.LabelsA.push(_loc4_);
        }

        public function OnLabelPressed(param1:MouseEvent):void
        {
            var _loc3_:Object = null;
            var _loc2_:LabelItem = param1.currentTarget as LabelItem;
            if (_loc2_)
            {
                _loc3_ = new Object();
                _loc3_.id = _loc2_.id;
                _loc3_.Source = this;
                dispatchEvent(new CustomEvent(LABEL_MOUSE_SELECTION_EVENT, _loc3_, true));
            }
        }

        public function Finalize(param1:Boolean = true):*
        {
            var _loc2_:* = undefined;
            if (param1)
            {
                _loc2_ = 0;
                while (_loc2_ < this.LabelsA.length)
                {
                    this.MaxStringWidth = Math.max(this.MaxStringWidth, this.LabelsA[_loc2_].textWidth);
                    _loc2_++;
                }
            }
            this.TotalWidth = 0;
            _loc2_ = 0;
            while (_loc2_ < this.LabelsA.length)
            {
                this.LabelsA[_loc2_].maxWidth = this.MaxStringWidth * this.m_LabelWidthScale;
                this.LabelsA[_loc2_].x = this.TotalWidth;
                this.LabelsA[_loc2_].y = 23;
                this.TotalWidth = this.TotalWidth + this.LabelsA[_loc2_].maxWidth;
                _loc2_++;
            }
            this.Selector_mc.width = this.LabelsA[0].maxWidth;
            if (this.SelectorGray_mc != null)
            {
                this.SelectorGray_mc.width = this.LabelsA[0].maxWidth;
            }
            if (param1)
            {
                dispatchEvent(new CustomEvent(LABEL_SELECTOR_FINALIZED_EVENT, null, true));
            }
        }

        public function set leftIndex(param1:uint):*
        {
            this.LeftIndex = param1;
        }

        public function get SelectedID():uint
        {
            if (this.SelectedIndex == uint.MAX_VALUE)
            {
                return uint.MAX_VALUE;
            }
            return this.LabelsA[this.SelectedIndex].id;
        }

        public function get selectedIndex():uint
        {
            return this.SelectedIndex;
        }

        public function set SelectedID(param1:uint):*
        {
            this.FoundSelection = false;
            var _loc2_:int = 0;
            while (_loc2_ < this.LabelsA.length)
            {
                if (this.LabelsA[_loc2_].id == param1)
                {
                    this.SetLeftIndex(this.GetLeftIndex(_loc2_), false);
                    this.SetSelection(_loc2_, true, false);
                    this.FoundSelection = true;
                    break;
                }
                _loc2_++;
            }
            if (!this.FoundSelection)
            {
                if (this.LabelsA.length == 0)
                {
                    this.Selector_mc.visible = false;
                    this.SelectorGray_mc.visible = false;
                }
                else
                {
                    this.SetLeftIndex(this.GetLeftIndex(0), false);
                    this.SetSelection(0, true, false);
                    this.FoundSelection = true;
                }
            }
        }

        public function GetLeftIndex(param1:int):*
        {
            var _loc2_:* = Math.floor(this.m_MaxVisible / 2);
            var _loc3_:* = Math.ceil(this.m_MaxVisible / 2);
            if (param1 < _loc3_)
            {
                return 0;
            }
            if (param1 < this.LabelsA.length - _loc2_)
            {
                return Math.max(param1 - _loc2_, 0);
            }
            return Math.max(this.LabelsA.length - this.m_MaxVisible, 0);
        }

        public function get SelectedText():String
        {
            return this.LabelsA[this.SelectedIndex].text;
        }

        public function RemoveSelectedItem():*
        {
            this.Slider_mc.removeChild(this.LabelsA[this.SelectedIndex]);
            this.LabelsA.splice(this.SelectedIndex, 1);
            this.Finalize(false);
            if (this.SelectedIndex < this.LabelsA.length)
            {
                this.SetSelection(this.SelectedIndex, true, true);
            }
            else if (this.LabelsA.length > 0)
            {
                this.SetSelection(this.SelectedIndex - 1, true, true);
            }
        }

        public function SelectPrevious(param1:Boolean = true):void
        {
            var _loc2_:int = 0;
            if (this.Enabled && this.SelectedIndex > 0)
            {
                _loc2_ = this.SelectedIndex - 1;
                while (_loc2_ > -1)
                {
                    if (this.LabelsA[_loc2_].selectable)
                    {
                        this.SetSelection(_loc2_, true, param1);
                        if (this.BGSCodeObj != null)
                        {
                            BGSExternalInterface.call(this.BGSCodeObj, "PlaySound", "UIWorkshopModeMenuCategoryLeft");
                        }
                        break;
                    }
                    _loc2_--;
                }
            }
        }

        public function SelectNext(param1:Boolean = true):void
        {
            var _loc3_:int = 0;
            var _loc2_:* = this.LabelsA.length;
            if (this.Enabled && this.SelectedIndex < _loc2_ - 1)
            {
                _loc3_ = this.SelectedIndex + 1;
                while (_loc3_ < _loc2_)
                {
                    if (this.LabelsA[_loc3_].selectable)
                    {
                        this.SetSelection(_loc3_, true, param1);
                        if (this.BGSCodeObj != null)
                        {
                            BGSExternalInterface.call(this.BGSCodeObj, "PlaySound", "UIWorkshopModeMenuCategoryRight");
                        }
                        break;
                    }
                    _loc3_++;
                }
            }
        }

        private function GetOffsetForLeftIndex(param1:uint):*
        {
            var _loc2_:* = -param1 * this.LabelsA[0].maxWidth;
            return _loc2_;
        }

        private function GetCenteredOffsetForLeftIndex(param1:uint):*
        {
            var _loc2_:* = this.LabelsA[0].maxWidth * Math.min(this.m_MaxVisible, this.LabelsA.length);
            var _loc3_:* = this.GetOffsetForLeftIndex(param1) + this.m_CenterPointOffset - _loc2_ / 2;
            return _loc3_;
        }

        public function SetLeftIndex(param1:uint, param2:Boolean):*
        {
            this.LastSliderX = this.GetCenteredOffsetForLeftIndex(this.LeftIndex);
            this.Slider_mc.x = this.LastSliderX;
            this.TargetSliderX = this.GetCenteredOffsetForLeftIndex(param1);
            this.UpdateLabelVisibility(this.LeftIndex, true);
            this.LeftIndex = param1;
            if (param2)
            {
                this.AnimationFramesLeftSlider = this.AnimFrameCount;
            }
            else
            {
                this.Slider_mc.x = this.TargetSliderX;
                this.AnimationFramesLeftSlider = 0;
            }
            this.UpdateLabelVisibility(param1, !param2);
        }

        public function UpdateLabelVisibility(param1:*, param2:*):*
        {
            var _loc3_:* = this.LabelsA.length;
            var _loc4_:* = 0;
            while (_loc4_ < _loc3_)
            {
                if (_loc4_ < param1)
                {
                    this.LabelsA[_loc4_].visible = false;
                }
                else if (_loc4_ < param1 + this.m_MaxVisible)
                {
                    if (param2)
                    {
                        this.LabelsA[_loc4_].visible = true;
                    }
                }
                else
                {
                    this.LabelsA[_loc4_].visible = false;
                }
                _loc4_++;
            }
        }

        public function GetRelativeSelectionIndex():uint
        {
            return this.SelectedIndex - this.LeftIndex;
        }

        public function UpdateSelection():*
        {
            if (this.SelectedIndex < uint.MAX_VALUE)
            {
                this.SetSelection(this.SelectedIndex, true, false);
                this.LBButtonData.ButtonEnabled = this.SelectedIndex > 0;
                this.RBButtonData.ButtonEnabled = this.SelectedIndex < this.LabelsA.length - 1;
            }
        }

        public function SetSelection(param1:uint, param2:Boolean, param3:Boolean):*
        {
            if (this.SelectedIndex < uint.MAX_VALUE)
            {
                this.LabelsA[this.SelectedIndex].selected = false;
            }
            var _loc4_:* = 0;
            if (this.LabelsA.length)
            {
                _loc4_ = this.LabelsA[0].maxWidth;
            }
            this.SelectedIndex = param1;
            if (param3 && this.AnimFrameCount <= 0)
            {
                this.LastSelectorX = this.Selector_mc.x;
                this.TargetSelectorX = param1 * _loc4_;
                this.AnimationFramesLeftSelector = this.AnimFrameCount;
            }
            else
            {
                this.Selector_mc.x = param1 * _loc4_;
                if (this.SelectorGray_mc != null)
                {
                    this.SelectorGray_mc.x = param1 * _loc4_;
                }
                this.LabelsA[this.SelectedIndex].selected = true;
            }
            this.SetLeftIndex(this.GetLeftIndex(this.SelectedIndex), param3);
            var _loc5_:Object = new Object();
            _loc5_.Text = this.LabelsA[param1].text;
            _loc5_.ID = this.LabelsA[param1].id;
            _loc5_.Source = this;
            _loc5_.HandleSelectionImmediately = param2;
            this.LBButtonData.ButtonEnabled = param1 > 0;
            this.RBButtonData.ButtonEnabled = param1 < this.LabelsA.length - 1;
            dispatchEvent(new CustomEvent(LABEL_SELECTED_EVENT, _loc5_, true));
        }

        public function Update(param1:Number):*
        {
            this.UpdateSelector(param1);
            this.UpdateSlider(param1);
        }

        public function UpdateSelector(param1:Number):*
        {
            var _loc2_:* = undefined;
            var _loc3_:* = undefined;
            var _loc4_:* = undefined;
            if (this.AnimationFramesLeftSelector > 0)
            {
                _loc2_ = param1 / (1 / 30);
                _loc3_ = this.TargetSelectorX - this.LastSelectorX;
                _loc4_ = _loc3_ / this.AnimFrameCount;
                this.Selector_mc.x = this.Selector_mc.x + _loc4_ * _loc2_;
                if (this.SelectorGray_mc != null)
                {
                    this.SelectorGray_mc.x = this.SelectorGray_mc.x + _loc4_ * _loc2_;
                }
                this.AnimationFramesLeftSelector = this.AnimationFramesLeftSelector - _loc2_;
                this.AnimationFramesLeftSelector = Math.max(this.AnimationFramesLeftSelector, 0);
                if (this.TargetSelectorX < this.LastSelectorX && this.Selector_mc.x < this.TargetSelectorX)
                {
                    this.Selector_mc.x = this.TargetSelectorX;
                    if (this.SelectorGray_mc != null)
                    {
                        this.SelectorGray_mc.x = this.TargetSelectorX;
                    }
                }
                else if (this.TargetSelectorX > this.LastSelectorX && this.Selector_mc.x > this.TargetSelectorX)
                {
                    this.Selector_mc.x = this.TargetSelectorX;
                    if (this.SelectorGray_mc != null)
                    {
                        this.SelectorGray_mc.x = this.TargetSelectorX;
                    }
                }
                if (this.AnimationFramesLeftSelector == 0)
                {
                    this.LabelsA[this.SelectedIndex].selected = true;
                }
            }
        }

        public function UpdateSlider(param1:Number):*
        {
            var _loc2_:* = undefined;
            var _loc3_:* = undefined;
            var _loc4_:* = undefined;
            if (this.AnimationFramesLeftSlider > 0)
            {
                _loc2_ = param1 / (1 / 30);
                _loc3_ = this.TargetSliderX - this.LastSliderX;
                _loc4_ = _loc3_ / this.AnimFrameCount;
                this.Slider_mc.x = this.Slider_mc.x + _loc4_ * _loc2_;
                this.AnimationFramesLeftSlider = this.AnimationFramesLeftSlider - _loc2_;
                this.AnimationFramesLeftSlider = Math.max(this.AnimationFramesLeftSlider, 0);
                if (this.TargetSliderX < this.LastSliderX && this.Slider_mc.x < this.TargetSliderX)
                {
                    this.Slider_mc.x = this.TargetSliderX;
                }
                else if (this.TargetSliderX > this.LastSliderX && this.Slider_mc.x > this.TargetSliderX)
                {
                    this.Slider_mc.x = this.TargetSliderX;
                }
                if (this.AnimationFramesLeftSlider == 0)
                {
                    this.Selector_mc.x = this.LabelsA[this.SelectedIndex].x;
                    if (this.SelectorGray_mc != null)
                    {
                        this.SelectorGray_mc.x = this.LabelsA[this.SelectedIndex].x;
                    }
                    this.UpdateLabelVisibility(this.LeftIndex, true);
                    this.LabelsA[this.SelectedIndex].selected = true;
                }
            }
        }

        public function SetSelectable(param1:uint, param2:Boolean):*
        {
            var _loc3_:uint = 0;
            while (_loc3_ < this.LabelsA.length)
            {
                if (this.LabelsA[_loc3_].id == param1)
                {
                    this.LabelsA[_loc3_].selectable = param2;
                }
                _loc3_++;
            }
        }

        public function MakeCurrentLabelUnselectable():*
        {
            var _loc1_:int = 0;
            var _loc2_:* = uint.MAX_VALUE;
            this.LabelsA[this.SelectedIndex].selectable = false;
            _loc1_ = this.SelectedIndex - 1 as int;
            while (_loc2_ == uint.MAX_VALUE && _loc1_ >= 0)
            {
                if (this.LabelsA[_loc1_].selectable)
                {
                    _loc2_ = _loc1_ as uint;
                }
                _loc1_--;
            }
            _loc1_ = this.SelectedIndex + 1 as int;
            while (_loc2_ == uint.MAX_VALUE && _loc1_ < this.LabelsA.length)
            {
                if (this.LabelsA[_loc1_].selectable)
                {
                    _loc2_ = _loc1_ as uint;
                }
                _loc1_++;
            }
            this.SetSelection(_loc2_, true, false);
        }

        public function GetLabelIndex(param1:uint):int
        {
            var _loc2_:uint = 0;
            while (_loc2_ < this.LabelsA.length)
            {
                if (this.LabelsA[_loc2_].id == param1)
                {
                    return _loc2_;
                }
                _loc2_++;
            }
            return -1;
        }

        public function GetLabel(param1:int):LabelItem
        {
            if (param1 >= 0 && param1 < this.LabelsA.length)
            {
                return this.LabelsA[param1];
            }
            throw new Error("LabelSelector::GetLabel() - aIndex out of range.");
        }
    }
}
