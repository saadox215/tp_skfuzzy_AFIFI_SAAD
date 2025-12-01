/* --- 1. Définition des maladies (Règles) --- */
/* Le système vérifie les hypothèses une par une. */

maladie(grippe) :-
    a_symptome(fievre),
    a_symptome(toux),
    a_symptome(fatigue),
    a_symptome(courbatures).

maladie(angine) :-
    a_symptome(mal_gorge),
    a_symptome(fievre),
    \+ a_symptome(toux).  /* \+ signifie NOT : pas de toux généralement */

maladie(covid) :-
    a_symptome(fievre),
    a_symptome(toux),
    a_symptome(fatigue),
    \+ a_symptome(eternuements).

maladie(allergie) :-
    a_symptome(eternuements),
    a_symptome(nez_qui_coule),
    \+ a_symptome(fievre).

/* --- Liste des symptômes pour l'explication (Partie 3) --- */
/* Cela nous servira à dire POURQUOI on a trouvé cette maladie */
symptomes_caracteristiques(grippe, [fievre, toux, fatigue, courbatures]).
symptomes_caracteristiques(angine, [mal_gorge, fievre]).
symptomes_caracteristiques(covid, [fievre, toux, fatigue]).
symptomes_caracteristiques(allergie, [eternuements, nez_qui_coule]).

/* --- 2. Moteur d'interaction --- */

/* Déclaration des faits dynamiques pour stocker les réponses */
:- dynamic positif/1.
:- dynamic negatif/1.

/* Prédicat pour vérifier un symptôme */
a_symptome(S) :-
    positif(S), !.        /* Déjà confirmé OUI -> on arrête et renvoie Vrai */

a_symptome(S) :-
    negatif(S), !, fail.  /* Déjà confirmé NON -> on arrête et renvoie Faux */

a_symptome(S) :-
    poser_question(S).    /* Pas encore connu -> on pose la question */

/* Prédicat pour poser la question et stocker la réponse */
poser_question(S) :-
    format('Avez-vous le symptôme suivant : ~w ? (o/n) ', [S]),
    read(Reponse),        /* Attention : l'utilisateur doit mettre un point '.' après 'o' ou 'n' */
    traiter_reponse(S, Reponse).

traiter_reponse(S, 'o') :-
    assert(positif(S)).   /* On mémorise que c'est VRAI */

traiter_reponse(S, 'n') :-
    assert(negatif(S)),   /* On mémorise que c'est FAUX */
    fail.                 /* On fait échouer le prédicat car le symptôme est absent */

/* --- 3. Lancement et Explications --- */

expert :-
    write('--- BIENVENUE DANS LE SYSTEME EXPERT MEDICAL ---'), nl,
    write('Veuillez repondre par "o." ou "n." (avec le point).'), nl, nl,
    
    /* Nettoyage des réponses de la session précédente */
    retractall(positif(_)),
    retractall(negatif(_)),
    
    /* Recherche de toutes les maladies possibles */
    findall(M, maladie(M), ListeMaladies),
    
    /* Affichage des résultats */
    afficher_resultats(ListeMaladies).

/* Cas où aucune maladie n'est trouvée */
afficher_resultats([]) :-
    nl, write('Le système n a pas pu determiner de diagnostic précis.').

/* Cas où des maladies sont trouvées : on les liste et on explique */
afficher_resultats([Tete|Queue]) :-
    nl, write(' DIAGNOSTIC TROUVE : '), write(Tete), nl,
    expliquer(Tete),
    afficher_resultats(Queue).

/* Explication : Affiche les symptômes qui ont mené à la conclusion */
expliquer(Maladie) :-
    symptomes_caracteristiques(Maladie, Liste),
    write('  -> Raison : Vous presentez les symptomes : '), write(Liste), nl.

