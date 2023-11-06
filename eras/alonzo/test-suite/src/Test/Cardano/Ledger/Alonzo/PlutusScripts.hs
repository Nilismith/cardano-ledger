-- | This file is generated by plutus-preprocessor/src/Main.hs
module Test.Cardano.Ledger.Alonzo.PlutusScripts where

import Cardano.Ledger.Alonzo.Scripts (AlonzoScript (PlutusScript), CostModel, mkCostModel)
import Cardano.Ledger.Plutus.Language (Language (..), Plutus (..), PlutusBinary (..))
import Data.ByteString.Short (pack)
import Data.Either (fromRight)
import qualified PlutusLedgerApi.Test.V1.EvaluationContext as V1
import qualified PlutusLedgerApi.Test.V1.EvaluationContext as V2

testingCostModelV1 :: CostModel
testingCostModelV1 =
  fromRight (error "testingCostModelV1 is not well-formed") $
    mkCostModel PlutusV1 (0 <$ V1.costModelParamsForTesting)

testingCostModelV2 :: CostModel
testingCostModelV2 =
  fromRight (error "testingCostModelV2 is not well-formed") $
    mkCostModel PlutusV2 (0 <$ V2.costModelParamsForTesting)

{- Preproceesed Plutus Script
guessTheNumber'2_0 :: PlutusTx.Builtins.Internal.BuiltinData ->
                      PlutusTx.Builtins.Internal.BuiltinData -> ()
guessTheNumber'2_0 d1_1 d2_2 = if d1_1 PlutusTx.Eq.== d2_2
                                then GHC.Tuple.()
                                else PlutusTx.Builtins.error GHC.Tuple.()
-}

guessTheNumber2 :: AlonzoScript era
guessTheNumber2 =
  (PlutusScript . Plutus PlutusV1 . PlutusBinary . pack . concat)
    [ [88, 25, 1, 0, 0, 34, 83, 53, 51, 53, 115, 70, 110, 188, 0]
    , [128, 4, 72, 128, 8, 72, 128, 4, 68, 128, 4, 89]
    ]

{- Preproceesed Plutus Script
guessTheNumber'3_0 :: PlutusTx.Builtins.Internal.BuiltinData ->
                      PlutusTx.Builtins.Internal.BuiltinData ->
                      PlutusTx.Builtins.Internal.BuiltinData -> ()
guessTheNumber'3_0 d1_1 d2_2 _d3_3 = if d1_1 PlutusTx.Eq.== d2_2
                                      then GHC.Tuple.()
                                      else PlutusTx.Builtins.error GHC.Tuple.()
-}

guessTheNumber3 :: AlonzoScript era
guessTheNumber3 =
  (PlutusScript . Plutus PlutusV1 . PlutusBinary . pack . concat)
    [ [88, 26, 1, 0, 0, 34, 37, 51, 83, 51, 87, 52, 102, 235, 192]
    , [12, 0, 132, 136, 0, 132, 136, 0, 68, 72, 0, 69, 129]
    ]

{- Preproceesed Plutus Script
evendata'_0 :: PlutusTx.Builtins.Internal.BuiltinData ->
               PlutusTx.Builtins.Internal.BuiltinData ->
               PlutusTx.Builtins.Internal.BuiltinData -> ()
evendata'_0 d1_1 _d2_2 _d3_3 = let n_4 = PlutusTx.Builtins.unsafeDataAsI d1_1
                                in if PlutusTx.Prelude.modulo n_4 2 PlutusTx.Eq.== 0
                                    then GHC.Tuple.()
                                    else PlutusTx.Builtins.error GHC.Tuple.()
-}

evendata3 :: AlonzoScript era
evendata3 =
  (PlutusScript . Plutus PlutusV1 . PlutusBinary . pack . concat)
    [ [88, 38, 1, 0, 0, 34, 37, 51, 83, 35, 51, 87, 52, 102, 225]
    , [192, 5, 32, 0, 18, 32, 2, 18, 32, 1, 50, 51, 112, 192, 2]
    , [144, 2, 27, 173, 0, 49, 18, 0, 17, 97]
    ]

{- Preproceesed Plutus Script
odddata'_0 :: PlutusTx.Builtins.Internal.BuiltinData ->
              PlutusTx.Builtins.Internal.BuiltinData ->
              PlutusTx.Builtins.Internal.BuiltinData -> ()
odddata'_0 d1_1 _d2_2 _d3_3 = let n_4 = PlutusTx.Builtins.unsafeDataAsI d1_1
                               in if PlutusTx.Prelude.modulo n_4 2 PlutusTx.Eq.== 1
                                   then GHC.Tuple.()
                                   else PlutusTx.Builtins.error GHC.Tuple.()
-}

