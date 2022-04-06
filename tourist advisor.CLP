; commentaire
; fait ordonné : ville à évaluer
; ( évaluation <ville> )
; Exemple : (evaluation Paris)
;	     (evaluation Saint-Etienne)
; Test : valeur, comparaison, positions
; (evaluation Paris Saint-Etienne) != (evaluation Saint-Etienne Paris)

; fait structuré : les K sur les villes
(deftemplate Architecture "information about architecture"
	(slot city (default ?DERIVE))
	(slot nbMonument (type INTEGER) (default 0))
	(slot nbGreenParks (type INTEGER) (default 0))
	(slot existence (allowed-symbols ancien modern) (default modern))
	(multislot buildings (cardinality 1 10))
	(slot museum (allowed-symbols oui non))
	(slot ancient (allowed-symbols oui non))
	(slot wide_avenue (allowed-symbols oui non))
)


(deftemplate Gastronomy "information about gastronomy"
	(slot city (default ?DERIVE))
	(slot nbRestaurants (type INTEGER) (default 1))
	(slot nbEtoile (type INTEGER))
	(slot gastro_tradition (allowed-symbols oui non))
)

(deftemplate QualityOfLife "information about quality of life"
	(slot city (default ?DERIVE))
	(slot folk_tradition (allowed-symbols oui non) (default non))
	(slot provence(allowed-symbols oui non) (default non))
	(slot seaside(allowed-symbols oui non) (default non))
)

(deftemplate MyEvaluation
	(slot city (type SYMBOL))
	(multislot architecture (allowed-symbols beautiful historic))
	(multislot gastronomy (allowed-symbols good_restaurants very_good_restaurants))
	(slot opinion (allowed-symbols merite_detour eviter))
	(slot welcoming_native (allowed-symbols oui non))
	(slot vegetation (allowed-symbols abundant_vegetation))
)



(deffacts test "my fact base"
	(evaluation Paris)
	(Architecture (city Paris) (nbGreenParks 6))
)


(defrule createMyEvaluation
	?e <-(evaluation ?v); ?v est libre
	(not (MyEvaluation (city ?v))); ?v est liée
=> ;action
	(assert (MyEvaluation (city ?v))); ajout dans la base faits
	(retract ?e)
)


(defrule BeautifulCity "R4"
	?me <-(MyEvaluation (city ?c) (architecture $?l))
		(not (MyEvaluation (city ?c) (architecture $? beautiful $?)))
	(Architecture (city ?c) (nbGreenParks ?nbg &:(> ?nbg 5) &: (< ?nbg 10)))
=>
	(modify ?me (architecture $?l beautiful))
)

(defrule REtoile "R6"
	?me <-(MyEvaluation (city ?c) (gastronomy $?l))
		(not (MyEvaluation (city ?c) (gastronomy $? very_good_restaurants $?)))
	(Gastronomy (city ?c)(nbEtoile ?nbE &: (> ?nbE 2)))
=>
	(modify ?me (gastronomy $?l very_good_restaurants))
)

(defrule R1
	?me<-(MyEvaluation (city ?c) (architecture $? beautiful $?)
	(gastronomy $? very_good_restaurants $?))
=>
	(modify ?me (opinion merite_detour))
)

(defrule R2
	?me<-(MyEvaluation (city ?c) 
	(architecture $? historic $?) 
	(gastronomy $? good_restaurants $?)
	(opinion ~merite_detour))
=>
	(modify ?me (opinion merite_detour))
)

(defrule R3
	?me<-(MyEvaluation (city ?c)
	(welcoming_native oui)
	(opinion ~merite_detour))

	(QualityOfLife (city ?c) 
	(folk_tradition oui))
=>
	(modify ?me (opinion merite_detour))
)

(defrule R5
	?me<-(MyEvaluation (city ?c)(gastronomy $?l))
	(not (MyEvaluation (city ?c)
	(gastronomy $? good_restaurants $?)))
	(Gastronomy (city ?c) (gastro_tradition oui))
=>
	(modify ?me (gastronomy $?l good_restaurants))
)

(defrule R7
	?me<-(MyEvaluation (city ?c) (architecture $?l))
	(Architecture (city ?c) (ancient oui) (museum oui))
=>
	(modify ?me (architecture $?l historic))
)

(defrule R8
	?me<-(MyEvaluation (city ?c))
	(QualityOfLife (provence oui) (seaside oui))
=>
	(modify ?me (welcoming_native oui))
)

(defrule R9
	?me<-(MyEvaluation (city ?c))
	(Architecture (city ?c) (nbGreenParks ?nbg &:(> ?nbg 1)) (wide_avenue oui))
=>
	(modify ?me (vegetation abundant_vegetation))
)
	