package Shared.AS3
{
    import Shared.AS3.Events.PlatformChangeEvent;
    import Shared.AS3.Events.PlatformRequestEvent;
    import flash.events.Event;

    public dynamic class BSUIComponent extends BSDisplayObject
    {
        private var _uiPlatform:uint;
        private var _uiController:uint;
        private var _uiKeyboard:uint;
        private var _bPS3Switch:Boolean;
        private var _bAcquiredByNativeCode:Boolean;

        public function BSUIComponent()
        {
            super();
            this._uiPlatform = PlatformChangeEvent.PLATFORM_INVALID;
            this._uiController = PlatformChangeEvent.PLATFORM_INVALID;
            this._uiKeyboard = PlatformChangeEvent.PLATFORM_INVALID;
            this._bPS3Switch = false;
            this._bAcquiredByNativeCode = false;
        }

        public function get uiPlatform():uint
        {
            return this._uiPlatform;
        }

        public function get uiController():uint
        {
            return this._uiController;
        }

        public function get uiKeyboard():uint
        {
            return this._uiKeyboard;
        }

        public function get bPS3Switch():Boolean
        {
            return this._bPS3Switch;
        }

        public function get bAcquiredByNativeCode():Boolean
        {
            return this._bAcquiredByNativeCode;
        }

        public function onAcquiredByNativeCode():*
        {
            this._bAcquiredByNativeCode = true;
        }

        override public function redrawDisplayObject():void
        {
            try
            {
                this.redrawUIComponent();
                return;
            }
            catch (e:Error)
            {
                trace(this + " " + this.name + ": " + e.getStackTrace());
                return;
            }
        }

        private final function onSetPlatformEvent(param1:Event):*
        {
            var _loc2_:PlatformChangeEvent = param1 as PlatformChangeEvent;
            this.SetPlatform(_loc2_.uiPlatform, _loc2_.bPS3Switch);
        }

        override public function onAddedToStage():void
        {
            dispatchEvent(new PlatformRequestEvent(this));
            if (stage)
            {
                stage.addEventListener(PlatformChangeEvent.PLATFORM_CHANGE, this.onSetPlatformEvent);
            }
        }

        override public function onRemovedFromStage():void
        {
            if (stage)
            {
                stage.removeEventListener(PlatformChangeEvent.PLATFORM_CHANGE, this.onSetPlatformEvent);
            }
        }

        public function redrawUIComponent():void
        {
        }

        public function SetPlatform(param1:uint, param2:Boolean):void
        {
            if (this._uiPlatform != param1 || this._bPS3Switch != param2)
            {
                this._uiPlatform = param1;
                this._uiController = param1;
                this._bPS3Switch = param2;
                SetIsDirty();
            }
        }
    }
}
