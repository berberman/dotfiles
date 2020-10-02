import XMonad
import XMonad.Config.Kde
import qualified XMonad.StackSet as W
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Util.SpawnOnce
import Data.Function ((&))
import qualified Data.Map as M
import XMonad.Hooks.FadeInactive
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Layout.Spacing

main = xmonad . ewmh . docks $ kde4Config
    { modMask = mod4Mask -- use the Windows button as mod
    , focusFollowsMouse = False
    , manageHook = manageHook kde4Config <+> myManageHook <+> manageDocks
    , layoutHook = spacingRaw True (Border 0 10 10 10) True (Border 10 10 10 10) True $ avoidStruts $ layoutHook kde4Config
    , handleEventHook = fullscreenEventHook
    , workspaces = named ++ map show [ (1 & (length named +))  .. 9]
    , logHook = myLogHook
    , startupHook = startupHook kde4Config >> spawn "picom --config ~/.xmonad/picom.conf &"
    , borderWidth = 0
    , terminal = "alacritty"
    } `additionalKeys` myKeys
      where
        named = ["Web", "IM", "Code", "Proc", "Music"]

myKeys = [ ((mod4Mask, xK_r), spawn "dmenu_run")
         , ((mod4Mask .|. controlMask, xK_r), spawn "xmonad --recompile && xmonad --restart")
         , ((mod4Mask .|. controlMask, xK_l), spawn "killall latte-dock && kstart5 latte-dock")
         ]

myManageHook = composeAll . concat $
    [ [ className   =? c --> doFloat           | c <- myFloats]
    , [ className   =? c --> doShift "IM"      | c <- imApps] 
    , [ className   =? c --> doShift "Web"     | c <- webApps]
    , [ name        =? "weechat"      --> doShift "IM"]
    , [ name        =? "KRDC"         --> doShift "Remote"]
    , [ name        =? "Media viewer" --> doFloat]
    ]
  where
      name = stringProperty "WM_NAME"
      myFloats      = ["lattedock", "yakuake", "jetbrains-toolbox"]
      webApps       = ["chromium"]
      imApps        = ["telegram-desktop", "slack", "element"]
   
myLogHook :: X ()
myLogHook = fadeInactiveLogHook 1.0
