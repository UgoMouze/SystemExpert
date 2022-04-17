(deftemplate Utilisateur
	(slot nom (type STRING))
	(multislot competences (type STRING))
	(slot service (type STRING))
	(slot niveau_hierarchique (type INTEGER)); le plus heaut niveau hierarchique est le niveau 1
	(slot disponible (allowed-symbols oui non) (default non))
)

(deftemplate Message
	(slot emmeteur (type STRING))
	(slot destinataire (type STRING))
	(slot sujet (allowed-symbols prive non_prive) (default non_prive))
	(slot entete (type STRING))
	(slot priorite (type INTEGER) (default 0))
	(slot contenu (type STRING))
)

(deffacts test
	(Utilisateur (nom "Mouze") 
	(competences "manger" "boire" "dormir")
	(service "IA")
	(niveau_hierarchique 1)
	(disponible oui))	

	(Utilisateur (nom "Ugo") 
	(competences "manger" "boire" "dormir")
	(service "IA")
	(niveau_hierarchique 3)
	(disponible non))

	(Message (emmeteur "Elouan")
	(destinataire "Ugo")
	(sujet non_prive)
	(entete "bonjour")
	(priorite 1)
	(contenu "bonjour ca va"))
)

	

(defrule R1
	(Utilisateur (nom ?u)(disponible oui)); on ajoute que le destinaire est disponible pour ne pas avoir de probleme avec R2
	?msg<-(Message (emmeteur ?e) (entete ?ent) (destinataire ?u)(contenu ?contenu))

=>
	(printout t "Emmeteur" crlf)
	(printout t ?e crlf)
	(printout t "Destinataire" crlf)
	(printout t ?u crlf)
	(printout t "Sujet" crlf)
	(printout t ?ent crlf)
	(printout t "Contenu :" crlf)
	(printout t ?contenu crlf)
	(retract ?msg)

)

(defrule R2
	(Message (emmeteur ?e) 
	(destinataire ?u) 
	(sujet prive) 
	(entete ?ent)
	(priorite ?p))

	(Utilisateur (nom ?u) (disponible non))
=>
	(assert (Message (emmeteur ?u)(destinataire ?e) (sujet prive)
	(entete ?ent)
	(contenu (str-cat "le recepteur" ?u "n'est pas disponible"))
	(priorite ?p)))
)

(defrule R3_entrant
	(Utilisateur (nom ?dirserv)(service ?s)
	(niveau_hierarchique ?niv &:(= ?niv 1)))
	
	(Utilisateur (nom ?u)
	(service ?s))
	
	(not (Utilisateur (nom ?u)
	(niveau_hierarchique ?niv &:(= ?niv 1))))

	(Message (emmeteur ?e) 
	(destinataire ?u) 
	(sujet non_prive) 
	(priorite ?p)
	(entete ?ent)
	(contenu ?cont))
	
	
=>
	(assert(Message (emmeteur ?e)
	(priorite ?p)
	(entete (str-cat "Fwd " ?u (str-cat " " ?e (str-cat " " ?ent))))
	(destinataire ?dirserv)
	(contenu ?cont)))
)

(defrule R3_sortant
	(Utilisateur (nom ?dirserv)(service ?s)
	(niveau_hierarchique ?niv &:(= ?niv 1)))
	
	(Utilisateur (nom ?u)
	(service ?s))
	
	(not (Utilisateur (nom ?u)
	(niveau_hierarchique ?niv &:(= ?niv 1))))

	(Message (emmeteur ?u) 
	(destinataire ?e) 
	(sujet non_prive) 
	(priorite ?p)
	(entete ?ent)
	(contenu ?cont))
	
	
=>
	(assert(Message (emmeteur ?e)
	(priorite ?p)
	(entete (str-cat ?u ?e ?ent))
	(destinataire ?dirserv)
	(contenu ?cont)))
)

(defrule R4
	(Utilisateur (nom ?u)(disponible oui));
	?msg<-(Message (emmeteur ?e) (entete ?ent) (destinataire ?u)(contenu ?contenu)(priorite ?p))
	(not(Message (destinataire ?u)(priorite ?pf &:(> ?pf ?p))))

=>
	(printout t "Emmeteur" crlf)
	(printout t ?e crlf)
	(printout t "Destinataire" crlf)
	(printout t ?u crlf)
	(printout t "Sujet" crlf)
	(printout t ?ent crlf)
	(printout t "Contenu :" crlf)
	(printout t ?contenu crlf)
	(retract ?msg)
)

(defrule R5
	?msg<-(Message (destinataire ?comp) (emmeteur ?e))
	
	(Utilisateur (nom ?e) (service ?s))

	(Utilisateur (service ?s) (competences ?comp) (nom ?n)(disponible oui));on ajoute la disponibilité pour être cohérent avec la suite
=>
	
	(modify ?msg (destinataire ?n)
	(entete (str-cat "Message compétence interne: " ?comp " ")
	))
)

(defrule R6
	?msg<-(Message (destinataire ?comp) (emmeteur ?e))
	
	(Utilisateur (nom ?e) (service ?s))

	(not(Utilisateur (service ?s) (competences ?comp) (disponible oui)))
	
	(Utilisateur (nom ?n) (competences ?comp) (disponible oui))
=>
	
	(modify ?msg (destinataire ?n)
	(entete (str-cat "Message compétence interne: " ?comp " ")
	))
)

(defrule R7
	?msg<-(Message (destinataire ?comp) (emmeteur ?e))
	
	(Utilisateur (nom ?e) (service ?s))

	(not(Utilisateur (competences ?comp) (disponible oui)))
	
	(Utilisateur (nom ?n) (competences ?comp))
=>
	
	(modify ?msg (destinataire ?n)
	(entete (str-cat "Message compétence interne: " ?comp " ")
	))
)