odddata3 :: AlonzoScript era
odddata3 =
  (PlutusScript . Plutus PlutusV1 . PlutusBinary . pack . concat)
    [ [88, 38, 1, 0, 0, 34, 37, 51, 83, 35, 51, 87, 52, 102, 225]
    , [192, 5, 32, 2, 18, 32, 2, 18, 32, 1, 50, 51, 112, 192, 2]
    , [144, 2, 27, 173, 0, 49, 18, 0, 17, 97]
    ]

{- Preproceesed Plutus Script
evenRedeemer'_0 :: PlutusTx.Builtins.Internal.BuiltinData ->
                   PlutusTx.Builtins.Internal.BuiltinData ->
                   PlutusTx.Builtins.Internal.BuiltinData -> ()
evenRedeemer'_0 _d1_1 d2_2 _d3_3 = let n_4 = PlutusTx.Builtins.unsafeDataAsI d2_2
                                    in if PlutusTx.Prelude.modulo n_4 2 PlutusTx.Eq.== 0
                                        then GHC.Tuple.()
                                        else PlutusTx.Builtins.error GHC.Tuple.()
-}

evenRedeemer3 :: AlonzoScript era
evenRedeemer3 =
  (PlutusScript . Plutus PlutusV1 . PlutusBinary . pack . concat)
    [ [88, 38, 1, 0, 0, 34, 37, 51, 83, 35, 51, 87, 52, 102, 225]
    , [192, 5, 32, 0, 18, 32, 2, 18, 32, 1, 50, 51, 112, 192, 2]
    , [144, 2, 27, 173, 0, 33, 18, 0, 17, 97]
    ]

{- Preproceesed Plutus Script
oddRedeemer'_0 :: PlutusTx.Builtins.Internal.BuiltinData ->
                  PlutusTx.Builtins.Internal.BuiltinData ->
                  PlutusTx.Builtins.Internal.BuiltinData -> ()
oddRedeemer'_0 _d1_1 d2_2 _d3_3 = let n_4 = PlutusTx.Builtins.unsafeDataAsI d2_2
                                   in if PlutusTx.Prelude.modulo n_4 2 PlutusTx.Eq.== 1
                                       then GHC.Tuple.()
                                       else PlutusTx.Builtins.error GHC.Tuple.()
-}

oddRedeemer3 :: AlonzoScript era
oddRedeemer3 =
  (PlutusScript . Plutus PlutusV1 . PlutusBinary . pack . concat)
    [ [88, 38, 1, 0, 0, 34, 37, 51, 83, 35, 51, 87, 52, 102, 225]
    , [192, 5, 32, 2, 18, 32, 2, 18, 32, 1, 50, 51, 112, 192, 2]
    , [144, 2, 27, 173, 0, 33, 18, 0, 17, 97]
    ]

{- Preproceesed Plutus Script
sumsTo10'_0 :: PlutusTx.Builtins.Internal.BuiltinData ->
               PlutusTx.Builtins.Internal.BuiltinData ->
               PlutusTx.Builtins.Internal.BuiltinData -> ()
sumsTo10'_0 d1_1 d2_2 _d3_3 = let {n_4 = PlutusTx.Builtins.unsafeDataAsI d1_1;
                                   m_5 = PlutusTx.Builtins.unsafeDataAsI d2_2}
                               in if (m_5 PlutusTx.Numeric.+ n_4) PlutusTx.Eq.== 10
                                   then GHC.Tuple.()
                                   else PlutusTx.Builtins.error GHC.Tuple.()
-}

sumsTo103 :: AlonzoScript era
sumsTo103 =
  (PlutusScript . Plutus PlutusV1 . PlutusBinary . pack . concat)
    [ [88, 47, 1, 0, 0, 50, 34, 37, 51, 83, 35, 51, 87, 52, 102]
    , [225, 192, 5, 32, 20, 18, 32, 2, 18, 32, 1, 50, 50, 51, 112]
    , [0, 4, 0, 38, 0, 160, 8, 96, 8, 0, 66, 36, 0, 34, 196]
    , [110, 180, 0, 65]
    ]

{- Preproceesed Plutus Script
oddRedeemer2'_0 :: PlutusTx.Builtins.Internal.BuiltinData ->
                   PlutusTx.Builtins.Internal.BuiltinData -> ()
oddRedeemer2'_0 d1_1 _d3_2 = let n_3 = PlutusTx.Builtins.unsafeDataAsI d1_1
                              in if PlutusTx.Prelude.modulo n_3 2 PlutusTx.Eq.== 1
                                  then GHC.Tuple.()
                                  else PlutusTx.Builtins.error GHC.Tuple.()
-}

