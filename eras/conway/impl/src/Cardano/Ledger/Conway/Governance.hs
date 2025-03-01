{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE UndecidableSuperClasses #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Cardano.Ledger.Conway.Governance (
  EraGov (..),
  EnactState (..),
  RatifyState (..),
  RatifyEnv (..),
  RatifySignal (..),
  ConwayGovState (..),
  Committee (..),
  committeeMembersL,
  committeeThresholdL,
  GovAction (..),
  GovActionState (..),
  GovActionIx (..),
  GovActionId (..),
  GovActionPurpose (..),
  DRepPulsingState (..),
  DRepPulser (..),
  govActionIdToText,
  Voter (..),
  Vote (..),
  VotingProcedure (..),
  VotingProcedures (..),
  foldlVotingProcedures,
  ProposalProcedure (..),
  GovProcedures (..),
  Anchor (..),
  AnchorData (..),
  indexedGovProps,
  Constitution (..),
  ConwayEraGov (..),
  votingStakePoolThreshold,
  votingDRepThreshold,
  votingCommitteeThreshold,
  isStakePoolVotingAllowed,
  isDRepVotingAllowed,
  isCommitteeVotingAllowed,
  reorderActions,
  actionPriority,
  Proposals,
  mkProposals,
  unsafeMkProposals,
  GovPurposeId (..),
  PRoot (..),
  PEdges (..),
  PGraph (..),
  pRootsL,
  pPropsL,
  prRootL,
  prChildrenL,
  peChildrenL,
  pGraphL,
  pGraphNodesL,
  GovRelation (..),
  hoistGovRelation,
  withGovActionParent,
  toPrevGovActionIds,
  fromPrevGovActionIds,
  grPParamUpdateL,
  grHardForkL,
  grCommitteeL,
  grConstitutionL,
  proposalsActions,
  proposalsAddAction,
  proposalsRemoveWithDescendants,
  proposalsAddVote,
  proposalsIds,
  proposalsApplyEnactment,
  proposalsSize,
  proposalsLookupId,
  proposalsActionsMap,
  cgsProposalsL,
  cgsDRepPulsingStateL,
  cgsCurPParamsL,
  cgsPrevPParamsL,
  cgsCommitteeL,
  cgsConstitutionL,
  ensCommitteeL,
  ensConstitutionL,
  ensCurPParamsL,
  ensPrevPParamsL,
  ensWithdrawalsL,
  ensTreasuryL,
  ensPrevGovActionIdsL,
  ensPrevPParamUpdateL,
  ensPrevHardForkL,
  ensPrevCommitteeL,
  ensPrevConstitutionL,
  ensProtVerL,
  rsEnactStateL,
  rsExpiredL,
  rsEnactedL,
  rsDelayedL,
  constitutionScriptL,
  constitutionAnchorL,
  gasIdL,
  gasDepositL,
  gasCommitteeVotesL,
  gasDRepVotesL,
  gasStakePoolVotesL,
  gasExpiresAfterL,
  gasActionL,
  gasReturnAddrL,
  gasProposedInL,
  gasProposalProcedureL,
  gasDeposit,
  gasAction,
  gasReturnAddr,
  pProcDepositL,
  pProcGovActionL,
  pProcReturnAddrL,
  pProcAnchorL,
  newEpochStateDRepPulsingStateL,
  epochStateDRepPulsingStateL,
  epochStateStakeDistrL,
  epochStateIncrStakeDistrL,
  epochStateRegDrepL,
  epochStateUMapL,
  reDRepDistrL,
  pulseDRepPulsingState,
  completeDRepPulsingState,
  extractDRepPulsingState,
  forceDRepPulsingState,
  finishDRepPulser,
  computeDrepDistr,
  getRatifyState,
  conwayGovStateDRepDistrG,
  psDRepDistrG,
  dormantEpoch,
  PulsingSnapshot (..),
  setCompleteDRepPulsingState,
  setFreshDRepPulsingState,
  psProposalsL,
  psDRepDistrL,
  psDRepStateL,
  RunConwayRatify (..),
  govStatePrevGovActionIds,
  mkEnactState,

  -- * Exported for testing
  pparamsUpdateThreshold,
  TreeMaybe (..),
  toGovRelationTree,
  toGovRelationTreeEither,
) where

