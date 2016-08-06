module Solution where

import Data.List
import Data.Map (Map)
import Folding
import Geom
import Problem
import qualified Data.Map as M

type Facet = [Int]

data Solution a = Solution [Point a] [Facet] [Point a]
                deriving (Show)

sortUnique :: (Ord a) => [a] -> [a]
sortUnique = map head . group . sort

sameContents :: (Ord a) => (Polygon a, History a) -> (Polygon a, History a) -> Bool
sameContents (lp, _) (rp, _) = (sortUnique lp) == (sortUnique rp)

unfold, fold :: (Fractional a) => (Polygon a, History a) -> (Polygon a, History a)
unfold (ps, hs) = (foldl (flip mirror) ps hs, hs)
fold (ps, hs) = unfold (ps, reverse hs)

mkSolution :: (Fractional a, Ord a) => [(Polygon a, History a)] -> Solution a
mkSolution phs = Solution source facets destination
    where polygons = nubBy sameContents $ map unfold phs

          source = sortUnique . concat $ map fst polygons
          table = M.fromList $ zip source [0 ..]

          facets = map (map (table M.!) . fst) polygons

          destination = let tags ph = map (table M.!) (fst ph)
                            move ph = zip (tags ph) (fst $ fold ph)
                        in map snd . sortUnique . concat $ map move polygons

solve :: Problem Rational -> Solution Rational
solve (Problem silhouette _) = mkSolution $ wrap (convexHull $ concat silhouette) paper
