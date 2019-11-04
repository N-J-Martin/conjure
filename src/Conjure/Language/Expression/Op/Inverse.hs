{-# LANGUAGE DeriveGeneric, DeriveDataTypeable, DeriveFunctor, DeriveTraversable, DeriveFoldable, ViewPatterns #-}

module Conjure.Language.Expression.Op.Inverse where

import Conjure.Prelude
import Conjure.Language.Expression.Op.Internal.Common

import qualified Data.Aeson as JSON             -- aeson
import qualified Data.HashMap.Strict as M       -- unordered-containers
import qualified Data.Vector as V               -- vector


data OpInverse x = OpInverse x x
    deriving (Eq, Ord, Show, Data, Functor, Traversable, Foldable, Typeable, Generic)

instance Serialize x => Serialize (OpInverse x)
instance Hashable  x => Hashable  (OpInverse x)
instance ToJSON    x => ToJSON    (OpInverse x) where toJSON = genericToJSON jsonOptions
instance FromJSON  x => FromJSON  (OpInverse x) where parseJSON = genericParseJSON jsonOptions

instance (TypeOf x, Pretty x) => TypeOf (OpInverse x) where
    typeOf p@(OpInverse f g) = do
        TypeFunction fFrom fTo <- typeOf f
        TypeFunction gFrom gTo <- typeOf g
        if typesUnify [fFrom, gTo] && typesUnify [fTo, gFrom]
            then return TypeBool
            else raiseTypeError p

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
