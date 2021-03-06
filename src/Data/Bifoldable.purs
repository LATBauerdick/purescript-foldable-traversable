module Data.Bifoldable where

import Prelude

import Control.Apply (applySecond)

import Data.Monoid (class Monoid, mempty)
import Data.Monoid.Conj (Conj(..))
import Data.Monoid.Disj (Disj(..))
import Data.Monoid.Dual (Dual(..))
import Data.Monoid.Endo (Endo(..))
import Data.Newtype (unwrap)

-- | `Bifoldable` represents data structures with two type arguments which can be
-- | folded.
-- |
-- | A fold for such a structure requires two step functions, one for each type
-- | argument. Type class instances should choose the appropriate step function based
-- | on the type of the element encountered at each point of the fold.
-- |
-- | Default implementations are provided by the following functions:
-- |
-- | - `bifoldrDefault`
-- | - `bifoldlDefault`
-- | - `bifoldMapDefaultR`
-- | - `bifoldMapDefaultL`
-- |
-- | Note: some combinations of the default implementations are unsafe to
-- | use together - causing a non-terminating mutually recursive cycle.
-- | These combinations are documented per function.
class Bifoldable p where
  bifoldr :: forall a b c. (a -> c -> c) -> (b -> c -> c) -> c -> p a b -> c
  bifoldl :: forall a b c. (c -> a -> c) -> (c -> b -> c) -> c -> p a b -> c
  bifoldMap :: forall m a b. Monoid m => (a -> m) -> (b -> m) -> p a b -> m

-- | A default implementation of `bifoldr` using `bifoldMap`.
-- |
-- | Note: when defining a `Bifoldable` instance, this function is unsafe to
-- | use in combination with `bifoldMapDefaultR`.
bifoldrDefault
  :: forall p a b c
   . Bifoldable p
  => (a -> c -> c)
  -> (b -> c -> c)
  -> c
  -> p a b
  -> c
bifoldrDefault f g z p = unwrap (bifoldMap (Endo <<< f) (Endo <<< g) p) z

-- | A default implementation of `bifoldl` using `bifoldMap`.
-- |
-- | Note: when defining a `Bifoldable` instance, this function is unsafe to
-- | use in combination with `bifoldMapDefaultL`.
bifoldlDefault
  :: forall p a b c
   . Bifoldable p
  => (c -> a -> c)
  -> (c -> b -> c)
  -> c
  -> p a b
  -> c
bifoldlDefault f g z p =
  unwrap
    (unwrap
      (bifoldMap (Dual <<< Endo <<< flip f) (Dual <<< Endo <<< flip g) p))
    z

-- | A default implementation of `bifoldMap` using `bifoldr`.
-- |
-- | Note: when defining a `Bifoldable` instance, this function is unsafe to
-- | use in combination with `bifoldrDefault`.
bifoldMapDefaultR
  :: forall p m a b
   . Bifoldable p => Monoid m
  => (a -> m)
  -> (b -> m)
  -> p a b
  -> m
bifoldMapDefaultR f g p = bifoldr (append <<< f) (append <<< g) mempty p

-- | A default implementation of `bifoldMap` using `bifoldl`.
-- |
-- | Note: when defining a `Bifoldable` instance, this function is unsafe to
-- | use in combination with `bifoldlDefault`.
bifoldMapDefaultL
  :: forall p m a b
   . Bifoldable p => Monoid m
  => (a -> m)
  -> (b -> m)
  -> p a b
  -> m
bifoldMapDefaultL f g p = bifoldl (\m a -> m <> f a) (\m b -> m <> g b) mempty p


-- | Fold a data structure, accumulating values in a monoidal type.
bifold :: forall t m. Bifoldable t => Monoid m => t m m -> m
bifold = bifoldMap id id

-- | Traverse a data structure, accumulating effects using an `Applicative` functor,
-- | ignoring the final result.
bitraverse_
  :: forall t f a b c d
   . Bifoldable t => Applicative f
  => (a -> f c)
  -> (b -> f d)
  -> t a b
  -> f Unit
bitraverse_ f g = bifoldr (applySecond <<< f) (applySecond <<< g) (pure unit)

-- | A version of `bitraverse_` with the data structure as the first argument.
bifor_
  :: forall t f a b c d
   . Bifoldable t => Applicative f
  => t a b
  -> (a -> f c)
  -> (b -> f d)
  -> f Unit
bifor_ t f g = bitraverse_ f g t

-- | Collapse a data structure, collecting effects using an `Applicative` functor,
-- | ignoring the final result.
bisequence_
  :: forall t f a b
   . Bifoldable t => Applicative f
  => t (f a) (f b)
  -> f Unit
bisequence_ = bitraverse_ id id

-- | Test whether a predicate holds at any position in a data structure.
biany
  :: forall t a b c
   . Bifoldable t => BooleanAlgebra c
  => (a -> c)
  -> (b -> c)
  -> t a b
  -> c
biany p q = unwrap <<< bifoldMap (Disj <<< p) (Disj <<< q)

-- | Test whether a predicate holds at all positions in a data structure.
biall
  :: forall t a b c
   . Bifoldable t => BooleanAlgebra c
  => (a -> c)
  -> (b -> c)
  -> t a b
  -> c
biall p q = unwrap <<< bifoldMap (Conj <<< p) (Conj <<< q)
