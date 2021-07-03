package Menu.BarterMenu
{
	import Shared.AS3.ListFilterer

	public class BarterListFilterer extends ListFilterer
	{
		public function BarterListFilterer()
		{
			super();
		}

		override public function EntryMatchesFilter(param1: Object): Boolean
		{
			var result: Boolean = false;
			if (param1 == null)
			{
				result = false;
			}
			else
			{
				var TentativeCount: int = param1.count;
				if (param1.hasOwnProperty("barterCount"))
				{
					TentativeCount -= param1.barterCount;
				}

				result = (super.EntryMatchesFilter(param1) && TentativeCount > 0);
			}
			
			return result;
		}
	}
}