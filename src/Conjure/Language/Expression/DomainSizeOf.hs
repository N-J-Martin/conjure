{-# OPTIONS_GHC -fno-warn-orphans #-}

module Conjure.Language.Expression.DomainSizeOf ( DomainSizeOf(..) ) where

-- conjure
import Conjure.Prelude
import Conjure.Bug
import Conjure.Language.Definition
import Conjure.Language.AdHoc
import Conjure.Language.Domain
import Conjure.Language.Expression.Op
import Conjure.Language.Lenses

import Conjure.Language.DomainSizeOf
import Conjure.Language.Pretty


instance DomainSizeOf Expression Expression where
    domainSizeOf DomainBool = return 2
    domainSizeOf (DomainInt [] ) = fail "domainSizeOf infinite integer domain"
    domainSizeOf (DomainInt [r]) = domainSizeOfRange r
    domainSizeOf (DomainInt rs ) = make opSum . fromList <$> mapM domainSizeOfRange rs
    domainSizeOf (DomainEnum n Nothing _) = return $
        let n' = n `mappend` "_EnumSize"
        in  Reference n' (Just (DeclHasRepr Given n' (DomainInt [])))
    domainSizeOf (DomainUnnamed _ x) = return x
    domainSizeOf (DomainTuple []) = return 1
    domainSizeOf (DomainTuple xs) = make opProduct . fromList <$> mapM domainSizeOf xs
    domainSizeOf (DomainRecord xs) = make opProduct . fromList <$> mapM (domainSizeOf . snd) xs
    domainSizeOf (DomainVariant xs) = make opSum . fromList <$> mapM (domainSizeOf . snd) xs
    domainSizeOf (DomainMatrix index inner) = make opPow <$> domainSizeOf inner <*> domainSizeOf index
    domainSizeOf (DomainSet _ (SetAttr sizeAttr) inner) = do
        innerSize <- domainSizeOf inner
        case sizeAttr of
            SizeAttr_None           -> return (make opPow 2 innerSize)
            SizeAttr_Size size      -> return (nchoosek (make opFactorial) innerSize size)
            SizeAttr_MinSize _      -> return (make opPow 2 innerSize)              -- TODO: can be better
            SizeAttr_MaxSize _      -> return (make opPow 2 innerSize)              -- TODO: can be better
            SizeAttr_MinMaxSize _ _ -> return (make opPow 2 innerSize)              -- TODO: can be better
    domainSizeOf (DomainMSet _ attrs inner) = do
        innerSize <- domainSizeOf inner
        let
            getMaxSize = case attrs of
                MSetAttr (SizeAttr_Size x) _ -> return x
                MSetAttr (SizeAttr_MaxSize x) _ -> return x
                MSetAttr (SizeAttr_MinMaxSize _ x) _ -> return x
                MSetAttr _ (OccurAttr_MaxOccur x) -> return (x * innerSize)
                MSetAttr _ (OccurAttr_MinMaxOccur _ x) -> return (x * innerSize)
                _ -> fail ("domainSizeOf.getMaxSize, mset not supported. attributes:" <+> pretty attrs)
            getMaxOccur = case attrs of
                MSetAttr _ (OccurAttr_MaxOccur x) -> return x
                MSetAttr _ (OccurAttr_MinMaxOccur _ x) -> return x
                MSetAttr (SizeAttr_Size x) _ -> return (make opMin $ fromList [x, innerSize])
                MSetAttr (SizeAttr_MaxSize x) _ -> return (make opMin $ fromList [x, innerSize])
                MSetAttr (SizeAttr_MinMaxSize _ x) _ -> return (make opMin $ fromList [x, innerSize])
                _ -> fail ("domainSizeOf.getMaxSize, mset not supported. attributes:" <+> pretty attrs)
        maxSize  <- getMaxSize
        maxOccur <- getMaxOccur
        return (make opPow maxOccur maxSize)
    domainSizeOf (DomainSequence _ (SequenceAttr sizeAttr _) innerTo) =
        domainSizeOf $ DomainRelation def (RelationAttr sizeAttr def) [innerTo, innerTo]
    domainSizeOf (DomainFunction _ (FunctionAttr sizeAttr _ _) innerFr innerTo) =
        domainSizeOf $ DomainRelation def (RelationAttr sizeAttr def) [innerFr, innerTo]
    domainSizeOf (DomainRelation _ (RelationAttr sizeAttr _binRelAttr) inners) =
        domainSizeOf (DomainSet def (SetAttr sizeAttr) (DomainTuple inners))
    domainSizeOf (DomainPartition _ a inner) =
        domainSizeOf $ DomainSet def (SetAttr (partsNum  a))
                      $ DomainSet def (SetAttr (partsSize a)) inner
    domainSizeOf d = bug ("not implemented: domainSizeOf:" <+> pretty d)


domainSizeOfRange :: (Op a :< a, ExpressionLike a, Pretty a, MonadFail m, Num a, Eq a) => Range a -> m a
domainSizeOfRange RangeSingle{} = return 1
domainSizeOfRange (RangeBounded 1 u) = return u
domainSizeOfRange (RangeBounded l u) = return $ make opSum $ fromList [1, make opMinus u l]
domainSizeOfRange r = fail ("domainSizeOf infinite range:" <+> pretty r)