import Cardano.Ledger.BaseTypes (
  EpochNo (..),
  Globals (..),
  StrictMaybe (..),
 )
import Cardano.Ledger.Binary (
  DecCBOR (..),
  DecShareCBOR (..),
  EncCBOR (..),
  FromCBOR (..),
  ToCBOR (..),
 )
import Cardano.Ledger.Binary.Coders (
  Decode (..),
  Encode (..),
  decode,
  encode,
  (!>),
  (<!),
 )
import Cardano.Ledger.CertState (Obligations (..))
import Cardano.Ledger.Coin (Coin (..))
import Cardano.Ledger.Conway.Era (ConwayEra)
import Cardano.Ledger.Conway.Governance.DRepPulser
import Cardano.Ledger.Conway.Governance.Internal
import Cardano.Ledger.Conway.Governance.Procedures
import Cardano.Ledger.Conway.Governance.Proposals
import Cardano.Ledger.Core
import Cardano.Ledger.Crypto (Crypto)
import Cardano.Ledger.DRep (DRep (..))
import Cardano.Ledger.PoolDistr (PoolDistr (..))
import Cardano.Ledger.Shelley.Governance
import Cardano.Ledger.Shelley.LedgerState (
  EpochState (..),
  NewEpochState (..),
  certDState,
  certVState,
  credMap,
  dsUnified,
  epochStateGovStateL,
  epochStateTreasuryL,
  esLStateL,
  lsCertState,
  lsUTxOState,
  lsUTxOStateL,
  nesEsL,
  utxosGovStateL,
  utxosStakeDistr,
  vsCommitteeState,
  vsDReps,
 )
import Cardano.Ledger.UMap
import Cardano.Ledger.Val (Val (..))
import Control.DeepSeq (NFData (..))
import Control.Monad.Trans.Reader (ReaderT, ask)
import Data.Aeson (KeyValue, ToJSON (..), object, pairs, (.=))
import Data.Default.Class (Default (..))
import Data.Foldable (Foldable (..))
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Ratio ((%))
import GHC.Generics (Generic)
import Lens.Micro
import Lens.Micro.Extras (view)
import NoThunks.Class (NoThunks (..))

-- =============================================
data ConwayGovState era = ConwayGovState
  { cgsProposals :: !(Proposals era)
  , cgsCommittee :: !(StrictMaybe (Committee era))
  , cgsConstitution :: !(Constitution era)
  , cgsCurPParams :: !(PParams era)
  , cgsPrevPParams :: !(PParams era)
  , cgsDRepPulsingState :: !(DRepPulsingState era)
  -- ^ The 'cgsDRepPulsingState' field is a pulser that incrementally computes the stake
  -- distribution of the DReps over the Epoch following the close of voting at end of
  -- the previous Epoch. It assembles this with some of its other internal components
  -- into a (RatifyEnv era) when it completes, and then calls the RATIFY rule and
  -- eventually returns the updated RatifyState. The pulser is created at the Epoch
  -- boundary, but does no work until it is pulsed in the 'NEWEPOCH' rule, whenever the
  -- system is NOT at the epoch boundary.
  }
  deriving (Generic, Show)

deriving instance EraPParams era => Eq (ConwayGovState era)

cgsProposalsL :: Lens' (ConwayGovState era) (Proposals era)
cgsProposalsL = lens cgsProposals (\x y -> x {cgsProposals = y})

cgsDRepPulsingStateL :: Lens' (ConwayGovState era) (DRepPulsingState era)
cgsDRepPulsingStateL = lens cgsDRepPulsingState (\x y -> x {cgsDRepPulsingState = y})

cgsCommitteeL :: Lens' (ConwayGovState era) (StrictMaybe (Committee era))
cgsCommitteeL = lens cgsCommittee (\x y -> x {cgsCommittee = y})

cgsConstitutionL :: Lens' (ConwayGovState era) (Constitution era)
cgsConstitutionL = lens cgsConstitution (\x y -> x {cgsConstitution = y})

cgsCurPParamsL :: Lens' (ConwayGovState era) (PParams era)
cgsCurPParamsL = lens cgsCurPParams (\x y -> x {cgsCurPParams = y})

cgsPrevPParamsL :: Lens' (ConwayGovState era) (PParams era)
cgsPrevPParamsL = lens cgsPrevPParams (\x y -> x {cgsPrevPParams = y})

