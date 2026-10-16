// Surah names: Latin transliteration (shared by all languages) and the
// meaning of each name in en / tk / tr / ru. Turkmen meanings are marked
// REVIEW in CLAUDE.md (no authoritative Turkmen Quran translation exists).
// ignore_for_file: lines_longer_than_80_chars

const surahTranslit = <String>[
  'Al-Fatihah', 'Al-Baqarah', "Ali 'Imran", 'An-Nisa', "Al-Ma'idah", "Al-An'am", "Al-A'raf", 'Al-Anfal', 'At-Tawbah', 'Yunus',
  'Hud', 'Yusuf', "Ar-Ra'd", 'Ibrahim', 'Al-Hijr', 'An-Nahl', 'Al-Isra', 'Al-Kahf', 'Maryam', 'Ta-Ha',
  'Al-Anbiya', 'Al-Hajj', "Al-Mu'minun", 'An-Nur', 'Al-Furqan', "Ash-Shu'ara", 'An-Naml', 'Al-Qasas', "Al-'Ankabut", 'Ar-Rum',
  'Luqman', 'As-Sajdah', 'Al-Ahzab', 'Saba', 'Fatir', 'Ya-Sin', 'As-Saffat', 'Sad', 'Az-Zumar', 'Ghafir',
  'Fussilat', 'Ash-Shura', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jathiyah', 'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf',
  'Adh-Dhariyat', 'At-Tur', 'An-Najm', 'Al-Qamar', 'Ar-Rahman', "Al-Waqi'ah", 'Al-Hadid', 'Al-Mujadilah', 'Al-Hashr', 'Al-Mumtahanah',
  'As-Saff', "Al-Jumu'ah", 'Al-Munafiqun', 'At-Taghabun', 'At-Talaq', 'At-Tahrim', 'Al-Mulk', 'Al-Qalam', 'Al-Haqqah', "Al-Ma'arij",
  'Nuh', 'Al-Jinn', 'Al-Muzzammil', 'Al-Muddaththir', 'Al-Qiyamah', 'Al-Insan', 'Al-Mursalat', "An-Naba'", "An-Nazi'at", "'Abasa",
  'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin', 'Al-Inshiqaq', 'Al-Buruj', 'At-Tariq', "Al-A'la", 'Al-Ghashiyah', 'Al-Fajr', 'Al-Balad',
  'Ash-Shams', 'Al-Layl', 'Ad-Duha', 'Ash-Sharh', 'At-Tin', "Al-'Alaq", 'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah', "Al-'Adiyat",
  "Al-Qari'ah", 'At-Takathur', "Al-'Asr", 'Al-Humazah', 'Al-Fil', 'Quraysh', "Al-Ma'un", 'Al-Kawthar', 'Al-Kafirun', 'An-Nasr',
  'Al-Masad', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas',
];

const _en = <String>[
  'The Opening', 'The Cow', 'Family of Imran', 'The Women', 'The Table Spread', 'The Cattle', 'The Heights', 'The Spoils of War', 'The Repentance', 'Jonah',
  'Hud', 'Joseph', 'The Thunder', 'Abraham', 'The Rocky Tract', 'The Bee', 'The Night Journey', 'The Cave', 'Mary', 'Ta-Ha',
  'The Prophets', 'The Pilgrimage', 'The Believers', 'The Light', 'The Criterion', 'The Poets', 'The Ant', 'The Stories', 'The Spider', 'The Romans',
  'Luqman', 'The Prostration', 'The Combined Forces', 'Sheba', 'The Originator', 'Ya-Sin', 'Those Ranged in Ranks', 'Sad', 'The Troops', 'The Forgiver',
  'Explained in Detail', 'The Consultation', 'Ornaments of Gold', 'The Smoke', 'The Kneeling', 'The Sand Dunes', 'Muhammad', 'The Victory', 'The Rooms', 'Qaf',
  'The Winnowing Winds', 'The Mount', 'The Star', 'The Moon', 'The Most Merciful', 'The Inevitable', 'The Iron', 'The Pleading Woman', 'The Exile', 'The Woman Examined',
  'The Ranks', 'Friday', 'The Hypocrites', 'Mutual Loss and Gain', 'The Divorce', 'The Prohibition', 'The Sovereignty', 'The Pen', 'The Reality', 'The Ascending Stairways',
  'Noah', 'The Jinn', 'The Enwrapped One', 'The Cloaked One', 'The Resurrection', 'The Human', 'Those Sent Forth', 'The Great News', 'Those Who Pull Out', 'He Frowned',
  'The Folding Up', 'The Cleaving', 'The Defrauders', 'The Splitting Open', 'The Constellations', 'The Night Star', 'The Most High', 'The Overwhelming', 'The Dawn', 'The City',
  'The Sun', 'The Night', 'The Morning Light', 'The Relief', 'The Fig', 'The Clinging Clot', 'The Night of Power', 'The Clear Proof', 'The Earthquake', 'The Chargers',
  'The Striking Calamity', 'Competition in Increase', 'Time', 'The Slanderer', 'The Elephant', 'Quraysh', 'Small Kindnesses', 'Abundance', 'The Disbelievers', 'The Help',
  'The Palm Fibre', 'Sincerity', 'The Daybreak', 'Mankind',
];

