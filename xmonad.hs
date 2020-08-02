import XMonad
import XMonad.Config.Kde
import qualified XMonad.StackSet as W
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Util.SpawnOnce
import Data.Function ((&))
import qualified Data.Map as M
import XMonad.Hooks.FadeInactive

main = xmonad . ewmh . docks $ kde4Config
    { modMask = mod4Mask -- use the Windows button as mod
    , focusFollowsMouse = False
    , manageHook = manageHook kde4Config <+> myManageHook <+> manageDocks
    , layoutHook = avoidStruts  $  layoutHook kde4Config
    , handleEventHook = fullscreenEventHook
    , keys = \c -> mykeys c `M.union` keys kde4Config c
    , workspaces = named ++ map show [ (1 & (length named +))  .. 9]
    , logHook = myLogHook
    , startupHook = startupHook kde4Config >> spawn "xcompmgr -c &"
    }
      where
        named = ["Web", "IM", "Code", "Remote"]

mykeys (XConfig {modMask = modm}) = M.fromList $ [((modm , xK_r), spawn "dmenu_run")]

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
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 0.9 
