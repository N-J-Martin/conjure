{-# LANGUAGE TupleSections #-}

module Conjure.Process.Unnameds
    ( removeUnnamedsFromModel
    ) where

import Conjure.Prelude
import Conjure.Language.Definition
import Conjure.Language.Domain


-- | The argument is a model before nameResolution.
--   Only intended to work on problem specifications.
--   Replaces unnamed types with integers.
removeUnnamedsFromModel :: MonadFail m => Model -> m Model
removeUnnamedsFromModel model = do
    statements' <- forM (mStatements model) $ \ st ->
            case st of
                Declaration (LettingDomainDefnUnnamed name size) -> do
                    let outDomain = mkDomainIntBNamed name 1 size
                    return $ Declaration $ Letting name $ Domain outDomain
                _ -> return st
    return model { mStatements = statements' }