oddRedeemer2 :: AlonzoScript era
oddRedeemer2 =
  (PlutusScript . Plutus PlutusV1 . PlutusBinary . pack . concat)
    [ [88, 38, 1, 0, 0, 34, 83, 53, 50, 51, 53, 115, 70, 110, 28]
    , [0, 82, 0, 33, 34, 0, 33, 34, 0, 19, 35, 55, 12, 0, 41]
    , [0, 33, 186, 208, 2, 17, 32, 1, 22, 1]
    ]

{- Preproceesed Plutus Script
evenRedeemer2'_0 :: PlutusTx.Builtins.Internal.BuiltinData ->
                    PlutusTx.Builtins.Internal.BuiltinData -> ()
evenRedeemer2'_0 d1_1 _d3_2 = let n_3 = PlutusTx.Builtins.unsafeDataAsI d1_1
                               in if PlutusTx.Prelude.modulo n_3 2 PlutusTx.Eq.== 0
                                   then GHC.Tuple.()
                                   else PlutusTx.Builtins.error GHC.Tuple.()
-}

evenRedeemer2 :: AlonzoScript era
evenRedeemer2 =
  (PlutusScript . Plutus PlutusV1 . PlutusBinary . pack . concat)
    [ [88, 38, 1, 0, 0, 34, 83, 53, 50, 51, 53, 115, 70, 110, 28]
    , [0, 82, 0, 1, 34, 0, 33, 34, 0, 19, 35, 55, 12, 0, 41]
    , [0, 33, 186, 208, 2, 17, 32, 1, 22, 1]
    ]

{- Preproceesed Plutus Script
redeemerIs102'_0 :: PlutusTx.Builtins.Internal.BuiltinData ->
                    PlutusTx.Builtins.Internal.BuiltinData -> ()
redeemerIs102'_0 d1_1 _d3_2 = let n_3 = PlutusTx.Builtins.unsafeDataAsI d1_1
                               in if n_3 PlutusTx.Eq.== 10
                                   then GHC.Tuple.()
                                   else PlutusTx.Builtins.error GHC.Tuple.()
-}

redeemerIs102 :: AlonzoScript era
redeemerIs102 =
  (PlutusScript . Plutus PlutusV1 . PlutusBinary . pack . concat)
    [ [88, 30, 1, 0, 0, 34, 83, 53, 50, 51, 53, 115, 70, 110, 28]
    , [0, 82, 1, 65, 34, 0, 33, 34, 0, 19, 117, 160, 4, 34, 64]
    , [2, 45]
    ]

{- Preproceesed Plutus Script
guessTheNumber'2_0 :: PlutusTx.Builtins.Internal.BuiltinData ->
                      PlutusTx.Builtins.Internal.BuiltinData -> ()
guessTheNumber'2_0 d1_1 d2_2 = if d1_1 PlutusTx.Eq.== d2_2
                                then GHC.Tuple.()
                                else PlutusTx.Builtins.error GHC.Tuple.()
-}

guessTheNumber2V2 :: AlonzoScript era
guessTheNumber2V2 =
  (PlutusScript . Plutus PlutusV2 . PlutusBinary . pack . concat)
    [ [88, 25, 1, 0, 0, 34, 83, 53, 51, 53, 115, 70, 110, 188, 0]
    , [128, 4, 72, 128, 8, 72, 128, 4, 68, 128, 4, 89]
    ]

{- Preproceesed Plutus Script
guessTheNumber'3_0 :: PlutusTx.Builtins.Internal.BuiltinData ->
                      PlutusTx.Builtins.Internal.BuiltinData ->
                      PlutusTx.Builtins.Internal.BuiltinData -> ()
guessTheNumber'3_0 d1_1 d2_2 _d3_3 = if d1_1 PlutusTx.Eq.== d2_2
                                      then GHC.Tuple.()
                                      else PlutusTx.Builtins.error GHC.Tuple.()
-}

guessTheNumber3V2 :: AlonzoScript era
guessTheNumber3V2 =
  (PlutusScript . Plutus PlutusV2 . PlutusBinary . pack . concat)
    [ [88, 26, 1, 0, 0, 34, 37, 51, 83, 51, 87, 52, 102, 235, 192]
    , [12, 0, 132, 136, 0, 132, 136, 0, 68, 72, 0, 69, 129]
    ]
