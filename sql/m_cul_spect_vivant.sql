/****************************************************************************************
** Script SQL pour les données métiers "Culture" et sur la thématique du spectacle vivant.
****************************************************************************************/

------------------------------------------------------------------------
-- SPECTALE VIVANT V1.0
-- Creation de la structure des données
-- PotsgreSQL/PostGIS
--
-- Propriétaire : Région Nouvelle-Aquitaine - http://nouvelle-aquitaine.fr/ 
-- Auteur : Tony VINCENT
------------------------------------------------------------------------


------------------------------------------------------------------------
-- Schéma : Création du schéma
------------------------------------------------------------------------
/*
-- DROP SCHEMA IF EXIST met_cul;
CREATE SCHEMA met_cul
  AUTHORIZATION "pre-sig-usr";
 
COMMENT ON SCHEMA met_cul IS 'Schéma pour les données métiers sur la culture';

GRANT ALL ON SCHEMA met_cul TO "pre-sig-usr";
GRANT ALL ON SCHEMA met_cul TO "pre-sig-ro";
*/

------------------------------------------------------------------------
-- met_cul.m_cul_spect_vivant_struct_p
------------------------------------------------------------------------

--DROP TABLE IF EXISTS met_cul.m_cul_spect_vivant_struct_p;
CREATE TABLE met_cul.m_cul_spect_vivant_struct_p
(
    id serial,
    geom geometry(MultiPoint,2154),
    code character varying(15),
    siret character varying(15) NOT NULL,
    nom character varying,
    nom_cplt character varying,
    code_insee character varying(5),
    commune character varying(150),
    adresse character varying,
    adr_cplt character varying,
    adr_cedex character varying,
    cp character varying(5),
    web character varying,
    annee character varying(4) NOT NULL,
    direction character varying(100),
    budget_glo numeric(9,2),
    mont_aide numeric(9,2),
    rayon_aide character varying (20),
    loc_val boolean DEFAULT FALSE NOT NULL,
    data_val boolean DEFAULT FALSE NOT NULL, 
    date_sai timestamp without time zone NOT NULL DEFAULT now(),
    date_maj timestamp without time zone,
    loc_pert character varying,
    loc_type character varying,
    CONSTRAINT m_cul_spect_vivant_struct_p_pkey PRIMARY KEY (id),
    CONSTRAINT m_cul_spect_vivant_struct_p_uniq UNIQUE (siret,annee)
);

-- Droits sur la table
GRANT ALL ON TABLE met_cul.m_cul_spect_vivant_struct_p TO "pre-sig-usr";
GRANT ALL ON TABLE met_cul.m_cul_spect_vivant_struct_p TO "pre-sig-ro";

-- Description de la table
COMMENT ON TABLE met_cul.m_cul_spect_vivant_struct_p
  IS 'Contient les structures de Nouvelle-Aquitaine intervenant dans le spectacle vivant (Point)';

-- Description des colonnes
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.id IS 'Identifiant numérique automatique ';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.geom IS 'Attribut contenant la géométrie';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.code IS 'Code Région de la sructure';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.siret IS 'Numéro de SIRET de la structure';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.nom IS 'Nom de la structure';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.nom_cplt IS 'Nom complémentaire de la structure ';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.code_insee IS 'Code insee de la commune';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.commune IS 'Libellé de la commune';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.adresse IS 'Adresse de la structure';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.adr_cplt IS 'Adresse complémentaire de la structure';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.adr_cedex IS 'Cedex de la sructure';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.cp IS 'Code postal de la structure';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.web IS 'Adresse du site web de la structure';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.annee IS 'Année référence de la donnée';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.direction IS 'Définit comment est composé la direction (Homme, Femme, Paritaire, Collectif H, Collectif Femme)';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.budget_glo IS 'Budget global de la structure';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.mont_aide IS 'Le montant de l''aide versé par la Région';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.rayon_aide IS 'Le rayonnement de l''aide versé par la Région';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.loc_val IS 'La localisation du point est validé (Oui/Non), Non est la valeur par défaut';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.data_val IS 'Les données renseignées sont validées (Oui/Non), Non est la valeur par défaut';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.date_sai IS 'Correspond à la date de saisie de la donnée, valeur non null et par défaut : now()';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.date_maj IS 'Correspond à la date de mise à jour de la donnée, à gérer par un trigger before pour update';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.loc_pert IS 'Pertinence de la localisation faite via QBano (plus il se rapproche de 1, plus c''est juste)';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.loc_type IS 'Type de localisation (Au numéro, à la rue, à la commune, ...';

-- Import de données pour TEST
--DELETE FROM met_cul.m_cul_spect_vivant_struct_p;
INSERT INTO met_cul.m_cul_spect_vivant_struct_p(
	geom, code, siret, nom, nom_cplt, code_insee, commune,
	adresse, adr_cplt, adr_cedex, cp, web,annee,
	direction, budget_glo, mont_aide, rayon_aide, loc_pert, loc_type )
