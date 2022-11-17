:: It seems required to run this script as administrator because that seems required from symlinking.

:: * For retail: `<game installation directory>\_retail_`
:: * For WotLK: `<game installation directory>\_classic_`
:: * For vanilla: `<game installation directory>\_classic_era_`
set "path=C:\Program Files (x86)\World of Warcraft\_retail_"

mklink /D "%path%\Interface\AddOns\ActionSequenceDoer" "%~dp0\AddOns\ActionSequenceDoer"
mklink /D "%path%\Interface\AddOns\Array" "%~dp0\AddOns\Array"
mklink /D "%path%\Interface\AddOns\AStar" "%~dp0\AddOns\AStar"
mklink /D "%path%\Interface\AddOns\BinaryHeap" "%~dp0\AddOns\BinaryHeap"
mklink /D "%path%\Interface\AddOns\Boolean" "%~dp0\AddOns\Boolean"
mklink /D "%path%\Interface\AddOns\Coroutine" "%~dp0\AddOns\Coroutine"
mklink /D "%path%\Interface\AddOns\Events" "%~dp0\AddOns\Events"
mklink /D "%path%\Interface\AddOns\Function" "%~dp0\AddOns\Function"
mklink /D "%path%\Interface\AddOns\Math" "%~dp0\AddOns\Math"
mklink /D "%path%\Interface\AddOns\Movement" "%~dp0\AddOns\Movement"
mklink /D "%path%\Interface\AddOns\Object" "%~dp0\AddOns\Object"
mklink /D "%path%\Interface\AddOns\OffMeshHandler" "%~dp0\AddOns\OffMeshHandler"
mklink /D "%path%\Interface\AddOns\Set" "%~dp0\AddOns\Set"
mklink /D "%path%\Interface\AddOns\Vector" "%~dp0\AddOns\Vector"
mklink /D "%path%\Interface\AddOns\Yielder" "%~dp0\AddOns\Yielder"
mklink /D "%path%\Interface\AddOns\GMR" "%~dp0\AddOns\GMR"
mklink /D "%path%\Interface\AddOns\HWT" "%~dp0\AddOns\HWT"
mklink /D "%path%\Interface\AddOns\Unlocker" "%~dp0\AddOns\Unlocker"
mklink /D "%path%\Interface\AddOns\Core" "%~dp0\AddOns\Core"
mklink /D "%path%\Interface\AddOns\Serialization" "%~dp0\AddOns\Serialization"
mklink /D "%path%\Interface\AddOns\APIDumper" "%~dp0\AddOns\APIDumper"
mklink /D "%path%\Interface\AddOns\Bot" "%~dp0\AddOns\Bot"
mklink /D "%path%\Interface\AddOns\AutoGear" "%~dp0\AddOns\AutoGear"
mklink /D "%path%\Interface\AddOns\Tooltips" "%~dp0\AddOns\Tooltips"
mklink /D "%path%\Interface\AddOns\Questing" "%~dp0\AddOns\Questing"
