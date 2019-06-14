-- | 'Game.chakra' processing.
module Engine.Chakras
  ( random
  , remove
  , gain
  ) where

import ClassyPrelude.Yesod

import           Core.Util ((—))
import qualified Class.Play as P
import           Class.Play (GameT, PlayT)
import qualified Class.Random as R
import           Class.Random (RandomT)
import qualified Model.Chakra as Chakra
import           Model.Chakra (Chakra(..), Chakras)
import qualified Data.Vector as Vec
import qualified Model.Game as Game
import qualified Model.Ninja as Ninja

-- | Randomly picks a 'Chakra' of any kind except 'Rand'.
random :: ∀ m. RandomT m => m Chakra
random = toEnum <$> R.random (fromEnum Blood) (fromEnum Tai)

-- | Removes some number of 'Chakra's from the target's team. 
-- 'Chakra's are chosen randomly from the available pool of 'Game.chakra'.
-- Removed 'Chakra's are collected into a 'Chakras' object and returned.
remove :: ∀ m. (PlayT m, RandomT m) => Int -> m Chakras
remove amount
  | amount <= 0 = return 0
  | otherwise   = do
    target <- P.target
    chakras <- Chakra.fromChakras . Game.getChakra target <$> P.game
    removed <- Chakra.collect . Vec.take amount <$> R.shuffle chakras
    P.modify $ Game.adjustChakra target (— removed)
    return removed

-- | Adds as many random 'Chakra's as the number of living 'Ninja's on the
-- player's team to the player's 'Game.chakra'.
gain :: ∀ m. (GameT m, RandomT m) => m ()
gain = do
    player <- P.player
    living <- length . filter (Ninja.playing player) . Game.ninjas <$> P.game
    randoms :: [Chakra] <- replicateM living random
    P.modify $ Game.adjustChakra player (+ Chakra.collect randoms)