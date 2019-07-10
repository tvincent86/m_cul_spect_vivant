# m_cul_spect_vivant
Script SQL pour les données métiers "Culture" et sur la thématique du spectacle vivant.

------------------------------------------------------------------------
-- SPECTALE VIVANT V1.0
-- Creation de la structure des données
-- PostgreSQL/PostGIS
--
-- Propriétaire : Région Nouvelle-Aquitaine - http://nouvelle-aquitaine.fr/ 
-- Auteur : Tony VINCENT
------------------------------------------------------------------------


------------------------------------------------------------------------
-- Schéma : Création du schéma
------------------------------------------------------------------------
/*
-- DROP SCHEMA met_cul;
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
    commune character varying,
    adresse character varying,
    adresse_cplt character varying,
    adresse_cedex character varying,
    cp character varying,
    ville_cp character varying,
    web character varying,
    annee character varying(4) NOT NULL,
    direction character varying(100),
    budget_global numeric(9,2),
    montant_aide numeric(9,2),
    rayonnement_aide character varying (10),
    localisation_valide boolean DEFAULT FALSE NOT NULL,
    donnees_valide boolean DEFAULT FALSE NOT NULL, 
    date_sai timestamp without time zone NOT NULL DEFAULT now(),
    date_maj timestamp without time zone,
    localisation_pertinence character varying,
    localisation_type character varying,
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
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.geom IS 'Attribut contenant la géométrie';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.code_insee IS 'Code insee de la commune';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.commune IS 'Libellé de la commune';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.adresse IS '';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.adresse_cplt IS '';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.adresse_cedex IS '';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.cp IS '';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.ville_cp IS '';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p. IS '';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p. IS '';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p. IS '';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.date_sai IS 'Correspond à la date de saisie de la donnée, , valeur non null et par défaut : now()';
COMMENT ON COLUMN met_cul.m_cul_spect_vivant_struct_p.date_maj IS 'Correspond à la date de mise à jour de la donnée, à gérer par un trigger before pour update';

-- Import de données pour TEST
--DELETE FROM met_cul.m_cul_spect_vivant_struct_p;
INSERT INTO met_cul.m_cul_spect_vivant_struct_p(
	geom, code, siret, nom, nom_cplt, code_insee, commune,
	adresse, adresse_cplt, adresse_cedex, cp,ville_cp, web,annee,
	direction, budget_global, montant_aide, rayonnement_aide, date_import, localisation_pertinence, localisation_type )
SELECT t1.geom, null, REPLACE(REPLACE(t1.siret,' ',''),'.',''), t1."nom du bé", t1."nom usuel", t1."cp insee", t2.nom_com, 
	t1.adresse, t1."adresse co", t1.cedex, t1."code posta", t1.commune,null, '2019',direction, CAST("budget glo" AS money), CAST(montant_ai AS money), rayonnemen, 
	'09/07/2019', t1.score, t1.type
FROM (SELECT * FROM z_maj.spectacle_vivant_geoloc_struct2 WHERE siret IS NOT NULL AND siret != 'non renseigné') t1
INNER JOIN ref_adminexpress.r_admexp_commune_fr t2
ON t1."cp insee" = t2.insee_com  ORDER BY t1.siret;
