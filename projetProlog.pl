%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               GRAMMAIRE                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% On utilisera les opérateurs classiques 
operateur(+).
operateur(-).
operateur(/).
operateur(*).
plus(+).
moins(-).
divise(/).
fois(*).

/*  Les seules unités qu'on souhaite traiter son les grammes, mètres et octets
        Unite -> g | m | o
    Les seules quantitées qu'on souhaite traiter sont les kilos, hecto, déca, déci, centi, milli
        Quantite -> k | h | dca | d | c | m
        Mesure -> Unite | Unite Quantite    */
        
quantite(k).
quantite(h).
quantite(dca).
quantite(d).
quantite(c).
quantite(m).

kilo(k).
hecto(h).
deca(dca).
deci(d).
centi(c).
milli(m).

unite(g).
unite(m).
unite(o).

% Ici on verifie que M est une mesure
mesure(M):-
    unite(M).
mesure(M):-
    atom_concat(Q,U,M),
    quantite(Q),
    unite(U).
    
% Ici on ressort l'Unite U et la quantité Q de la mesure M    
mesure(M,M):-
    unite(M).

mesure(M,Q,U):-
    atom_concat(Q,U,M), 
    quantite(Q),
    unite(U).  
    
%   Un facteur c'est un nombre suivi d'une mesure
facteur([A,B]):-
    number(A),mesure(B).

/*  Une ligne de commande c'est 
        un facteur
        ou ligne de commande, un operateur, une ligne de commande   */    
commande(L):-
    facteur(L).
commande([Nb,M,O|R]):-
    mesure(M),
    operateur(O),
    commande([Nb,M]),operateur(O),commande(R).
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/*  SPEC : operation/4
    operation(O,A,B,R) vrai ssi 
        R= A + B (si O est +)
        R= A * B (si O est /)
        R= A / B (si O est *)
        R= A - B (si O est -)
*/
operation(Op,F1,F2,Res):-
    plus(Op),
    Res is F1+F2.
operation(Op,F1,F2,Res):-
    moins(Op),
    Res is F1-F2.
operation(Op,F1,F2,Res):-
    dif(F2,0),
    divise(Op),
    Res is F1/F2.
operation(Op,_,0,0):-
    divise(Op).
operation(Op,F1,F2,Res):-
    fois(Op),
    Res is F1*F2.

    
% Les multiplications / Divisions utiles pour les conversions 
multiplieParMille(R,S):-S is R*1000.
multiplieParCent(R,S):- S is R*100.
multiplieParDix(R,S):-  S is R*10.
diviseParDix(R,S):-     S is R/10.
diviseParCent(R,S):-    S is R/100.
diviseParMille(R,S):-   S is R/1000.

% Petit raccourci plus 'lisible' pour les fonctions de conversions
fromKilo(R,S):-     multiplieParMille(R,S).
fromHecto(R,S):-    multiplieParCent(R,S).
fromDeca(R,S):-     multiplieParDix(R,S).
fromDeci(R,S):-     diviseParDix(R,S).
fromCenti(R,S):-    diviseParCent(R,S).
fromMilli(R,S):-    diviseParMille(R,S).

toKilo(R,S):-       diviseParMille(R,S).
toHecto(R,S):-      diviseParCent(R,S).    
toDeca(R,S):-       diviseParDix(R,S).
toDeci(R,S):-       multiplieParDix(R,S).
toCenti(R,S):-      multiplieParCent(R,S).
toMilli(R,S):-      multiplieParMille(R,S).

% Les conversions depuis les kilos/Hecto.... vers l'unité neutre
conversionFrom(Nb,U,R):-
    kilo(U),
    fromKilo(Nb,R).
conversionFrom(Nb,U,R):-
    hecto(U),
    fromHecto(Nb,R).
conversionFrom(Nb,U,R):-
    deca(U),
    fromDeca(Nb,R).
conversionFrom(Nb,U,R):-
    deci(U),
    fromDeci(Nb,R).
conversionFrom(Nb,U,R):-
    centi(U),
    fromCenti(Nb,R).
conversionFrom(Nb,U,R):-
    milli(U),
    fromMilli(Nb,R).

% Les conversions depuis l'unité neutre vers les kilos/Hecto....  
conversionTo(Nb,U,R):-
    kilo(U),
    toKilo(Nb,R).
conversionTo(Nb,U,R):-
    hecto(U),
    toHecto(Nb,R).
conversionTo(Nb,U,R):-
    deca(U),
    toDeca(Nb,R).
conversionTo(Nb,U,R):-
    deci(U),
    toDeci(Nb,R).
conversionTo(Nb,U,R):-
    centi(U),
    toCenti(Nb,R).
conversionTo(Nb,U,R):-
    milli(U),
    toMilli(Nb,R).

