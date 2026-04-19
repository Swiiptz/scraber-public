/// Convertit un texte markdown brut en texte lisible en plein écran.
///
/// Le contenu stocké côté scraper peut contenir des fragments de markdown
/// (titres `##`, blocs de code ``` ``` ``` ```, emphase `**…**`, liens
/// `[texte](url)`, etc.). On produit une version texte qui :
///   - enlève les fences de code, les titres, les tableaux ;
///   - préserve les listes sous forme `• …` ;
///   - conserve uniquement le libellé des liens ;
///   - compresse les suites de blancs.
String sanitizeMarkdown(String input) {
  if (input.isEmpty) return input;
  var text = input.replaceAll('\r\n', '\n');

  // Fences de code ``` ``` : on conserve le contenu interne sans backticks.
  text = text.replaceAllMapped(
    RegExp(r'```[a-zA-Z0-9_-]*\n?([\s\S]*?)```', multiLine: true),
    (m) => m.group(1) ?? '',
  );
  // Fence orpheline (ouverture sans fermeture, souvent due à une troncature).
  text = text.replaceAll(RegExp(r'```[a-zA-Z0-9_-]*'), '');
  // Code inline `…`
  text = text.replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m.group(1) ?? '');

  // Images ![alt](url) → alt
  text = text.replaceAllMapped(
    RegExp(r'!\[([^\]]*)\]\([^)]*\)'),
    (m) => m.group(1) ?? '',
  );
  // Liens [texte](url) → texte
  text = text.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\([^)]*\)'),
    (m) => m.group(1) ?? '',
  );

  // Titres ATX : on accepte la version début de ligne ET la version inline
  // (après un espace), car le scraper a pu aplatir les `\n` en espaces.
  text = text.replaceAllMapped(
    RegExp(r'(^|\s)#{1,6}\s+'),
    (m) => m.group(1) ?? '',
  );

  // Blockquotes `> ` → ''
  text = text.replaceAll(RegExp(r'^\s*>\s?', multiLine: true), '');

  // Listes `-`, `*`, `+` ou `1.` → `• `
  text = text.replaceAll(
    RegExp(r'^\s*[-*+]\s+', multiLine: true),
    '• ',
  );
  text = text.replaceAll(
    RegExp(r'^\s*\d+\.\s+', multiLine: true),
    '• ',
  );

  // Emphase **gras**, *italique*, __gras__, _italique_
  text = text.replaceAllMapped(
    RegExp(r'\*\*([^*]+)\*\*'),
    (m) => m.group(1) ?? '',
  );
  text = text.replaceAllMapped(
    RegExp(r'__([^_]+)__'),
    (m) => m.group(1) ?? '',
  );
  text = text.replaceAllMapped(
    RegExp(r'(?<![*\w])\*([^*\n]+)\*(?!\w)'),
    (m) => m.group(1) ?? '',
  );
  text = text.replaceAllMapped(
    RegExp(r'(?<![_\w])_([^_\n]+)_(?!\w)'),
    (m) => m.group(1) ?? '',
  );

  // Séparateurs horizontaux `---` ou `***`
  text = text.replaceAll(
    RegExp(r'^\s*(?:-{3,}|\*{3,}|_{3,})\s*$', multiLine: true),
    '',
  );

  // Tableaux pipe (rudimentaire) : on convertit les `|` en espaces.
  text = text.replaceAll(
    RegExp(r'^\s*\|(.+)\|\s*$', multiLine: true),
    ' ',
  );

  // Compression des blancs : max 2 retours à la ligne successifs.
  text = text.replaceAll(RegExp(r'[ \t]+\n'), '\n');
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text.trim();
}

/// Détermine si `content` est redondant avec `summary` (inclus ou quasi-égal).
bool isContentRedundantWithSummary(String summary, String content) {
  final s = _normalize(summary);
  final c = _normalize(content);
  if (s.isEmpty || c.isEmpty) return false;
  if (s == c) return true;
  // Tolérance : si le summary couvre ≥ 90% du contenu, on considère redondant.
  if (c.startsWith(s) && s.length >= c.length * 0.9) return true;
  return false;
}

String _normalize(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'[^\p{L}\p{N} ]', unicode: true), '')
      .trim();
}

