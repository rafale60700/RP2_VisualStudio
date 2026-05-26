-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:3306
-- Généré le : mar. 26 mai 2026 à 23:12
-- Version du serveur : 5.7.24
-- Version de PHP : 8.3.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `gsb_frais2`
--

-- --------------------------------------------------------

--
-- Structure de la table `comptable`
--

CREATE TABLE `comptable` (
  `id` char(4) NOT NULL,
  `nbFichesRefusees` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `comptable`
--

INSERT INTO `comptable` (`id`, `nbFichesRefusees`) VALUES
('a800', 0),
('b13', 0),
('c54', 0),
('d23', 0),
('e52', 0);

-- --------------------------------------------------------

--
-- Structure de la table `etat`
--

CREATE TABLE `etat` (
  `id` char(2) NOT NULL,
  `libelle` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `etat`
--

INSERT INTO `etat` (`id`, `libelle`) VALUES
('CL', 'Saisie clôturée'),
('CR', 'Fiche créée - saisie en cours'),
('RB', 'Remboursée'),
('VA', 'Validée et mise en paiement');

-- --------------------------------------------------------

--
-- Structure de la table `fichefrais`
--

CREATE TABLE `fichefrais` (
  `idutilisateur` char(4) NOT NULL,
  `mois` char(6) NOT NULL,
  `nbJustificatifs` int(11) DEFAULT NULL,
  `montantValide` decimal(10,2) DEFAULT NULL,
  `dateModif` date DEFAULT NULL,
  `idEtat` char(2) DEFAULT 'CR',
  `idComptable` char(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `fichefrais`
--

INSERT INTO `fichefrais` (`idutilisateur`, `mois`, `nbJustificatifs`, `montantValide`, `dateModif`, `idEtat`, `idComptable`) VALUES
('a131', '202508', 0, '0.00', '2025-09-04', 'CL', NULL),
('a131', '202509', 0, '0.00', '2025-09-04', 'CR', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `fraisforfait`
--

CREATE TABLE `fraisforfait` (
  `id` char(3) NOT NULL,
  `libelle` char(20) DEFAULT NULL,
  `montant` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `fraisforfait`
--

INSERT INTO `fraisforfait` (`id`, `libelle`, `montant`) VALUES
('ETP', 'Forfait Etape', '110.00'),
('KM', 'Frais Kilometrique', '0.62'),
('NUI', 'Nuitee Hotel', '80.00'),
('REP', 'Repas Restaurant', '25.00');

-- --------------------------------------------------------

--
-- Structure de la table `lignefraisforfait`
--

CREATE TABLE `lignefraisforfait` (
  `idutilisateur` char(4) NOT NULL,
  `mois` char(6) NOT NULL,
  `idFraisForfait` char(3) NOT NULL,
  `quantite` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `lignefraisforfait`
--

INSERT INTO `lignefraisforfait` (`idutilisateur`, `mois`, `idFraisForfait`, `quantite`) VALUES
('a131', '202508', 'ETP', 0),
('a131', '202508', 'KM', 0),
('a131', '202508', 'NUI', 0),
('a131', '202508', 'REP', 0),
('a131', '202509', 'ETP', 0),
('a131', '202509', 'KM', 0),
('a131', '202509', 'NUI', 0),
('a131', '202509', 'REP', 0);

-- --------------------------------------------------------

--
-- Structure de la table `lignefraishorsforfait`
--

CREATE TABLE `lignefraishorsforfait` (
  `id` int(11) NOT NULL,
  `idutilisateur` char(4) DEFAULT NULL,
  `mois` char(6) DEFAULT NULL,
  `libelle` varchar(100) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `montant` decimal(10,2) DEFAULT NULL,
  `idComptableRefus` char(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déclencheurs `lignefraishorsforfait`
--
DELIMITER $$
CREATE TRIGGER `after_delete_lfhf` AFTER DELETE ON `lignefraishorsforfait` FOR EACH ROW BEGIN
    IF OLD.idComptableRefus IS NOT NULL THEN
        UPDATE comptable
        SET nbFichesRefusees = (
            SELECT COUNT(*) FROM lignefraishorsforfait
            WHERE idComptableRefus = OLD.idComptableRefus
        )
        WHERE id = OLD.idComptableRefus;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_lfhf` AFTER INSERT ON `lignefraishorsforfait` FOR EACH ROW BEGIN
    IF NEW.idComptableRefus IS NOT NULL THEN
        UPDATE comptable
        SET nbFichesRefusees = (
            SELECT COUNT(*) FROM lignefraishorsforfait
            WHERE idComptableRefus = NEW.idComptableRefus
        )
        WHERE id = NEW.idComptableRefus;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_update_lfhf` AFTER UPDATE ON `lignefraishorsforfait` FOR EACH ROW BEGIN
    IF OLD.idComptableRefus IS NOT NULL THEN
        UPDATE comptable
        SET nbFichesRefusees = (
            SELECT COUNT(*) FROM lignefraishorsforfait
            WHERE idComptableRefus = OLD.idComptableRefus
        )
        WHERE id = OLD.idComptableRefus;
    END IF;
    IF NEW.idComptableRefus IS NOT NULL THEN
        UPDATE comptable
        SET nbFichesRefusees = (
            SELECT COUNT(*) FROM lignefraishorsforfait
            WHERE idComptableRefus = NEW.idComptableRefus
        )
        WHERE id = NEW.idComptableRefus;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `utilisateur`
--

CREATE TABLE `utilisateur` (
  `id` char(4) NOT NULL,
  `nom` char(30) DEFAULT NULL,
  `prenom` char(30) DEFAULT NULL,
  `login` char(20) DEFAULT NULL,
  `mdp` varchar(255) DEFAULT NULL,
  `adresseRue` char(40) DEFAULT NULL,
  `codePostal` char(5) DEFAULT NULL,
  `ville` char(30) DEFAULT NULL,
  `dateEmbauche` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `utilisateur`
--

INSERT INTO `utilisateur` (`id`, `nom`, `prenom`, `login`, `mdp`, `adresseRue`, `codePostal`, `ville`, `dateEmbauche`) VALUES
('a131', 'Villechalane', 'Louis', 'lvillachane', 'ca3983640f22d6a38a0708731ac697146026828b88594f9522ae5517960bd56d', '8 rue des Charmes', '46000', 'Cahors', '2005-12-21'),
('a17', 'Andre', 'David', 'dandre', '165a63d5371a0ccb21b23e8881d59116bfd8377d9cad418de1215da4af09e39d', '1 rue Petit', '46200', 'Lalbenque', '1998-11-23'),
('a200', 'Dupont', 'Jean', 'jdupont', '0329cc7a8f0c75d022436a7727427279066225c4ae528579c512bbd217fed930', '10 rue de Paris', '75000', 'Paris', '2024-01-01'),
('a55', 'Bedos', 'Christian', 'cbedos', '7461ef03c6debab576933c6e42e71bfdd9f070da3abbb5d8758fa1fc3fe65fc0', '1 rue Peranud', '46250', 'Montcuq', '1995-01-12'),
('a800', 'Guichard', 'Rafael', 'guichardr', '0329cc7a8f0c75d022436a7727427279066225c4ae528579c512bbd217fed930', '78 rue de rue', '78000', 'Rue', '2026-04-09'),
('a93', 'Tusseau', 'Louis', 'ltusseau', '227daca101749f45a829988faf79144d87d1d2e7a90ce07896ec56e697b7a449', '22 rue des Ternes', '46123', 'Gramat', '2000-05-01'),
('b13', 'Bentot', 'Pascal', 'pbentot', 'e0020387b3eaa7414296fdfa7af5cfe48f6cf514f4350df2ff23b138e5e80e9e', '11 allee des Cerises', '46512', 'Bessines', '1992-07-09'),
('b16', 'Bioret', 'Luc', 'lbioret', '4dcb2c67707621b6bfa81c71db8ea33f6bfe217275bad06241d1f0cdd9171fd3', '1 Avenue gambetta', '46000', 'Cahors', '1998-05-11'),
('b19', 'Bunisset', 'Francis', 'fbunisset', '57b592489c1851ed5db43ab164cb2e3fbf88a3eeeba963518f41798260d0fdaa', '10 rue des Perles', '93100', 'Montreuil', '1987-10-21'),
('b25', 'Bunisset', 'Denise', 'dbunisset', '4de535fc4bb81bf16f8396701c72b84dbcfaa1232823cbc62fbf9d8295840921', '23 rue Manin', '75019', 'Paris', '2010-12-05'),
('b28', 'Cacheux', 'Bernard', 'bcacheux', '9be0be929c729fe93b16b974b6a7f79ce77ecb399135f23ba8c47318bc3f0885', '114 rue Blanche', '75017', 'Paris', '2009-11-12'),
('b34', 'Cadic', 'Eric', 'ecadic', 'ed5c1022a39ba567bf81c922e7bebcefe1ae1bb29f1ee4d68cb571096ab699cd', '123 avenue de la Republique', '75011', 'Paris', '2008-09-23'),
('b4', 'Charoze', 'Catherine', 'ccharoze', '09f61f8d9cd65e6a0c258087c485b6293541364e42bd97b2d7936580c8aa3c54', '100 rue Petit', '75019', 'Paris', '2005-11-12'),
('b50', 'Clepkens', 'Christophe', 'cclepkens', '7e9353475b3d90a2ffbedd346b8fd143ff42d8808b43aa8b804465d98827925c', '12 allee des Anges', '93230', 'Romainville', '2003-08-11'),
('b59', 'Cottin', 'Vincenne', 'vcottin', '264fa0634d763fefc9de03d9412af78b553304a1e59bc7c1faf8fd5b4fd26e48', '36 rue Des Roches', '93100', 'Montreuil', '2001-11-18'),
('b825', 'Labu', 'Marco', 'emlabu', '4d0b15d53c81ed1a8445440857ad08ac82cb225a4758b4c421cc19f27124674c', '321 avenue de la Mer', '30240', 'Grau du Roi', '2018-09-23'),
('c14', 'Daburon', 'Francois', 'fdaburon', '2558ad19d564eeafadc7395065d14f6fc244e21c9510079838d5d5c2aa660385', '13 rue de Chanzy', '94000', 'Creteil', '2002-02-11'),
('c3', 'De', 'Philippe', 'pde', '80a51081489841526217f5958fe37b1231a8385aa6195c4d5f13cda07ef112b1', '13 rue Barthes', '94000', 'Creteil', '2010-12-14'),
('c54', 'Debelle', 'Michel', 'mdebelle', 'e87f267d00031b3853d13ea6c4abd3aa8ba9a7362f151b23b1d8ab7a36237661', '181 avenue Barbusse', '93210', 'Rosny', '2006-11-23'),
('d13', 'Debelle', 'Jeanne', 'jdebelle', '8447a77dcc8a1ab290625d2de92107ad506fe226f21ccc7b94db5576957371e9', '134 allee des Joncs', '44000', 'Nantes', '2000-05-11'),
('d23', 'Defay', 'Nicolas', 'ndefay', '0329cc7a8f0c75d022436a7727427279066225c4ae528579c512bbd217fed930', '51 Bld Gaston Monnerville', '97440', 'Saint-Denis', '2023-08-01'),
('d51', 'Debroise', 'Michel', 'mdebroise', 'd908f177158faee7d45535e52ca19d1182a4cfc2ac2c44cc6d56540a36b43e08', '2 Bld Jourdain', '44000', 'Nantes', '2001-04-17'),
('e22', 'Desmarquest', 'Nathalie', 'ndesmarquest', '045758ae4faff6e3a69776daea65b425c06df1806fb9fee23001b51ce8ad92f7', '14 Place d Arc', '45000', 'Orleans', '2005-11-12'),
('e24', 'Desnost', 'Pierre', 'pdesnost', '9afdf4579e4688162115b09e0a72a810a3a0db98c3142d2a524d2fbb7a1d83a9', '16 avenue des Cedres', '23200', 'Gueret', '2001-02-05'),
('e39', 'Dudouit', 'Frederic', 'fdudouit', '82189fa33089b33bda4fe93c84cc0ef3e9b5746222735ea948f85aa4faa92b8c', '18 rue de l eglise', '23120', 'GrandBourg', '2000-08-01'),
('e49', 'Duncombe', 'Claude', 'cduncombe', '1a96aed84026e53d447df5b3501f468b6b1a104d496183b80010aec0ed6e57e3', '19 rue de la tour', '23100', 'La Souterraine', '1987-10-10'),
('e5', 'Enault-Pascreau', 'Celine', 'cenault', '5044827970b11b704c3f4bd8025c38a334df3a194247e6b03c3a330eab07316c', '25 place de la gare', '23200', 'Gueret', '1995-09-01'),
('e52', 'Eynde', 'Valerie', 'veynde', '9d3744e22dcada1717408fdf079bff21f3f8cb514e3402b19d990df01f33325e', '3 Grand Place', '13015', 'Marseille', '1999-11-01'),
('e63', 'Alphonsine', 'Emmanuel', 'ealphonsine', '0329cc7a8f0c75d022436a7727427279066225c4ae528579c512bbd217fed930', '51 Bld Gaston Monnerville', '97440', 'Saint-Denis', '2023-08-01'),
('f21', 'Finck', 'Jacques', 'jfinck', '577d67f320202216ee7f2fe26b363daada983b0d06521a7c89aeb049eafc97f5', '10 avenue du Prado', '13002', 'Marseille', '2001-11-10'),
('f39', 'Fremont', 'Fernande', 'ffremont', 'b409a4db2e8a88fb10f427ef3ff3452dd3489b75648a7593f6ad74d4572ae06b', '4 route de la mer', '13012', 'Allauh', '1998-10-01'),
('f4', 'Gest', 'Alain', 'agest', 'a8a5b00ccbc425791ae7e9bdca16fc7e108c9d58e6d70b0c66f327b82b083ec9', '30 avenue de la mer', '13025', 'Berre', '1985-11-01');

-- --------------------------------------------------------

--
-- Structure de la table `visiteur`
--

CREATE TABLE `visiteur` (
  `id` char(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `visiteur`
--

INSERT INTO `visiteur` (`id`) VALUES
('a131'),
('a17'),
('a55'),
('a93'),
('b16'),
('b19'),
('b25'),
('b28'),
('b34'),
('b4'),
('b50'),
('b59'),
('b825'),
('c14'),
('c3'),
('d13'),
('d51'),
('e22'),
('e24'),
('e39'),
('e49'),
('e5'),
('e63'),
('f21'),
('f39'),
('f4');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `comptable`
--
ALTER TABLE `comptable`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `etat`
--
ALTER TABLE `etat`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `fichefrais`
--
ALTER TABLE `fichefrais`
  ADD PRIMARY KEY (`idutilisateur`,`mois`),
  ADD KEY `idEtat` (`idEtat`),
  ADD KEY `idComptable` (`idComptable`);

--
-- Index pour la table `fraisforfait`
--
ALTER TABLE `fraisforfait`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `lignefraisforfait`
--
ALTER TABLE `lignefraisforfait`
  ADD PRIMARY KEY (`idutilisateur`,`mois`,`idFraisForfait`),
  ADD KEY `idFraisForfait` (`idFraisForfait`);

--
-- Index pour la table `lignefraishorsforfait`
--
ALTER TABLE `lignefraishorsforfait`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idutilisateur` (`idutilisateur`,`mois`),
  ADD KEY `idComptableRefus` (`idComptableRefus`);

--
-- Index pour la table `utilisateur`
--
ALTER TABLE `utilisateur`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `login` (`login`);

--
-- Index pour la table `visiteur`
--
ALTER TABLE `visiteur`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `lignefraishorsforfait`
--
ALTER TABLE `lignefraishorsforfait`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `comptable`
--
ALTER TABLE `comptable`
  ADD CONSTRAINT `comptable_ibfk_1` FOREIGN KEY (`id`) REFERENCES `utilisateur` (`id`);

--
-- Contraintes pour la table `fichefrais`
--
ALTER TABLE `fichefrais`
  ADD CONSTRAINT `fichefrais_ibfk_1` FOREIGN KEY (`idEtat`) REFERENCES `etat` (`id`),
  ADD CONSTRAINT `fichefrais_ibfk_2` FOREIGN KEY (`idutilisateur`) REFERENCES `utilisateur` (`id`),
  ADD CONSTRAINT `fichefrais_ibfk_3` FOREIGN KEY (`idComptable`) REFERENCES `comptable` (`id`);

--
-- Contraintes pour la table `lignefraisforfait`
--
ALTER TABLE `lignefraisforfait`
  ADD CONSTRAINT `lignefraisforfait_ibfk_1` FOREIGN KEY (`idutilisateur`,`mois`) REFERENCES `fichefrais` (`idutilisateur`, `mois`),
  ADD CONSTRAINT `lignefraisforfait_ibfk_2` FOREIGN KEY (`idFraisForfait`) REFERENCES `fraisforfait` (`id`);

--
-- Contraintes pour la table `lignefraishorsforfait`
--
ALTER TABLE `lignefraishorsforfait`
  ADD CONSTRAINT `lignefraishorsforfait_ibfk_1` FOREIGN KEY (`idutilisateur`,`mois`) REFERENCES `fichefrais` (`idutilisateur`, `mois`),
  ADD CONSTRAINT `lignefraishorsforfait_ibfk_2` FOREIGN KEY (`idComptableRefus`) REFERENCES `comptable` (`id`);

--
-- Contraintes pour la table `visiteur`
--
ALTER TABLE `visiteur`
  ADD CONSTRAINT `visiteur_ibfk_1` FOREIGN KEY (`id`) REFERENCES `utilisateur` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
