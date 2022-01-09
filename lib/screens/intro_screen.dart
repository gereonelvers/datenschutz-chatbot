import 'package:another_flushbar/flushbar.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

/// This is the screen that introduces the user to the app on first launch
class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController controller = PageController(initialPage: 0);

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        color: BottyColors.greyWhite,
        child: Stack(
          children: [
            PageView(
              scrollDirection: Axis.horizontal,
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              children: const <Widget>[IntroWelcomeScreen(), IntroConsentScreen(), IntroFinishScreen()],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                      child: TextButton(
                        onPressed: backward,
                        child: const Text("Zurück", style: TextStyle(color: Colors.black)),
                      )),
                  Expanded(
                      child: TextButton(
                    onPressed: forward,
                    child: const Text("Weiter", style: TextStyle(color: Colors.black)),
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  backward() {
    setState(() {
      if (controller.page != 0) {
        controller.animateToPage(controller.page!.toInt() - 1, duration: const Duration(milliseconds: 200), curve: Curves.ease);
      }
    });
  }

  forward() async {
    setState(() {
      if (controller.page == 1) {
        if (!IntroConsentScreen.changedName) {
          Flushbar(
              margin: const EdgeInsets.fromLTRB(15,32,15,10),
              borderRadius: BorderRadius.circular(20),
              backgroundColor: BottyColors.greyWhite,
              titleColor: Colors.black,
              messageColor: Colors.black,
              animationDuration: const Duration(milliseconds: 200),
              icon: Image.asset("assets/img/data-white.png", color: Colors.black),
              flushbarPosition: FlushbarPosition.TOP,
              title: 'Sorry!',
              message: "Bitte gib deinen Namen ein 🧑‍",
              boxShadows: const [BoxShadow(color: Colors.grey, offset: Offset(0.0, 0.2), blurRadius: 10.0)],
              duration: const Duration(milliseconds: 1500),
              ).show(context);
          return;
        }
        if (!IntroConsentScreen.dataConsent) {
          Flushbar(
            margin: const EdgeInsets.fromLTRB(15,32,15,10),
            borderRadius: BorderRadius.circular(20),
            backgroundColor: BottyColors.greyWhite,
            titleColor: Colors.black,
            messageColor: Colors.black,
            animationDuration: const Duration(milliseconds: 200),
            icon: Image.asset("assets/img/data-white.png", color: Colors.black),
            flushbarPosition: FlushbarPosition.TOP,
            title: 'Sorry!',
            message: "Bitte akzeptiere unsere Datenschutzerklärung ⚖‍",
            boxShadows: const [BoxShadow(color: Colors.grey, offset: Offset(0.0, 0.2), blurRadius: 10.0)],
            duration: const Duration(milliseconds: 1500),
          ).show(context);
          return;
        }
        controller.animateToPage(controller.page!.toInt() + 1, duration: const Duration(milliseconds: 200), curve: Curves.ease);
      } else if (controller.page == 2) {
        exitIntro();
      } else {
        controller.animateToPage(controller.page!.toInt() + 1, duration: const Duration(milliseconds: 200), curve: Curves.ease);
      }
    });
  }

  exitIntro() async {
    ProgressModel progress = await ProgressModel.getProgressModel();
    progress.setValue("finishedIntro", true);
    Navigator.of(context).pop();
  }

}

// First Screen
class IntroWelcomeScreen extends StatelessWidget {
  const IntroWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      color: BottyColors.greyWhite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 32),
            child: Text(
              "Willkommen!",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 32),
            ),
          ),
          Material(
            elevation: 20,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(45))),
            child: InkWell(
              onTap: () {},
              borderRadius: const BorderRadius.all(Radius.circular(45)),
              child:
              Padding(
                padding: const EdgeInsets.fromLTRB(32,0,32,32),
                child: Lottie.asset("assets/lottie/botty-float.json",
                  height: 162,
                  width: 130,
                  repeat: true,
                ),
              )
            ),
            color: Colors.white,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 48, 8, 0),
            child: Text(
              "Hi, ich bin Botty!",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 22),
            ),
          ),
          const Text(
            "Lass uns gemeinsam\nDatenschutz lernen!",
            style: TextStyle(color: BottyColors.darkBlue, fontSize: 16),
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(8, 32, 8, 0),
          //   child: Text(
          //     "Logos bald hier (TUM, DigiConsult,...)",
          //     style: TextStyle(color: BottyColors.darkBlue, fontSize: 20),
          //   ),
          // )
        ],
      ),
    ));
  }

}

