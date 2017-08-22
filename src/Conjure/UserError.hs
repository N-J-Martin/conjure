module Conjure.UserError
    ( MonadUserError(..), userErr1
    , UserErrorT(..), runUserError
    , failToUserError
    ) where

import Conjure.Prelude hiding ( fail )
import qualified Conjure.Prelude as Prelude ( MonadFail(..) )
import Conjure.Bug
import Conjure.Language.Pretty

-- base
import System.Exit ( exitWith, ExitCode(..) )
import System.IO as X ( stderr, hPutStrLn )
import Control.Monad ( fail )

-- pipes
import qualified Pipes


userErr1 :: MonadUserError m => Doc -> m a
userErr1 = userErr . return

class (Functor m, Monad m) => MonadUserError m where
    userErr :: [Doc] -> m a

instance MonadUserError (Either Doc) where
    userErr msgs = do
        let msgsOut = case msgs of
                []    -> bug "userErr []"
                [msg] -> [ "Error:" <++> msg ]
                _     -> [ "Error" <+> pretty (i :: Int) <> ":" <++> msg
                         | (i, msg) <- zip [1..] msgs
                         ]
        Left (vcat msgsOut)

-- user errors exit with exit code 2 now.
-- in the future we intend to exit with different exit code for different kind of user errors,
-- but they will always use values >1
-- exit code 0 is for success
-- exit code 1 is for bugs
-- exit code >1 for user errors
instance MonadUserError IO where
    userErr msgs =
        case userErr msgs of
            Left doc -> hPutStrLn stderr (renderNormal (doc :: Doc)) >> exitWith (ExitFailure 2)
            Right x  -> return x

instance MonadUserError m => MonadUserError (IdentityT m) where
    userErr = lift . userErr

instance MonadUserError m => MonadUserError (MaybeT m) where
    userErr = lift . userErr

instance MonadUserError m => MonadUserError (ExceptT m) where
    userErr = lift . userErr

instance MonadUserError m => MonadUserError (StateT st m) where
    userErr = lift . userErr

instance (MonadUserError m, Monoid w) => MonadUserError (WriterT w m) where
    userErr = lift . userErr

instance MonadUserError m => MonadUserError (ReaderT r m) where
    userErr = lift . userErr

instance MonadUserError m => MonadUserError (Pipes.Proxy a b c d m) where
    userErr = lift . userErr


-- | This is to run a MonadUserError. Everything else should lift.
newtype UserErrorT m a = UserErrorT { runUserErrorT :: m (Either [Doc] a) }

runUserError :: UserErrorT Identity a -> Either [Doc] a
runUserError ma = runIdentity (runUserErrorT ma)

instance (Functor m) => Functor (UserErrorT m) where
    fmap f = UserErrorT . fmap (fmap f) . runUserErrorT

instance (Functor m, MonadFail m) => Applicative (UserErrorT m) where
    pure = return
    (<*>) = ap

instance (MonadFail m) => Monad (UserErrorT m) where
    return a = UserErrorT $ return (Right a)
    m >>= k = UserErrorT $ do
        a <- runUserErrorT m
        case a of
            Left e -> return (Left e)
            Right x -> runUserErrorT (k x)
    fail = lift . fail

instance (MonadIO m, MonadFail m) => MonadIO (UserErrorT m) where
    liftIO comp = UserErrorT $ do
        res <- liftIO comp
        return (Right res)

instance MonadTrans UserErrorT where
    lift comp = UserErrorT $ do
        res <- comp
        return (Right res)

instance MonadFail m => MonadFail (UserErrorT m) where
    fail = lift . Prelude.fail

instance MonadFail m => MonadUserError (UserErrorT m) where
    userErr msgs = UserErrorT $ return $ Left msgs


failToUserError :: MonadUserError m => ExceptT m a -> m a
failToUserError comp = do
    res <- runExceptT comp
    case res of
        Left err -> userErr1 err
        Right x  -> return x
