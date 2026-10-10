/// Model & data statis koleksi Dzikir Pagi dan Petang
class DzikirItem {
  final String id;
  final String arabic;
  final String latin;
  final String translation;
  final String fadhilah;
  final int count;
  final DzikirType type;

  const DzikirItem({
    required this.id,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.fadhilah,
    required this.count,
    required this.type,
  });
}

enum DzikirType { pagi, petang }

// ─── DZIKIR PAGI ─────────────────────────────────────────────────────────────
const List<DzikirItem> dzikirPagi = [
  DzikirItem(
    id: 'p1',
    arabic:
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    latin:
        "Ashbahnaa wa asbahal mulku lillah, walhamdulillah, laa ilaaha illallah wahdahu laa syariika lah, lahul mulku wa lahul hamdu wa huwa 'ala kulli syai-in qadiir.",
    translation:
        'Kami telah memasuki waktu pagi dan kerajaan hanya milik Allah. Segala puji bagi Allah. Tidak ada ilah yang berhak disembah selain Allah semata, tiada sekutu bagi-Nya. Bagi-Nya kerajaan dan bagi-Nya segala pujian, dan Dia Maha Kuasa atas segala sesuatu.',
    fadhilah:
        'Dibaca setiap pagi, memohon perlindungan dan menetapkan tauhid kepada Allah.',
    count: 1,
    type: DzikirType.pagi,
  ),
  DzikirItem(
    id: 'p2',
    arabic:
        'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
    latin:
        "Allaahumma bika ashbahnaa, wa bika amsaynaa, wa bika nahyaa, wa bika namuutu wa ilaykan-nusyuur.",
    translation:
        'Ya Allah, dengan rahmat dan pertolongan-Mu kami memasuki waktu pagi, dan dengan rahmat dan pertolongan-Mu kami memasuki waktu petang. Dengan kehendak-Mu kami hidup dan dengan kehendak-Mu kami mati. Dan kepada-Mu lah kebangkitan (kami).',
    fadhilah:
        'Dibaca satu kali setiap pagi, menandakan ketergantungan penuh kepada Allah.',
    count: 1,
    type: DzikirType.pagi,
  ),
  DzikirItem(
    id: 'p3',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    latin:
        "Allaahumma anta rabbii laa ilaaha illaa anta, khalaqtanii wa ana 'abduka, wa ana 'alaa 'ahdika wa wa'dika mastatho'tu, a'udzu bika min syarri maa shona'tu, abuu-u laka bini'matika 'alayya, wa abuu-u laka bidzambii faghfir lii fa-innahuu laa yaghfirudz-dzunuuba illaa anta.",
    translation:
        'Ya Allah, Engkau adalah Rabbku. Tidak ada ilah yang berhak disembah selain Engkau. Engkau telah menciptakanku dan aku adalah hamba-Mu. Aku menetapi perjanjian-Mu dan janji-Mu semampuku. Aku berlindung kepada-Mu dari kejelekan perbuatanku. Aku mengakui nikmat-Mu kepadaku dan aku mengakui dosaku. Maka ampunilah aku. Sesungguhnya tidak ada yang mengampuni dosa-dosa selain Engkau.',
    fadhilah:
        'Sayyidul Istighfar. Siapa yang membacanya di pagi hari dengan penuh keyakinan lalu meninggal di hari itu, maka dia termasuk ahli surga. (HR. Bukhari)',
    count: 1,
    type: DzikirType.pagi,
  ),
  DzikirItem(
    id: 'p4',
    arabic:
        'اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ',
    latin:
        "Allaahumma innii ashbahtu usyhiduka, wa usyhidu hamalata 'arsyika, wa malaa-ikataka, wa jamii'a khalqika, annaka antallahu laa ilaaha illaa anta wahdaka laa syariika lak, wa anna muhammadan 'abduka wa rasuuluka.",
    translation:
        'Ya Allah, sesungguhnya aku di waktu pagi mempersaksikan Engkau, malaikat yang memikul arasy-Mu, para malaikat, dan seluruh makhluk-Mu, bahwa sesungguhnya Engkau adalah Allah, tiada ilah yang berhak disembah kecuali Engkau, Yang Maha Esa, tidak ada sekutu bagi-Mu, dan sesungguhnya Muhammad adalah hamba-Mu dan Rasul-Mu.',
    fadhilah:
        'Allah akan membebaskanmu dari api neraka pada hari itu. (HR. Abu Dawud)',
    count: 4,
    type: DzikirType.pagi,
  ),
  DzikirItem(
    id: 'p5',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    latin: 'Subhaanallaahi wa bihamdih.',
    translation: 'Maha Suci Allah dan segala puji bagi-Nya.',
    fadhilah:
        'Siapa yang membacanya 100x di waktu pagi dan petang, tidak ada seorangpun yang datang pada hari kiamat dengan membawa sesuatu yang lebih baik darinya. (HR. Muslim)',
    count: 100,
    type: DzikirType.pagi,
  ),
  DzikirItem(
    id: 'p6',
    arabic:
        'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ',
    latin:
        "Allaahumma 'aafinii fii badanii, allaahumma 'aafinii fii sam'ii, allaahumma 'aafinii fii bashorii, laa ilaaha illaa anta.",
    translation:
        'Ya Allah, selamatkan tubuhku (dari penyakit dan hal yang tidak aku inginkan). Ya Allah, selamatkan pendengaranku. Ya Allah, selamatkan penglihatanku. Tiada ilah yang berhak disembah selain Engkau.',
    fadhilah: 'Dibaca 3x setiap pagi dan petang. (HR. Abu Dawud)',
    count: 3,
    type: DzikirType.pagi,
  ),
  DzikirItem(
    id: 'p7',
    arabic:
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    latin:
        "Bismillaahilladzi laa yadhurru ma'asmihi syai-un fil ardhi wa laa fis-samaa-i wa huwas-samii'ul 'aliim.",
    translation:
        'Dengan nama Allah yang tidak ada sesuatu pun di bumi maupun di langit yang dapat menimbulkan mudarat bersama nama-Nya, dan Dia Maha Mendengar lagi Maha Mengetahui.',
    fadhilah:
        'Siapa yang membacanya tiga kali di waktu pagi, ia tidak akan tertimpa musibah yang tiba-tiba hingga petang. (HR. Abu Dawud, Tirmidzi)',
    count: 3,
    type: DzikirType.pagi,
  ),
  DzikirItem(
    id: 'p8',
    arabic:
        'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
    latin:
        "Radhiitu billaahi rabbaa, wa bil-islaami diinaa, wa bi-muhammadin shallallaahu 'alayhi wa sallama nabiyyaa.",
    translation:
        'Aku ridha Allah sebagai Rabbku, Islam sebagai agamaku, dan Muhammad shallallahu alaihi wa sallam sebagai Nabiku.',
    fadhilah:
        'Berhak mendapat ridha Allah. (HR. Ahmad, Abu Dawud, Tirmidzi, Ibnu Majah)',
    count: 3,
    type: DzikirType.pagi,
  ),
];