govStatePrevGovActionIds :: ConwayEraGov era => GovState era -> GovRelation StrictMaybe era
govStatePrevGovActionIds = view $ proposalsGovStateL . pRootsL . to toPrevGovActionIds

conwayGovStateDRepDistrG ::
  SimpleGetter (ConwayGovState era) (Map (DRep (EraCrypto era)) (CompactForm Coin))
conwayGovStateDRepDistrG = to (\govst -> (psDRepDistr . fst) $ finishDRepPulser (cgsDRepPulsingState govst))

getRatifyState :: ConwayGovState era -> RatifyState era
getRatifyState (ConwayGovState {cgsDRepPulsingState}) = snd $ finishDRepPulser cgsDRepPulsingState

mkEnactState :: ConwayEraGov era => GovState era -> EnactState era
mkEnactState gs =
  EnactState
    { ensCommittee = gs ^. committeeGovStateL
    , ensConstitution = gs ^. constitutionGovStateL
    , ensCurPParams = gs ^. curPParamsGovStateL
    , ensPrevPParams = gs ^. prevPParamsGovStateL
    , ensTreasury = zero
    , ensWithdrawals = mempty
    , ensPrevGovActionIds = govStatePrevGovActionIds gs
    }

-- TODO: Implement Sharing: https://github.com/intersectmbo/cardano-ledger/issues/3486
instance EraPParams era => DecShareCBOR (ConwayGovState era) where
  decShareCBOR _ =
    decode $
      RecD ConwayGovState
        <! From
        <! From
        <! From
        <! From
        <! From
        <! From

instance EraPParams era => DecCBOR (ConwayGovState era) where
  decCBOR =
    decode $
      RecD ConwayGovState
        <! From
        <! From
        <! From
        <! From
        <! From
        <! From

instance EraPParams era => EncCBOR (ConwayGovState era) where
  encCBOR ConwayGovState {..} =
    encode $
      Rec ConwayGovState
        !> To cgsProposals
        !> To cgsCommittee
        !> To cgsConstitution
        !> To cgsCurPParams
        !> To cgsPrevPParams
        !> To cgsDRepPulsingState

instance EraPParams era => ToCBOR (ConwayGovState era) where
  toCBOR = toEraCBOR @era

instance EraPParams era => FromCBOR (ConwayGovState era) where
  fromCBOR = fromEraCBOR @era

instance EraPParams era => Default (ConwayGovState era) where
  def = ConwayGovState def def def def def (DRComplete def def)

instance EraPParams era => NFData (ConwayGovState era)

instance EraPParams era => NoThunks (ConwayGovState era)

instance EraPParams era => ToJSON (ConwayGovState era) where
  toJSON = object . toConwayGovPairs
  toEncoding = pairs . mconcat . toConwayGovPairs

toConwayGovPairs :: (KeyValue e a, EraPParams era) => ConwayGovState era -> [a]
toConwayGovPairs cg@(ConwayGovState _ _ _ _ _ _) =
  let ConwayGovState {..} = cg
   in [ "proposals" .= cgsProposals
      , "nextRatifyState" .= extractDRepPulsingState cgsDRepPulsingState
      , "committee" .= cgsCommittee
      , "constitution" .= cgsConstitution
      , "currentPParams" .= cgsCurPParams
      , "previousPParams" .= cgsPrevPParams
      ]

instance EraPParams (ConwayEra c) => EraGov (ConwayEra c) where
  type GovState (ConwayEra c) = ConwayGovState (ConwayEra c)

  curPParamsGovStateL = cgsCurPParamsL

  prevPParamsGovStateL = cgsPrevPParamsL

  obligationGovState st =
    Obligations
      { oblProposal = foldMap' gasDeposit $ proposalsActions (st ^. cgsProposalsL)
      , oblDRep = Coin 0
      , oblStake = Coin 0
      , oblPool = Coin 0
      }

class EraGov era => ConwayEraGov era where
  constitutionGovStateL :: Lens' (GovState era) (Constitution era)
  proposalsGovStateL :: Lens' (GovState era) (Proposals era)
  drepPulsingStateGovStateL :: Lens' (GovState era) (DRepPulsingState era)
  committeeGovStateL :: Lens' (GovState era) (StrictMaybe (Committee era))

