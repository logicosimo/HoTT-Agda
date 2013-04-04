{-# OPTIONS --without-K #-}

open import Base
open import Homotopy.Pushout
open import Homotopy.VanKampen.Guide

module Homotopy.VanKampen.Code {i} (d : pushout-diag i)
  (l : legend i (pushout-diag.C d)) where

  open import Homotopy.Truncation
  open import Homotopy.PathTruncation

  private
    module PackA1 (d : pushout-diag i)
      (l : legend i (pushout-diag.C d)) (n : legend.name l) where
      open pushout-diag d
      open legend l

      -- Code from A.
      open import Homotopy.VanKampen.SplitCode d l (f $ loc n)
      -- Code from B. F for `flipped'.
      import Homotopy.VanKampen.SplitCode (pushout-diag-flip d) l (g $ loc n) as F

      private
        ap⇒bp-split : (∀ {a₂} → code-a a₂ → F.code-b a₂)
                    × (∀ {b₂} → code-b b₂ → F.code-a b₂)
        ap⇒bp-split = code-rec-nondep
          F.code-b ⦃ λ _ → F.code-b-is-set _ ⦄
          F.code-a ⦃ λ _ → F.code-a-is-set _ ⦄
          (λ p → F.⟧a refl₀ _ F.a⟦ n ⟧b p)
          (λ n₁ pco p → pco F.a⟦ n₁ ⟧b p)
          (λ n₁ pco p → pco F.b⟦ n₁ ⟧a p)
          (λ n₁ pco → F.code-b-refl-refl n₁ pco)
          (λ n₁ pco → F.code-a-refl-refl n₁ pco)
          (λ n₁ pco n₂ r → F.code-ba-swap n₁ pco n₂ r)

      aa⇒ba : ∀ {a₂} → code-a a₂ → F.code-b a₂
      aa⇒ba = π₁ ap⇒bp-split
      ab⇒bb : ∀ {b₂} → code-b b₂ → F.code-a b₂
      ab⇒bb = π₂ ap⇒bp-split

  private
    module PackA2 (d : pushout-diag i)
      (l : legend i (pushout-diag.C d)) (n : legend.name l) where
      open pushout-diag d
      open legend l

      -- Code from A.
      open import Homotopy.VanKampen.SplitCode d l (f $ loc n)
      open PackA1 d l n public
      -- Code from B. F for `flipped'.
      private
        module F where
          open import Homotopy.VanKampen.SplitCode (pushout-diag-flip d) l (g $ loc n) public
          open PackA1 (pushout-diag-flip d) l n public

      private
        aba-glue-code-split : (∀ {a₂} (co : code-a a₂) → F.ab⇒bb (aa⇒ba co) ≡ co)
                            × (∀ {b₂} (co : code-b b₂) → F.aa⇒ba (ab⇒bb co) ≡ co)
      abstract
        aba-glue-code-split = code-rec
          (λ {a} co → F.ab⇒bb (aa⇒ba co) ≡ co)
          ⦃ λ _ → ≡-is-set $ code-a-is-set _ ⦄
          (λ {b} co → F.aa⇒ba (ab⇒bb co) ≡ co)
          ⦃ λ _ → ≡-is-set $ code-b-is-set _ ⦄
          (λ p →
            ⟧a refl₀ _ a⟦ n ⟧b refl₀ _ b⟦ n ⟧a p
                ≡⟨ code-a-merge n (refl₀ _) p ⟩
            ⟧a refl₀ _ ∘₀ p
                ≡⟨ ap (λ x → ⟧a x) $ refl₀-left-unit p ⟩∎
            ⟧a p
                ∎)
          (λ n₁ {co} eq p → ap (λ x → x b⟦ n₁ ⟧a p) eq)
          (λ n₁ {co} eq p → ap (λ x → x a⟦ n₁ ⟧b p) eq)
          (λ _ _ → code-has-all-cells₂-a _ _)
          (λ _ _ → code-has-all-cells₂-b _ _)
          (λ _ _ _ _ → code-has-all-cells₂-a _ _)

      aba-glue-code-a : ∀ {a₂} (co : code-a a₂) → F.ab⇒bb (aa⇒ba co) ≡ co
      aba-glue-code-a = π₁ aba-glue-code-split
      aba-glue-code-b : ∀ {b₂} (co : code-b b₂) → F.aa⇒ba (ab⇒bb co) ≡ co
      aba-glue-code-b = π₂ aba-glue-code-split

  private
    module PackA3 (d : pushout-diag i)
      (l : legend i (pushout-diag.C d)) (n : legend.name l) where
      open pushout-diag d
      open legend l

      -- Code from A.
      open import Homotopy.VanKampen.SplitCode d l (f $ loc n)
      open PackA2 d l n public
      -- Code from B. F for `flipped'.
      private
        module F where
          open import Homotopy.VanKampen.SplitCode (pushout-diag-flip d) l (g $ loc n) public
          open PackA2 (pushout-diag-flip d) l n public

      flipped-code : P → Set i
      flipped-code = F.code ◯ pushout-flip

      private
        ap⇒bp-glue : ∀ c → transport (λ p → code p → flipped-code p) (glue c) aa⇒ba ≡ ab⇒bb
      abstract
        ap⇒bp-glue = loc-fiber-rec l
          (λ c → transport (λ p → code p → flipped-code p) (glue c) aa⇒ba ≡ ab⇒bb)
          ⦃ λ _ → Π-is-set (λ _ → F.code-a-is-set _) _ _ ⦄
          (λ n → funext λ co →
            transport (λ p → code p → flipped-code p) (glue $ loc n) aa⇒ba co
                ≡⟨ trans-→ code flipped-code (glue $ loc n) aa⇒ba co ⟩
            transport flipped-code (glue $ loc n)
              (aa⇒ba $ transport code (! $ glue $ loc n) co)
                ≡⟨ ap (λ x → transport flipped-code (glue $ loc n) $ aa⇒ba x)
                    $ trans-code-!glue-loc n co ⟩
            transport flipped-code (glue $ loc n) (aa⇒ba $ b⇒a n co)
                ≡⟨ refl _ ⟩
            transport flipped-code (glue $ loc n) (F.a⇒b n $ ab⇒bb co)
                ≡⟨ ! $ trans-ap F.code pushout-flip (glue $ loc n)
                     $ F.a⇒b n $ ab⇒bb co ⟩
            transport F.code (ap pushout-flip $ glue $ loc n) (F.a⇒b n $ ab⇒bb co)
                ≡⟨ ap (λ x → transport F.code x $ F.a⇒b n $ ab⇒bb co)
                      $ pushout-β-glue-nondep _ right left (! ◯ glue) $ loc n ⟩
            transport F.code (! $ glue $ loc n) (F.a⇒b n $ ab⇒bb co)
                ≡⟨ F.trans-code-!glue-loc n (F.a⇒b n $ ab⇒bb co) ⟩
            F.b⇒a n (F.a⇒b n $ ab⇒bb co)
                ≡⟨ F.code-a-refl-refl n $ ab⇒bb co ⟩∎
            ab⇒bb co
                ∎)

      ap⇒bp : ∀ {p} → code p → flipped-code p
      ap⇒bp {p} = pushout-rec
        (λ x → code x → flipped-code x)
        (λ _ → aa⇒ba)
        (λ _ → ab⇒bb)
        ap⇒bp-glue
        p

  module PackB1 (d : pushout-diag i)
    (l : legend i (pushout-diag.C d)) where
    open pushout-diag d
    open legend l

    open import Homotopy.VanKampen.SplitCode d l

    trans-q-code-a : ∀ {a₁ a₂} (q : a₁ ≡ a₂) {a₃} (p : _ ≡₀ a₃)
      → transport (λ x → code-a x a₃) q (a a₁ p)
      ≡ a a₂ (proj (! q) ∘₀ p)
    trans-q-code-a (refl _) p = ap (λ x → a _ x) $ ! $ refl₀-left-unit p

    trans-!q-code-a : ∀ {a₁ a₂} (q : a₂ ≡ a₁) {a₃} (p : _ ≡₀ a₃)
      → transport (λ x → code-a x a₃) (! q) (a a₁ p)
      ≡ a a₂ (proj q ∘₀ p)
    trans-!q-code-a (refl _) p = ap (λ x → a _ x) $ ! $ refl₀-left-unit p

    trans-q-code-ba : ∀ {a₁ a₂} (q : a₁ ≡ a₂) {a₃} n co (p : _ ≡₀ a₃)
      → transport (λ x → code-a x a₃) q (ba a₁ n co p)
      ≡ ba a₂ n (transport (λ x → code-b x (g $ loc n)) q co) p
    trans-q-code-ba (refl _) n co p = refl _

    trans-q-code-ab : ∀ {a₁ a₂} (q : a₁ ≡ a₂) {b₃} n co (p : _ ≡₀ b₃)
      → transport (λ x → code-b x b₃) q (ab a₁ n co p)
      ≡ ab a₂ n (transport (λ x → code-a x (f $ loc n)) q co) p
    trans-q-code-ab (refl _) n co p = refl _

  -- Nice interface
  module _ where
    open pushout-diag d
    open legend l
    private
      -- Code from A.
      import Homotopy.VanKampen.SplitCode d l as SC
      module C = PackA3 d l
      -- Code from B. Code flipped.
      import Homotopy.VanKampen.SplitCode (pushout-diag-flip d) l as SCF
      module CF = PackA3 (pushout-diag-flip d) l

    P : Set i
    P = pushout d

    module _ where
      -- Things that can be directly re-exported
      -- FIXME Ideally, this should be ‵SC'.
      -- Somehow that doesn′t work.
      open import Homotopy.VanKampen.SplitCode d l
        public using () renaming
          ( code            to a-code
          ; code-a          to a-code-a
          ; code-b          to a-code-b
          ; code-rec        to a-code-rec
          ; code-rec-nondep to a-code-rec-nondep
          ; code-is-set     to a-code-is-set
          ; code-a-is-set   to a-code-a-is-set
          ; code-b-is-set   to a-code-b-is-set
          )
      module _ {a₁ : A} where
        open import Homotopy.VanKampen.SplitCode d l a₁
          public using () renaming
            ( code-a-refl-refl  to a-code-a-refl-refl
            ; code-b-refl-refl  to a-code-b-refl-refl
            ; code-ab-swap      to a-code-ab-swap
            ; trans-a           to trans-a-code-a
            ; trans-ba          to trans-a-code-ba
            ; trans-ab          to trans-a-code-ab
            ; a⇒b               to aa⇒ab
            ; b⇒a               to ab⇒aa
            )

      a-a : ∀ {a₁} {a₂} → a₁ ≡₀ a₂ → a-code-a a₁ a₂
      a-a = SC.a _

      infixl 6 a-a
      syntax a-a co = ⟧a co

      a-ba : ∀ {a₁} {a₂} n → a-code-b a₁ (g $ loc n) → f (loc n) ≡₀ a₂ → a-code-a a₁ a₂
      a-ba = SC.ba _

      infixl 6 a-ba
      syntax a-ba n co p = co ab⟦ n ⟧a p

      a-ab : ∀ {a₁} {b₂} n → a-code-a a₁ (f $ loc n) → g (loc n) ≡₀ b₂ → a-code-b a₁ b₂
      a-ab = SC.ab _

      infixl 6 a-ab
      syntax a-ab n co p = co aa⟦ n ⟧b p

    module _ where
      -- Things that can be directly re-exported
      open import Homotopy.VanKampen.SplitCode (pushout-diag-flip d) l
        public using () renaming
          ( code-a          to b-code-b
          ; code-b          to b-code-a
          ; code-rec        to b-code-rec
          ; code-rec-nondep to b-code-rec-nondep
          ; code-a-is-set   to b-code-b-is-set
          ; code-b-is-set   to b-code-a-is-set
          )

      b-code : B → P → Set i
      b-code b = SCF.code b ◯ pushout-flip

      module _ {b₁ : B} where
        open import Homotopy.VanKampen.SplitCode (pushout-diag-flip d) l b₁
          public using () renaming
            ( code-a-refl-refl  to b-code-b-refl-refl
            ; code-b-refl-refl  to b-code-a-refl-refl
            ; code-ab-swap      to b-code-ba-swap
            ; trans-a           to trans-b-code-b
            ; trans-ba          to trans-b-code-ab
            ; trans-ab          to trans-b-code-ba
            ; a⇒b               to bb⇒ba
            ; b⇒a               to ba⇒bb
            )

      b-b : ∀ {b₁} {b₂} → b₁ ≡₀ b₂ → b-code-b b₁ b₂
      b-b = SCF.a _

      infixl 6 b-b
      syntax b-b co = ⟧b co

      b-ab : ∀ {b₁} {b₂} n → b-code-a b₁ (f $ loc n) → g (loc n) ≡₀ b₂ → b-code-b b₁ b₂
      b-ab = SCF.ba _

      infixl 6 b-ab
      syntax b-ab c co p = co ba⟦ c ⟧b p

      b-ba : ∀ {b₁} {a₂} n → b-code-b b₁ (g $ loc n) → f (loc n) ≡₀ a₂ → b-code-a b₁ a₂
      b-ba = SCF.ab _

      infixl 6 b-ba
      syntax b-ba c co p = co bb⟦ c ⟧a p

      b-code-is-set : ∀ b₁ p₂ → is-set (b-code b₁ p₂)
      b-code-is-set b₁ = SCF.code-is-set b₁ ◯ pushout-flip

    -- Tail flipping
    open PackA3 d l public using () renaming
      ( aa⇒ba to aa⇒ba
      ; ab⇒bb to ab⇒bb
      ; ap⇒bp to ap⇒bp
      )
    open PackA3 (pushout-diag-flip d) l public using () renaming
      ( aa⇒ba to bb⇒ab
      ; ab⇒bb to ba⇒aa
      )

    -- Tail drifting
    open PackB1 d l public using () renaming
      ( trans-q-code-a  to trans-q-a-code-a
      ; trans-!q-code-a to trans-!q-a-code-a
      ; trans-q-code-ba to trans-q-a-code-ba
      ; trans-q-code-ab to trans-q-a-code-ab
      )
    open PackB1 (pushout-diag-flip d) l public using () renaming
      ( trans-q-code-a  to trans-q-b-code-b
      ; trans-!q-code-a to trans-!q-b-code-b
      ; trans-q-code-ba to trans-q-b-code-ab
      ; trans-q-code-ab to trans-q-b-code-ba
      )

    bp⇒ap : ∀ n {p} → b-code (g $ loc n) p → a-code (f $ loc n) p
    bp⇒ap n {p} = transport
      (λ x → b-code (g $ loc n) p → a-code (f $ loc n) x)
      (pushout-flip-flip p)
      (CF.ap⇒bp n {pushout-flip p})

    private
      Laba : name → P → Set i
      Laba = λ n p → ∀ (co : a-code (f $ loc n) p) → bp⇒ap n {p} (ap⇒bp n {p} co) ≡ co
    private
      aba-glue-code : ∀ c {p} → Laba c p
    abstract
      aba-glue-code n {p} = pushout-rec (Laba n)
        (λ _ → C.aba-glue-code-a n)
        (λ _ → C.aba-glue-code-b n)
        (λ _ → funext λ _ → prop-has-all-paths (a-code-b-is-set (f $ loc n) _ _ _) _ _)
        p

    private
      Lbab : name → P → Set i
      Lbab = λ n p → ∀ (co : b-code (g $ loc n) p) → ap⇒bp n {p} (bp⇒ap n {p} co) ≡ co
    private
      bab-glue-code : ∀ n {p} → Lbab n p
    abstract
      bab-glue-code n {p} = pushout-rec (Lbab n)
        (λ _ → CF.aba-glue-code-b n)
        (λ _ → CF.aba-glue-code-a n)
        (λ _ → funext λ _ → prop-has-all-paths (b-code-b-is-set (g $ loc n) _ _ _) _ _)
        p

    private
      glue-code-loc : ∀ n p → a-code (f $ loc n) p ≃ b-code (g $ loc n) p
      glue-code-loc n p = ap⇒bp n {p} , iso-is-eq
        (ap⇒bp n {p}) (bp⇒ap n {p}) (bab-glue-code n {p}) (aba-glue-code n {p})

    private
      TapbpTa : ∀ n₁ n₂ (r : loc n₁ ≡ loc n₂) {a}
        → a-code-a (f $ loc n₂) a → Set i
      TapbpTa n₁ n₂ r {a} co =
          transport (λ x → b-code-a x a) (ap g r)
            (aa⇒ba n₁ {a} $ transport (λ x → a-code-a x a) (! $ ap f r) co)
        ≡ aa⇒ba n₂ {a} co

      TapbpTb : ∀ n₁ n₂ (r : loc n₁ ≡ loc n₂) {b}
        → a-code-b (f $ loc n₂) b → Set i
      TapbpTb n₁ n₂ r {b} co =
          transport (λ x → b-code-b x b) (ap g r)
            (ab⇒bb n₁ {b} $ transport (λ x → a-code-b x b) (! $ ap f r) co)
        ≡ ab⇒bb n₂ {b} co

      TapbpTp : ∀ n₁ n₂ (r : loc n₁ ≡ loc n₂) {p}
        → a-code (f $ loc n₂) p → Set i
      TapbpTp n₁ n₂ r {p} co =
          transport (λ x → b-code x p) (ap g r)
            (ap⇒bp n₁ {p} $ transport (λ x → a-code x p) (! $ ap f r) co)
        ≡ ap⇒bp n₂ {p} co

    private
      ap⇒bp-shift-split : ∀ n₁ n₂ r
        → (∀ {a₂} co → TapbpTa n₁ n₂ r {a₂} co)
        × (∀ {b₂} co → TapbpTb n₁ n₂ r {b₂} co)
    abstract
      ap⇒bp-shift-split n₁ n₂ r = a-code-rec (f $ loc n₂)
        (TapbpTa n₁ n₂ r)
        ⦃ λ _ → ≡-is-set $ b-code-a-is-set _ _ ⦄
        (TapbpTb n₁ n₂ r)
        ⦃ λ _ → ≡-is-set $ b-code-b-is-set _ _ ⦄
        (λ {a} p →
          transport (λ x → b-code-a x a) (ap g r)
            (aa⇒ba n₁ {a} $ transport (λ x → a-code-a x a) (! $ ap f r) $ ⟧a p)
              ≡⟨ ap (transport (λ x → b-code-a x a) (ap g r) ◯ aa⇒ba n₁ {a})
                    $ trans-!q-a-code-a (ap f r) p ⟩
          transport (λ x → b-code-a x a) (ap g r)
            (⟧b refl₀ _ bb⟦ n₁ ⟧a proj (ap f r) ∘₀ p)
              ≡⟨ trans-q-b-code-ba (ap g r) _ _ _ ⟩
          transport (λ x → b-code-b x (g $ loc n₁)) (ap g r) (⟧b refl₀ _)
            bb⟦ n₁ ⟧a proj (ap f r) ∘₀ p
              ≡⟨ ap (λ x → x bb⟦ n₁ ⟧a proj (ap f r) ∘₀ p) $ trans-q-b-code-b (ap g r) _ ⟩
          ⟧b proj (! (ap g r)) ∘₀ refl₀ _ bb⟦ n₁ ⟧a proj (ap f r) ∘₀ p
              ≡⟨ ap (λ x → ⟧b x bb⟦ n₁ ⟧a proj (ap f r) ∘₀ p) $ refl₀-right-unit _ ⟩
          ⟧b proj (! (ap g r)) bb⟦ n₁ ⟧a proj (ap f r) ∘₀ p
              ≡⟨ ! $ SCF.code-a-shift (g $ loc n₂) n₁ (proj (! (ap g r))) n₂ (proj r) p ⟩
          ⟧b proj (! (ap g r) ∘ ap g r) bb⟦ n₂ ⟧a p
              ≡⟨ ap (λ x → ⟧b proj x bb⟦ n₂ ⟧a p) $ opposite-left-inverse $ ap g r ⟩∎
          aa⇒ba n₂ {a} (⟧a p)
              ∎)
        (λ {a} n {co} pco p →
          transport (λ x → b-code-a x a) (ap g r)
            (aa⇒ba n₁ {a} $ transport (λ x → a-code-a x a) (! $ ap f r) $ co ab⟦ n ⟧a p)
              ≡⟨ ap (transport (λ x → b-code-a x a) (ap g r) ◯ aa⇒ba n₁ {a})
                    $ trans-q-a-code-ba (! $ ap f r) n co p ⟩
          transport (λ x → b-code-a x a) (ap g r)
            (ab⇒bb n₁ {g $ loc n} (transport (λ x → a-code-b x (g $ loc n)) (! $ ap f r) co) bb⟦ n ⟧a p)
              ≡⟨ trans-q-b-code-ba (ap g r) _ _ _ ⟩
          transport (λ x → b-code-b x (g $ loc n)) (ap g r)
            (ab⇒bb n₁ {g $ loc n} (transport (λ x → a-code-b x (g $ loc n)) (! $ ap f r) co)) bb⟦ n ⟧a p
              ≡⟨ ap (λ x → x bb⟦ n ⟧a p) pco ⟩∎
          ab⇒bb n₂ {g $ loc n} co bb⟦ n ⟧a p
              ∎)
        (λ {b} n {co} pco p →
          transport (λ x → b-code-b x b) (ap g r)
            (ab⇒bb n₁ {b} $ transport (λ x → a-code-b x b) (! $ ap f r) $ co aa⟦ n ⟧b p)
              ≡⟨ ap (transport (λ x → b-code-b x b) (ap g r) ◯ ab⇒bb n₁ {b})
                    $ trans-q-a-code-ab (! $ ap f r) n co p ⟩
          transport (λ x → b-code-b x b) (ap g r)
            (aa⇒ba n₁ {f $ loc n} (transport (λ x → a-code-a x (f $ loc n)) (! $ ap f r) co) ba⟦ n ⟧b p)
              ≡⟨ trans-q-b-code-ab (ap g r) _ _ _ ⟩
          transport (λ x → b-code-a x (f $ loc n)) (ap g r)
            (aa⇒ba n₁ {f $ loc n} (transport (λ x → a-code-a x (f $ loc n)) (! $ ap f r) co)) ba⟦ n ⟧b p
              ≡⟨ ap (λ x → x ba⟦ n ⟧b p) pco ⟩∎
          aa⇒ba n₂ {f $ loc n} co ba⟦ n ⟧b p
              ∎)
        (λ _ _ → prop-has-all-paths (b-code-a-is-set _ _ _ _) _ _)
        (λ _ _ → prop-has-all-paths (b-code-b-is-set _ _ _ _) _ _)
        (λ _ _ _ _ → prop-has-all-paths (b-code-a-is-set _ _ _ _) _ _)

    private
      ap⇒bp-shift : ∀ n₁ n₂ r {p} co → TapbpTp n₁ n₂ r {p} co
    abstract
      ap⇒bp-shift n₁ n₂ r {p} co =
        pushout-rec
          (λ p → ∀ co → TapbpTp n₁ n₂ r {p} co)
          (λ a → π₁ (ap⇒bp-shift-split n₁ n₂ r) {a})
          (λ b → π₂ (ap⇒bp-shift-split n₁ n₂ r) {b})
          (λ c → funext λ _ → prop-has-all-paths (b-code-is-set (g $ loc n₂) (right $ g c) _ _) _ _)
          p co

    glue-code-eq-route : ∀ p n₁ n₂ (r : loc n₁ ≡ loc n₂)
      → transport (λ c → a-code (f c) p ≃ b-code (g c) p) r (glue-code-loc n₁ p)
      ≡ glue-code-loc n₂ p
    abstract
      glue-code-eq-route p n₁ n₂ r = equiv-eq $ funext λ co →
        π₁ (transport (λ c → a-code (f c) p ≃ b-code (g c) p) r (glue-code-loc n₁ p)) co
          ≡⟨ ap (λ x → x co) $ app-trans
              (λ c → a-code (f c) p ≃ b-code (g c) p)
              (λ c → a-code (f c) p → b-code (g c) p)
              (λ _ → π₁)
              r
              (glue-code-loc n₁ p) ⟩
        transport (λ c → a-code (f c) p → b-code (g c) p) r (ap⇒bp n₁ {p}) co
          ≡⟨ trans-→ (λ c → a-code (f c) p) (λ c → b-code (g c) p) r (ap⇒bp n₁ {p}) co ⟩
        transport (λ c → b-code (g c) p) r (ap⇒bp n₁ {p} $ transport (λ c → a-code (f c) p) (! r) co)
          ≡⟨ ap (transport (λ c → b-code (g c) p) r ◯ ap⇒bp n₁ {p}) $ ! $ trans-ap (λ x → a-code x p) f (! r) co ⟩
        transport (λ c → b-code (g c) p) r (ap⇒bp n₁ {p} $ transport (λ x → a-code x p) (ap f (! r)) co)
          ≡⟨ ap (λ x → transport (λ c → b-code (g c) p) r $ ap⇒bp n₁ {p}
                      $ transport (λ x → a-code x p) x co)
                $ ap-opposite f r ⟩
        transport (λ c → b-code (g c) p) r (ap⇒bp n₁ {p} $ transport (λ x → a-code x p) (! $ ap f r) co)
          ≡⟨ ! $ trans-ap (λ x → b-code x p) g r _ ⟩
        transport (λ x → b-code x p) (ap g r) (ap⇒bp n₁ {p} $ transport (λ x → a-code x p) (! $ ap f r) co)
          ≡⟨ ap⇒bp-shift n₁ n₂ r {p} co ⟩∎
        ap⇒bp n₂ {p} co
          ∎

    glue-code-eq : ∀ c p → a-code (f c) p ≃ b-code (g c) p
    glue-code-eq c p = visit-fiber-rec l (λ c → a-code (f c) p ≃ b-code (g c) p)
      ⦃ λ c → ≃-is-set (a-code-is-set (f c) p) (b-code-is-set (g c) p) ⦄
      (λ n → glue-code-loc n p)
      (glue-code-eq-route p)
      c

    code : P → P → Set i
    code = pushout-rec-nondep (P → Set i) a-code b-code
      (λ c → funext λ p → eq-to-path $ glue-code-eq c p)

    open import HLevelBis
    abstract
      code-is-set : ∀ p₁ p₂ → is-set (code p₁ p₂)
      code-is-set = pushout-rec
        (λ p₁ → ∀ p₂ → is-set $ code p₁ p₂)
        a-code-is-set
        b-code-is-set
        (λ _ → prop-has-all-paths (Π-is-prop λ _ → is-set-is-prop) _ _)

    -- Useful lemma
    module _ {a₁ : A} where
      open import Homotopy.VanKampen.SplitCode d l a₁
        public using () renaming
          ( trans-code-glue-loc   to trans-a-code-glue-loc
          ; trans-code-!glue-loc  to trans-a-code-!glue-loc
          )

    abstract
      trans-b-code-glue-loc : ∀ {b₁} n₂ co → transport (b-code b₁) (glue $ loc n₂) co ≡ ba⇒bb n₂ co
      trans-b-code-glue-loc {b₁} n₂ co =
        transport (b-code b₁) (glue $ loc n₂) co
            ≡⟨ ! $ trans-ap (SCF.code b₁) pushout-flip (glue $ loc n₂) co ⟩
        transport (SCF.code b₁) (ap pushout-flip (glue $ loc n₂)) co
            ≡⟨ ap (λ x → transport (SCF.code b₁) x co)
                  $ pushout-β-glue-nondep _ right left (! ◯ glue) (loc n₂) ⟩
        transport (SCF.code b₁) (! (glue $ loc n₂)) co
            ≡⟨ SCF.trans-code-!glue-loc b₁ n₂ co ⟩∎
        ba⇒bb n₂ co
            ∎

    abstract
      trans-b-code-!glue-loc : ∀ {b₁} n₂ co → transport (b-code b₁) (! (glue $ loc n₂)) co ≡ bb⇒ba n₂ co
      trans-b-code-!glue-loc {b₁} n₂ co =
        transport (b-code b₁) (! (glue $ loc n₂)) co
            ≡⟨ ! $ trans-ap (SCF.code b₁) pushout-flip (! (glue $ loc n₂)) co ⟩
        transport (SCF.code b₁) (ap pushout-flip (! (glue $ loc n₂))) co
            ≡⟨ ap (λ x → transport (SCF.code b₁) x co)
                  $ pushout-β-!glue-nondep _ right left (! ◯ glue) (loc n₂) ⟩
        transport (SCF.code b₁) (! (! (glue $ loc n₂))) co
            ≡⟨ ap (λ x → transport (SCF.code b₁) x co)
                  $ opposite-opposite $ glue $ loc n₂ ⟩
        transport (SCF.code b₁) (glue $ loc n₂) co
            ≡⟨ SCF.trans-code-glue-loc b₁ n₂ co ⟩∎
        bb⇒ba n₂ co
            ∎

    abstract
      trans-glue-code-loc : ∀ n {p} (co : a-code (f $ loc n) p)
        → transport (λ x → code x p) (glue $ loc n) co
        ≡ ap⇒bp n {p} co
      trans-glue-code-loc n {p} co =
          transport (λ x → code x p) (glue $ loc n) co
              ≡⟨ ! $ trans-ap (λ f → f p) code (glue $ loc n) co ⟩
          transport (λ f → f p) (ap code (glue $ loc n)) co
              ≡⟨ ap (λ x →  transport (λ f → f p) x co)
                  $ pushout-β-glue-nondep (P → Set i) a-code b-code
                    (λ c → funext λ p → eq-to-path $ glue-code-eq c p)
                  $ loc n ⟩
          transport (λ f → f p) (funext λ p → eq-to-path $ glue-code-eq (loc n) p) co
              ≡⟨ ! $ trans-ap (λ X → X) (λ f → f p)
                      (funext λ p → eq-to-path $ glue-code-eq (loc n) p) co ⟩
          transport (λ X → X) (happly (funext λ p → eq-to-path $ glue-code-eq (loc n) p) p) co
              ≡⟨ ap (λ x → transport (λ X → X) (x p) co)
                    $ happly-funext (λ p → eq-to-path $ glue-code-eq (loc n) p) ⟩
          transport (λ X → X) (eq-to-path $ glue-code-eq (loc n) p) co
              ≡⟨ trans-id-eq-to-path (glue-code-eq (loc n) p) co ⟩
          π₁ (glue-code-eq (loc n) p) co
              ≡⟨ ap (λ x → π₁ x co) $
                  visit-fiber-β-loc l
                  (λ c → a-code (f c) p ≃ b-code (g c) p)
                  ⦃ λ c → ≃-is-set (a-code-is-set (f c) p) (b-code-is-set (g c) p) ⦄
                  (λ n → glue-code-loc n p)
                  (glue-code-eq-route p)
                  n ⟩∎
          ap⇒bp n {p} co
              ∎

    abstract
      trans-!glue-code-loc : ∀ n {p} (co : b-code (g $ loc n) p)
        → transport (λ x → code x p) (! $ glue $ loc n) co
        ≡ bp⇒ap n {p} co
      trans-!glue-code-loc n {p} co =
        move!-transp-right (λ x → code x p) (glue $ loc n) co (bp⇒ap n {p} co)
          $ ! $
            transport (λ x → code x p) (glue $ loc n) (bp⇒ap n {p} co)
              ≡⟨ trans-glue-code-loc n {p} (bp⇒ap n {p} co) ⟩
            ap⇒bp n {p} (bp⇒ap n {p} co)
              ≡⟨ bab-glue-code n {p} co ⟩∎
            co
              ∎
