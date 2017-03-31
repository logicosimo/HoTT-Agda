{-# OPTIONS --without-K --rewriting #-}

open import HoTT

module stash.modalities.Modalities where

  record Modality ℓ : Type (lsucc ℓ) where
    field

      is-local : Type ℓ → Type ℓ
      is-local-is-prop : {A : Type ℓ} → is-prop (is-local A)

      ◯ : Type ℓ → Type ℓ
      ◯-is-local : {A : Type ℓ} → is-local (◯ A)

      η : {A : Type ℓ} → A → ◯ A

      ◯-elim : {A : Type ℓ} {B : ◯ A → Type ℓ}
        (B-local : Π (◯ A) (λ a → is-local (B a)))
        → Π A (B ∘ η) → Π (◯ A) B

      ◯-elim-β : {A : Type ℓ} {B : ◯ A → Type ℓ}
        (B-local : Π (◯ A) (λ a → is-local (B a))) (f : Π A (B ∘ η))
        → (a : A) → ◯-elim B-local f (η a) == f a

      ◯-=-is-local : {A : Type ℓ} (a₀ a₁ : ◯ A) → is-local (a₀ == a₁)

  module _ {ℓ} (M : Modality ℓ) where

    open Modality M

    ◯-Type : Type (lsucc ℓ)
    ◯-Type = Σ (Type ℓ) is-local

    is-◯-connected : Type ℓ → Type ℓ
    is-◯-connected A = is-contr (◯ A)

    is-◯-equiv : {A B : Type ℓ} → (A → B) → Type ℓ
    is-◯-equiv {B = B} f = (b : B) → is-◯-connected (hfiber f b)

    is-lex : Type (lsucc ℓ)
    is-lex = {A B : Type ℓ} (f : A → B) →
             is-◯-connected A → is-◯-connected B →
             (b : B) → is-◯-connected (hfiber f b)

    -- Some basic constructions

    ◯-rec : {A B : Type ℓ} (w : is-local B) (f : A → B) → ◯ A → B
    ◯-rec w = ◯-elim (λ _ → w)

    ◯-rec-β : {A B : Type ℓ} (w : is-local B) (f : A → B) (a : A) → ◯-rec w f (η a) == f a
    ◯-rec-β w = ◯-elim-β (λ _ → w)

    ◯-fmap : {A B : Type ℓ} (f : A → B) → (◯ A → ◯ B)
    ◯-fmap f = ◯-rec ◯-is-local (λ a → η (f a))

    ◯-fmap-β : {A B : Type ℓ} (f : A → B) (a : A) → ◯-fmap f (η a) == η (f a)
    ◯-fmap-β f a = ◯-rec-β ◯-is-local (λ a → η (f a)) a

    ◯-isemap : {A B : Type ℓ} (f : A → B) → is-equiv f → is-equiv (◯-fmap f)
    ◯-isemap f f-ise = is-eq _ (◯-fmap g) to-from from-to where
      open is-equiv f-ise
      abstract
        to-from : ∀ ◯b → ◯-fmap f (◯-fmap g ◯b) == ◯b
        to-from = ◯-elim
          (λ ◯b → ◯-=-is-local (◯-fmap f (◯-fmap g ◯b)) ◯b)
          (λ b → ap (◯-fmap f) (◯-fmap-β g b) ∙ ◯-fmap-β f (g b) ∙ ap η (f-g b))
        from-to : ∀ ◯a → ◯-fmap g (◯-fmap f ◯a) == ◯a
        from-to = ◯-elim
          (λ ◯a → ◯-=-is-local (◯-fmap g (◯-fmap f ◯a)) ◯a)
          (λ a → ap (◯-fmap g) (◯-fmap-β f a) ∙ ◯-fmap-β g (f a) ∙ ap η (g-f a))

    -- This is the only appearence of univalence, but ...
    local-is-replete : {A B : Type ℓ} → is-local A → A ≃ B → is-local B
    local-is-replete w eq = transport is-local (ua eq) w

    -- This name aligns with the current codebase better.
    equiv-preserves-local : {A B : Type ℓ} → A ≃ B → is-local A → is-local B
    equiv-preserves-local e A-is-loc = local-is-replete A-is-loc e

    local-implies-η-equiv : {A : Type ℓ} → is-local A → is-equiv (η {A})
    local-implies-η-equiv {A} w = is-eq (η {A}) η-inv inv-l inv-r

       where η-inv : ◯ A → A
             η-inv = ◯-rec w (idf A)

             inv-r : (a : A) → η-inv (η a) == a
             inv-r = ◯-rec-β w (idf A)

             inv-l : (a : ◯ A) → η (η-inv a) == a
             inv-l = ◯-elim (λ a₀ → ◯-=-is-local _ _)
                            (λ a₀ → ap η (inv-r a₀))

    η-equiv-implies-local : {A : Type ℓ} → is-equiv (η {A}) → is-local A
    η-equiv-implies-local {A} eq = local-is-replete {◯ A} {A} ◯-is-local ((η , eq) ⁻¹)

    retract-is-local : {A B : Type ℓ} (w : is-local A)
                       (f : A → B) (g : B → A) (r : (b : B) → f (g b) == b) →
                       is-local B
    retract-is-local {A} {B} w f g r = η-equiv-implies-local {B} (is-eq η η-inv inv-l inv-r)

      where η-inv : ◯ B → B
            η-inv = f ∘ (◯-rec w g)

            inv-r : (b : B) → η-inv (η b) == b
            inv-r b = ap f (◯-rec-β w g b) ∙ r b

            inv-l : (b : ◯ B) → η (η-inv b) == b
            inv-l = ◯-elim (λ b → ◯-=-is-local _ _) (λ b → ap η (inv-r b))

    =-preserves-local : {A : Type ℓ} {a₀ a₁ : A} → is-local A → is-local (a₀ == a₁)
    =-preserves-local {A} {a₀} {a₁} w  = local-is-replete
      (◯-=-is-local (η a₀) (η a₁)) (ap-equiv (η , local-implies-η-equiv w) a₀ a₁ ⁻¹)

    Π-is-local : {A : Type ℓ} {B : A → Type ℓ} (w : (a : A) → is-local (B a)) → is-local (Π A B)
    Π-is-local {A} {B} w = retract-is-local {◯ (Π A B)} {Π A B} ◯-is-local η-inv η r

      where η-inv : ◯ (Π A B) → Π A B
            η-inv φ' a = ◯-rec (w a) (λ φ → φ a) φ'

            r : (φ : Π A B) → η-inv (η φ) == φ
            r φ = λ= (λ a → ◯-rec-β (w a) (λ φ₀ → φ₀ a) φ)

    →-is-local : {A B : Type ℓ} → is-local B → is-local (A → B)
    →-is-local w = Π-is-local (λ _ → w)

    ◯-fmap2 : {A B C : Type ℓ} (f : A → B → C) → (◯ A → ◯ B → ◯ C)
    ◯-fmap2 f = ◯-rec (→-is-local ◯-is-local) (λ a → ◯-fmap (f a))

    ◯-fmap2-β : {A B C : Type ℓ} (f : A → B → C) (a : A) (b : B)
      → (◯-fmap2 f (η a) (η b) == η (f a b))
    ◯-fmap2-β f a b = app= (◯-rec-β (→-is-local ◯-is-local) (λ a → ◯-fmap (f a)) a) (η b)
                    ∙ ◯-fmap-β (f a) b

    Σ-is-local : {A : Type ℓ} (B : A → Type ℓ)
                 (lA : is-local A) (lB : (a : A) → is-local (B a)) →
                 is-local (Σ A B)
    Σ-is-local {A} B lA lB = retract-is-local {◯ (Σ A B)} {Σ A B} ◯-is-local η-inv η r

      where h : ◯ (Σ A B) → A
            h = (is-equiv.g (local-implies-η-equiv lA)) ∘ (◯-fmap fst)

            h-β : (ab : Σ A B) → h (η ab) == fst ab
            h-β ab = ap (is-equiv.g (local-implies-η-equiv lA)) (◯-fmap-β fst ab) ∙
                         is-equiv.g-f (local-implies-η-equiv lA) (fst ab)

            k₀ : (w : ◯ (Σ A B)) → ◯ (B (h w))
            k₀ = ◯-elim {A = Σ A B} (λ _ → ◯-is-local)
              (λ ab → transport! (◯ ∘ B) (h-β ab) (η (snd ab)))

            k₁ : {a : A} → ◯ (B a) → B a
            k₁ {a} =  is-equiv.g (local-implies-η-equiv (lB a))

            k : (w : ◯ (Σ A B)) → B (h w)
            k w = is-equiv.g (local-implies-η-equiv (lB (h w))) (k₀ w)

            k-β : (ab : Σ A B) → k (η ab) == snd ab [ B ↓ h-β ab ]
            k-β ab = ap↓ k₁ (from-transp! (λ a → ◯ (B a)) (h-β ab) k₀-β) ∙'ᵈ
                     is-equiv.g-f (local-implies-η-equiv (lB (fst ab))) (snd ab)

              where k₀-β : k₀ (η ab) == transport! (λ a → ◯ (B a)) (h-β ab) (η (snd ab))
                    k₀-β =  ◯-elim-β {A = Σ A B} (λ _ → ◯-is-local)
                      ((λ ab → transport! (◯ ∘ B) (h-β ab) (η (snd ab)))) ab

            C : ◯ (Σ A B) → Type ℓ
            C w = B (h w)

            η-inv : ◯ (Σ A B) → Σ A B
            η-inv w = h w , ◯-elim (lB ∘ h) (k ∘ η) w

            r : (x : Σ A B) → η-inv (η x) == x
            r (a , b) = pair= (h-β (a , b)) (◯-elim-β (lB ∘ h) (k ∘ η) (a , b) ∙ᵈ (k-β (a , b)))

    abstract
      pre∘-◯-conn-is-equiv : {A B : Type ℓ} {h : A → B} → is-◯-equiv h →
                             (P : B → ◯-Type) → is-equiv (λ (s : Π B (fst ∘ P)) → s ∘ h)
      pre∘-◯-conn-is-equiv {A} {B} {h} c P = is-eq f g f-g g-f

        where f : Π B (fst ∘ P) → Π A (fst ∘ P ∘ h)
              f k a = k (h a)

              helper : Π A (fst ∘ P ∘ h) → (b : B) → ◯ (Σ A (λ a → h a == b)) → (fst (P b))
              helper t b = ◯-rec (snd (P b)) (λ x → transport (fst ∘ P) (snd x) (t (fst x)))

              helper-β : (t : Π A (fst ∘ P ∘ h)) → (b : B) → (r : hfiber h b) →
                         helper t b (η r) == transport (fst ∘ P) (snd r) (t (fst r))
              helper-β t b = ◯-rec-β (snd (P b)) (λ x → transport (fst ∘ P) (snd x) (t (fst x)))

              g : Π A (fst ∘ P ∘ h) → Π B (fst ∘ P)
              g t b = helper t b (fst (c b))

              f-g : ∀ t → f (g t) == t
              f-g t = λ= $ λ a → transport
                (λ r → ◯-rec (snd (P (h a))) _ r == t a)
                (! (snd (c (h a)) (η (a , idp))))
                (◯-rec-β (snd (P (h a))) _ (a , idp))

              g-f : ∀ k → g (f k) == k
              g-f k = λ= λ (b : B) →
                ◯-elim {A = hfiber h b}
                       (λ r → =-preserves-local (snd (P b)))
                       (λ r → lemma₁ (fst r) b (snd r))
                       (fst (c b))

                  where lemma₀ : (a : A) → (b : B) → (p : h a == b) →
                               helper (k ∘ h) b (η (a , p)) == k b
                        lemma₀ a .(h a) idp = helper-β (k ∘ h) (h a) (a , idp)

                        lemma₁ : (a : A) → (b : B) → (p : h a == b) →
                               helper (k ∘ h) b (fst (c b)) == k b
                        lemma₁ a b p = transport! (λ r → helper (k ∘ h) b r == k b)
                          (snd (c b) (η (a , p))) (lemma₀ a b p)


    ◯-extend : {A B : Type ℓ} (f : A → B) → is-◯-equiv f →
                        (P : B → ◯-Type) → Π A (fst ∘ P ∘ f) → Π B (fst ∘ P)
    ◯-extend f c P s = is-equiv.g (pre∘-◯-conn-is-equiv {h = f} c P) s

    ◯-preserves-× : {A B : Type ℓ} → ◯ (A × B) ≃ ◯ A × ◯ B
    ◯-preserves-× {A} {B} = equiv ◯-split ◯-pair inv-l inv-r

      where ◯-fst : ◯ (A × B) → ◯ A
            ◯-fst ab = ◯-fmap fst ab

            ◯-fst-β : (ab : A × B) → ◯-fst (η ab) == η (fst ab)
            ◯-fst-β ab = ◯-rec-β ◯-is-local _ ab

            ◯-snd : ◯ (A × B) → ◯ B
            ◯-snd ab = ◯-fmap snd ab

            ◯-snd-β : (ab : A × B) → ◯-snd (η ab) == η (snd ab)
            ◯-snd-β ab = ◯-rec-β ◯-is-local _ ab

            ◯-split : ◯ (A × B) → ◯ A × ◯ B
            ◯-split ab = (◯-fst ab , ◯-snd ab)

            ◯-pair : ◯ A × ◯ B → ◯ (A × B)
            ◯-pair = uncurry (◯-fmap2 _,_)

            ◯-pair-β : (a : A) → (b : B) → ◯-pair (η a , η b) == η (a , b)
            ◯-pair-β = ◯-fmap2-β _,_

            lem₀ : (a : ◯ A) → (b : ◯ B) → ◯-fst (◯-pair (a , b)) == a
            lem₀ = ◯-elim (λ _ → Π-is-local λ _ → ◯-=-is-local _ _)
                          (λ a → ◯-elim
                            (λ _ → ◯-=-is-local _ _)
                            (λ b → ap ◯-fst (◯-pair-β a b) ∙ ◯-fst-β (a , b)))

            lem₁ : (a : ◯ A) → (b : ◯ B) → ◯-snd (◯-pair (a , b)) == b
            lem₁ = ◯-elim (λ _ → Π-is-local λ _ → ◯-=-is-local _ _)
                          (λ a → ◯-elim
                            (λ _ → ◯-=-is-local _ _)
                            (λ b → ap ◯-snd (◯-pair-β a b) ∙ ◯-snd-β (a , b)))

            inv-l : (ab : ◯ A × ◯ B) → ◯-split (◯-pair ab) == ab
            inv-l (a , b) = pair×= (lem₀ a b) (lem₁ a b)

            inv-r : (ab : ◯ (A × B)) → ◯-pair (◯-split ab) == ab
            inv-r = ◯-elim (λ _ → ◯-=-is-local _ _)
                           (λ ab → ap ◯-pair (pair×= (◯-fst-β ab) (◯-snd-β ab)) ∙ ◯-pair-β (fst ab) (snd ab))
