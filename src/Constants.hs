{-# LANGUAGE CPP #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TemplateHaskell #-}

#define DATADIR "datafiles/"

-- #define DEBUG

module Constants ( figlet, reservedNamesTxt, reservedOpNamesTxt
                 , FreshName, getFreshName, newRuleVar, isFreshName, mkFreshNames
                 , trace, traceM
                 ) where

import Control.Monad.State ( MonadState )
import Data.ByteString.Char8 ( unpack)
import Data.FileEmbed ( embedFile )
import Data.List ( (\\), isPrefixOf )
import Data.List.Split ( splitOn )
import Data.Set as S ( Set, fromList )

import Has
import Utils ( strip )



#ifdef DEBUG

import qualified Debug.Trace as D

trace :: String -> a -> a
trace = D.trace

traceM :: Monad m => String -> m ()
traceM s = trace s $ return ()

#else

trace :: String -> a -> a
trace _ = id

traceM :: Monad m => String -> m ()
traceM _ = return ()

#endif




figlet :: String
figlet = unpack $(embedFile (DATADIR ++ "conjure.figlet"))

reservedSet :: S.Set String
reservedSet = S.fromList $ reservedNamesTxt ++ reservedOpNamesTxt

-- reservedNames are loaded from `reservedNames.txt` at compile time-
reservedNamesTxt :: [String]
reservedNamesTxt
    = filter (not . null)
    $ map (strip . removeComment)
    $ lines
    $ unpack $(embedFile (DATADIR ++ "reservedNames.txt"))

-- reservedOpNames are loaded from `reservedOpNames.txt` at compile time
reservedOpNamesTxt :: [String]
reservedOpNamesTxt
    = filter (not . null)
    $ map (strip . removeComment)
    $ lines
    $ unpack $(embedFile (DATADIR ++ "reservedOpNames.txt"))

removeComment :: String -> String
removeComment s = case splitOn "#" s of
                    (i:_) -> i
                    _     -> error "Constants.removeComment"

newRuleVar :: String -> String
newRuleVar = (ruleVarPrefix ++)

ruleVarPrefix :: String
ruleVarPrefix = "__INRULE_"

newtype FreshName = FreshName String

freshNames :: [String]
freshNames = [ "__" ++ show i | i <- [ (1 :: Integer) .. ] ]

mkFreshNames :: [String] -> [FreshName]
mkFreshNames used = map FreshName (freshNames \\ used)

getFreshName :: (MonadState st m, Has st [FreshName]) => m String
getFreshName = do
    (FreshName n:ns) <- getM
    putM ns
    return n

isFreshName :: String -> Bool
isFreshName s = not (ruleVarPrefix `isPrefixOf` s) && "__" `isPrefixOf` s