const _tk = <String>[
  'Açyş', 'Sygyr', 'Ymranyň maşgalasy', 'Aýallar', 'Saçak', 'Mallar', 'Belentlikler', 'Oljalar', 'Toba', 'Ýunus',
  'Hud', 'Ýusup', 'Gök gürlemesi', 'Ybraýym', 'Hijr', 'Ary', 'Gijeki syýahat', 'Gowak', 'Merýem', 'Taha',
  'Pygamberler', 'Haj', 'Möminler', 'Nur', 'Aýyryjy', 'Şahyrlar', 'Garynjalar', 'Kyssalar', 'Möý', 'Rumlar',
  'Lukman', 'Sežde', 'Birleşen toparlar', 'Saba', 'Ýaradyjy', 'Ýasin', 'Hatar duranlar', 'Sad', 'Topar-topar', 'Bagyşlaýjy',
  'Düşündirilen', 'Maslahat', 'Altyn bezegler', 'Tüsse', 'Dyza çökenler', 'Çäge depeleri', 'Muhammet', 'Ýeňiş', 'Otaglar', 'Kaf',
  'Sowurýan şemallar', 'Tur dagy', 'Ýyldyz', 'Aý', 'Rahman', 'Bolmaly waka', 'Demir', 'Jedelleşýän aýal', 'Sürgün', 'Synalýan aýal',
  'Hatar', 'Anna', 'Münafyklar', 'Aldanyş', 'Talak', 'Gadagan etmek', 'Mülk', 'Galam', 'Hakykat', 'Basgançaklar',
  'Nuh', 'Jynlar', 'Bürenen', 'Örtünen', 'Kyýamat', 'Ynsan', 'Iberilenler', 'Beýik habar', 'Sogrup alýanlar', 'Gaşyny çytdy',
  'Düýrülmek', 'Ýarylmak', 'Ölçegde aldaýanlar', 'Açylmak', 'Burçlar', 'Gijeki ýyldyz', 'Iň Beýik', 'Gurşap alýan', 'Daň', 'Şäher',
  'Gün', 'Gije', 'Irdenki ýagtylyk', 'Göwnüňi açmak', 'Injir', 'Laýta gan', 'Kadyr gijesi', 'Aýdyň delil', 'Ýer titremesi', 'Çapýan atlar',
  'Uly betbagtçylyk', 'Köpeltmek ýaryşy', 'Zaman', 'Gybatçy', 'Pil', 'Kureýş', 'Kiçijik ýagşylyklar', 'Bolluk', 'Kapyrlar', 'Kömek',
  'Hurma süýümi', 'Yhlas', 'Daň ýagtysy', 'Adamlar',
];

