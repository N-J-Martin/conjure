{-# LANGUAGE DeriveGeneric, DeriveDataTypeable, DeriveFunctor, DeriveTraversable, DeriveFoldable, ViewPatterns #-}

module Conjure.Language.Expression.Op.Inverse where

import Conjure.Prelude
import Conjure.Language.Expression.Op.Internal.Common

import qualified Data.Aeson as JSON             -- aeson
import qualified Data.HashMap.Strict as M       -- unordered-containers
import qualified Data.Vector as V               -- vector

import Data.Permutation


data OpInverse x = OpInverse x x
    deriving (Eq, Ord, Show, Data, Functor, Traversable, Foldable, Typeable, Generic)

instance Serialize x => Serialize (OpInverse x)
instance Hashable  x => Hashable  (OpInverse x)
instance ToJSON    x => ToJSON    (OpInverse x) where toJSON = genericToJSON jsonOptions
instance FromJSON  x => FromJSON  (OpInverse x) where parseJSON = genericParseJSON jsonOptions

instance (TypeOf x, Pretty x) => TypeOf (OpInverse x) where
    typeOf p@(OpInverse f g) = do
        ft <- typeOf f
        case ft of
          TypeFunction fFrom fTo -> do
            TypeFunction gFrom gTo <- typeOf g
            if typesUnify [fFrom, gTo] && typesUnify [fTo, gFrom]
                then return TypeBool
                else raiseTypeError p
          TypePermutation fi -> do
            TypePermutation gi <- typeOf g
            if typesUnify [fi,gi]
              then return TypeBool
              else raiseTypeError p
          _ -> raiseTypeError p 

instance EvaluateOp OpInverse where
    evaluateOp (OpInverse (viewConstantFunction -> Just xs) (viewConstantFunction -> Just ys)) =
        return $ ConstantBool $ and $ concat [ [ (j,i) `elem` ys | (i,j) <- xs ]
                                             , [ (j,i) `elem` xs | (i,j) <- ys ]
                                             ]
    evaluateOp (OpInverse (viewConstantPermutation -> Just xs) (viewConstantPermutation -> Just ys)) =
        case (toFunction <$> fromCycles xs, toFunction <$> fromCycles ys) of
          (Right xfn, Right lfn) -> return $ ConstantBool $ and $ (\x -> x == lfn (xfn x)) <$> join xs
          (Left (PermutationError e),_) -> na $ "evaluateOp{OpInverse}:" <++> pretty e 
          (_,Left (PermutationError e)) -> na $ "evaluateOp{OpInverse}:" <++> pretty e 
    evaluateOp op = na $ "evaluateOp{OpInverse}:" <++> pretty (show op)

instance SimplifyOp OpInverse x where
    simplifyOp _ = na "simplifyOp{OpInverse}"

instance Pretty x => Pretty (OpInverse x) where
    prettyPrec _ (OpInverse a b) = "inverse" <> prettyList prParens "," [a,b]

instance VarSymBreakingDescription x => VarSymBreakingDescription (OpInverse x) where
    varSymBreakingDescription (OpInverse a b) = JSON.Object $ M.fromList
        [ ("type", JSON.String "OpInverse")
        , ("children", JSON.Array $ V.fromList
            [ varSymBreakingDescription a
            , varSymBreakingDescription b
            ])
        ]
