{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE PatternSynonyms #-}

-- | This module exports the user-facing interface for the library.
-- It is supposed to contain everything you need to write constraints
-- and implement `HasSpec` and `HasSimpleRep` instances.
module Constrained (
  Spec (..), -- TODO: it would be nice not to expose this whole thing
  Pred (..), -- TODO: it would be nice not to expose this whole thing
  Term,
  Binder (..), -- TODO: it would be nice not to expose this whole thing
  HasSpec (..),
  HasSimpleRep (..),
  NumLike (..),
  OrdLike (..),
  Forallable (..),
  Foldy (..),
  MaybeBounded (..),
  FunctionLike (..),
  Functions (..),
  HOLE (..),
  BaseUniverse,
  Member,
  BaseFn,
  BaseFns,
  Fix,
  OneofL,
  IsPred,
  IsNormalType,
  Value (..),
  SOP,
  (:::),
  MapFn,
  FunFn,
  -- TODO: it would be nice not to have to expose these
  PairSpec (..),
  NumSpec (..),
  MapSpec (..),
  FoldSpec (..),
  genFromSpec,
  genFromSpec_,
  genFromSpecWithSeed,
  conformsToSpec,
  conformsToSpecProp,
  giveHint,
  typeSpec,
  con,
  isCon,
  onCon,
  sel,
  caseBoolSpec,
  constrained,
  constrained',
  satisfies,
  letBind,
  match,
  assert,
  assertExplain,
  caseOn,
  branch,
  ifElse,
  onJust,
  isJust,
  reify,
  reify',
  genHint,
  dependsOn,
  forAll,
  forAll',
  exists,
  unsafeExists,
  fst_,
  snd_,
  pair_,
  (<=.),
  (<.),
  (==.),
  (/=.),
  (||.),
  member_,
  subset_,
  disjoint_,
  singleton_,
  elem_,
  not_,
  foldMap_,
  sum_,
  size_,
  rng_,
  dom_,
  left_,
  right_,
  toGeneric_,
  fromGeneric_,
  injectFn,
  app,
  lit,
  -- Working with number-like types
  emptyNumSpec,
  combineNumSpec,
  genFromNumSpec,
  conformsToNumSpec,
  toPredsNumSpec,
  -- TODO: this is super yucky, it would be good to implement
  -- the linear lambda thing to get rid of this.
  composeFn,
  fstFn,
  sndFn,
  addFn,
  toGenericFn,
  toSimpleRepSpec,
  fromSimpleRepSpec,
  algebra,
  inject,
  toPred,
  module X,
)
where

import Constrained.GenT as X
import Constrained.Internals
import Constrained.List as X
import Constrained.Spec.Tree as X