const _tr = <String>[
  'Açılış', 'İnek', 'İmran Ailesi', 'Kadınlar', 'Sofra', 'Davarlar', 'Yüksek Yerler', 'Ganimetler', 'Tövbe', 'Yunus',
  'Hûd', 'Yusuf', 'Gök Gürültüsü', 'İbrahim', 'Hicr', 'Bal Arısı', 'Gece Yolculuğu', 'Mağara', 'Meryem', 'Tâ-Hâ',
  'Peygamberler', 'Hac', 'Müminler', 'Nur', 'Ayırt Edici', 'Şairler', 'Karıncalar', 'Kıssalar', 'Örümcek', 'Rumlar',
  'Lokman', 'Secde', 'Gruplar', 'Sebe', 'Yaratan', 'Yâsîn', 'Saf Duranlar', 'Sâd', 'Zümreler', 'Bağışlayan',
  'Açıklanmış', 'Danışma', 'Altın Süsler', 'Duman', 'Diz Çökenler', 'Kum Tepeleri', 'Muhammed', 'Fetih', 'Odalar', 'Kâf',
  'Savuranlar', 'Tûr Dağı', 'Yıldız', 'Ay', 'Rahmân', 'Olay', 'Demir', 'Tartışan Kadın', 'Sürgün', 'İmtihan Edilen Kadın',
  'Saf', 'Cuma', 'Münafıklar', 'Aldanış', 'Boşanma', 'Yasaklama', 'Mülk', 'Kalem', 'Gerçek Olay', 'Yükselme Yolları',
  'Nuh', 'Cinler', 'Örtünen', 'Bürünen', 'Kıyamet', 'İnsan', 'Gönderilenler', 'Haber', 'Söküp Çıkaranlar', 'Yüzünü Ekşitti',
  'Dürülme', 'Yarılma', 'Ölçüde Hile Yapanlar', 'Çatlama', 'Burçlar', 'Gece Gelen', 'En Yüce', 'Kuşatan', 'Tan Vakti', 'Şehir',
  'Güneş', 'Gece', 'Kuşluk Vakti', 'Göğüs Açma', 'İncir', 'Alak', 'Kadir', 'Apaçık Delil', 'Deprem', 'Koşan Atlar',
  'Büyük Felaket', 'Çokluk Yarışı', 'Asır', 'Dedikoducu', 'Fil', 'Kureyş', 'Yardım', 'Bol Nimet', 'Kâfirler', 'Zafer',
  'Hurma Lifi', 'İhlas', 'Sabah Aydınlığı', 'İnsanlar',
];

const _ru = <String>[
  'Открывающая', 'Корова', 'Семейство Имрана', 'Женщины', 'Трапеза', 'Скот', 'Преграды', 'Трофеи', 'Покаяние', 'Юнус',
  'Худ', 'Юсуф', 'Гром', 'Ибрахим', 'Аль-Хиджр', 'Пчёлы', 'Ночной перенос', 'Пещера', 'Марьям', 'Та Ха',
  'Пророки', 'Хадж', 'Верующие', 'Свет', 'Различение', 'Поэты', 'Муравьи', 'Рассказ', 'Паук', 'Римляне',
  'Лукман', 'Земной поклон', 'Союзники', 'Саба', 'Творец', 'Йа Син', 'Выстроившиеся в ряды', 'Сад', 'Толпы', 'Прощающий',
  'Разъяснены', 'Совет', 'Украшения', 'Дым', 'Коленопреклонённые', 'Барханы', 'Мухаммад', 'Победа', 'Комнаты', 'Каф',
  'Рассеивающие', 'Гора', 'Звезда', 'Месяц', 'Милостивый', 'Падающее', 'Железо', 'Препирающаяся', 'Сбор', 'Испытуемая',
  'Ряды', 'Пятница', 'Лицемеры', 'Взаимное обделение', 'Развод', 'Запрещение', 'Власть', 'Письменная трость', 'Неизбежное', 'Ступени',
  'Нух', 'Джинны', 'Закутавшийся', 'Завернувшийся', 'Воскресение', 'Человек', 'Посылаемые', 'Весть', 'Вырывающие', 'Нахмурился',
  'Скручивание', 'Раскалывание', 'Обвешивающие', 'Разверзнется', 'Созвездия', 'Ночной путник', 'Высочайший', 'Покрывающее', 'Заря', 'Город',
  'Солнце', 'Ночь', 'Утро', 'Раскрытие', 'Смоковница', 'Сгусток', 'Предопределение', 'Ясное знамение', 'Землетрясение', 'Мчащиеся',
  'Великое бедствие', 'Страсть к приумножению', 'Предвечернее время', 'Хулитель', 'Слон', 'Курайшиты', 'Мелочь', 'Изобилие', 'Неверующие', 'Помощь',
  'Пальмовые волокна', 'Искренность', 'Рассвет', 'Люди',
];

/// Meaning of surah [number] (1-based) in [language] (falls back to English).
String surahMeaning(int number, String language) {
  final list = switch (language) {
    'tk' => _tk,
    'tr' => _tr,
    'ru' => _ru,
    _ => _en,
  };
  return list[number - 1];
}
