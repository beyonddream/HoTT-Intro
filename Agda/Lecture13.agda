{-# OPTIONS --without-K --allow-unsolved-metas #-}

module Lecture13 where

import Lecture12
open Lecture12 public

-- Section 13.1

cocone : {l1 l2 l3 l4 : Level} {S : UU l1} {A : UU l2} {B : UU l3}
  (f : S → A) (g : S → B) → UU l4 → UU _
cocone {A = A} {B = B} f g X =
  Σ (A → X) (λ i → Σ (B → X) (λ j → (i ∘ f) ~ (j ∘ g)))

dgen-pushout : {l1 l2 l3 l4 l5 : Level} {S : UU l1} {A : UU l2} {B : UU l3}
  (f : S → A) (g : S → B) {X : UU l4} (c : cocone f g X) {P : X → UU l5} →
  ((x : X) → P x) →
  Σ ( (a : A) → P (pr1 c a))
    ( λ φ → Σ ( (b : B) → P (pr1 (pr2 c) b))
      ( λ ψ → (s : S) → Id (tr P (pr2 (pr2 c) s) (φ (f s))) (ψ (g s))))
dgen-pushout f g (dpair i (dpair j H)) α =
  dpair
    ( λ a → α (i a))
    ( dpair
      ( λ b → α (j b))
      ( λ s → apd α (H s)))

Ind-pushout : {l1 l2 l3 l4 : Level} {S : UU l1} {A : UU l2} {B : UU l3}
  (f : S → A) (g : S → B) {X : UU l4} (c : cocone f g X) (l5 : Level) → UU _
Ind-pushout f g {X} c l5 = (P : X → UU l5) → sec (dgen-pushout f g c {P})

PUSHOUT : {l1 l2 l3 : Level} {S : UU l1} {A : UU l2} {B : UU l3}
  (f : S → A) (g : S → B) → UU _
PUSHOUT {l1} {l2} {l3} f g =
  Σ ( UU (l1 ⊔ (l2 ⊔ l3)))
    ( λ X → Σ (cocone f g X)
      ( λ c → Ind-pushout f g c (lsuc (l1 ⊔ (l2 ⊔ l3)))))

-- Section 13.3

-- We first give several different conditions that are equivalent to the
-- universal property of pushouts.

cocone-map : {l1 l2 l3 l4 l5 : Level} {S : UU l1} {A : UU l2} {B : UU l3}
  (f : S → A) (g : S → B) {X : UU l4} {Y : UU l5} →
  cocone f g X → (X → Y) → cocone f g Y
cocone-map f g (dpair i (dpair j H)) h =
  dpair (h ∘ i) (dpair (h ∘ j) (h ·l H))

universal-property-pushout : {l1 l2 l3 l4 : Level} {S : UU l1} {A : UU l2}
  {B : UU l3} (f : S → A) (g : S → B) {X : UU l4} →
  cocone f g X → {l5 : Level} (Y : UU l5) → UU _
universal-property-pushout f g c Y = is-equiv (cocone-map f g {Y = Y} c)

cone-pullback-property-pushout : {l1 l2 l3 l4 : Level} {S : UU l1} {A : UU l2}
  {B : UU l3} (f : S → A) (g : S → B) {X : UU l4} (c : cocone f g X) →
  {l : Level} (Y : UU l) →
  cone (λ (h : A → Y) → h ∘ f) (λ (h : B → Y) → h ∘ g) (X → Y)
cone-pullback-property-pushout f g {X} (dpair i (dpair j H)) Y =
  dpair
    ( λ (h : X → Y) → h ∘ i)
    ( dpair
      ( λ (h : X → Y) → h ∘ j)
      ( λ h → eq-htpy (h ·l H)))

pullback-property-pushout : {l1 l2 l3 l4 : Level} {S : UU l1} {A : UU l2}
  {B : UU l3} (f : S → A) (g : S → B) {X : UU l4} (c : cocone f g X) →
  {l : Level} (Y : UU l) → UU (l1 ⊔ (l2 ⊔ (l3 ⊔ (l4 ⊔ l))))
pullback-property-pushout {l1} {l2} {l3} {l4} {S} {A} {B} f g {X} c {l} Y =
  is-pullback
    ( λ (h : A → Y) → h ∘ f)
    ( λ (h : B → Y) → h ∘ g)
    ( cone-pullback-property-pushout f g c Y)

dependent-universal-property-pushout : {l1 l2 l3 l4 : Level}
  {S : UU l1} {A : UU l2} {B : UU l3}
  (f : S → A) (g : S → B) {X : UU l4} (c : cocone f g X)
  (l : Level) → UU _
dependent-universal-property-pushout f g {X} c l =
  (P : X → UU l) → is-equiv (dgen-pushout f g c {P})

dependent-pullback-property-pushout : {l1 l2 l3 l4 : Level}
  {S : UU l1} {A : UU l2} {B : UU l3} (f : S → A) (g : S → B)
  {X : UU l4} (c : cocone f g X) {l : Level} (P : X → UU l) →
  UU (l1 ⊔ (l2 ⊔ (l3 ⊔ (l4 ⊔ l))))
dependent-pullback-property-pushout {l1} {l2} {l3} {l4} {S} {A} {B} f g {X}
  (dpair i (dpair j H)) {l} P =
  is-pullback
    ( λ (h : (a : A) → P (i a)) → λ s → tr P (H s) (h (f s)))
    ( λ (h : (b : B) → P (j b)) → λ s → h (g s))
    ( dpair
      ( λ (h : (x : X) → P x) → λ a → h (i a))
      ( dpair
        ( λ (h : (x : X) → P x) → λ b → h (j b))
        ( λ h → eq-htpy (λ s → apd h (H s)))))

triangle-pullback-property-pushout-universal-property-pushout :
  {l1 l2 l3 l4 : Level} {S : UU l1} {A : UU l2}
  {B : UU l3} (f : S → A) (g : S → B) {X : UU l4} (c : cocone f g X) →
  {l : Level} (Y : UU l) →
  ( cocone-map f g c) ~
  ( ( tot (λ i' → tot (λ j' p → htpy-eq p))) ∘
    ( gap (λ h → h ∘ f) (λ h → h ∘ g) (cone-pullback-property-pushout f g c Y)))
