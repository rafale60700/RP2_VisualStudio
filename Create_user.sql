-- Créer l'utilisateur gsb_user avec mot de passe
CREATE USER 'gsb_user2'@'localhost' IDENTIFIED BY '12-Soleil&';

-- Donner tous les droits sur la base gsb_frais
GRANT ALL PRIVILEGES ON gsb_frais2.* TO 'gsb_user2'@'localhost';

-- Appliquer les changements
FLUSH PRIVILEGES;
