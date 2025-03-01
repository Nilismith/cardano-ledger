{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module Test.Cardano.Ledger.Conway.Imp.EnactSpec (spec) where

import Cardano.Ledger.Address
import Cardano.Ledger.BaseTypes
import Cardano.Ledger.Coin
import Cardano.Ledger.Conway.Core
import Cardano.Ledger.Conway.Governance
import Cardano.Ledger.Conway.PParams
import Cardano.Ledger.Conway.Rules
import Cardano.Ledger.Credential
import Cardano.Ledger.Shelley.LedgerState
import Cardano.Ledger.Val (zero, (<->))
import Control.Monad (forM)
import Control.State.Transition.Extended (STS (..))
import Data.Default.Class (def)
import Data.Foldable (foldl', traverse_)
import qualified Data.List.NonEmpty as NE
import qualified Data.Map.Strict as Map
import Data.Ratio ((%))
import qualified Data.Sequence as Seq
import Data.Word (Word64)
import Lens.Micro
import Test.Cardano.Ledger.Conway.ImpTest
import Test.Cardano.Ledger.Core.Rational
import Test.Cardano.Ledger.Imp.Common
import Type.Reflection (Typeable)

spec ::
  forall era.
  ( ConwayEraImp era
  , NFData (Event (EraRule "ENACT" era))
  , ToExpr (Event (EraRule "ENACT" era))
  , Eq (Event (EraRule "ENACT" era))
  , Typeable (Event (EraRule "ENACT" era))
  ) =>
  SpecWith (ImpTestState era)
spec =
  describe "ENACT" $ do
    treasuryWithdrawalsSpec
    hardForkInitiationSpec
    noConfidenceSpec
    constitutionSpec
    actionPrioritySpec

treasuryWithdrawalsSpec ::
  forall era.
  ( ConwayEraImp era
  , NFData (Event (EraRule "ENACT" era))
  , ToExpr (Event (EraRule "ENACT" era))
  , Eq (Event (EraRule "ENACT" era))
  , Typeable (Event (EraRule "ENACT" era))
  ) =>
  SpecWith (ImpTestState era)
treasuryWithdrawalsSpec =
  describe "Treasury withdrawals" $ do
    it "Modify EnactState as expected" $ do
      rewardAcount1 <- registerRewardAccount
      govActionId <- submitTreasuryWithdrawals [(rewardAcount1, Coin 666)]
      gas <- getGovActionState govActionId
      let govAction = gasAction gas
      enactStateInit <- getEnactState
      let signal =
            EnactSignal
              { esGovActionId = govActionId
              , esGovAction = govAction
              }
          enactState =
            enactStateInit
              { ensTreasury = Coin 1000
              }
      enactState' <- runImpRule @"ENACT" () enactState signal
      ensWithdrawals enactState' `shouldBe` [(raCredential rewardAcount1, Coin 666)]

      rewardAcount2 <- registerRewardAccount
      let withdrawals' =
            [ (rewardAcount1, Coin 111)
            , (rewardAcount2, Coin 222)
            ]
      govActionId' <- submitTreasuryWithdrawals withdrawals'
      gas' <- getGovActionState govActionId'
      let govAction' = gasAction gas'
      let signal' =
            EnactSignal
              { esGovActionId = govActionId'
              , esGovAction = govAction'
              }

      enactState'' <- runImpRule @"ENACT" () enactState' signal'

      ensWithdrawals enactState''
        `shouldBe` [ (raCredential rewardAcount1, Coin 777)
                   , (raCredential rewardAcount2, Coin 222)
                   ]
      ensTreasury enactState'' `shouldBe` Coin 1

    it "Withdrawals exceeding treasury submitted in a single proposal" $ do
      (drepC, committeeC, _) <- electBasicCommittee
      modifyPParams $ ppGovActionLifetimeL .~ EpochInterval 5
      initialTreasury <- getTreasury
      numWithdrawals <- choose (1, 10)
      withdrawals <- genWithdrawalsExceeding initialTreasury numWithdrawals

      void $ enactTreasuryWithdrawals withdrawals drepC committeeC
      checkNoWithdrawal initialTreasury withdrawals

      let sumRequested = foldMap snd withdrawals

      impAnn "Submit a treasury donation that can cover the withdrawals" $ do
        let tx =
              mkBasicTx mkBasicTxBody
                & bodyTxL . treasuryDonationTxBodyL .~ (sumRequested <-> initialTreasury)
        submitTx_ tx
      passNEpochs 2
      getTreasury `shouldReturn` zero
      sumRewardAccounts withdrawals `shouldReturn` sumRequested

    it "Withdrawals exceeding maxBound Word64 submitted in a single proposal" $ do
      (drepC, committeeC, _) <- electBasicCommittee
      modifyPParams $ ppGovActionLifetimeL .~ EpochInterval 5
      initialTreasury <- getTreasury
      numWithdrawals <- choose (1, 10)
      withdrawals <- genWithdrawalsExceeding (Coin (fromIntegral (maxBound :: Word64))) numWithdrawals
      void $ enactTreasuryWithdrawals withdrawals drepC committeeC
      checkNoWithdrawal initialTreasury withdrawals

    it "Withdrawals exceeding treasury submitted in several proposals within the same epoch" $ do
      (drepC, committeeC, _) <- electBasicCommittee
      modifyPParams $ ppGovActionLifetimeL .~ EpochInterval 5
      initialTreasury <- getTreasury
      numWithdrawals <- choose (1, 10)
      withdrawals <- genWithdrawalsExceeding initialTreasury numWithdrawals

      impAnn "submit in individual proposals in the same epoch" $ do
        traverse_
          ( \w -> do
              gaId <- submitTreasuryWithdrawals @era [w]
              submitYesVote_ (DRepVoter drepC) gaId
              submitYesVote_ (CommitteeVoter committeeC) gaId
          )
          withdrawals
        passNEpochs 2

        let expectedTreasury =
              foldl'
                ( \acc (_, x) ->
                    if acc >= x
                      then acc <-> x
                      else acc
                )
                initialTreasury
                withdrawals

        getTreasury `shouldReturn` expectedTreasury
        -- check that the sum of the rewards matches what was spent from the treasury
        sumRewardAccounts withdrawals `shouldReturn` (initialTreasury <-> expectedTreasury)
  where
    getTreasury = getsNES (nesEsL . esAccountStateL . asTreasuryL)
    sumRewardAccounts withdrawals = mconcat <$> traverse (getRewardAccountAmount . fst) withdrawals
    genWithdrawalsExceeding (Coin val) n = do
      pcts <- replicateM (n - 1) $ choose (1, 100)
      let tot = sum pcts
      Positive excess <- arbitrary
      let amounts = Coin excess : map (\x -> Coin $ ceiling ((x * val) % tot)) pcts
      forM amounts $ \amount -> (,amount) <$> registerRewardAccount
    checkNoWithdrawal initialTreasury withdrawals = do
      getTreasury `shouldReturn` initialTreasury
      sumRewardAccounts withdrawals `shouldReturn` zero

hardForkInitiationSpec :: ConwayEraImp era => SpecWith (ImpTestState era)
hardForkInitiationSpec =
  it "HardForkInitiation" $ do
    (_, committeeMember, _) <- electBasicCommittee
    modifyPParams $ \pp ->
      pp
        & ppDRepVotingThresholdsL
          %~ ( \dvt ->
                dvt
                  { dvtHardForkInitiation = 2 %! 3
                  }
             )
        & ppPoolVotingThresholdsL
          %~ ( \pvt ->
                pvt
                  { pvtHardForkInitiation = 2 %! 3
                  }
             )
        & ppGovActionLifetimeL
          .~ EpochInterval 20
    _ <- setupPoolWithStake $ Coin 22_000_000
    (stakePoolId1, _, _) <- setupPoolWithStake $ Coin 22_000_000
    (stakePoolId2, _, _) <- setupPoolWithStake $ Coin 22_000_000
    (dRep1, _, _) <- setupSingleDRep 11_000_000
    (dRep2, _, _) <- setupSingleDRep 11_000_000
    curProtVer <- getsNES $ nesEsL . curPParamsEpochStateL . ppProtocolVersionL
    nextMajorVersion <- succVersion $ pvMajor curProtVer
    let nextProtVer = curProtVer {pvMajor = nextMajorVersion}
    govActionId <- submitGovAction $ HardForkInitiation SNothing nextProtVer
    submitYesVote_ (CommitteeVoter committeeMember) govActionId
    submitYesVote_ (DRepVoter (KeyHashObj dRep1)) govActionId
    submitYesVote_ (StakePoolVoter stakePoolId1) govActionId
    passNEpochs 2
    getsNES (nesEsL . curPParamsEpochStateL . ppProtocolVersionL) `shouldReturn` curProtVer
    submitYesVote_ (DRepVoter (KeyHashObj dRep2)) govActionId
    passNEpochs 2
    getsNES (nesEsL . curPParamsEpochStateL . ppProtocolVersionL) `shouldReturn` curProtVer
    submitYesVote_ (StakePoolVoter stakePoolId2) govActionId
    passNEpochs 2
    getsNES (nesEsL . curPParamsEpochStateL . ppProtocolVersionL) `shouldReturn` nextProtVer

noConfidenceSpec :: forall era. ConwayEraImp era => SpecWith (ImpTestState era)
noConfidenceSpec =
  it "NoConfidence" $ do
    modifyPParams $ \pp ->
      pp
        & ppDRepVotingThresholdsL . dvtCommitteeNoConfidenceL .~ 1 %! 2
        & ppPoolVotingThresholdsL . pvtCommitteeNoConfidenceL .~ 1 %! 2
        & ppCommitteeMaxTermLengthL .~ EpochInterval 200
    let
      getCommittee =
        getsNES $
          nesEsL . esLStateL . lsUTxOStateL . utxosGovStateL . committeeGovStateL
      assertNoCommittee :: HasCallStack => ImpTestM era ()
      assertNoCommittee =
        do
          committee <- getCommittee
          impAnn "There should not be a committee" $ committee `shouldBe` SNothing
    assertNoCommittee
    khCC <- freshKeyHash
    (drep, _, _) <- setupSingleDRep 1_000_000
    let committeeMap =
          Map.fromList
            [ (KeyHashObj khCC, EpochNo 50)
            ]
    prevGaidCommittee@(GovPurposeId gaidCommittee) <-
      electCommittee
        SNothing
        drep
        mempty
        committeeMap
    (khSPO, _, _) <- setupPoolWithStake $ Coin 42_000_000
    logStakeDistr
    submitYesVote_ (StakePoolVoter khSPO) gaidCommittee
    replicateM_ 4 passEpoch
    impAnn "Committee should be elected" $ do
      committee <- getCommittee
      committee `shouldBe` SJust (Committee committeeMap $ 1 %! 2)
    pp <- getsNES $ nesEsL . curPParamsEpochStateL
    returnAddr <- registerRewardAccount
    gaidNoConf <-
      submitProposal $
        ProposalProcedure
          { pProcReturnAddr = returnAddr
          , pProcGovAction = NoConfidence (SJust prevGaidCommittee)
          , pProcDeposit = pp ^. ppGovActionDepositL
          , pProcAnchor = def
          }
    submitYesVote_ (StakePoolVoter khSPO) gaidNoConf
    submitYesVote_ (DRepVoter $ KeyHashObj drep) gaidNoConf
    replicateM_ 4 passEpoch
    assertNoCommittee

constitutionSpec :: ConwayEraImp era => SpecWith (ImpTestState era)
constitutionSpec =
  it "Constitution" $ do
    (dRep, committeeMember, _) <- electBasicCommittee
    (govActionId, constitution) <- submitConstitution SNothing

    proposalsBeforeVotes <- getsNES $ newEpochStateGovStateL . proposalsGovStateL
    pulserBeforeVotes <- getsNES newEpochStateDRepPulsingStateL

    submitYesVote_ (DRepVoter dRep) govActionId
    submitYesVote_ (CommitteeVoter committeeMember) govActionId

    proposalsAfterVotes <- getsNES $ newEpochStateGovStateL . proposalsGovStateL
    pulserAfterVotes <- getsNES newEpochStateDRepPulsingStateL

    impAnn "Votes are recorded in the proposals" $ do
      let proposalsWithVotes =
            proposalsAddVote
              (CommitteeVoter committeeMember)
              VoteYes
              govActionId
              ( proposalsAddVote
                  (DRepVoter dRep)
                  VoteYes
                  govActionId
                  proposalsBeforeVotes
              )
      proposalsAfterVotes `shouldBe` proposalsWithVotes

    impAnn "Pulser has not changed" $
      pulserAfterVotes `shouldBe` pulserBeforeVotes

    passEpoch

    impAnn "New constitution is not enacted after one epoch" $ do
      constitutionAfterOneEpoch <- getsNES $ newEpochStateGovStateL . constitutionGovStateL
      constitutionAfterOneEpoch `shouldBe` def

    impAnn "Pulser should reflect the constitution to be enacted" $ do
      pulser <- getsNES newEpochStateDRepPulsingStateL
      let ratifyState = extractDRepPulsingState pulser
      gasId <$> rsEnacted ratifyState `shouldBe` govActionId Seq.:<| Seq.Empty
      rsEnactState ratifyState ^. ensConstitutionL `shouldBe` constitution

    passEpoch

    impAnn "Constitution is enacted after two epochs" $ do
      curConstitution <- getsNES $ newEpochStateGovStateL . constitutionGovStateL
      curConstitution `shouldBe` constitution

    impAnn "Pulser is reset" $ do
      pulser <- getsNES newEpochStateDRepPulsingStateL
      let pulserRatifyState = extractDRepPulsingState pulser
      rsEnacted pulserRatifyState `shouldBe` Seq.empty
      enactState <- getEnactState
      rsEnactState pulserRatifyState `shouldBe` enactState

actionPrioritySpec ::
  forall era.
  ConwayEraImp era =>
  SpecWith (ImpTestState era)
actionPrioritySpec =
  describe "Competing proposals ratified in the same epoch" $ do
    it
      "higher action priority wins"
      $ do
        (drepC, _, gpi) <- electBasicCommittee
        (poolKH, _, _) <- setupPoolWithStake $ Coin 1_000_000
        modifyPParams $ ppGovActionLifetimeL .~ EpochInterval 5
        cc <- KeyHashObj <$> freshKeyHash
        gai1 <-
          submitGovAction $
            UpdateCommittee (SJust gpi) mempty (Map.singleton cc (EpochNo 30)) $
              1 %! 2
        -- gai2 is the first action of a higher priority
        gai2 <- submitGovAction $ NoConfidence $ SJust gpi
        gai3 <- submitGovAction $ NoConfidence $ SJust gpi
        traverse_ @[]
          ( \gaid -> do
              submitYesVote_ (DRepVoter drepC) gaid
              submitYesVote_ (StakePoolVoter poolKH) gaid
          )
          [gai1, gai2, gai3]
        passNEpochs 2
        getLastEnactedCommittee
          `shouldReturn` SJust (GovPurposeId gai2)
        expectNoCurrentProposals

        committee <-
          getsNES $
            nesEsL . esLStateL . lsUTxOStateL . utxosGovStateL . committeeGovStateL
        committee `shouldBe` SNothing

    let val1 = Coin 1_000_001
    let val2 = Coin 1_000_002
    let val3 = Coin 1_000_003

    it "proposals of same priority are enacted in order of submission" $ do
      (drepC, committeeC, _) <- electBasicCommittee
      modifyPParams $ ppGovActionLifetimeL .~ EpochInterval 5
      pGai0 <-
        submitParameterChange
          SNothing
          $ def & ppuDRepDepositL .~ SJust val1
      pGai1 <-
        submitParameterChange
          (SJust $ GovPurposeId pGai0)
          $ def & ppuDRepDepositL .~ SJust val2
      pGai2 <-
        submitParameterChange
          (SJust $ GovPurposeId pGai1)
          $ def & ppuDRepDepositL .~ SJust val3
      traverse_ @[]
        ( \gaid -> do
            submitYesVote_ (DRepVoter drepC) gaid
            submitYesVote_ (CommitteeVoter committeeC) gaid
        )
        [pGai0, pGai1, pGai2]
      passNEpochs 2
      getLastEnactedParameterChange
        `shouldReturn` SJust (GovPurposeId pGai2)
      expectNoCurrentProposals
      getsNES (nesEsL . curPParamsEpochStateL . ppDRepDepositL)
        `shouldReturn` val3

    it "only the first action of a transaction gets enacted" $ do
      (drepC, committeeC, _) <- electBasicCommittee
      modifyPParams $ ppGovActionLifetimeL .~ EpochInterval 5
      gaids <-
        submitGovActions $
          NE.fromList
            [ ParameterChange
                SNothing
                (def & ppuDRepDepositL .~ SJust val1)
                SNothing
            , ParameterChange
                SNothing
                (def & ppuDRepDepositL .~ SJust val2)
                SNothing
            , ParameterChange
                SNothing
                (def & ppuDRepDepositL .~ SJust val3)
                SNothing
            ]
      traverse_
        ( \gaid -> do
            submitYesVote_ (DRepVoter drepC) gaid
            submitYesVote_ (CommitteeVoter committeeC) gaid
        )
        gaids
      passNEpochs 2
      getsNES (nesEsL . curPParamsEpochStateL . ppDRepDepositL)
        `shouldReturn` val1
      expectNoCurrentProposals
