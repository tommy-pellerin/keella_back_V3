# Keella Back API

## Description
KEELLA Back API est une plateforme de location en ligne qui met en relation des personnes souhaitant louer des équipements sportifs et des espaces pour pratiquer des activités sportives. Inspirée par le modéle d'Airbnb, elle se concentre spécifiquement sur le domaine sportif.

Les utilisateurs peuvent parcourir une variété d'équipements sportifs et d'espaces disponibles dans leur région ou dans un lieu qu'ils prévoient de visiter. Ils peuvent réserver et payer la location directement via l'application, offrant une commodité et une sécurité similaires à celles d'Airbnb.

De plus, les personnes qui possédent des équipements sportifs ou des espaces qu'elles n'utilisent pas tout le temps peuvent les inscrire sur l'application pour les louer à d'autres. C'est une excellente façon de monétiser ces ressources inutilisées.

En somme, votre application offre une solution pratique et économique pour les amateurs de sport, tout en créant une nouvelle source de revenus pour les propriétaires d'équipements et d'espaces sportifs.


## To do list:
- manage user account with admin account:
  => Verify when signin with severals account that there is no problem with DEVISE current_user and user from token
- Verify authenticate_user!
- translate DEVISE
- Implémentation d'un "soft delete" = quand un utilisateur est supprimé avec destroy, l'objet est simplement marqué comme supprimé (en définissant la valeur de deleted_at), mais les données restent dans la base.
- users can suggest new category
- reviews city relations
- reviews availabilities : il generate a of work to the server when request a workout availiabilities 