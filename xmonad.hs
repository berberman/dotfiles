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
    , startupHook = startupHook kde4Config >> spawn "xcompmgr -cfF -t-5 -l-5 -r5 -o.55 &"
    , borderWidth = 0
    } `additionalKeys` myKeys
      where
        named = ["Web", "IM", "Code", "Remote"]

myKeys = [ ((mod4Mask, xK_r), spawn "dmenu_run")
         , ((mod4Mask .|. controlMask, xK_r), spawn "xmonad --recompile && xmonad --restart")
         ]

myManageHook = composeAll . concat $
    [ [ className   =? c --> doFloat           | c <- myFloats]
    , [ className   =? c --> doShift "IM"      | c <- imApps] 
    , [ className   =? c --> doShift "Web"     | c <- webApps]
    , [ name        =? "~ : weechat — Konsole" --> doShift "IM"]
    , [ name        =? "KRDC"                  --> doShift "Remote"]
    ]
  where
      name = stringProperty "WM_NAME"
      myFloats      = ["lattedock", "yakuake", "jetbrains-toolbox"]
      webApps       = ["Chromium"]
      imApps        = ["telegram-desktop", "Slack", "Element (Riot)"]
   
myLogHook :: X ()
myLogHook = fadeInactiveLogHook 0.9