triangle-pullback-property-pushout-universal-property-pushout
  {S = S} {A = A} {B = B} f g (dpair i (dpair j H)) Y h =
    eq-pair
      ( dpair refl (eq-pair (dpair refl (inv (issec-eq-htpy (h ·l H))))))

pullback-property-pushout-universal-property-pushout :
  {l1 l2 l3 l4 : Level} {S : UU l1} {A : UU l2}
  {B : UU l3} (f : S → A) (g : S → B) {X : UU l4} (c : cocone f g X) →
  {l : Level} (Y : UU l) →
  universal-property-pushout f g c Y → pullback-property-pushout f g c Y
pullback-property-pushout-universal-property-pushout
  f g (dpair i (dpair j H)) Y up-c =
  let c = (dpair i (dpair j H)) in
  is-equiv-right-factor
    ( cocone-map f g c)
    ( tot (λ i' → tot (λ j' p → htpy-eq p)))
    ( gap (λ h → h ∘ f) (λ h → h ∘ g) (cone-pullback-property-pushout f g c Y))
    ( triangle-pullback-property-pushout-universal-property-pushout f g c Y)
    ( is-equiv-tot-is-fiberwise-equiv
      ( λ i' → is-equiv-tot-is-fiberwise-equiv
        ( λ j' → funext (i' ∘ f) (j' ∘ g))))
    ( up-c)

universal-property-pushout-pullback-property-pushout :
  {l1 l2 l3 l4 : Level} {S : UU l1} {A : UU l2}
  {B : UU l3} (f : S → A) (g : S → B) {X : UU l4} (c : cocone f g X) →
  {l : Level} (Y : UU l) →
  pullback-property-pushout f g c Y → universal-property-pushout f g c Y
universal-property-pushout-pullback-property-pushout
  f g (dpair i (dpair j H)) Y pb-c =
  let c = (dpair i (dpair j H)) in
  is-equiv-comp
    ( cocone-map f g c)
    ( tot (λ i' → tot (λ j' p → htpy-eq p)))
    ( gap (λ h → h ∘ f) (λ h → h ∘ g) (cone-pullback-property-pushout f g c Y))
    ( triangle-pullback-property-pushout-universal-property-pushout f g c Y)
    ( pb-c)
    ( is-equiv-tot-is-fiberwise-equiv
      ( λ i' → is-equiv-tot-is-fiberwise-equiv
        ( λ j' → funext (i' ∘ f) (j' ∘ g))))