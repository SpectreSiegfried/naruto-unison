module Model.Context
  ( Context(..)
  , fromStatus
  , reflect
  ) where

import           Model.Internal (Context(..))
import           Model.Status (Status)
import qualified Model.Status as Status

fromStatus :: Status -> Context
fromStatus st = Context { skill  = Status.skill st
                        , user   = Status.user st
                        , target = Status.user st
                        }

reflect :: Context -> Context
reflect ctx = ctx { target = user ctx }