class CrisisHotline {
  const CrisisHotline(this.name, this.number, {this.isText = false});
  final String name;
  final String number;
  final bool isText;
}

class CrisisCountry {
  const CrisisCountry({
    required this.name,
    required this.flag,
    required this.hotlines,
  });
  final String name;
  final String flag;
  final List<CrisisHotline> hotlines;
}

const kCrisisCountries = <CrisisCountry>[
  CrisisCountry(
    name: 'India',
    flag: '🇮🇳',
    hotlines: [
      CrisisHotline('iCall (TISS)', '9152987821'),
      CrisisHotline('Vandrevala Foundation', '18602662345'),
      CrisisHotline('AASRA', '9820466627'),
      CrisisHotline('Fortis Stress Helpline', '8376804102'),
    ],
  ),
  CrisisCountry(
    name: 'United States',
    flag: '🇺🇸',
    hotlines: [
      CrisisHotline('988 Suicide & Crisis Lifeline', '988'),
      CrisisHotline('Crisis Text Line', '741741', isText: true),
      CrisisHotline('SAMHSA Helpline', '18006624357'),
    ],
  ),
  CrisisCountry(
    name: 'United Kingdom',
    flag: '🇬🇧',
    hotlines: [
      CrisisHotline('Samaritans', '116123'),
      CrisisHotline('PAPYRUS (Under 35)', '08000684141'),
      CrisisHotline('Mind Infoline', '03001233393'),
    ],
  ),
  CrisisCountry(
    name: 'Canada',
    flag: '🇨🇦',
    hotlines: [
      CrisisHotline('Talk Suicide Canada', '18334563210'),
      CrisisHotline('Crisis Text Line', '686868', isText: true),
      CrisisHotline('Kids Help Phone', '18006686868'),
    ],
  ),
  CrisisCountry(
    name: 'Australia',
    flag: '🇦🇺',
    hotlines: [
      CrisisHotline('Lifeline Australia', '131114'),
      CrisisHotline('Beyond Blue', '1300224636'),
      CrisisHotline('Kids Helpline', '1800551800'),
    ],
  ),
  CrisisCountry(
    name: 'Ireland',
    flag: '🇮🇪',
    hotlines: [
      CrisisHotline('Samaritans Ireland', '116123'),
      CrisisHotline('Pieta House', '1800247247'),
      CrisisHotline('Text About It', '50808', isText: true),
    ],
  ),
  CrisisCountry(
    name: 'New Zealand',
    flag: '🇳🇿',
    hotlines: [
      CrisisHotline('Lifeline Aotearoa', '0800543354'),
      CrisisHotline('Suicide Crisis Helpline', '0508828865'),
      CrisisHotline('Youthline', '0800376633'),
    ],
  ),
  CrisisCountry(
    name: 'South Africa',
    flag: '🇿🇦',
    hotlines: [
      CrisisHotline('SADAG Helpline', '0800567567'),
      CrisisHotline('Suicide Crisis Line', '0800819198'),
      CrisisHotline('Lifeline', '0861322322'),
    ],
  ),
  CrisisCountry(
    name: 'Germany',
    flag: '🇩🇪',
    hotlines: [
      CrisisHotline('Telefonseelsorge', '08001110111'),
      CrisisHotline('Telefonseelsorge (alt)', '08001110222'),
    ],
  ),
  CrisisCountry(
    name: 'France',
    flag: '🇫🇷',
    hotlines: [
      CrisisHotline('Numéro National Prévention Suicide', '3114'),
      CrisisHotline('SOS Amitié', '0972394050'),
    ],
  ),
  CrisisCountry(
    name: 'Brazil',
    flag: '🇧🇷',
    hotlines: [
      CrisisHotline('CVV (Centro de Valorização da Vida)', '188'),
      CrisisHotline('CVV Chat', '188', isText: true),
    ],
  ),
  CrisisCountry(
    name: 'Pakistan',
    flag: '🇵🇰',
    hotlines: [
      CrisisHotline('Umang Helpline', '03117786264'),
      CrisisHotline('Rozan Counseling', '051111416522'),
    ],
  ),
  CrisisCountry(
    name: 'Bangladesh',
    flag: '🇧🇩',
    hotlines: [
      CrisisHotline('Kaan Pete Roi', '01779554391'),
    ],
  ),
  CrisisCountry(
    name: 'Nigeria',
    flag: '🇳🇬',
    hotlines: [
      CrisisHotline('SURPIN Helpline', '09080217555'),
      CrisisHotline('Mentally Aware Nigeria', '08099999940'),
    ],
  ),
  CrisisCountry(
    name: 'Kenya',
    flag: '🇰🇪',
    hotlines: [
      CrisisHotline('Befrienders Kenya', '0722178177'),
    ],
  ),
  CrisisCountry(
    name: 'Philippines',
    flag: '🇵🇭',
    hotlines: [
      CrisisHotline('NCMH Crisis Hotline', '1553'),
      CrisisHotline('Hopeline', '028804673'),
    ],
  ),
  CrisisCountry(
    name: 'Nepal',
    flag: '🇳🇵',
    hotlines: [
      CrisisHotline('Transcultural Psychosocial Organization', '16600185555'),
    ],
  ),
  CrisisCountry(
    name: 'Sri Lanka',
    flag: '🇱🇰',
    hotlines: [
      CrisisHotline('CCCline', '1333'),
      CrisisHotline('Sumithrayo', '0112696666'),
    ],
  ),
  CrisisCountry(
    name: 'Singapore',
    flag: '🇸🇬',
    hotlines: [
      CrisisHotline('Samaritans of Singapore', '18002214444'),
      CrisisHotline('Crisis Support', '1767'),
    ],
  ),
  CrisisCountry(
    name: 'Mexico',
    flag: '🇲🇽',
    hotlines: [
      CrisisHotline('SAPTEL', '5552595205'),
      CrisisHotline('CONADIC Línea de la Vida', '8008911011'),
    ],
  ),
];
