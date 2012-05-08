BS.rb
===

Outil en ligne de commande pour marquer comme récupéré ses épisodes sur BetaSeries.

Prérequis
===
Pour le bonne utilisation de ce script vous aurez besoin :

* Un compte [BetaSeries](http://betaseries.com)
* Une [clé API BetaSeries](http://www.betaseries.com/api)
* [Ruby](http://www.ruby-lang.org/fr/)
* La [gem JSON](http://flori.github.com/json/)

Configuration
===

Pour commencer il faut éditer le fichier Config.rb avec les informations suivantes :

* **User** : Nom d'utilisateur BetaSeries
* **Password** : Mot de passe BetaSeries
* **APIkey** : Votre clé API
* **Folder** : Le chemin vers votre dossier de séries

Utilisation
===

Avec votre terminal, allez dans le dossier de l'application, puis lancez là avec la commande suivante :

	ruby BS.rb

Divers
===

Ce script créé un cache afin de ne pas envoyer des requètes inutiles vers l'API de BetaSeries. Il s'agit du fichier **cache.bs**.

Si vous rencontrez des difficultés avec le logiciel, vous pouvez supprimer ce fichier afin qu'il rescanne toutes vos séries.

Remerciements
===
BetaSeries pour sa formidable API.