/*  SPEC : getUfromF/2
    getUfromF(F,U) vrai ssi 
        U est l'unité de mesure F
        
    exemple :   conversion_facteur([1,kg],g)    true
                conversion_facteur([1,kg],kg)   false
*/
getUfromF([Nb,QU],U):-
    facteur([Nb,QU]),
    mesure(QU,U).
getUfromF([Nb,QU],U):-
    facteur([Nb,QU]),
    mesure(QU,_,U).    


/*  SPEC : verifUniciteCommande/2
    verifUniciteCommande(L,U) vrai ssi 
        toute les unités de la chaine de commandes sont l'unité U
    
    exemple :   verifUniciteCommande([1,g,+,15,kg],g) vrai
                verifUniciteCommande([1,m,+,3,g],g) faux
*/
verifUniciteCommande([],_).
verifUniciteCommande(L,U):-
    append(F,S,L),
    getUfromF(F,U),
    verifUniciteCommande(S,U).  %  On verifie déja que F est un facteur dans ce prédicat
verifUniciteCommande(L,U):-
    append([O|F],S,L),
    operateur(O),
    getUfromF(F,U),             %  On verifie déja que F est un facteur dans ce prédicat
    verifUniciteCommande(S,U).


/*  SPEC : conversion_facteur/2
    conversion_facteur(F,R) vrai ssi 
        R est l'entier converti dans l'unité de mesure  neutre du facteur F
        
    exemple : conversion_facteur([1,kg],1000)
*/
conversion_facteur(F,R):-
    facteur(F),
    append([Nb],[M],F),
    number(Nb),
    mesure(M,Q,_),%On est dans le cas où on n'est pas dans l'unité neutre
    conversionFrom(Nb,Q,R).
conversion_facteur(F,Nb):-
    facteur(F),
    append([Nb],[M],F),
    number(Nb),
    mesure(M,_).    %On est dans le cas où on esdt deja dans l'unité neutre

/*  SPEC : calcul_chaine/3
    calcul_chaine(L,Ar,R) vrai ssi 
        R est le resultat des operations de la lignes de commandes L avec Ar la valeur de l'ancienne calcul
        
    exemple : calcul_chaine([1,kg,+,10,g],_,1010)
*/
calcul_chaine([],Ar,Ar).
calcul_chaine(L,_,Res):-
    append(F,S,L),
    conversion_facteur(F,R),    % Dans ce prédicats on verifie déja que F est un facteur
    calcul_chaine(S,R,Res).
calcul_chaine(L,Ar,Res):-
    append([O|F],S,L),
    operateur(O),
    conversion_facteur(F,Nr),   % Dans ce prédicats on verifie déja que F est un facteur
    operation(O,Ar,Nr,R),
    calcul_chaine(S,R,Res).
    

saisitDeLaCommande(L):-
    writeln('Donner votre calcul ?'),
    readln(L),
    verifUniciteCommande(L,_).
%   writeln(L).    
/*saisitDeLaCommande(L):-
    writeln('Votre dernière commande ne vérifiait pas l\'unicité'),
    writeln('Donner votre calcul ?'),
    readln(E),
    not(verifUniciteCommande(E,_)),
    saisitDeLaCommande(L).    */

saisitDeLaMesure(M):-
    writeln('Dans quelle unité de mesure souhaitez vous le résultat ?'),
    readln([M]),
    mesure(M).
%   writeln(M).
/*saisitDeLaMesure(M):-
    writeln('Merci de saisir une unité de mesure valide'),
    writeln('Dans quelle unité de mesure souhaitez vous le résultat ?'),
    readln([Mf]),
    not(atom(Mf)),
    not(mesure(Mf)),
    saisitDeLaMesure(M).*/

verifUniciteGeneral(C,M):-
    ( mesure(M,_,U);mesure(M,U) ),
    verifUniciteCommande(C,U).
verifUniciteGeneral(C,M):-
    ( mesure(M,_,U);mesure(M,U) ),
    not(verifUniciteCommande(C,U)),
    writeln('Votre saisi ne verifie pas l\'unicité'),
    saisitDeLaCommande(L),
    saisitDeLaMesure(M1),
    verifUniciteGeneral(L,M1).

calculatrice(C,M,R):-
    calcul_chaine(C,_,Res),
    mesure(M,Q,_),
    conversionTo(Res,Q,R).
calculatrice(C,M,R):-
    calcul_chaine(C,_,R),
    mesure(M,_).
affichageResultat(R,U):-
    write(R),writeln(U).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main :-
    saisitDeLaCommande(E),
    saisitDeLaMesure(M),
    verifUniciteGeneral(E,M),
    calculatrice(E,M,Res),
    affichageResultat(Res,M).
:- main, halt.