// Second Screen
class IntroConsentScreen extends StatefulWidget {
  const IntroConsentScreen({Key? key}) : super(key: key);
  static bool dataConsent = false;
  static bool changedName = false;


  @override
  _IntroConsentScreenState createState() => _IntroConsentScreenState();
}

class _IntroConsentScreenState extends State<IntroConsentScreen> {
  @override
  initState() {
    initProgressModel();
    super.initState();
  }

  String name = "Name";
  late ProgressModel progress;
  bool classroomToggle = true; // defaults to true (since we dont want the user to accidentally fail to select)
  int _index = 0; // index for stepper
  final String privacyPolicy = r"""
                                <p>Zuletzt aktualisiert: Januar 08, 2022</p>
                                <p>Diese Datenschutzrichtlinie beschreibt unsere Richtlinien und Verfahren für die Erfassung, Verwendung und Offenlegung Ihrer Daten, wenn Sie den Dienst nutzen, und informiert Sie über Ihre Datenschutzrechte und darüber, wie das Gesetz Sie schützt.</p>
                                <p>Wir verwenden Ihre persönlichen Daten zur Bereitstellung und Verbesserung des Dienstes. Durch die Nutzung des Dienstes erklären Sie sich mit der Erfassung und Nutzung von Informationen in Übereinstimmung mit dieser Datenschutzrichtlinie einverstanden. Diese Datenschutzrichtlinie wurde mit Hilfe einer <a href="https://www.privacypolicies.com/blog/privacy-policy-template/" target="_blank">Vorlage für Datenschutzrichtlinien</a> erstellt.</p>
                                <h1>Interpretationen und Definitionen</h1>
                                <h2>Interpretationen</h2>
                                <p>Die Wörter, deren Anfangsbuchstaben groß geschrieben sind, haben die unter den nachstehenden Bedingungen definierte Bedeutung. Die folgenden Definitionen haben dieselbe Bedeutung, unabhängig davon, ob sie im Singular oder im Plural stehen.</p>
                                <h2>Definitionen</h2>
                                <p>Für die Zwecke dieser Datenschutzrichtlinie:</p>
                                <ul>
                                <li>
                                <p><strong>Account</strong> bedeutet ein einzigartiges Konto, das für Sie erstellt wurde, um auf unseren Service oder Teile davon zuzugreifen.</p>
                                </li>
                                <li>
                                <p><strong>Verbundenes Unternehmen</strong> bedeutet ein Unternehmen, das eine Partei kontrolliert, von ihr kontrolliert wird oder mit ihr unter gemeinsamer Kontrolle steht, wobei "Kontrolle" den Besitz von 50 % oder mehr der Aktien, Kapitalanteile oder anderer Wertpapiere bedeutet, die zur Wahl von Direktoren oder anderen leitenden Angestellten berechtigt sind.</p>
                                </li>
                                <li>
                                <p><strong>Anwendung</strong> bezeichnet das vom Unternehmen zur Verfügung gestellte Softwareprogramm, das von Ihnen auf ein beliebiges elektronisches Gerät heruntergeladen wird und den Namen Botty trägt.</p>
                                </li>
                                <li>
                                <p><strong>Unternehmen</strong> (in diesem Vertrag entweder als &quot;das Unternehmen&quot;, &quot;wir&quot;, &quot;uns&quot; oder &quot;unser&quot; bezeichnet) bezieht sich auf Botty.</p>
                                </li>
                                <li>
                                <p><strong>Land</strong> bezieht sich auf: Bayern, Deutschland</p>
                                </li>
                                <li>
                                <p><strong>Gerät</strong> bedeutet jedes Gerät, das auf den Service zugreifen kann, wie z.B. ein Computer, ein Mobiltelefon oder ein digitales Tablet.</p>
                                </li>
                                <li>
                                <p><strong>Personenbezogene Daten</strong> sind alle Informationen, die sich auf eine identifizierte oder identifizierbare Person beziehen.</p>
                                </li>
                                <li>
                                <p><strong>Service</strong> bezieht sich auf die Anwendung.</p>
                                </li>
                                <li>
                                <p><strong>Dienstleister</strong> bezeichnet jede natürliche oder juristische Person, die die Daten im Auftrag des Unternehmens verarbeitet. Er bezieht sich auf Drittunternehmen oder Einzelpersonen, die vom Unternehmen angestellt sind, um die Dienstleistung zu erleichtern, die Dienstleistung im Namen des Unternehmens zu erbringen, Dienstleistungen im Zusammenhang mit der Dienstleistung zu erbringen oder das Unternehmen bei der Analyse der Nutzung der Dienstleistung zu unterstützen.</p>
                                </li>
                                <li>
                                <p><strong>Nutzungsdaten</strong> beziehen sich auf automatisch erfasste Daten, die entweder durch die Nutzung des Dienstes oder durch die Infrastruktur des Dienstes selbst erzeugt werden (z. B. die Dauer eines Seitenbesuchs).</p>
                                </li>
                                <li>
                                <p><strong>Sie</strong> bezeichnet die Person, die auf den Service zugreift oder ihn nutzt, bzw. das Unternehmen oder eine andere juristische Person, in deren Namen eine solche Person auf den Service zugreift oder ihn nutzt, je nach Fall.</p>
                                </li>
                                </ul>
                                <h1>Erfassung und Verwendung Ihrer persönlichen Daten</h1>
                                <h2>Arten von gesammelten Daten</h2>
                                <h3>Persönliche Daten</h3>
                                <p>Während der Nutzung unseres Dienstes können wir Sie bitten, uns bestimmte personenbezogene Daten mitzuteilen, die dazu verwendet werden können, Sie zu kontaktieren oder zu identifizieren. Persönlich identifizierbare Informationen können unter anderem sein:</p>
                                <ul>
                                <li>Verwendungsdaten</li>
                                </ul>
                                <h3>Verwendungsdaten</h3>
                                <p>Nutzungsdaten werden bei der Nutzung des Dienstes automatisch erfasst.</p>
                                <p>Zu den Nutzungsdaten können Informationen wie die Internetprotokolladresse Ihres Geräts (z. B. IP-Adresse), der Browsertyp, die Browserversion, die von Ihnen besuchten Seiten unseres Dienstes, die Uhrzeit und das Datum Ihres Besuchs, die auf diesen Seiten verbrachte Zeit, eindeutige Gerätekennungen und andere Diagnosedaten gehören.</p>
                                <p>Wenn Sie mit oder über ein mobiles Gerät auf den Dienst zugreifen, können wir bestimmte Informationen automatisch erfassen, einschließlich, aber nicht beschränkt auf die Art des von Ihnen verwendeten mobilen Geräts, die eindeutige ID Ihres mobilen Geräts, die IP-Adresse Ihres mobilen Geräts, Ihr mobiles Betriebssystem, die Art des von Ihnen verwendeten mobilen Internetbrowsers, eindeutige Gerätekennungen und andere Diagnosedaten.</p>
                                <p>Wir können auch Informationen erfassen, die Ihr Browser sendet, wenn Sie unseren Dienst besuchen oder wenn Sie über ein mobiles Gerät auf den Dienst zugreifen.</p>
                                <h2>Verwendung Ihrer persönlichen Daten</h2>
                                <p>Das Unternehmen kann personenbezogene Daten für die folgenden Zwecke verwenden:</p>
                                <ul>
                                <li>
                                <p><strong>Zur Bereitstellung und Aufrechterhaltung unserer Dienstleistung</strong>, einschließlich der Überwachung der Nutzung unserer Dienstleistung.</p>
                                </li>
                                <li>
                                <p><strong>Um Ihr Konto zu verwalten:</strong>, um Ihre Registrierung als Nutzer der Dienstleistung zu verwalten. Die von Ihnen bereitgestellten persönlichen Daten können Ihnen Zugang zu verschiedenen Funktionen des Service geben, die Ihnen als registriertem Nutzer zur Verfügung stehen.</p>
                                </li>
                                <li>
                                <p><strong>Für die Erfüllung eines Vertrags:</strong> die Entwicklung, Einhaltung und Durchführung des Kaufvertrags für die Produkte, Artikel oder Dienstleistungen, die Sie gekauft haben, oder eines anderen Vertrags mit uns über den Service.</p>
                                </li>
                                <li>
                                <p><strong>Um mit Ihnen in Kontakt zu treten:</strong> Um Sie per E-Mail, Telefonanrufe, SMS oder andere gleichwertige Formen der elektronischen Kommunikation zu kontaktieren, wie z. B. Push-Benachrichtigungen einer mobilen Anwendung in Bezug auf Aktualisierungen oder informative Mitteilungen im Zusammenhang mit den Funktionen, Produkten oder vertraglich vereinbarten Dienstleistungen, einschließlich der Sicherheitsupdates, wenn dies für ihre Durchführung notwendig oder angemessen ist.</p>
                                </li>
                                <li>
                                <p><strong>Um Sie</strong> mit Neuigkeiten, Sonderangeboten und allgemeinen Informationen über andere Waren, Dienstleistungen und Veranstaltungen zu versorgen, die wir anbieten und die denen ähnlich sind, die Sie bereits gekauft oder angefragt haben, es sei denn, Sie haben sich dagegen entschieden, solche Informationen zu erhalten.</p>
                                </li>
                                <li>
                                <p><strong>Um Ihre Anfragen zu verwalten:</strong> Um Ihre Anfragen an uns zu bearbeiten und zu verwalten.</p>
                                </li>
                                <li>
                                <p><strong>Für Geschäftsübertragungen:</strong> Wir können Ihre Daten verwenden, um eine Fusion, Veräußerung, Umstrukturierung, Reorganisation, Auflösung oder einen anderen Verkauf oder eine Übertragung einiger oder aller unserer Vermögenswerte zu bewerten oder durchzuführen, sei es als laufender Betrieb oder als Teil eines Konkurses, einer Liquidation oder eines ähnlichen Verfahrens, bei dem die von uns gespeicherten personenbezogenen Daten unserer Dienstleistungsnutzer zu den übertragenen Vermögenswerten gehören.</p>
                                </li>
                                <li>
                                <p><strong>Für andere Zwecke</strong>: Wir können Ihre Daten für andere Zwecke verwenden, wie z.B. zur Datenanalyse, zur Ermittlung von Nutzungstrends, zur Bestimmung der Wirksamkeit unserer Werbekampagnen und zur Bewertung und Verbesserung unseres Service, unserer Produkte, Dienstleistungen, unseres Marketings und Ihrer Erfahrungen.</p>
                                </li>
                                </ul>
                                <p>Wir können Ihre personenbezogenen Daten in den folgenden Situationen weitergeben:</p>
                                <ul>
                                <li><strong>Mit Dienstanbietern:</strong> Wir können Ihre persönlichen Daten an Dienstanbieter weitergeben, um die Nutzung unseres Dienstes zu überwachen und zu analysieren und um Sie zu kontaktieren.</li>                                
                                <li><strong>Für Geschäftsübertragungen:</strong> Wir können Ihre persönlichen Daten in Verbindung mit oder während der Verhandlungen über eine Fusion, den Verkauf von Unternehmensvermögen, eine Finanzierung oder die Übernahme unseres gesamten oder eines Teils unseres Unternehmens durch ein anderes Unternehmen weitergeben oder übertragen.</li>
                                <li><strong>Mit verbundenen Unternehmen:</strong> Wir können Ihre Daten an unsere verbundenen Unternehmen weitergeben; in diesem Fall verpflichten wir diese verbundenen Unternehmen, diese Datenschutzrichtlinie einzuhalten. Zu den verbundenen Unternehmen gehören unsere Muttergesellschaft und alle anderen Tochtergesellschaften, Joint-Venture-Partner oder andere Unternehmen, die wir kontrollieren oder die unter gemeinsamer Kontrolle mit uns stehen.</li>
                                <li><strong>Mit Geschäftspartnern:</strong> Wir können Ihre Daten an unsere Geschäftspartner weitergeben, um Ihnen bestimmte Produkte, Dienstleistungen oder Werbeaktionen anzubieten.</li>
                                <li><strong>Mit anderen Nutzern:</strong> Wenn Sie persönliche Informationen weitergeben oder auf andere Weise in den öffentlichen Bereichen mit anderen Nutzern interagieren, können diese Informationen von allen Nutzern eingesehen und öffentlich nach außen verbreitet werden.</li>
                                <li><strong>Mit Ihrer Zustimmung</strong>: Mit Ihrem Einverständnis können wir Ihre personenbezogenen Daten für jeden anderen Zweck offenlegen.</li>
                                </ul>
                                <h2>Aufbewahrung Ihrer persönlichen Daten</h2>
                                <p>Das Unternehmen wird Ihre persönlichen Daten nur so lange aufbewahren, wie es für die in dieser Datenschutzrichtlinie genannten Zwecke erforderlich ist. Wir werden Ihre personenbezogenen Daten in dem Umfang aufbewahren und verwenden, der erforderlich ist, um unseren rechtlichen Verpflichtungen nachzukommen (z. B. wenn wir Ihre Daten aufbewahren müssen, um geltende Gesetze einzuhalten), Streitigkeiten beizulegen und unsere rechtlichen Vereinbarungen und Richtlinien durchzusetzen.</p>
                                <p>Das Unternehmen speichert die Nutzungsdaten auch für interne Analysezwecke. Nutzungsdaten werden im Allgemeinen für einen kürzeren Zeitraum aufbewahrt, es sei denn, diese Daten werden verwendet, um die Sicherheit oder die Funktionalität unseres Dienstes zu verbessern, oder wir sind gesetzlich verpflichtet, diese Daten für längere Zeiträume aufzubewahren.</p>
                                <h2>Übermittlung Ihrer persönlichen Daten</h2>
                                <p>Ihre Informationen, einschließlich personenbezogener Daten, werden in den Betriebsbüros des Unternehmens und an anderen Orten verarbeitet, an denen sich die an der Verarbeitung beteiligten Parteien befinden. Das bedeutet, dass diese Informationen an Computer außerhalb Ihres Staates, Ihrer Provinz, Ihres Landes oder einer anderen staatlichen Gerichtsbarkeit, in der andere Datenschutzgesetze als in Ihrer Gerichtsbarkeit gelten, übertragen und dort gespeichert werden können.</p>
                                <p>Mit Ihrer Zustimmung zu dieser Datenschutzrichtlinie und der anschließenden Übermittlung solcher Informationen erklären Sie sich mit dieser Übertragung einverstanden.</p>
                                <p>Das Unternehmen wird alle angemessenen Schritte unternehmen, um sicherzustellen, dass Ihre Daten sicher und in Übereinstimmung mit dieser Datenschutzrichtlinie behandelt werden, und es wird keine Übermittlung Ihrer persönlichen Daten an eine Organisation oder ein Land stattfinden, wenn nicht angemessene Kontrollen vorhanden sind, die die Sicherheit Ihrer Daten und anderer persönlicher Informationen einschließen.</p>
                                <h2>Offenlegung Ihrer persönlichen Daten</h2>
                                <h3>Geschäftsvorfälle</h3>
                                <p>Wenn das Unternehmen an einer Fusion, einer Übernahme oder einem Verkauf von Vermögenswerten beteiligt ist, können Ihre persönlichen Daten übertragen werden. Wir werden Sie darüber informieren, bevor Ihre persönlichen Daten übertragen werden und einer anderen Datenschutzrichtlinie unterliegen.</p>
                                <h3>Strafverfolgung</h3>
                                <p>Unter bestimmten Umständen kann das Unternehmen verpflichtet sein, Ihre persönlichen Daten offenzulegen, wenn dies gesetzlich vorgeschrieben ist oder als Reaktion auf berechtigte Anfragen von Behörden (z. B. einem Gericht oder einer Regierungsbehörde).</p>
                                <h3>Sonstige rechtliche Anforderungen</h3>
                                <p>Das Unternehmen kann Ihre persönlichen Daten in gutem Glauben offenlegen, dass eine solche Maßnahme notwendig ist, um:</p>
                                <ul>
                                <li>Um einer gesetzlichen Verpflichtung nachkommen</li>
                                <li>Schutz und Verteidigung der Rechte und des Eigentums des Unternehmens</li>
                                <li>Verhinderung oder Untersuchung von möglichem Fehlverhalten im Zusammenhang mit dem Dienst</li>
                                <li>Persönliche Sicherheit der Nutzer des Dienstes oder der Öffentlichkeit zu schützen</li>
                                <li>Schutz vor rechtlicher Haftung</li>
                                </ul>
                                <h2>Sicherheit Ihrer persönlichen Daten</h2>
                                <p>Die Sicherheit Ihrer persönlichen Daten ist uns wichtig, aber denken Sie daran, dass keine Methode der Übertragung über das Internet oder der elektronischen Speicherung 100% sicher ist. Wir bemühen uns, Ihre persönlichen Daten mit kommerziell akzeptablen Mitteln zu schützen, können aber keine absolute Sicherheit garantieren.</p>
                                <h1>Datenschutz für Kinder</h1>
                                <p>Unser Service richtet sich nicht an Personen unter 13 Jahren. Wir sammeln nicht wissentlich personenbezogene Daten von Personen unter 13 Jahren. Wenn Sie ein Elternteil oder Erziehungsberechtigter sind und wissen, dass Ihr Kind uns personenbezogene Daten zur Verfügung gestellt hat, kontaktieren Sie uns bitte. Wenn wir erfahren, dass wir personenbezogene Daten von Personen unter 13 Jahren ohne Überprüfung der elterlichen Zustimmung erfasst haben, ergreifen wir Maßnahmen, um diese Informationen von unseren Servern zu entfernen.</p>
                                <p>Wenn wir uns auf die Zustimmung als Rechtsgrundlage für die Verarbeitung Ihrer Daten stützen müssen und Ihr Land die Zustimmung eines Elternteils erfordert, können wir die Zustimmung Ihres Elternteils verlangen, bevor wir diese Daten sammeln und verwenden.</p>
                                <h1>Links zu anderen Websites</h1>
                                <p>Unser Service kann Links zu anderen Websites enthalten, die nicht von uns betrieben werden. Wenn Sie auf einen Link einer dritten Partei klicken, werden Sie auf die Seite dieser dritten Partei weitergeleitet. Wir empfehlen Ihnen dringend, die Datenschutzrichtlinien jeder Website, die Sie besuchen, zu lesen.</p>
                                <p>Wir haben keine Kontrolle über und übernehmen keine Verantwortung für den Inhalt, die Datenschutzrichtlinien oder Praktiken von Websites oder Diensten Dritter.</p>
                                <h1>Änderungen an dieser Datenschutzrichtlinie</h1>
                                <p>Wir können unsere Datenschutzrichtlinie von Zeit zu Zeit aktualisieren. Wir werden Sie über alle Änderungen informieren, indem wir die neue Datenschutzrichtlinie auf dieser Seite veröffentlichen.</p>
                                <p>Wir werden Sie per E-Mail und/oder durch einen auffälligen Hinweis in unserem Service informieren, bevor die Änderung in Kraft tritt, und das Datum der letzten Aktualisierung oben in dieser Datenschutzrichtlinie aktualisieren.</p>
                                <p>Wir empfehlen Ihnen, diese Datenschutzrichtlinie regelmäßig auf Änderungen zu überprüfen. Änderungen an dieser Datenschutzrichtlinie werden wirksam, wenn sie auf dieser Seite veröffentlicht werden.</p>
                                <h1>Kontakt</h1>
                                <p>Wenn Sie Fragen zu dieser Datenschutzrichtlinie haben, können Sie uns kontaktieren:</p>
                                <ul>
                                <li>
                                <p>Via E-Mail: gereon.elvers@tum.de</p>
                                </li>
                                <li>
                                <p>Via Telefon: 015204446662</p>
                                </li>
                                </ul>
                               """;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: BottyColors.greyWhite,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 32, 8, 8),
              child: Text(
                "📝 Erstmal der Papierkram...",
                style: TextStyle(color: BottyColors.darkBlue, fontSize: 24),
              ),
            ),
            Stepper(
              physics: const ClampingScrollPhysics(),
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Visibility(
                    visible: !(_index == 2),
                    child: Row(
                      children: [
                        Visibility(
                          visible: !(_index == 0),
                          child: TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text(
                              'Zurück',
                              style: TextStyle(color: BottyColors.darkBlue),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                BottyColors.blue,
                              ),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ))),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Weiter',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              currentStep: _index,
              onStepCancel: () {
                if (_index > 0) {
                  setState(() {
                    _index -= 1;
                  });
                }
              },
              onStepContinue: () {
                if (_index <= 1) {
                  setState(() {
                    _index += 1;
                  });
                }
              },
              onStepTapped: (int index) {
                setState(() {
                  _index = index;
                });
              },
              steps: [
                Step(
                  title: const Text("💻 Name", style: TextStyle(fontSize: 18)),
                  content: Column(
                    children: [
                      const Text(
                        "Wie dürfen wir dich nennen? 🤔",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 16),
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 18)),
                      TextField(
                        cursorColor: BottyColors.darkBlue,
                        decoration: InputDecoration(
                            hoverColor: BottyColors.darkBlue,
                            hintText: name,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(color: BottyColors.darkBlue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(color: BottyColors.darkBlue),
                            ),
                            labelText: "Name",
                            labelStyle: const TextStyle(color: BottyColors.darkBlue)),
                        onChanged: updateName,
                      ),
                    ],
                  ),
                  //state: StepState.complete
                ),
                Step(
                    title: const Text("📜 Datenschutzerklärung", style: TextStyle(fontSize: 18)),
                    content: Column(
                      children: [
                        SizedBox(
                            height: 250,
                            child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Html(data: privacyPolicy)),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: Row(children: [
                            Expanded(
                              flex: 1,
                              child: Checkbox(
                                value: IntroConsentScreen.dataConsent,
                                onChanged: (bool? value) {
                                  setState(() {
                                    IntroConsentScreen.dataConsent = !IntroConsentScreen.dataConsent;
                                  });
                                },
                                activeColor: BottyColors.darkBlue,
                              ),
                            ),
                            Flexible(
                              flex: 4,
                              child: Wrap(
                                children: const [
                                  Text(
                                    "Ich habe die Datenschutzerklärung gelesen und stimme ihr zu.",
                                  ),
                                ],
                              ),
                            )
                          ]),
                        )
                      ],
                    )),
                Step(
                  title: const Text("🎮 Spielmodus", style: TextStyle(fontSize: 18)),
                  content: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                classroomToggle = !classroomToggle;
                                progress.setValue("classroomToggle", classroomToggle);
                              });
                            },
                            child: const Text(
                              "Spielst du in der Klasse?",
                              style: TextStyle(color: BottyColors.darkBlue, fontSize: 16),
                            ),
                          ),
                          const Spacer(),
                          Align(
                              alignment: Alignment.topRight,
                              child: Switch(
                                activeColor: BottyColors.blue,
                                onChanged: (bool value) {
                                  setState(() {
                                    classroomToggle = value;
                                    progress.setValue("classroomToggle", value);
                                  });
                                },
                                value: classroomToggle,
                                activeThumbImage: const AssetImage(
                                  "assets/img/school-solid.png",
                                ),
                                inactiveThumbImage: const AssetImage("assets/img/school-solid.png"),
                              )),
                        ],
                      ),
                      const Text(
                          "Falls du in die App im Unterricht verwendest, wird Botty dich Schritt-für-Schritt durch die Inhalte führen ☺\nTipp: Natürlich kannst du den Haken natürlich auch einfach so auswählen 🙃")
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ));
  }

  updateName(String text) {
    setState(() {
      name = text;
      progress.setValue("username", name);
      if (text.trim() != "") IntroConsentScreen.changedName = true;
    });
  }

  initProgressModel() async {
    progress = await ProgressModel.getProgressModel();
    progress.setValue("classroomToggle", true);
  }
}

// Third Screen
class IntroFinishScreen extends StatelessWidget {
  const IntroFinishScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      color: BottyColors.greyWhite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
            child: Lottie.asset("assets/lottie/feedback.json"),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: Text(
              "Und los geht's! 🚀",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 24),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Text(
              "Wir freuen uns, dass du uns dabei hilfst, Botty zu testen. Hoffentlich wirst du dabei genauso viel Spaß haben, wie wir bei der Entwicklung.\n"
              "Bitte lass uns wissen, wie dir die App gefällt!",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 16),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("- dein ITBL-Botty-Team\n(Martin, Delun, Lena, Leonie, Liping und Gereon)"),
          )
        ],
      ),
    ));
  }
}
