(set-logic NIA)

(set-option :produce-models true)
(set-option :incremental true)

; Deklarace promennych pro vstupy
; ===============================

; Parametry
(declare-fun A () Int)
(declare-fun B () Int)
(declare-fun C () Int)
(declare-fun D () Int)
(declare-fun E () Int)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; START OF SOLUTION ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; XLOGIN: xpokorr00

; Zde doplnte vase reseni

(
    assert(
    ite(or
        (<= D 0)(<= E 0) false true
    )
)

; bonus:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; END OF SOLUTION ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Testovaci vstupy
; ================

(echo "Test 1 - vstup A=1, B=1, C=3")
(echo "a) Ocekavany vystup je sat a D+E se rovna 17")
(check-sat-assuming (
  (= A 1) (= B 1) (= C 3)
))
(get-value (D E (+ D E)))
(echo "b) Neexistuje jine reseni nez 17, ocekavany vystup je unsat")
(check-sat-assuming (
  (= A 1) (= B 1) (= C 3) (distinct (+ D E) 17)
))

(echo "")
(echo "")

(echo "Test 2 - vstup A=5, B=2, C=5")
(echo "a) Ocekavany vystup je sat a D+E se rovna 18")
(check-sat-assuming (
  (= A 5) (= B 2) (= C 5)
))
(get-value (D E (+ D E)))
(echo "b) Neexistuje jine reseni nez 18, ocekavany vystup je unsat")
(check-sat-assuming (
  (= A 5) (= B 2) (= C 5) (distinct (+ D E) 18)
))

(echo "")
(echo "")

(echo "Test 3 - vstup A=100, B=15, C=1")
(echo "a) Ocekavany vystup je sat a D+E se rovna 2")
(check-sat-assuming (
  (= A 100) (= B 15) (= C 1)
))
(get-value (D E (+ D E)))
(echo "b) Neexistuje jine reseni nez 2, ocekavany vystup je unsat")
(check-sat-assuming (
  (= A 100) (= B 15) (= C 1) (distinct (+ D E) 2)
))

(echo "")
(echo "")

(echo "Test 4 - vstup A=5, B=5, C=3")
(echo "a) Ocekavany vystup je sat a D+E se rovna 2")
(check-sat-assuming (
  (= A 5) (= B 5) (= C 3)
))
(get-value (D E (+ D E)))
(echo "b) Neexistuje jine reseni nez 2, ocekavany vystup je unsat")
(check-sat-assuming (
  (= A 5) (= B 5) (= C 3) (distinct (+ D E) 2)
))

(echo "")
(echo "")

(echo "Test 5 - vstup A=1, B=1, C=1")
(echo "a) Ocekavany vystup je unsat")
(check-sat-assuming (
  (= A 1) (= B 1) (= C 1)
))

(echo "")
(echo "")

(echo "Test 6 - vstup A=4, B=5, C=3")
(echo "a) Ocekavany vystup je sat a D+E se rovna 2")
(check-sat-assuming (
  (= A 4) (= B 5) (= C 3)
))
(get-value (D E (+ D E)))
(echo "b) Neexistuje jine reseni nez 2, ocekavany vystup je unsat")
(check-sat-assuming (
  (= A 4) (= B 5) (= C 3) (distinct (+ D E) 2)
))

(echo "")
(echo "")

(echo "Test 7 - vstup A=0, B=0, C=0")
(echo "a) Ocekavany vystup je unsat")
(check-sat-assuming (
  (= A 0) (= B 0) (= C 0)
))

(echo "")
(echo "")

(echo "Test 8 - vstup A=100, B=-50, C=-75")
(echo "a) Ocekavany vystup je sat a D+E se rovna 4628")
(check-sat-assuming (
  (= A 100) (= B -50) (= C -75)
))
(get-value (D E (+ D E)))
(echo "b) Neexistuje jine reseni nez 4628, ocekavany vystup je unsat")
(check-sat-assuming (
  (= A 100) (= B -50) (= C -75) (distinct (+ D E) 4628)
))

(echo "")
(echo "")

(echo "Test 9 - vstup A=3, B=2, C=2")
(echo "a) Ocekavany vystup je sat a D+E se rovna 7")
(check-sat-assuming (
  (= A 3) (= B 2) (= C 2)
))
(get-value (D E (+ D E)))
(echo "b) Neexistuje jine reseni nez 7, ocekavany vystup je unsat")
(check-sat-assuming (
  (= A 3) (= B 2) (= C 2) (distinct (+ D E) 7)
))

(echo "")
(echo "")

(echo "Test 10 - vstup A=-100, B=-15, C=-90")
(echo "a) Ocekavany vystup je sat a D+E se rovna 977")
(check-sat-assuming (
  (= A -100) (= B -15) (= C -90)
))
(get-value (D E (+ D E)))
(echo "b) Neexistuje jine reseni nez 977, ocekavany vystup je unsat")
(check-sat-assuming (
  (= A -100) (= B -15) (= C -90) (distinct (+ D E) 977)
))