// ─── DZIKIR PETANG ────────────────────────────────────────────────────────────
const List<DzikirItem> dzikirPetang = [
  DzikirItem(
    id: 'q1',
    arabic:
        'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    latin:
        "Amsaynaa wa amsal mulku lillah, walhamdulillah, laa ilaaha illallah wahdahu laa syariika lah, lahul mulku wa lahul hamdu wa huwa 'ala kulli syai-in qadiir.",
    translation:
        'Kami telah memasuki waktu petang dan kerajaan hanya milik Allah. Segala puji bagi Allah. Tidak ada ilah yang berhak disembah selain Allah semata, tiada sekutu bagi-Nya. Bagi-Nya kerajaan dan bagi-Nya segala pujian, dan Dia Maha Kuasa atas segala sesuatu.',
    fadhilah: 'Bacaan pokok petang hari, menetapkan tauhid kepada Allah.',
    count: 1,
    type: DzikirType.petang,
  ),
  DzikirItem(
    id: 'q2',
    arabic:
        'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
    latin:
        "Allaahumma bika amsaynaa, wa bika ashbahnaa, wa bika nahyaa, wa bika namuutu wa ilaykal-mashiir.",
    translation:
        'Ya Allah, dengan rahmat dan pertolongan-Mu kami memasuki waktu petang, dan dengan rahmat serta pertolongan-Mu kami memasuki waktu pagi. Dengan kehendak-Mu kami hidup dan dengan kehendak-Mu kami mati. Dan hanya kepada-Mu lah tempat kembali (kami).',
    fadhilah: 'Dibaca satu kali setiap petang. (HR. Tirmidzi)',
    count: 1,
    type: DzikirType.petang,
  ),
  DzikirItem(
    id: 'q3',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    latin:
        "Allaahumma anta rabbii laa ilaaha illaa anta, khalaqtanii wa ana 'abduka, wa ana 'alaa 'ahdika wa wa'dika mastatho'tu, a'udzu bika min syarri maa shona'tu, abuu-u laka bini'matika 'alayya, wa abuu-u laka bidzambii faghfir lii fa-innahuu laa yaghfirudz-dzunuuba illaa anta.",
    translation:
        'Ya Allah, Engkau adalah Rabbku. Tidak ada ilah yang berhak disembah selain Engkau. Engkau telah menciptakanku dan aku adalah hamba-Mu. Aku menetapi perjanjian-Mu dan janji-Mu semampuku. Aku berlindung kepada-Mu dari kejelekan perbuatanku. Aku mengakui nikmat-Mu kepadaku dan aku mengakui dosaku. Maka ampunilah aku. Sesungguhnya tidak ada yang mengampuni dosa-dosa selain Engkau.',
    fadhilah:
        'Sayyidul Istighfar. Siapa yang membacanya di waktu petang dengan penuh keyakinan lalu meninggal di malam itu, maka dia termasuk ahli surga. (HR. Bukhari)',
    count: 1,
    type: DzikirType.petang,
  ),
  DzikirItem(
    id: 'q4',
    arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    latin: "A'uudzu bikalimaatillaahit-tammaati min syarri maa khalaq.",
    translation:
        'Aku berlindung dengan kalimat-kalimat Allah yang sempurna dari kejahatan makhluk yang diciptakan-Nya.',
    fadhilah:
        'Siapa yang membacanya 3x di waktu petang, tidak ada racun atau binatang berbisa yang membahayakannya malam itu. (HR. Ahmad, Tirmidzi)',
    count: 3,
    type: DzikirType.petang,
  ),
  DzikirItem(
    id: 'q5',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    latin: 'Subhaanallaahi wa bihamdih.',
    translation: 'Maha Suci Allah dan segala puji bagi-Nya.',
    fadhilah:
        'Siapa yang membacanya 100x di waktu pagi dan petang, tidak ada seorangpun yang datang pada hari kiamat dengan membawa sesuatu yang lebih baik darinya. (HR. Muslim)',
    count: 100,
    type: DzikirType.petang,
  ),
  DzikirItem(
    id: 'q6',
    arabic:
        'اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ',
    latin:
        "Allaahumma innii amsaytu usyhiduka, wa usyhidu hamalata 'arsyika, wa malaa-ikataka, wa jamii'a khalqika, annaka antallahu laa ilaaha illaa anta wahdaka laa syariika lak, wa anna muhammadan 'abduka wa rasuuluka.",
    translation:
        'Ya Allah, sesungguhnya aku di waktu petang mempersaksikan Engkau, malaikat yang memikul arasy-Mu, para malaikat, dan seluruh makhluk-Mu, bahwa sesungguhnya Engkau adalah Allah, tiada ilah yang berhak disembah kecuali Engkau, Yang Maha Esa, tidak ada sekutu bagi-Mu, dan sesungguhnya Muhammad adalah hamba-Mu dan Rasul-Mu.',
    fadhilah:
        'Allah akan membebaskanmu dari api neraka pada malam itu. (HR. Abu Dawud)',
    count: 4,
    type: DzikirType.petang,
  ),
  DzikirItem(
    id: 'q7',
    arabic:
        'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ',
    latin:
        "Allaahumma 'aafinii fii badanii, allaahumma 'aafinii fii sam'ii, allaahumma 'aafinii fii bashorii, laa ilaaha illaa anta.",
    translation:
        'Ya Allah, selamatkan tubuhku. Ya Allah, selamatkan pendengaranku. Ya Allah, selamatkan penglihatanku. Tiada ilah yang berhak disembah selain Engkau.',
    fadhilah: 'Dibaca 3x setiap pagi dan petang. (HR. Abu Dawud)',
    count: 3,
    type: DzikirType.petang,
  ),
  DzikirItem(
    id: 'q8',
    arabic:
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالآخِرَةِ',
    latin:
        "Allaahumma innii as-alukal-'afwa wal'aafiyata fid-dunyaa wal-aakhirah.",
    translation:
        'Ya Allah, sesungguhnya aku memohon maaf (ampunan) dan keselamatan di dunia dan akhirat.',
    fadhilah:
        'Nabi tidak pernah meninggalkan doa ini setiap pagi dan petang. (HR. Abu Dawud, Ibnu Majah)',
    count: 1,
    type: DzikirType.petang,
  ),
];
