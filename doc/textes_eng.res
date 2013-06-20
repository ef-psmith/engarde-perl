#textes_engarde=English Text by Michael Corish and JF Nicaud (15/10/2002)

Ce fichier contient les textes d'ENGARDE. Il peut être traduit dans une 
autre langue.
Pour cela :

* la première ligne doit être modifiée :
- en conservant le premier champ (#textes_engarde=)
- en traduisant et adaptant le texte après =

Une ligne commençant par # et contenant = décrit un texte, sinon, c'est un 
commentaire
qui est ignoré lors du chargement.
La partie entre # et = est le symbole qu'il ne faut pas modifier.
La partie après = est le corps du texte à traduire dans votre langue.

Pour certains textes, on donne aussi une version réduite
on utilise pour cela le même symbole avec % à la fin
exemple :
texte normal : #present=présent[/e|s/es]
texte réduit : #present%=P

Il est recommandé d'écrire les textes en minuscules. ENGARDE se charge des 
majuscules
en général.
Exception : il est recommandé d'écrire les textes réduits en majuscules.

******************************************************************************

On indique ici si on utilise une langue latine ou non en mettant oui ou non
Quand on met non, il n'y a pas de modificiation des textes :
- pas de transformation de minuscules en majuscules,
pas de suppression d'espaces, pas d'accord en genre et en nombre.
Il faut alors écrire des textes sans [ / | ]
mais il faut conserver les ^

Indicate below if the language uses latine letters (write oui or non)
When non is written, the texts are not modified:
- no transofrmation in upper/lower case
- no suppression of spaces, no gender or number consideration.
Texts must be writtent without [ / | ]
but ^ must be kept

#alphabet_latin=oui

Indicate below if you wante Engarde manage upercase for title or not

#majuscules_automatiques=oui

Indicate below the size of the labels for the input windows when you want a 
fixed size.
0 means automatic size (use it for latin languages)
another value is the precie size in pixels, usually between 100 and 200 (use 
it for
Chinese for example).

#size_of_label=0

******************************************************************************
                        LA COMPETITION

#competition=(f)competition[|s]
#nouv_compe_indiv=new individual competition
#parametres=options
#parametres_principaux=main options
#individuelle=individual[/|s/s]
#par_equipes=team
#type_compe=competition type
#national=national[/|s/s]
#international=international[/|s/s]
#domaine_compe=competition domain
#arme=weapon
#fleuret=foil
#epee=epee
#sabre=sabre

#organisateur=(m)organiser
#federation=(f)federation
#titre_reduit=(m)short title
#texte=text

#titre_ligne=title on one line

#titre1=title : line 1
#titre2=title : line 2
#titre3=title : line 3
#titre4=title : line 4


******************************************************************************

                       LES ENTITES DES TABLES

toutes les entités ont un nom
pour les tireurs et les arbitres, le nom est le nom de famille
#nom=(m)name[|s]

les nations ont un nom en 3 lettres et un nom complet
#nom_etendu=(m)full name[|s]

les entités ont des affiliations (club, nation...)
#affiliation=affiliation
#affiliation_possible=(f)possible affiliation[|s]

Pour les les tireurs, les arbitres et les équipes
#presence=(f)presence
#presence%=(f)pres
les adjectifs associés [homme/dame|hommes/dames]
#present=present[/|/]
#present%=P
#absent=absent[/|/]
#absent%=A
#absentpardefaut=absent by default
#presentpardefaut=present by default

Pour les tireurs et les arbitres :
#sexe=(m)sex[|s]
#sexe%=(m)sex[|s]
les adjectifs associés [homme/dame|hommes/dames] ACCORDES AVEC LE MOT SEXE
#masculin=male
#masculin%=M
#feminin=female
#feminin%=F

Pour les tireurs :
#categorie=category
#categorie%=cat
#veteran=veteran[/|s/s]
#veteran%=V
#senior=senior[|s]
#senior%=S
#junior=junior[|s]
#junior%=J
#cadet=cadet[/|s/s]
#cadet%=C
#minime=minime[|s]
#minime%=M
#benjamin=benjamin[/|s/s]
#benjamin%=B
#pupille=pupille[|s]
#pupille%=P
#poussin=poussin[|s]
#poussin%=O

pour les clubs, ligues, nations
#effectif=available

***********
LES TIREURS

tireur : [homme/dame|hommes/dames]
#tireur=fencer[/|s/s]

un tireur a les champs : nom, numero, presence
il a une équipe (en compétition par équipe)
des affiliations parmi : nation, ligue, club
les autres champs sont :

#prenom=(m)first name[|s]
#prenom%=(m)f. name
#nomprenom=(m)name[|s] and first name[|s]
#nomprenom%=(m)name[|s]
#date_nais=(f)date[] of birth
#date_nais%=(f)d.o.b.
#licence_fie=(f)FIE licence
#licence_fie%=(f)FIE lic.
#cle=key
#cle_fie=(f)FIE key
#cle_fie%=(f)key
#comp_lice_fie=(f)FIE key
#comp_lice_fie%=(f)key
#licence=(f)licence[|s]
#licence%=(f)lic.
#dossard=(m)mask number[|s]
#dossard%=(m)mask nos.
#serie=(m)seeding
#serie%=seeding
#mobile=mobile
les points AU PLURIEL
#points=(m+)points
#points%=(m+)pts
#rang=(m)rank
#rang%=(m)rank
#nb_poules=number of poules
#nb_poules%=poules
#nb_matches=number of matches
#nb_matches%=matches
#nb_finales=nbre de finales
#nb_finales%=finales

#groupe=group
#groupe%=grp
#vic_match=victory/match
#vic_match%=V/M
#indice=indicator
#indice%=ind.
#td=hits scored
#td%=HS
#tr=hits received
#tr%=HR

***********
LES EQUIPES

#equipe=(f)team[|s]

une équipe a les champs : nom, numero, presence
des affiliations parmi : nation, ligue, club
les autres champs sont :

#serie_eq=(m)seeding
les points au pluriel
#points_eq=(m+)points

***********
LES CLUBS

#club=(m)club[|s]

un club a les champs : nom, numero
des affiliations parmi : nation, ligue

***********
LES LIGUES

#ligue=(f)region[|s]

les ligues sont des regroupements de clubs dans une nation
dans certaines nations, ce sont des états ou des régions

#etat=State[|s]
#region=Region [|s]

une ligue a les champs : nom, numero
une affiliation éventuelle : nation

***********
LES NATIONS

#nation=(f)countr[y|ies]

une nation a les champs : nom, numero

***********
LES ARBITRES

#arbitre=(m)referee[|s]

un arbitre a les champs : nom, numero, presence, prenom, sexe, categorie
des affiliations parmi : nation, ligue, club


******************************************************************************

#formule=(f)formula[|e]
#formu_compe=formula of the competition
#pas_de_poule=this formula does not include poules
#pas_de_tableau=this formula does not include direct elimination
#pas_fini_poules=the poules are not complete
#clasmt_origine=original ranking
#tour_poules=^1 poules: round[1||s]
#nombre_tireurs=number of fencers
#nombre_tours_poules=number of rounds of poules
#qual_fin_poules_sur=number of rounds for qualification
#clas_fin_poules_sur=number of rounds for ranking
#qual_fin_poules_sur_x=qualification at the end of the poules on round ^1 
[1||]
#clas_fin_poules_sur_x=ranking at the end of the poules on round^1 [1||]
#nombre_touches_poules=number of hits in matches in the poules
#nombre_touches_tableaux=number of hits in matches in the direct elimination

#max_touches=maximum number of hits
#matches_en=matches of ^1 hit[1||s]
#dans_poules=in the poules
#nombre_suites_tableaux=number of phases of the direct elimination
#tire_3e=3rd place will be fenced
#formule_poules=formula for the poules
#formule_tableaux=formula for the direct elimination
#tour_no=round No ^1
#suite_tab_no=phase No ^1 of the direct elimination
#trop_exemptes=there are too many exempt fencers
#trop_poules=there are too many poules
#trop_qualifies=there are too many qualified fencers
#trop_tireurs=there are too many fencers

#bar_exemptes=barrage for exemptions

#modifier_valeurs=change values
#nb_change=the number of ^1 has changed
#revoir_formule=the formula must be checked
#au_depart=^1 at the start
#exempte=^1 exemption[1|/|s/s]
#il_faut=you must
#exemptes=exemptions
#non_exemptes=^1 non exempt
#pas_decalage=no separation
#decalage_par=separation by
#limite_a=restricted to ^1
#qualifies=qualifiers
#qualifie=^1 qualifier[1|/|s/s]
#elimines=eliminated
#elimine=^1 eliminated[1|/|/]
#par_poule=^1 by  poule
#a_l_indice=^1 by indicators
#a_la_fin=^1 at the end

#remp_auto_pou=automatic completion of the poules
#simu=to run the simulation
#est_fait=is complete

#poules_finies=poules completed
#compe_finie=competition ended
#on_en_est=you are currently at:
#const_poules=create the poules
#const_tableau=creation of the tableau
#saisie_poule=enter the poules
#remplissageauto=automatic completion
#feuilles_pou=poule sheets
#poules_const=constitution of the poules
#poules_resu=results of the poules
#poules_a_saisir=^1 poule[1||s] to enter
#tableaux_a_saisir=^1 tableau[1||x] to enter
#matches_a_saisir=^1 match[1||es] to enter
#matches_a_imp=^1 match[1||es] to print
#poules_a_imp=^1 poule[1||s] to print
#imp_toutes_pou=print all poules
#imp_des_pou=print certain poules
#de_poule=from poule
#a_poule=to poule
#poule_saisie=this poule has already been entered
#grille=grid
#imp_match_de=print the matches of
#imp_match_attente_de=print the matches waiting for

#refaire_poules=redo the poules
#refaire_tableau=redo the tableau
#refaire_poules_tno=redo the poules of round No ^1
#poules_tno=poules of round No ^1
#revenir_tour=go back to the previous round
#revenir_tour_no=go back to round No ^1
#modif_scores=change all the scores
#modif_raz=re-enter the poule deleting the previous data
#modif_poule_int=would you like to modify this poule
#repartition_poule=separation in the poules

#toutes_saisies=the poules are all entered
#bar_dans_poule=there is a barrage in the poule
#qual_poule=^1 qualified[1||s] in the poule
#pas_qual_poule=NON qualifiers in the poule
#qual_indice=^1 qualifier[1||s] by indicators
#y_a_barrage=there is a barrage
#poules_saisies=^1 poule[1||s] [1|has|have] been entered[1||s]

#perdre=would you like to discard this
#perdre_tab=would you like to discard the tableaux

#numero=number
#numero%=No
#total_tireurs_depart=fencers at the start
#nombre_exemptes=exemptions
#tireurs_dans_poules=fencers in the poules
#tireurs_dans_tableau=fencers in the tableau
#nombre_poules=number of poules
#tireurs_par_poule=number of fencers per poule
#critere_decal_1=separation criteria 1
#critere_decal_2=separation criteria 2
#critere_decal_3=separation criteria 3
#critere_placement=place in the poules by
#limite_decal=limit of separation
#qualifies_par_poule=number qualified per poule
#qualifies_indice=number qualified by indicators
#total_tireurs_fin=fencers at the end
#total_tireurs_depart%=fencers at the start
#nombre_exemptes%=exemptions
#tireurs_dans_poules%=in the poules
#tireurs_dans_tableau%=in the tableau
#nombre_poules%=no poules
#tireurs_par_poule%=no per poule
#critere_decal_1%=criteria 1
#critere_decal_2%=criteria 2
#critere_decal_3%=criteria 3
#critere_placement%=poule placement
#limite_decal%=separation limit
#qualifies_par_poule%=qualifiers/poule
#qualifies_indice%=qualifiers/indicators
#qualifies%=qualifiers
#total_tireurs_fin%=fencers end

#qualif_tour=qualification for round No ^1

******************************************************************************
                       LES POULES

#deroulement=Control

#poule=(f)poule[|s]
#poules=(f)poules
#x_poule=^1 poule[1||s]
#x_poule_de=^1 (f)poule[1||s] of ^2
#x_poule_de_ou=^1 (f)poule[1||s] of ^2 or ^3
#sais_poules=entry of the poules
#sais_matches=entry of the matches
#sais_pistes=entry of the pistes
#sais_arbitres=entry of the referees
#sais_horaires=entry of the times
#sais_piste_arbi=entry of the pistes and the referees
#modif_poules=modify the poules
#poule_no=poule No ^1
#match_no=match No ^1
#piste_no=piste No ^1
#piste=(f)piste[|s]
#piste%=P.
#pas_bon_no_pou=is not a correct poule number
#pas_bon_no_match=is not a correct match number
#pas_bon_tab=is not a tableau
#lettre_et_nombre=a letter and number are needed
#reordonne=re-order the poule
#garde_ordre=keep this order
#ajout_tir_pas_ds_pou=add a fencer absent from the poules
#les_tireurs=the fencers
#enleves_poules=removal from the poules

******************************************************************************
                       LES TABLEAUX

#tableau=(m)tableau[|x]
#tableau_de=tableau of ^1
#tableau_prelim_de=preliminary tableau of ^1
#tableau_prince_de=main tableau of ^1
#tableau_phase_de=tableau "phase ^1" of ^2
#tableau_final=final tableau
#demi_finales=semi-finals
#finale=final

******************************************************************************

#classement=(m)ranking[|s]
#classement_des=ranking of ^1
#classement_apres_pou=ranking at the end of the poules

******************************************************************************
                       Le menu principal

#nouv_compe=new competition
#ouvrir_compe=open competition
#fermer_compe=close competition
#sauvegarde=backup
#sauve_compe=save the fencers of the competition
#sauve_dans=save as
#faire_fic_trans=results files, other files

#fic_trans_dos=earlier format DOS transfer file
#fic_trans_FFF=FFF transfer file

#fic_resu=creation of a results file
#activiteArbitres=referee activity
#avec_series=with seeding
#avec_rangs=with ranking
#du_rang=from ranking
#au_rang=to ranking

#enreg_compe=Create a competition
#chargement=load
#prepa_tables=preparing tables
#prepa_affi=preparing listings
#ecraser=delete ^1
#pas_sur_elle=you can not copy a competition onto itself

#copie_de=copy of ^1
#choix_rpla=or select another competition to overwrite it
#rep_pas_cree=the directory ^1 has not been created

#modif_de=modification of ^1
#val_convient_pas=response not valid
#pour_cela=to do that
#arriere=you must return to a prevous stage
#dans_tableaux=in the tableaux
#valeur_initiale=initial value
#pas_encore_tab=tableau not started

******************************************************************************
                       La fiche des tables

#table=(f)table[|s]
#tri=sort

******************************************************************************

                       La fiche de saisie
#fiche=(f)file[|s]
#edition=entry
#affiliation=affiliation
#curseur_init=default field
#colonne1fixe=column 1 fixed

#import_fiche=import file
#importer=import
#importer_tous=import all
#effacer_champ=blank the field
#effacer_fiche=blank the file

#precedent=previous[//]
#suivant=next[/|/]
#premier=first [/|/]
#dernier=last[/|/]
#symetrique=symmetric value

#nouveau=new[/|/]
#saisir=input
#saisie=entry
#saisir_affil=enter affiliation
#modifier=modify
#chercher=search
#chercher_compe=search in the competition
#chercher_res=search in memory
#chercher_fic=search in file
#fermer=close
#suite=continue
#enregistrer=save
#enregistrement=saving
#quitter=quit Engarde
#retour_Engarde=go back to Engarde
#retour_init=return to initial state
#maximum=maximum
#vic_score=victory with score

When the 5 symbols victoire% defaite% abandon% exclusion% forfait%
are not defined below, victoire defaite abandon exclusion forfait
must begin with different letters (not w and not x)
#victoire=victory
#defaite=defeat
#abandon=abandonment
#exclusion=exclusion
#forfait=scratch

These 5 symbols must be defined when #alphabet_latin=non
They may also be defined when #alphabet_latin=oui
juste one latin letter for each, not x, not w, all different
#victoire%=v
#defaite%=d
#abandon%=a
#exclusion%=e
#forfait%=s

#efface_sym=symmetric removal
#sym_pas_defaite=the symmetric pair is not a defeat
#sym_pas_vic=the symmetric pair is not a victory
#vic_inf_defaite=victory with a score smaller that the defeat

#navigation=file
#meme_champ=same field
#premier_champ=first field
#oblige=you must give a [1|/] ^1

#deja_table=is already in the table
#on_prend_a_la_place=will take the place of
#on_a_ici=and we have here

  ^1 sera remplacé par un nombre, ^2 par tireur, club...
#il_y_a=^1 [1|^2]

  ^1 sera remplacé par classement...
#existe_pas=th[1|is|ese] ^1 do[1|es/es|/] not exist

  ^1 sera remplacé par tireurs, tours de poules...
#nombre_de=number of ^1
#ajouter=add
#supprimer=delete
#suppress=suppress
#suppress_x=deletion of ^1 [1|^2]
#pas_supp=you cannot delete
#car_compe=as [he/she|they/they] [is|are] in the competition
#car_util=as this ^1 [1|is|are] used by

#sur_premiere=first record
#sur_derniere=last record
#taper_deb=enter the start of the name

#agglomerer=merge
#agglo_x=merging of ^1 [1|^2]

******************************************************************************
                            La fiche de recherche

#recherche=search
#commencant_par=starting with
#contenant=containing
#exacte=exact
#approchee=resembles

#chercher_un=search [1|a/a|some/some] ^1
#chercher_autre=search [1|another/another|more/more] ^1
#resultat=the result is

******************************************************************************

#oui=yes
#oui%=y
#non=no
#non%=n
#vrai=true
#vrai%=t
#faux=false
#faux%=f
#ok=ok
#annuler=cancel
#aide=help
#pas_aide=help not found
#pas_fic=file not found
#generalites=general options
#contexte=context

#et=and
#ou=or
#date=(f)date
#au_lieu_de=instead of
#repart_parfaite=perfect separation
#n_imperfect=^1 imperfection[1||s]

#exemple=(m)example[|s]
#signature=signature[|s]
#pas_saisie=no input
#dbclick=double click
#use_menu=use menu ^1
#liste_vide=empty list
#liste_des=list of ^1

#reserve=memory
#charger=load
#vider=empty
#fichier=(m)file[|s]
^1 sera remplacé par fichier ou compétition
#est_de_genre=the ^1 is of type ^2
#on_charge_fic=load the file of ^1
#chargt_de=loading the ^1
#on_charge=loading even so
#entites_chargees=^1 [1|^2] loaded[2|/|/] in memory
#entites_reserve=^1 [1|^2] in memory
#reserve_vide=memory is empty
#on_importe=loading ^1 [1|^2] into the competition
#reste_importer=there remain to import:

#essai_trans=test of format "DOS transfer"
#prem_ligne=the first line gives
#est_fic_a_charger=is this the file to import
#pas_type_connu=file type not known

#page=(f)page[/s]
#marge=(f)margin[/s]

#concerne_tir=about the fencer[s/s]
#concerne_tir_pres=about the fencer[s/s] present
#concerne_arbi=about the referees
#concerne_arbi_pres=about the referees present
#tous=all
#ordre=order
#ordre_alpha=alphabetic order
#ordre_structure=structured order
#ordre_serie=ordered by seeding
#ordre_points=ordered by points
#ordre_rang=ordered by ranking
#selection=selection
#reglages_imp=print settings
#rub_a_imp=fields to print
#document=report
#contenu=contents
#police=font settings
#mise_en_page=print setup
#imprimer=print
#ajuster=adjust

#non_modifiable=this entity is not modifiable
#anomalie=anomaly
#termine=complete
#vide=empty
#preparation=being prepared
#en_cours=in progress

#dans=in
#match_non_lance=match not issued
#match_a_un=this match has only one fencer who has therefore has a bye
#match_deja_saisi=match already entered
#heure=(f)hour[|s]
#pas_vainqueur=no winner
#vainqueur=winner
#pb_match_suiv1=this match previously had a different winner
#pb_match_suiv2=who has already fenced the next tableau
#quand_meme_enreg=do you still want to enter this result
#pb_match_suiv3=who has already been place in the tableau of the next phase
#refaire_tab_suiv=you must redo the tableau for the next phase

#refaire=do you want to redo
#modif=do you want to modify

#clas_init_du_tab=initial ranking for the tableau
#tab_fin=the tableau is complete
#clas_du_tab=ranking of the tableau
#clas_des_tab=ranking of all tableaux
#clas_gene=overall ranking
#tir_en_lice=fencers still in competition

#de=from
#a=to
#depuis=from
#jusqua=to

#hasard_par_2=draw at random in groups of 2
#echange_2=^1 permutation[1||s] of 2 fencers out of ^2

#permut_gpe2=permutations of fencers by groups of 2

#chge_formu_tab=the formula of the tableaux has changed
#on_cree=create
#on_conserve=leave unchanged
#attention=warning
#type_formule=types of formula
#formu_classique=classic formula
#formu_fie_seniors=formula for World Cup - Seniors
#formu_fie_juniors=formula for World Cup - Juniors
#autre_formule=other formula
#choix_npoules=select the number of rounds of poules
#choix_ntab=select the number of phases of tableaux

#tous_tir_avec_series=all fencers with seeding

#en_lice_avec_rangs=fencers still in competition with ranking
#clas_gene_avec_rangs=results: final ranking

#pistesheures=pistes/times
#saisir_pistes=enter pistes
#saisir_heures=enter times
#feuilles_ma_attente=match sheets waiting
#feuilles_ma=match sheets
#tableauetpistes=tableaux and pistes
#const_tab=create a tableau
#refaire_tab=redo a tableau
#bad_taille_tab=the size of tableau is no good

pour des pourcentages, par exemple : 20% fait 34
#fait=^1% gives ^2
#on_peut_faire=one can do
#divers=miscellaneous
#ordre_special=special match order
#couleur=colour

#information=information
#confirmation=confirmation
#question=question
#choix=choice
#nouveautes=new features

#est_absent=^1 is absent
#nouveau_tir=^1 new fencer [1||s]

#supp_tour=remove from this round
#prend_pas=include within this round

#est_ce_ok=confirm ok

#des_absents=these fencers are absent
#bon_nb_exemptes=define the number of exempt fencers

#je_modifie=I change
#il_y_a_tir_dans_tab=^1 fencer [1||s] in the tableau
#nb_qualifies=number of qualifiers

#status=status
#normal=normal

#par_abandon=by abandonment
#par_exclusion=by exclusion
#par_forfait=by penalty

exemple: Dupont a pour status exclusion
#a_pour_status=^1 has the status of ^2

#faire_formu_tableau=define the formula for the tableaux
#mettre_qual_suite=create the qualifiers at the end of tableau number ^1
#ou_supp_suite=or ou suppress the production of tableau number ^1

#modif_incoherences=I correct the inconsistencies
#nb_tir_approx=approximate number of fencers
#plus_deux_tours_tab=it is extremely rare to have more than two phases of 
tableaux

#creation_annulee=creation cancelled
#repechage=repechage
#poule_incomplete=incomplete poule
#deux_fois_clas=^1 is in the ranking twice
#met_tir_abs=mark these fencers absent

#deja1=This competition is already open
#deja2=Would you like to open it "read only"
#deja3=to enable viewing of documents and printing
#deja4=and also to enable the creation of transfer files
#deja5=but not to update or modify the data of the competition

#supp_svg=suppression of backup files
#der_svg=the last backup is
#pas_svg=backups files suppresssed
#reprendre_sauve=enable backup files
#ouvrir_SVG=open a backup
#pas_sauve=this is not a backup
#pas_nom_rep_deja=do not choose a file that already exists

#options=options
#avec_affil=with affiliation prompt
#sans_affil=without affiliation prompt

#non_qual=^1 non qualifier[1||s]

#continuer_formu=to continue you must choose a formula
#reprend_svg=restore the backup
#non_exemp=Error: ^1 exempt fencer [1||s] are not marked exempt in the file
#non_places=Error: there [1|is|are] ^1  fencer [1||s] not placed

#cherche_fic=search for file ^1
#fic_existe_pas=file ^1 does not exist
#fic_pas_charge=file ^1 not loaded
#fic_non_trouve=file not found : ^1

#version_autre=this competition was created with a different version of 
Engarde
#danger_modif=it is DANGEROUS to run a competition with this file
#pas_pb_docu=there is no danger in printing documents from this file
#version_compe=conmpetition version
#version_eng=Engarde version

#est_deja_table=^1 is already in the table
#que_fait_on_de=what to do
#on_prend_pas=reject
#on_ajoute_pas=do not add
#on_le_prend=accept

#tirage_auto=automatic randomisation
#tirage_manuel=manual randomisation
#on_echange=swap
#interligne=line spacing
#coef_interligne=enter the line spacing in percentage, normal = 100

#fic_pas_cree=the file ^1 has not been created

#base_dossard=allocate as mask number the creation number offset by
#mettre_dos=allocate mask numbers
#ne_pas_mettre_dos=do not allocate mask numbers
#efface_dos=erase mask numbers

#copie_permente=would you like to keep a permanent up to date copy
#fic_existe=the file ^1 already exists
#lecture_seule=read only
#enreg_copie=save the copy of the competition

#est_copie1=this competition is a copy
#est_copie2=open the file "read only", the file remains a copy
#est_copie3=open the file "read/write", the file loses the status of being a 
copy
#mode_aux=open the file "read only"
#mode_ppal=open the file "read/write"

#avec_copie=work with a copy in ^1
#plus_copie=the copy in ^1 is not readable

#entree_progressive=progressive entry
#ajustement_tour=modifcation of round No ^1
#entree_nouv_tir=entry of new fencers

#elidir=direct elimination
#type_elidir=form of direct elimination
#classique=classic
#avec_exemptes=with exemptions
#complexe=complex
#pasTableau=no tableau

#pas_change_type_elidir=you cannot modify the form of direct elimination now

#type_3e_place=type of 3rd place
#a_indice=on indicators
#ex_aequo=equal
#par_match=by match

#formu_avec_ex=formula with exemptions
#formule_avec_prog=formula with progresssive entry
#ni_ex_ni_prog=no exemptions, no progressive entry

#avec=with ^1
#sans=without ^1
#choisir=select : ^1
#special=special
#raz=erase
#raz_formule=erase the formula
#champ_non_modifiable=this field cannot be modified

#assistant=assistant
#assistant_de=assistant of ^1
#choix_general=general option[|s]

  A VOIR SI ENTITE AU LIEU DE TIREUR
#tir_pas_pris=^1 fencer[1||s] not entered
#eq_pas_pris=^1 team[1||s] not entered
#nouvelle_eq=^1 new team[1||s]

#si_fermer=if you close now
#on_ferme=close
#nb_approx=approximate number of ^1
#ent_dans_poules=^1 in poules
#ent_par_poule=^1 per poule
#ent_dans_tableau=^1 in the tableau
#a_la_fin=^1 at the end

#equi_en_lice=teams still in competition
#concerne_eq=about the teams
#concerne_eq_pres=about the teams present
#attrib_equipe=allocate a team to someone who does not have one
#on_prend=take the ^1
#entite=entit[y|ies]

#nom_une_lettre=name and one letter

#origine1=origin 1
#origine2=origin 2
#origine3=origin 3
#origine4=origin 4
#origine5=origin 5
#origine6=origin 6

#progression_naturelle=natural progression
#classement_initial_par_groupes=initial ranking by groups
#classement_initial=initial ranking
#critere_constitution=criteria for constitution

#tour_de_poules=round[|s] of poules
#nom_tableaux=name of the tableaux
#suite_tableaux=phase[|s] of tableaux
#description_tableau=description[|s] of tableau[|x]

#description_modele=description of template
#enregister_modele=save as template
#charger_modele=load a template
#chargerFormule=load a formula
#sur_changer_formu=are you certain you want to change the formula

#classique_sans3=classic without match for 3rd place
#classique_avec3=classic with match for 3rd place

#tab_dir_sans3=direct elimination without match for 3rd place
#tab_dir_avec3=direct elimination with match for 3rd place

#tableau_direct=direct elimination
#tableau_prelim_32ex=preliminary tableau with 32 exemptions
#tableau_prince64=main tableau of 64
#tableau_place_n=tableau for ^1e place
#match_troisieme_place=match for third place
#troisieme_place=third place
#neme_place=^1e place
#quart_finales=quarter-finals

#prelim_et_ppal=Preliminary tableau with 32 exemptions and a main tableau

#non_supprimable=this entity may not be erased

#err_formu_tab=error in the formula of the tableaux
#nom_tab_err=name of phase of tableau incorrect
#nom_tab_dupli=duplicate name for phase of tableau
#pas_org=no origin
#org_err=type of origin incorrect in
#val_err=value incorrect in
#doit_etre=must be
#doit_etre_forme=must be in the form
#lettre_etant_suite=the letter being the name of the phase of tableau
#suite_inconnue=phase of tableau unknown
#tab_incorrect_inconnu=tableau unknown or incorrect
#circu_tab=looping in the phases of tableaux
#suites_ok=the correct phases are

#err_qualifes=number of incorrect qualifiers
#zero_puis2=must be 0, 1, 2, 4, 8, 16, 32 ...

#pas_tir_tab=the fencers of the original ranking are not in the tableaux
#tir_tab2fois=the fencers of the original ranking are not in the tableaux 
twice

#dest_vain_dupli=the winners of ^1 are in two phases of tableau
#dest_bat_dupli=the losers of ^1 are in two phases of tableau

#classe_apres=ranked after
#destination_vainqueurs=destination of the winners
#destination_battus=destination of the losers
#groupe_clasmt_battus=ranking group of the losers
#rang_premier_battu=ranking of 1st loser
#groupe_clasmt_vainqueur=ranking group of winner
#rang_premier_vainqueur=ranking of winner

#classe_apres%=rank after
#destination_vainqueurs%=dest winner
#destination_battus%=dest loser
#groupe_clasmt_battus%=rank gp loser
#rang_premier_battu%=rank 1st loser
#groupe_clasmt_vainqueur%=rank gp loser
#rang_premier_vainqueur%=rank 1st winner

#calcul_tableaux=calculate the tableaux
#calcul_groupes_clas=recalculate the groupes for the final ranking

#avertissement=warning
#modif_suites=modify the phases of tableaux
#modif_suites_expli1=when you modify the phases of tableaux
#modif_suites_expli2=the tableaux are completely recalculated
#modif_destination=modification of the destinations of tableaux
#modif_destination_expli1=when you modify the destinations of tableaux
#modif_destination_expli2=the ranking groups are recalculated
#modif_gpe_clas=modification of ranking groups
#modif_gpe_clas_expli1=when you modify the ranking groups
#modif_gpe_clas_expli2=the first ranking of the groups is recalculated

#creation_de=creation of ^1
#creation_1er_tab=creation of first tableau
#suppr_du_tableau=removal of tableau ^1, renamed ".old"
#pas_tab_en_cours=there is no tableau in progress
#pas_tab_a_faire=there is no tableau to create

#barrage_tableau=barrage at ranking ^1 for entry into a tableau
#garde_rang=^1 fencer[1||s] or team[1||s] keep this rank
#se_classe_apres=are ranked after
#formule_prevue=the formula is planned for ^1
#tableau_prevu=this tableau is planned for ^1

#pas_tab_refaisable=there is no tableau to redo
#tab_a_refaire=tableau to redo

#gpe_clas_diff=two ranking groups ^1 have different 1st rankings, ^2 and ^3

#pas_match_en_cours=there is no match in progress
#cherche_match=search for a match
#les_matches_de=view the matches of ^1
#en_cours_contre=match in progress against ^1
#gagne_contre=match won against ^1
#perdu_contre=match lost against ^1
#match_perdu=match lost
#rec_adversaire=search for an opponent
#pas_adversaire=no opponent
#score_trop_grand=score too high

#erreur_ecrire=error in writing file
#ressayer=retry

#rangPoule=ranking in the poule
#rangPoule%=rk poule

#tableau_inacheve=formula with incomplete tableau
#nombre_exemptes_tab=number of exemptions in the tableau
#nb_qualifies_tab=number of qualifiers at the end of the tableau

#on_limite_dec=limit the separation to ranking ^1
#pour_les_tir=For the fencers from ranking 1 to ^1
#on_dec_pas_plus=no separation further than ^1
#on_dec_plus=separation eventually further than ^1

#premier_est=the first ^1 of the list is ^2
#premier_doit_etre=^1 to place first in the file

#faire_sauvegarde=backup
#creation_sauvegarde=create a backup
#echec_sauvegarde=backup failed

#importer_un=import one
#importer_certains=import range

#documentation=documentation

#plusieurs_pou_arbi=give several poules to a referee

#criteres_arbitres=criteria for allocating the referees
#affectation_manu=manual allocation
#affectation_auto=allocation automatic
#affectation_arbi=allocation of referees
#affectation_arbi_quarts=allocation of referees by quarter of tableau
#reprise_arbitres=redo the referees for the quarters of:
#raz_arbitres=erase the allocation of referees
#tableauetarbitres=tableaux and referees

#pas_arbitre=no referee
#plus_arbitre=no more referees
#toutes_pou_arbi=all poules have a referee

#pas_arbi_ds_match=there is no referee for a match in progress
#pas_match_sans_arbi=there is no match in progress without a referee

#exempte1=exemption[|s]
#qualifie1=qualifier[|s]
#abandon1=abandonment
#elimine1=eliminated
#exclusion1=exclusion
#forfait1=scratch
#exempte1%=exemption[|s]
#qualifie1%=qualifier[|s]
#abandon1%=abandonment
#elimine1%=eliminated
#exclusion1%=exclusion
#forfait1%=scratch

#faire_svg=make a backup of the competition
#faire_copie=copy with permanent updates
#echec_copie=the copy has failed
#rempla_copie=overwrite the copy ^1
#capitaine=captain[|s]
#prem_dossard=start the mask numbers at

#ordre_interne=ordered by internal number

#champ_mesure=the field ^1 measure ^2 cm
#limite_champ=is limited to ^1 cm

#equipe_a=the team ^1 has ^2 fencers
#equipe_devrait=it should have 3 or 4 fencers
#permuter=permutation
#erreur_equipe=Error, team :
#rang_haut_bas=Use numbers 1, 2, 3 on the top, 4, 5, 6 on the bottom
#rangs_manquants=Numbers are missing
#rang_duplique=duplicate number
#rang_incorrect=incorrect number
#score=the score
#touche=hit[|s]

#demi_grille=half-grid

#remplacant=substitute
#rempla_equipe=substitution in team ^1
#num_match_remplacement=number of the match where the substitution occurs
#zero_pas_remplacement=give 0 for no substitution

#Feuille_rencontre=bout sheets
#rencontres=bouts
#rencontre_a_score=^1 bout[1||s] have detailed scores
#rencontres_tableau=bouts of tableau ^1
#scores_detailles=detailed scores

#HTML=HTML
#faire_document=make a document
#faire_fichier=make a file
#plusieurs_tableaux=several tableaux

#Tableau_en_fichier_HTML=tableau in an HTML file
#Poules_en_fichier_HTML=poules in an HTML file

#produit_deja_tire=the constitution of the tableau produces ^1 match[1||es] 
already fenced
#decale_deja_tire=avoid already fenced matches?
#pas_decale=cannot separate ^1

#date_limite_essai=This evaluation version is out of date
#plus_equipe=This version no more manages teams
#plus_html=This version no more produces HTML files

#dans_ordre=order of the numbers
#pret_decouper=ready to cut, ^1 per page

#exporter_table=export to a text file
#importer_table=import from a text file
#essai_texte=trying the text format
#pas_ligne1=delete the first line
#ignore=ignored

#calcul_serie=Calculate the teams numbers
#calcul_points=Calculate the teams points
#calcul_serie_de_tireurs=Recalculate the teams numbers with the fencers 
numbers
#calcul_points_de_tireurs=Recalculate the teams points with the fencers 
points
#faire_avec_table_eq=Please do that in the team table
#tireur_sans=fencer without ^1
#fiche_equipe=Team form
#attribution_eq=allocate teams

#resultats_provisoires=temporary results
#charger_pistes_heures=load pistes and time
#pas_tableau_actif=^1 is not an active tableau

#paiement=payment
#mode=mode

#equipes_select=the selected teams
#toutes_equipes=all the teams
#ordre_matches=match order
#equipe_adverse=opponent team

#essai_groupement=Try to group referees on two successive matches?
#echec_groupement=The grouping of ^1 failed
#autre_tableau=Another tableau?
#pas_creation_poules=The poules are not created

******************************************************************************
     $$$ the new texts of January 1rt, 2004 (version 8.1)
******************************************************************************

#id=identification
#annee=year
#checkin=check in close
#regional=regional
#local=local
#championnat=championship
#fic_trans_XML=XML transfer file
#a_partir_fic_xml=from an XML transfer file
#fic_xml_pour_comp=XML to create competition
 Below, do not translate DOCTYPE
#doctype_incorrect=incorrect DOCTYPE
#doctype_correct_sont=correct types are:
#entitesGen_chargees=^1 entit[1|y|ies] loaded in memory
#saisir_pistes_heures_tableau=enter pistes and times of a tableau
#saisir_pistes_heures_toutes_poules=enter pistes and times of the poules
#Feuille_rencontre_non_faite=the bout sheet has not been done

#SansLicence=^1 has no FIE licence number
#tireursSansLicence=Some fencers do not have an FIE licence number 
#DansCompeFIE=In FIE competitions, FIE licence numbers are obligatory
#CompleterLiceFIE=Complete the FIE licences now
#ContinuerCompe=Continue the competition

******************************************************************************
     $$$ the new texts of March 27, 2004 (version 8.1)
******************************************************************************

#PasDeTireur=No Fencers
#NbMatchPP=number of matches per page
#TouteLesPoule=All the poules of
#ont=are
#arbitresPour=referees for
#FaireAffectation=make the allocation ?
#MauvaiseAffecteArbi=Bad allocation of referees, match numbers : 
#ReprendArbi=RESELECT THE REFEREES FOR 1/
#affectation_arbi_8eme=allocation of referees by 1/8 of tableau
#affectation_arbi_16eme=allocation of referees by 1/16 of tableau
#matchesSansArbitre=matches without a referee, try again
#pasDeFichier=no file

#Restreindre1=Restrict a competition consists of saving only certain fencers/teams
#Restreindre2=by giving the status "Scratch" to the others. For example, after a round of poules,
#Restreindre3=if you want to make a division 1 with the fencers ranked from 1 to 64 and a
#Restreindre4=division 2 with the fencers ranked from 65 to the end, you start be making
#Restreindre5=2 copies of the competition (by making two backups) then you restrict one of the
#Restreindre6=backups to fencers from 1 to 64 adn the other to fencers from 64 to the end.
#Restreindre7=Do this immediately before the constitution of a round of poules or
#Restreindre8=creation of the first tableau.
#Restreindre9=Restrict this competition now ?

#PlusTirEnCompe=There are no more fencers in the competition
#Ilya=There [1|is|are]
#tirEqEnCompe=fencers/teams in the competition
#gardeApartirRang=start ranking
#jusquAuRang=end ranking

#suppressTousAbsents=Suppress absentees