instance Crypto c => ConwayEraGov (ConwayEra c) where
  constitutionGovStateL = cgsConstitutionL
  proposalsGovStateL = cgsProposalsL
  drepPulsingStateGovStateL = cgsDRepPulsingStateL
  committeeGovStateL = cgsCommitteeL

-- ===================================================================
-- Lenses for access to (DRepPulsingState era)

newEpochStateDRepPulsingStateL ::
  ConwayEraGov era => Lens' (NewEpochState era) (DRepPulsingState era)
newEpochStateDRepPulsingStateL =
  nesEsL . esLStateL . lsUTxOStateL . utxosGovStateL . drepPulsingStateGovStateL

epochStateDRepPulsingStateL :: ConwayEraGov era => Lens' (EpochState era) (DRepPulsingState era)
epochStateDRepPulsingStateL = esLStateL . lsUTxOStateL . utxosGovStateL . drepPulsingStateGovStateL

setCompleteDRepPulsingState ::
  GovState era ~ ConwayGovState era =>
  PulsingSnapshot era ->
  RatifyState era ->
  EpochState era ->
  EpochState era
setCompleteDRepPulsingState snapshot ratifyState epochState =
  epochState
    & epochStateGovStateL . cgsDRepPulsingStateL
      .~ DRComplete snapshot ratifyState

-- | Refresh the pulser in the EpochState using all the new data that is needed to compute
-- the RatifyState when pulsing completes.
setFreshDRepPulsingState ::
  ( GovState era ~ ConwayGovState era
  , Monad m
  , RunConwayRatify era
  , ConwayEraGov era
  ) =>
  EpochNo ->
  PoolDistr (EraCrypto era) ->
  EpochState era ->
  ReaderT Globals m (EpochState era)
setFreshDRepPulsingState epochNo stakePoolDistr epochState = do
  -- When we are finished with the pulser that was started at the last epoch boundary, we
  -- need to initialize a fresh DRep pulser. We do so by computing the pulse size and
  -- gathering the data, which we will snapshot inside the pulser. We expect approximately
  -- 10*k-many blocks to be produced each epoch, where `k` value is the stability
  -- window. We must ensure for secure operation of the Hard Fork Combinator that we have
  -- the new EnactState available 2 stability windows before the end of the epoch, while
  -- spreading out stake distribution computation throughout the first 8 stability
  -- windows. Therefore, we divide the number of stake credentials by 8*k
  globals <- ask
  let ledgerState = epochState ^. esLStateL
      utxoState = lsUTxOState ledgerState
      stakeDistr = credMap $ utxosStakeDistr utxoState
      certState = lsCertState ledgerState
      dState = certDState certState
      vState = certVState certState
      govState = epochState ^. epochStateGovStateL
      stakeSize = Map.size stakeDistr
      -- Maximum number of blocks we are allowed to roll back
      k = securityParameter globals
      pulseSize = max 1 (ceiling (toInteger stakeSize % (8 * toInteger k)))
      epochState' =
        epochState
          & epochStateGovStateL . cgsDRepPulsingStateL
            .~ DRPulsing
              ( DRepPulser
                  { dpPulseSize = pulseSize
                  , dpUMap = dsUnified dState
                  , dpBalance = stakeDistr -- used as the balance of things left to iterate over
                  , dpStakeDistr = stakeDistr -- used as part of the snapshot
                  , dpStakePoolDistr = stakePoolDistr
                  , dpDRepDistr = Map.empty -- The partial result starts as the empty map
                  , dpDRepState = vsDReps vState
                  , dpCurrentEpoch = epochNo
                  , dpCommitteeState = vsCommitteeState vState
                  , dpEnactState =
                      mkEnactState govState
                        & ensTreasuryL .~ epochState ^. epochStateTreasuryL
                  , dpProposals = proposalsActions (govState ^. cgsProposalsL)
                  , dpGlobals = globals
                  }
              )
  pure epochState'

-- | Force computation of DRep stake distribution and figure out the next enact
-- state. This operation is useful in cases when access to new EnactState or DRep stake
-- distribution is needed more than once. It is safe to call this function at any
-- point. Whenever pulser is already in computed state this will be a noop.
forceDRepPulsingState :: ConwayEraGov era => NewEpochState era -> NewEpochState era
forceDRepPulsingState nes = nes & newEpochStateDRepPulsingStateL %~ completeDRepPulsingState
