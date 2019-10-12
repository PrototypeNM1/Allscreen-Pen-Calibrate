@echo off

setlocal EnableDelayedExpansion

for /f "tokens=4,5 delims=. " %%a in ('ver') do set "version=%%a%%b"


if version lss 62 (
    ::set "wmic_query=wmic desktopmonitor get screenheight, screenwidth /format:value"
    for /f "tokens=* delims=" %%@ in ('wmic desktopmonitor get screenwidth /format:value') do (
        for /f "tokens=2 delims==" %%# in ("%%@") do set "xmax=%%#"
    )
    for /f "tokens=* delims=" %%@ in ('wmic desktopmonitor get screenheight /format:value') do (
        for /f "tokens=2 delims==" %%# in ("%%@") do set "ymax=%%#"
    )

) else (
    ::wmic path Win32_VideoController get VideoModeDescription,CurrentVerticalResolution,CurrentHorizontalResolution /format:value
    for /f "tokens=* delims=" %%@ in ('wmic path Win32_VideoController get CurrentHorizontalResolution  /format:value') do (
        for /f "tokens=2 delims==" %%# in ("%%@") do set "xmax=%%#"
    )
    for /f "tokens=* delims=" %%@ in ('wmic path Win32_VideoController get CurrentVerticalResolution /format:value') do (
        for /f "tokens=2 delims==" %%# in ("%%@") do set "ymax=%%#"
    )
)

echo Resolution !xmax!x!ymax!

if !xmax! lss !ymax! (
	set "ptsxmax=7"
	set "ptsymax=10"
	:: 42~=7.5^2
	set "divx=42
	:: 90~=9.5^2
	set "divy=90
) else (
	set /a "ptsxmax=10"
	set /a "ptsymax=7"
	:: 90~=9.5^2
	set "divx=90
	:: 42~=7.5^2
	set "divy=42
)
set "border=5"

set /a "xptmax=!xmax!-!border!"
set /a "xptrange=!xptmax!-!border!"
:: ptxmax actually half of the maximum points
set /a "rangemid=(!xptrange!/2)
set xpts=
set xptsback=
set /a "x=0"
:loopx
	set /a "xoff=!x!*!x!*!rangemid!/!divx!"
	set /a "xbegin=!border!+!xoff!"
	set /a "xend=!xptmax!-!xoff!"
	set xpts=!xpts!!xbegin!
	set xptsback=,!xend!!xptsback!
	set /a "x+=1"
	if !x! lss !ptsxmax! (
		set xpts=!xpts!,
		goto :loopx
	)
set xpts=!xpts!!xptsback!

set /a "yptmax=!ymax!-!border!"
set /a "yptrange=!yptmax!-!border!"
:: ptymax actually half of the maximum points
set /a "rangemid=(!yptrange!/2)
set ypts=
set yptsback=
set /a "y=0"
:loopy
	set /a "yoff=!y!*!y!*!rangemid!/!divy!"
	set /a "ybegin=!border!+!yoff!"
	set /a "yend=!yptmax!-!yoff!"
	set ypts=!ypts!!ybegin!
	set yptsback=,!yend!!yptsback!
	set /a "y+=1"
	if !y! lss !ptsymax! (
		set ypts=!ypts!,
		goto :loopy
	)
set ypts=!ypts!!yptsback!

start /wait tabcal clearcal devicekind=pen
echo.
echo "Exit the confirmation popup^!"
pause
tabcal lincal novalidate devicekind=pen XGridPts=!xpts! YGridPts=!ypts!

echo.
echo "If calibration won't start because it has not reset after resetting, the issue may be an interfering Wacom driver. Either use Wacom's calibration software or uninstall the Wacom driver, restart, and rerun this script.
pause

endlocal