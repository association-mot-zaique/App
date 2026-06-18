class LegalContent {
  LegalContent._();

  static String termsOfUse(String localeCode) {
    return switch (localeCode) {
      'fr' => _termsOfUseFr,
      'en' => _termsOfUseEn,
      'de' => _termsOfUseDe,
      'it' => _termsOfUseIt,
      _ => _termsOfUseEs,
    };
  }

  static String privacyPolicy(String localeCode) {
    return switch (localeCode) {
      'fr' => _privacyPolicyFr,
      'en' => _privacyPolicyEn,
      'de' => _privacyPolicyDe,
      'it' => _privacyPolicyIt,
      _ => _privacyPolicyEs,
    };
  }

  // ── Terms of Use ──────────────────────────────────────────────

  static const _termsOfUseFr = '''Conditions d'utilisation \u2013 MOT-ZAIQUE

Derni\u00e8re mise \u00e0 jour : mars 2026

Les pr\u00e9sentes conditions d'utilisation r\u00e9gissent l'utilisation de l'application MOT-ZAIQUE.

En utilisant l'application, vous acceptez ces conditions.

Objet de l'application

MOT-ZAIQUE est une application de Communication Alternative et Am\u00e9lior\u00e9e (CAA) destin\u00e9e \u00e0 aider les personnes non verbales \u00e0 communiquer \u00e0 l'aide de pictogrammes.

L'application est fournie gratuitement par l'association MOT-ZAIQUE.

Licence d'utilisation

L'utilisateur dispose d'un droit d'utilisation personnel, non exclusif et non transf\u00e9rable de l'application.

L'application ne peut pas \u00eatre utilis\u00e9e d'une mani\u00e8re contraire aux lois applicables.

Ressources tierces

L'application permet d'acc\u00e9der \u00e0 des pictogrammes fournis par le projet ARASAAC.

Ces pictogrammes ont \u00e9t\u00e9 cr\u00e9\u00e9s par Sergio Palao pour le Gouvernement d'Aragon et sont distribu\u00e9s sous licence Creative Commons BY-NC-SA.

Les utilisateurs doivent respecter les conditions de cette licence lors de toute r\u00e9utilisation de ces pictogrammes.

Disponibilit\u00e9

L'association MOT-ZAIQUE s'efforce d'assurer la disponibilit\u00e9 de l'application mais ne peut garantir un fonctionnement continu ou sans erreur.

Limitation de responsabilit\u00e9

L'application est fournie \u00ab telle quelle \u00bb sans garantie d'aucune sorte.

L'association MOT-ZAIQUE ne pourra \u00eatre tenue responsable de dommages r\u00e9sultant de l'utilisation ou de l'impossibilit\u00e9 d'utiliser l'application.

Modifications

Les pr\u00e9sentes conditions d'utilisation peuvent \u00eatre mises \u00e0 jour si l'application \u00e9volue.

Contact

Pour toute question : contact@motzaique.fr''';

  static const _termsOfUseEn = '''Terms of Use \u2013 MOT-ZAIQUE

Last updated: March 2026

These terms of use govern the use of the MOT-ZAIQUE application.

By using the application, you accept these terms.

Purpose of the application

MOT-ZAIQUE is an Alternative and Augmentative Communication (AAC) application designed to help non-verbal individuals communicate using pictograms.

The application is provided free of charge by the MOT-ZAIQUE association.

License of use

The user is granted a personal, non-exclusive and non-transferable right to use the application.

The application may not be used in a manner contrary to applicable laws.

Third-party resources

The application provides access to pictograms supplied by the ARASAAC project.

These pictograms were created by Sergio Palao for the Government of Aragon and are distributed under the Creative Commons BY-NC-SA license.

Users must comply with the terms of this license when reusing these pictograms.

Availability

The MOT-ZAIQUE association strives to ensure the availability of the application but cannot guarantee continuous or error-free operation.

Limitation of liability

The application is provided "as is" without warranty of any kind.

The MOT-ZAIQUE association shall not be held liable for damages resulting from the use or inability to use the application.

Modifications

These terms of use may be updated as the application evolves.

Contact

For any questions: contact@motzaique.fr''';

  static const _termsOfUseEs = '''Condiciones de uso \u2013 MOT-ZAIQUE

\u00daltima actualizaci\u00f3n: marzo de 2026

Las presentes condiciones de uso rigen el uso de la aplicaci\u00f3n MOT-ZAIQUE.

Al utilizar la aplicaci\u00f3n, usted acepta estas condiciones.

Objeto de la aplicaci\u00f3n

MOT-ZAIQUE es una aplicaci\u00f3n de Comunicaci\u00f3n Alternativa y Aumentativa (CAA) destinada a ayudar a las personas no verbales a comunicarse mediante pictogramas.

La aplicaci\u00f3n es proporcionada de forma gratuita por la asociaci\u00f3n MOT-ZAIQUE.

Licencia de uso

El usuario dispone de un derecho de uso personal, no exclusivo y no transferible de la aplicaci\u00f3n.

La aplicaci\u00f3n no puede utilizarse de manera contraria a las leyes aplicables.

Recursos de terceros

La aplicaci\u00f3n permite acceder a pictogramas proporcionados por el proyecto ARASAAC.

Estos pictogramas fueron creados por Sergio Palao para el Gobierno de Arag\u00f3n y se distribuyen bajo la licencia Creative Commons BY-NC-SA.

Los usuarios deben respetar las condiciones de esta licencia en cualquier reutilizaci\u00f3n de estos pictogramas.

Disponibilidad

La asociaci\u00f3n MOT-ZAIQUE se esfuerza por garantizar la disponibilidad de la aplicaci\u00f3n, pero no puede garantizar un funcionamiento continuo ni libre de errores.

Limitaci\u00f3n de responsabilidad

La aplicaci\u00f3n se proporciona \u00abtal cual\u00bb, sin garant\u00eda de ning\u00fan tipo.

La asociaci\u00f3n MOT-ZAIQUE no ser\u00e1 responsable de los da\u00f1os derivados del uso o de la imposibilidad de uso de la aplicaci\u00f3n.

Modificaciones

Las presentes condiciones de uso pueden actualizarse si la aplicaci\u00f3n evoluciona.

Contacto

Para cualquier consulta: contact@motzaique.fr''';

  static const _termsOfUseDe = '''Nutzungsbedingungen \u2013 MOT-ZAIQUE

Letzte Aktualisierung: M\u00e4rz 2026

Diese Nutzungsbedingungen regeln die Nutzung der Anwendung MOT-ZAIQUE.

Durch die Nutzung der Anwendung akzeptieren Sie diese Bedingungen.

Zweck der Anwendung

MOT-ZAIQUE ist eine Anwendung f\u00fcr Unterst\u00fctzte Kommunikation (UK), die nicht-sprechenden Personen helfen soll, mithilfe von Piktogrammen zu kommunizieren.

Die Anwendung wird vom Verein MOT-ZAIQUE kostenlos zur Verf\u00fcgung gestellt.

Nutzungslizenz

Der Benutzer erh\u00e4lt ein pers\u00f6nliches, nicht-exklusives und nicht \u00fcbertragbares Nutzungsrecht an der Anwendung.

Die Anwendung darf nicht in einer Weise verwendet werden, die gegen geltendes Recht verst\u00f6\u00dft.

Ressourcen Dritter

Die Anwendung erm\u00f6glicht den Zugriff auf Piktogramme, die vom ARASAAC-Projekt bereitgestellt werden.

Diese Piktogramme wurden von Sergio Palao f\u00fcr die Regierung von Aragonien erstellt und werden unter der Creative-Commons-Lizenz BY-NC-SA vertrieben.

Die Benutzer m\u00fcssen die Bedingungen dieser Lizenz bei jeder Wiederverwendung dieser Piktogramme einhalten.

Verf\u00fcgbarkeit

Der Verein MOT-ZAIQUE bem\u00fcht sich, die Verf\u00fcgbarkeit der Anwendung sicherzustellen, kann jedoch keinen ununterbrochenen oder fehlerfreien Betrieb garantieren.

Haftungsbeschr\u00e4nkung

Die Anwendung wird \u201ewie besehen\u201c ohne jegliche Garantie bereitgestellt.

Der Verein MOT-ZAIQUE kann nicht f\u00fcr Sch\u00e4den haftbar gemacht werden, die aus der Nutzung oder der Unm\u00f6glichkeit der Nutzung der Anwendung resultieren.

\u00c4nderungen

Diese Nutzungsbedingungen k\u00f6nnen aktualisiert werden, wenn sich die Anwendung weiterentwickelt.

Kontakt

Bei Fragen: contact@motzaique.fr''';

  static const _termsOfUseIt = '''Condizioni d'uso \u2013 MOT-ZAIQUE

Ultimo aggiornamento: marzo 2026

Le presenti condizioni d'uso regolano l'utilizzo dell'applicazione MOT-ZAIQUE.

Utilizzando l'applicazione, l'utente accetta le presenti condizioni.

Scopo dell'applicazione

MOT-ZAIQUE \u00e8 un'applicazione di Comunicazione Aumentativa e Alternativa (CAA) progettata per aiutare le persone non verbali a comunicare tramite pittogrammi.

L'applicazione \u00e8 fornita gratuitamente dall'associazione MOT-ZAIQUE.

Licenza d'uso

L'utente dispone di un diritto d'uso personale, non esclusivo e non trasferibile dell'applicazione.

L'applicazione non pu\u00f2 essere utilizzata in modo contrario alle leggi applicabili.

Risorse di terze parti

L'applicazione consente l'accesso a pittogrammi forniti dal progetto ARASAAC.

Questi pittogrammi sono stati creati da Sergio Palao per il Governo d'Aragona e sono distribuiti con licenza Creative Commons BY-NC-SA.

Gli utenti devono rispettare le condizioni di questa licenza in caso di riutilizzo di tali pittogrammi.

Disponibilit\u00e0

L'associazione MOT-ZAIQUE si impegna a garantire la disponibilit\u00e0 dell'applicazione, ma non pu\u00f2 garantire un funzionamento continuo o privo di errori.

Limitazione di responsabilit\u00e0

L'applicazione \u00e8 fornita \u00abcos\u00ec com'\u00e8\u00bb senza garanzie di alcun tipo.

L'associazione MOT-ZAIQUE non potr\u00e0 essere ritenuta responsabile per danni derivanti dall'uso o dall'impossibilit\u00e0 d'uso dell'applicazione.

Modifiche

Le presenti condizioni d'uso possono essere aggiornate in caso di evoluzione dell'applicazione.

Contatto

Per qualsiasi domanda: contact@motzaique.fr''';

  // ── Privacy Policy ────────────────────────────────────────────

  static const _privacyPolicyFr = '''Politique de confidentialit\u00e9 \u2013 MOT-ZAIQUE

Derni\u00e8re mise \u00e0 jour : mars 2026

L'application MOT-ZAIQUE est une application de Communication Alternative et Am\u00e9lior\u00e9e (CAA) destin\u00e9e \u00e0 aider les personnes non verbales \u00e0 communiquer \u00e0 l'aide de pictogrammes.

Cette application est \u00e9dit\u00e9e par l'association MOT-ZAIQUE.

Adresse :
MOT-ZAIQUE
6465 Rte de St-Jean du Gard
30140 Thoiras-Corbes
France

Site web : https://motzaique.fr
Email de contact : contact@motzaique.fr

Donn\u00e9es personnelles

L'application MOT-ZAIQUE ne collecte, ne transmet et ne partage aucune donn\u00e9e personnelle.

L'application ne n\u00e9cessite pas la cr\u00e9ation de compte utilisateur et ne demande aucune information personnelle.

Donn\u00e9es stock\u00e9es sur l'appareil

Certaines informations sont stock\u00e9es uniquement sur l'appareil de l'utilisateur, notamment :
\u2022 les pictogrammes t\u00e9l\u00e9charg\u00e9s
\u2022 les param\u00e8tres de l'application
\u2022 le code PIN permettant de prot\u00e9ger l'acc\u00e8s aux param\u00e8tres

Ces donn\u00e9es restent exclusivement sur l'appareil et ne sont jamais transmises \u00e0 un serveur externe.

Utilisation d'Internet

Une connexion internet est requise uniquement lorsque l'utilisateur choisit de rechercher et t\u00e9l\u00e9charger des pictogrammes depuis la base de donn\u00e9es ARASAAC.

Aucune donn\u00e9e personnelle n'est transmise lors de cette utilisation.

Ressources tierces

L'application permet d'acc\u00e9der \u00e0 des pictogrammes fournis par le projet ARASAAC.
Ces ressources sont soumises \u00e0 leurs propres conditions de licence.

Protection des enfants

L'application est destin\u00e9e \u00e0 accompagner les utilisateurs de Communication Alternative et Am\u00e9lior\u00e9e, y compris les enfants.
Cependant, l'application ne collecte aucune donn\u00e9e personnelle.

Modifications

Cette politique de confidentialit\u00e9 peut \u00eatre mise \u00e0 jour si l'application \u00e9volue.

Contact

Pour toute question concernant cette politique de confidentialit\u00e9 : contact@motzaique.fr''';

  static const _privacyPolicyEn = '''Privacy Policy \u2013 MOT-ZAIQUE

Last updated: March 2026

The MOT-ZAIQUE application is an Alternative and Augmentative Communication (AAC) application designed to help non-verbal individuals communicate using pictograms.

This application is published by the MOT-ZAIQUE association.

Address:
MOT-ZAIQUE
6465 Rte de St-Jean du Gard
30140 Thoiras-Corbes
France

Website: https://motzaique.fr
Contact email: contact@motzaique.fr

Personal data

The MOT-ZAIQUE application does not collect, transmit or share any personal data.

The application does not require user account creation and does not request any personal information.

Data stored on the device

Some information is stored only on the user's device, including:
\u2022 downloaded pictograms
\u2022 application settings
\u2022 the PIN code used to protect access to settings

This data remains exclusively on the device and is never transmitted to an external server.

Internet usage

An internet connection is required only when the user chooses to search for and download pictograms from the ARASAAC database.

No personal data is transmitted during this usage.

Third-party resources

The application provides access to pictograms supplied by the ARASAAC project.
These resources are subject to their own license terms.

Child protection

The application is intended to support Alternative and Augmentative Communication users, including children.
However, the application does not collect any personal data.

Modifications

This privacy policy may be updated as the application evolves.

Contact

For any questions regarding this privacy policy: contact@motzaique.fr''';

  static const _privacyPolicyEs = '''Pol\u00edtica de privacidad \u2013 MOT-ZAIQUE

\u00daltima actualizaci\u00f3n: marzo de 2026

La aplicaci\u00f3n MOT-ZAIQUE es una aplicaci\u00f3n de Comunicaci\u00f3n Alternativa y Aumentativa (CAA) destinada a ayudar a las personas no verbales a comunicarse mediante pictogramas.

Esta aplicaci\u00f3n es publicada por la asociaci\u00f3n MOT-ZAIQUE.

Direcci\u00f3n:
MOT-ZAIQUE
6465 Rte de St-Jean du Gard
30140 Thoiras-Corbes
Francia

Sitio web: https://motzaique.fr
Correo de contacto: contact@motzaique.fr

Datos personales

La aplicaci\u00f3n MOT-ZAIQUE no recopila, transmite ni comparte ning\u00fan dato personal.

La aplicaci\u00f3n no requiere la creaci\u00f3n de una cuenta de usuario y no solicita informaci\u00f3n personal alguna.

Datos almacenados en el dispositivo

Cierta informaci\u00f3n se almacena \u00fanicamente en el dispositivo del usuario, incluyendo:
\u2022 los pictogramas descargados
\u2022 los ajustes de la aplicaci\u00f3n
\u2022 el c\u00f3digo PIN para proteger el acceso a los ajustes

Estos datos permanecen exclusivamente en el dispositivo y nunca se transmiten a un servidor externo.

Uso de Internet

Se requiere una conexi\u00f3n a internet \u00fanicamente cuando el usuario elige buscar y descargar pictogramas desde la base de datos ARASAAC.

No se transmiten datos personales durante este uso.

Recursos de terceros

La aplicaci\u00f3n permite acceder a pictogramas proporcionados por el proyecto ARASAAC.
Estos recursos est\u00e1n sujetos a sus propias condiciones de licencia.

Protecci\u00f3n de menores

La aplicaci\u00f3n est\u00e1 destinada a acompa\u00f1ar a usuarios de Comunicaci\u00f3n Alternativa y Aumentativa, incluidos ni\u00f1os.
Sin embargo, la aplicaci\u00f3n no recopila ning\u00fan dato personal.

Modificaciones

Esta pol\u00edtica de privacidad puede actualizarse si la aplicaci\u00f3n evoluciona.

Contacto

Para cualquier consulta sobre esta pol\u00edtica de privacidad: contact@motzaique.fr''';

  static const _privacyPolicyDe = '''Datenschutzrichtlinie \u2013 MOT-ZAIQUE

Letzte Aktualisierung: M\u00e4rz 2026

Die Anwendung MOT-ZAIQUE ist eine Anwendung f\u00fcr Unterst\u00fctzte Kommunikation (UK), die nicht-sprechenden Personen helfen soll, mithilfe von Piktogrammen zu kommunizieren.

Diese Anwendung wird vom Verein MOT-ZAIQUE herausgegeben.

Adresse:
MOT-ZAIQUE
6465 Rte de St-Jean du Gard
30140 Thoiras-Corbes
Frankreich

Website: https://motzaique.fr
Kontakt-E-Mail: contact@motzaique.fr

Personenbezogene Daten

Die Anwendung MOT-ZAIQUE erhebt, \u00fcbermittelt und teilt keine personenbezogenen Daten.

Die Anwendung erfordert keine Erstellung eines Benutzerkontos und fragt keine pers\u00f6nlichen Informationen ab.

Auf dem Ger\u00e4t gespeicherte Daten

Einige Informationen werden ausschlie\u00dflich auf dem Ger\u00e4t des Benutzers gespeichert, darunter:
\u2022 heruntergeladene Piktogramme
\u2022 Anwendungseinstellungen
\u2022 der PIN-Code zum Schutz des Zugriffs auf die Einstellungen

Diese Daten verbleiben ausschlie\u00dflich auf dem Ger\u00e4t und werden niemals an einen externen Server \u00fcbermittelt.

Internetnutzung

Eine Internetverbindung ist nur erforderlich, wenn der Benutzer Piktogramme aus der ARASAAC-Datenbank suchen und herunterladen m\u00f6chte.

W\u00e4hrend dieser Nutzung werden keine personenbezogenen Daten \u00fcbermittelt.

Ressourcen Dritter

Die Anwendung erm\u00f6glicht den Zugriff auf Piktogramme, die vom ARASAAC-Projekt bereitgestellt werden.
Diese Ressourcen unterliegen ihren eigenen Lizenzbedingungen.

Kinderschutz

Die Anwendung ist daf\u00fcr bestimmt, Nutzer der Unterst\u00fctzten Kommunikation zu begleiten, einschlie\u00dflich Kinder.
Die Anwendung erhebt jedoch keine personenbezogenen Daten.

\u00c4nderungen

Diese Datenschutzrichtlinie kann aktualisiert werden, wenn sich die Anwendung weiterentwickelt.

Kontakt

Bei Fragen zu dieser Datenschutzrichtlinie: contact@motzaique.fr''';

  static const _privacyPolicyIt = '''Informativa sulla privacy \u2013 MOT-ZAIQUE

Ultimo aggiornamento: marzo 2026

L'applicazione MOT-ZAIQUE \u00e8 un'applicazione di Comunicazione Aumentativa e Alternativa (CAA) progettata per aiutare le persone non verbali a comunicare tramite pittogrammi.

Questa applicazione \u00e8 pubblicata dall'associazione MOT-ZAIQUE.

Indirizzo:
MOT-ZAIQUE
6465 Rte de St-Jean du Gard
30140 Thoiras-Corbes
Francia

Sito web: https://motzaique.fr
Email di contatto: contact@motzaique.fr

Dati personali

L'applicazione MOT-ZAIQUE non raccoglie, trasmette n\u00e9 condivide alcun dato personale.

L'applicazione non richiede la creazione di un account utente e non richiede alcuna informazione personale.

Dati memorizzati sul dispositivo

Alcune informazioni vengono memorizzate esclusivamente sul dispositivo dell'utente, tra cui:
\u2022 i pittogrammi scaricati
\u2022 le impostazioni dell'applicazione
\u2022 il codice PIN per proteggere l'accesso alle impostazioni

Questi dati restano esclusivamente sul dispositivo e non vengono mai trasmessi a un server esterno.

Utilizzo di Internet

Una connessione a Internet \u00e8 necessaria solo quando l'utente sceglie di cercare e scaricare pittogrammi dal database ARASAAC.

Nessun dato personale viene trasmesso durante questo utilizzo.

Risorse di terze parti

L'applicazione consente l'accesso a pittogrammi forniti dal progetto ARASAAC.
Queste risorse sono soggette alle proprie condizioni di licenza.

Protezione dei minori

L'applicazione \u00e8 destinata ad accompagnare gli utenti di Comunicazione Aumentativa e Alternativa, compresi i bambini.
Tuttavia, l'applicazione non raccoglie alcun dato personale.

Modifiche

La presente informativa sulla privacy pu\u00f2 essere aggiornata in caso di evoluzione dell'applicazione.

Contatto

Per qualsiasi domanda relativa a questa informativa sulla privacy: contact@motzaique.fr''';
}