SELECT t1.geom, null, REPLACE(REPLACE(t1.siret,' ',''),'.',''), t1."nom du bé", t1."nom usuel", t1."cp insee", t2.nom_com, 
	t1.adresse, t1."adresse co", t1.cedex, t1."code posta",null, '2019',direction, CAST("budget glo" AS money), CAST(montant_ai AS money), rayonnemen, 
	t1.score, t1.type
FROM (SELECT * FROM z_maj.spectacle_vivant_geoloc_struct2 WHERE siret IS NOT NULL AND siret != 'non renseigné') t1
INNER JOIN ref_adminexpress.r_admexp_commune_fr t2
ON t1."cp insee" = t2.insee_com  ORDER BY t1.siret;


------------------------------------------------------------------------
-- met_cul.m_cul_spect_vivant_detail
------------------------------------------------------------------------

--DROP TABLE IF EXISTS met_cul.m_cul_spect_vivant_detail;
CREATE TABLE met_cul.m_cul_spect_vivant_detail
(
    id serial,
    siret character varying(15) NOT NULL,
    annee character varying(4) NOT NULL,
    classe character varying(100) NOT NULL,
    cat character varying(150),
    cat_sc1 character varying(150), 
    cat_sc2 character varying(150), 
    esthetique character varying(150),
    data_val boolean DEFAULT FALSE NOT NULL, 
    date_sai timestamp without time zone NOT NULL DEFAULT now(),
    date_maj timestamp without time zone,
    CONSTRAINT m_cul_spect_vivant_detail_pkey PRIMARY KEY (id),
    FOREIGN KEY (siret,annee) REFERENCES met_cul.m_cul_spect_vivant_struct_p (siret,annee),
    CONSTRAINT m_cul_spect_vivant_detail_uniq UNIQUE (siret,annee,classe)
);

-- Droits sur la table
GRANT ALL ON TABLE met_cul.m_cul_spect_vivant_detail TO "pre-sig-usr";
GRANT ALL ON TABLE met_cul.m_cul_spect_vivant_detail TO "pre-sig-ro";

-- Description de la table
COMMENT ON TABLE met_cul.m_cul_spect_vivant_detail
  IS 'Contient le détail des structures du spectacle vivant (Classification, Sous-catégorie, Esthétique, ...)';

-- Description des colonnes
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_detail.id IS 'Identifiant numérique automatique ';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_detail.siret IS 'Numéro de SIRET de la structure';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_detail.annee IS 'Année référence de la donnée';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_detail.classe IS 'Classification de la structure (Création/Diffusion/Production';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_detail.cat IS 'Catégorie de la structure';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_detail.cat_sc1 IS 'Sous catégorie 1 de la structure';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_detail.cat_sc2 IS 'Sous catégorie 2 de la strucutre';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_detail.esthetique IS 'Esthétique de la strucutre';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_detail.data_val IS 'Les données renseignées sont validées (Oui/Non), Non est la valeur par défaut';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_detail.date_sai IS 'Correspond à la date de saisie de la donnée, valeur non null et par défaut : now()';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_detail.date_maj IS 'Correspond à la date de mise à jour de la donnée, à gérer par un trigger before pour update';


-- Détails "Création"
INSERT INTO met_cul.m_cul_spect_vivant_detail(
	siret, annee, classe, cat, cat_sc1, cat_sc2, esthetique)
SELECT REPLACE(REPLACE(siret,' ',''),'.',''), '2019', 'création', categorie, "sous categorie 1", "sous categorie 2", esthetique
	FROM z_maj.spectacle_vivant_detail_creation2 WHERE siret IS NOT NULL AND siret != 'non renseigné'; 
	
-- Détails "Diffusion"
INSERT INTO met_cul.m_cul_spect_vivant_detail(
	siret, annee, classe, cat, cat_sc1, cat_sc2, esthetique)
SELECT REPLACE(REPLACE(siret,' ',''),'.',''), '2019', 'diffusion', categorie, "sous categorie 1", "sous categorie 2", esthetique
	FROM z_maj.spectacle_vivant_detail_diffusion2 WHERE siret IS NOT NULL AND siret != 'non renseigné'; 

-- Détails "Production"
INSERT INTO met_cul.m_cul_spect_vivant_detail(
	siret, annee, classe, cat, cat_sc1, cat_sc2, esthetique)
SELECT REPLACE(REPLACE(siret,' ',''),'.',''), '2019', 'production', categorie, "sous categorie 1", "sous categorie 2", esthetique
	FROM z_maj.spectacle_vivant_detail_production2 WHERE siret IS NOT NULL AND siret != 'non renseigné'; 

