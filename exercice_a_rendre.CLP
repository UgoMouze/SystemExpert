(deftemplate Utilisateur
	(slot nom (type SYMBOL))
	(multislot competences (type SYMBOL))
	(slot service (type SYMBOL))
	(slot niveau_hierarchique (type INTEGER))
	(slot disponible (allowed-symbols oui non) (default non))
)

(deftemplate Message
	(slot emmeteur (type SYMBOL))
	(slot destinataire (type SYMBOL))
	(slot sujet (allowed-symbols prive non_prive) (default prive))
	(multislot entete (type SYMBOL))
	(slot priorite (type INTEGER))
	(multislot contenu (type SYMBOL))
)

(deffacts test
	(user Ugo)
	(Utilisateur (nom Ugo) 
	(competences manger boire dormir)
	(service IA)
	(niveau_hierarchique 3)
	(disponible non))

	(Message (emmeteur Elouan)
	(destinataire Ugo)
	(sujet prive)
	(entete bonjour)
	(priorite 1)
	(contenu bonjour ca va))
)

	

(defrule R1
	(Utilisateur (nom ?u)(disponible oui)); on ajoute que le destinaire est disponible pour ne pas avoir de probleme avec R2
	?msg<-(Message (destinataire ?u)(contenu ?contenu))
=>
	(printout t ?contenu crlf)
	(retract ?msg)
)

(defrule R2
	(Message (emmeteur ?e) 
	(destinataire ?u) 
	(sujet prive) 
	(entete $?ent))

	(Utilisateur (nom ?u) (disponible non))
=>
	(assert (Message (emmeteur ?u)(destinataire ?e) (sujet prive)
	(entete Re: $?ent)
	(contenu le recepteur ?u n'est pas disponible)))
)