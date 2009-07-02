{-# LANGUAGE TypeFamilies #-}

{-

An implementation of the p-Beauty Contest.

-}
module Examples.Beauty where

import Data.Function (on)
import Data.List
import Data.Maybe (fromJust)

import Hagl

type Bid  = Float
type Bids = ByPlayer Bid

-- Args: maxBid, p
data Beauty = Beauty Bid Float

type BeautyM = ExecM Beauty

instance Game Beauty where
  type Move  Beauty = Bid
  type State Beauty = ()
  initState _ = ()
  runGame = allPlayers decide >>= check >>= closest >>= wins

check :: Bids -> BeautyM Bids
check bids = do 
    Beauty m _ <- game
    case find (> m) (toList bids) of
      Nothing -> return bids
      Just b  -> fail ("Illegal bid: " ++ show b)

closest :: Bids -> BeautyM PlayerIx
closest (ByPlayer bids)  = do
    Beauty _ p <- game
    let target = p * sum bids / fromIntegral (length bids)
    let delta  = abs . subtract target
    let close  = minimumBy (compare `on` delta) bids
    return (fromJust (elemIndex close bids) + 1)

wins :: PlayerIx -> BeautyM Payoff
wins p = numPlayers >>= \np -> return (winner np p)