/// Réinjecte des sauts de ligne autour des marqueurs markdown dans un
/// contenu qui a été aplati par le scraper (`cleanText()` écrase les `\n`).
/// Sans ça un `## Titre` inline est lu comme un H2 englobant tout le reste,
/// et la page ressemble à un pavé « tout en gras ».
///
/// Stratégie :
/// - on isole chaque `# Titre` inline et on coupe le titre au premier `.`,
///   `:`, ou sinon après ~80 caractères (titres courts par convention) ;
/// - on insère des sauts autour des fences ``` ;
/// - on remet les listes numérotées / à puces sur leur propre ligne.
/// Idempotent.
String expandFlattenedMarkdown(String input) {
  if (input.isEmpty) return input;
  var text = input.replaceAll('\r\n', '\n');

  // ---- Fences ``` ```
  // Ouverture : injecter un saut avant + un saut après le nom de langage.
  text = text.replaceAllMapped(
    RegExp(r'(^|[^\n])\s*```([a-zA-Z0-9_-]*)\s*'),
    (m) {
      final prefix = m.group(1) ?? '';
      final lang = m.group(2) ?? '';
      final sep = prefix.isEmpty ? '' : '\n\n';
      return '$prefix$sep```$lang\n';
    },
  );
  // Fermeture orpheline sans saut autour.
  text = text.replaceAllMapped(
    RegExp(r'([^\n])\s*```(\s|$)'),
    (m) => '${m.group(1)}\n```\n\n',
  );

  // ---- Titres ATX inline : `## Titre Body body body…`
  text = text.replaceAllMapped(
    RegExp(r'(^|[^\n])\s*(#{1,6})\s+([^\n]+)'),
    (m) {
      final prefix = m.group(1) ?? '';
      final hashes = m.group(2) ?? '';
      final body = m.group(3) ?? '';
      final cut = _findHeadingBoundary(body);
      final heading = body.substring(0, cut).trimRight();
      final rest = body.substring(cut).trimLeft();
      final leading = prefix.isEmpty ? '' : '\n\n';
      return rest.isEmpty
          ? '$prefix$leading$hashes $heading'
          : '$prefix$leading$hashes $heading\n\n$rest';
    },
  );

  // ---- Listes ordonnées : « 1. foo 2. bar 3. baz »
  text = text.replaceAllMapped(
    RegExp(r'([^\n])\s+(\d+)\.\s+'),
    (m) => '${m.group(1)}\n${m.group(2)}. ',
  );
  // ---- Puces « - » / « • » / « * » séparées par un simple espace.
  // On exige que le marqueur soit précédé d'une ponctuation ou d'un chiffre
  // (pour ne pas casser les mots composés « cross-site », « multi-tenant »).
  text = text.replaceAllMapped(
    RegExp(r'([.:;)\]])\s+([•\-*])\s+'),
    (m) => '${m.group(1)}\n${m.group(2)} ',
  );
  // Bullet unicode précédé d'espace : toujours sûr.
  text = text.replaceAllMapped(
    RegExp(r'([^\n])\s+•\s+'),
    (m) => '${m.group(1)}\n• ',
  );

  // Compression finale : jamais plus de 2 sauts successifs.
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text.trim();
}

/// Trouve où couper un titre inline. Trois tentatives, par ordre de
/// confiance :
///   1. run de mots Title-Case / acronymes jusqu'au premier mot lowercase
///      (convention : un titre est en Casse Titre, le paragraphe qui suit
///      commence par un mot lowercase ou un nom propre composé) ;
///   2. premier `. ` ou `: ` dans les 80 premiers caractères ;
///   3. corps court ≤ 60 chars → c'est tout le titre ;
///   4. fallback : 1er espace entre le 30e et le 70e caractère.
int _findHeadingBoundary(String body) {
  final titleRun = RegExp(
    r'^((?:[A-Z][\w./\-]{1,}|[A-Z]{2,})'
    r'(?:\s+(?:[A-Z][\w./\-]{1,}|[A-Z]{2,}|of|for|and|the|in|on|to|&|vs\.?))*)',
  ).firstMatch(body);
  if (titleRun != null) {
    final heading = titleRun.group(1)!;
    if (heading.length >= 3 && heading.length <= 60) {
      final endIdx = heading.length;
      if (endIdx == body.length) return endIdx;
      if (body[endIdx] == ' ') {
        final peek = endIdx + 1 < body.length ? body[endIdx + 1] : '';
        final looksLikeParagraph = peek.isEmpty ||
            RegExp(r'[a-z0-9]').hasMatch(peek) ||
            '.(['.contains(peek);
        if (looksLikeParagraph) return endIdx;
      }
    }
  }
  final punc = RegExp(r'[.:]\s').firstMatch(body);
  if (punc != null && punc.start < 80) return punc.start + 1;
  if (body.length <= 60) return body.length;
  final spaceIdx = body.indexOf(' ', 30);
  if (spaceIdx > 0 && spaceIdx <= 70) return spaceIdx;
  return body.length.clamp(0, 60);
}
