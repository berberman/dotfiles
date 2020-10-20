import Data.Function ((&))
import qualified Data.Map as M
import XMonad
import XMonad.Config.Kde
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Spacing
import XMonad.Layout.ThreeColumns
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.SpawnOnce

main =
  xmonad . ewmh . docks $
    kde4Config
      { modMask = mod4Mask,
        focusFollowsMouse = False,
        manageHook = manageHook kde4Config <+> myManageHook <+> manageDocks,
        layoutHook = myLayoutHook,
        handleEventHook = fullscreenEventHook,
        workspaces = myWorkspaces,
        logHook = myLogHook,
        startupHook = startupHook kde4Config >> spawn "picom --config ~/.xmonad/picom.conf &",
        borderWidth = 0,
        terminal = "alacritty"
      }
      `additionalKeys` myKeys

myWorkspaces = let n = ["Web", "IM", "Code", "Proc", "Music"] in n ++ map show [(1 & (length n +)) .. 8]

spac = spacingRaw True (Border 0 10 10 10) True (Border 10 10 10 10) True . avoidStruts

myLayoutHook = spac (ThreeCol 1 (3 / 100) (1 / 2) ||| ThreeColMid 1 (3 / 100) (1 / 2) ||| Mirror (Tall 1 (3 / 100) (1 / 2)) ||| Full)

myKeys =
  [ ((mod4Mask, xK_r), spawn "rofi -combi-modi drun -theme Adapta-Nokto -show combi -show-icons"),
    ((mod4Mask .|. controlMask, xK_r), spawn "xmonad --recompile && xmonad --restart"),
    ((mod4Mask .|. controlMask, xK_l), spawn "killall latte-dock && kstart5 latte-dock"),
    ((mod4Mask .|. controlMask, xK_p), mySpawnOn "Web" chromium),
    ((mod4Mask .|. controlMask, xK_t), mySpawnOn "IM" tg),
    ((mod4Mask .|. controlMask, xK_e), mySpawnOn "IM" element),
    ((mod4Mask .|. controlMask, xK_d), spawn "dolphin"),
    ((mod4Mask .|. controlMask, xK_s), spawn "systemsettings5"),
    ((mod4Mask .|. controlMask, xK_f), spawn "emacs")
  ]

myManageHook =
  composeAll . concat $
    [ [className =? c --> doFloat | c <- floatByClass],
      [className =? c --> doShift "IM" | c <- imApps],
      [className =? c --> doShift "Web" | c <- webApps],
      [className =? c --> doIgnore | c <- ignoreByClass],
      [name =? "weechat" --> doShift "IM"],
      [name =? c --> doFloat | c <- floatByName]
    ]
  where
    name = stringProperty "WM_NAME"
    floatByClass = ["lattedock", "yakuake", "jetbrains-toolbox", "peek"]
    floatByName = ["Media viewer"]
    ignoreByClass = ["plasmashell"]
    webApps = [chromium]
    imApps = [tg, slack, element]

chromium = "chromium"

tg = "telegram-desktop"

element = "element-desktop"

slack = "slack"

myLogHook :: X ()
myLogHook = fadeInactiveLogHook 1.0

mySpawnOn workspace program = spawn program >> (windows $ W.greedyView workspace)
