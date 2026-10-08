<?php

namespace Database\Seeders\Quran\Dua;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DuaSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $enShortName = [
            //---> 1
            "For a Happy Family",
            //---> 2
            "After salam",
            //---> 3
            "After the last tashahhud and before salam",
            //---> 4
            "At the start of the prayer (after takbeer)",
            //---> 5
            "Be among the Righteous",
            //---> 6
            "Before eating",
            //---> 7
            "Before going to the bathroom",
            //---> 8
            "Between Takbir for prayer and start reading Fatiha",
            //---> 9
            "Between the two prostrations",
            //---> 10
            "Concerning the athan (the call to prayer)",
            //---> 11
            "Condolence",
            //---> 12
            "Confirmation of Faith",
            //---> 13
            "Dua e qunoot",
            //---> 14
            "Dua Prayer at the End of the Fast",
            //---> 15
            "For Acceptance",
            //---> 16
            "For good health",
            //---> 17
            "For Guidance and Mercy",
            //---> 18
            "Upon entering the mosque",
            //---> 19
            "Upon entering the mosque",
            //---> 20
            "When going to sleep",
            //---> 21
            "When waking up",

            //
        ];

        $arShortName = [
            //---> 1
            "للسعادة العائلية",
            //---> 2
            "بعد السلام",
            //---> 3
            "بعد التشهد الاخير وقبل",
            //---> 4
            "في بداية الصلاة بعد التكبير",
            //---> 5
            "لتكون من الأبرار",
            //---> 6
            "قبل الأكل",
            //---> 7
            "قبل الذهاب إلى الحمام",
            //---> 8
            "في بداية الصلاة",
            //---> 9
            "بين السجدتين",
            //---> 10
            "بعد الآذان",
            //---> 11
            "في العزاء",
            //---> 12
            "تأكيد الإيمان",
            //---> 13
            "القنوت",
            //---> 14
            "الإفطار",
            //---> 15
            "التقبل",
            //---> 16
            "لصحة جيدة",
            //---> 17
            "للهداية وطلب الرحمة",
            //---> 18
            "عند دخول المسجد",
            //---> 19
            "عند دخول المسجد",
            //---> 20
            "عند النوم",
            //---> 21
            "عند الاستيقاظ",
        ];

        $enFullName = [
            //---> 1
            "Our Lord, grant us from among our wives and offspring comfort to our eyes and make us an example for the righteous.",
            //---> 2
            "O Allah I ask for your forgiveness, O Allah I ask for your forgiveness, O Allah I ask for your forgiveness. You are the embodiment of Peace and from You is all peace, blessed are You, O Possessor of majesty and honour.",
            //---> 3
            "O Allah, I take refuge in You from the punishment of the grave, from the torment of the Fire, from the trials and tribulations of life and death and from the evil affliction of Al-Maseeh Ad-Dajjal.",
            //---> 4
            "How perfect You are O Allah, and I praise You. Blessed be Your name, and lofty is Your position and none has the right to be worshipped except You.",
            //---> 5
            "Our Lord! Forgive us our sins, wipe out our bad deeds, and grant that we join the righteous when we die.",
            //---> 6
            "In the name of Allah and with the blessings of Allah I begin (eating).",
            //---> 7
            "O Allah, I take refuge with you from all evil and evil-doers.",
            //---> 8
            "O Allah, distance me from my sins just as You have distanced The East from The West, O Allah, purify me of my sins as a white robe is purified of filth, O Allah, cleanse me of my sins with snow, water, and ice.",
            //---> 9
            "My Lord forgive me, My Lord forgive me.",
            //---> 10
            "O Allah, Owner of this perfect call and Owner of this prayer to be performed, bestow upon Muhammad al-waseelah and al-fadeelah and send him upon a praised platform which You have promised him.",
            //---> 11
            "Verily to Allah, belongs what He took and to Him belongs what He gave, and everything with Him has an appointed time…and then he r ordered for her to be patient and hope for Allah’s reward.(May Allah magnify your reward, make better your solace and forgive your deceased.)",
            //---> 12
            "Our Lord, we have believed in what You revealed and have followed the messenger Jesus, so register us among the witnesses [to truth].",
            //---> 13
            "O Allah! We beg help from You alone; ask forgiveness from You alone, and turn towards You and praise You for all the good things and are grateful to You and are not ungrateful to You and we part and break off with all those who are disobedient to you. O Allah! You alone do we worship and pray exclusively to You and bow before You alone and we hasten eagerly towards You and we fear Your severe punishment and hope for Your Mercy as your severe punishment is surely to be meted out to the unbelievers.",
            //---> 14
            "O Allah! I fasted for You and I believe in You and I put my trust in You and I break my fast with Your sustenance",
            //---> 15
            "Our Lord, accept [this] from us. Indeed You are the Hearing, the Knowing.",
            //---> 16
            "O Allah! Grant me health in my body. O Allah! Grant me good hearing. O Allah! Grant me good eyesight. There is no god but Thou.",
            //---> 17
            "Our Lord, grant us from Yourself mercy and prepare for us from our affair right guidance.",
            //---> 18
            "I take refuge with Allah, The Supreme and with His Noble Face, and His eternal authority from the accursed devil. In the name of Allah, and prayers and peace be upon the Messenger of Allah. O Allah, open the gates of Your mercy for me.",
            //---> 19
            "I take refuge with Allah, The Supreme and with His Noble Face, and His eternal authority from the accursed devil. In the name of Allah, and prayers and peace be upon the Messenger of Allah. O Allah, open the gates of Your mercy for me.",
            //---> 20
            "In Your name my Lord, I lie down and in Your name I rise, so if You should take my soul then have mercy upon it, and if You should return my soul then protect it in the manner You do so with Your righteous servants.",
            //---> 21
            "All praise is for Allah who gave us life after having taken it from us and unto Him is the resurrection.",
        ];

        $arFullName = [
            //---> 1
            "رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا",

            //---> 2
            "أَسْـتَغْفِرُ الله، أَسْـتَغْفِرُ الله، أَسْـتَغْفِرُ الله .اللّهُـمَّ أَنْـتَ السَّلامُ ، وَمِـنْكَ السَّلام ، تَبارَكْتَ يا ذا الجَـلالِ وَالإِكْـرام",

            //---> 3
            "اللّهُـمَّ إِنِّـي أَعـوذُ بِكَ مِـنْ عَذابِ القَـبْر، وَمِـنْ عَذابِ جَهَـنَّم، وَمِـنْ فِتْـنَةِ المَحْـيا وَالمَمـات، وَمِـنْ شَـرِّ فِتْـنَةِ المَسيحِ الدَّجّال",
            //---> 4
            "سُبْـحانَكَ اللّهُـمَّ وَبِحَمْـدِكَ وَتَبارَكَ اسْمُـكَ وَتَعـالى جَـدُّكَ وَلا إِلهَ غَيْرُك",
            //---> 5
            "رَبَّنَا فَاغْفِرْ لَنَا ذُنُوبَنَا وَكَفِّرْ عَنَّا سَيِّئَاتِنَا وَتَوَفَّنَا مَعَ الأبْرَارِ",
            //---> 6
            "بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ",
            //---> 7
            "اللَّهُـمَّ إِنِّي أَعُـوذُ بِـكَ مِـنَ الْخُـبْثِ وَالْخَبَائِثِ.",
            //---> 8
            "اللّهُـمَّ باعِـدْ بَيـني وَبَيْنَ خَطـايايَ كَما باعَدْتَ بَيْنَ المَشْرِقِ وَالمَغْرِبْ ، اللّهُـمَّ نَقِّنـي مِنْ خَطايايَ كَمـا يُـنَقَّى الثَّـوْبُ الأَبْيَضُ مِنَ الدَّنَسْ ، اللّهُـمَّ اغْسِلْنـي مِنْ خَطايـايَ بِالثَّلـجِ وَالمـاءِ وَالْبَرَدْ",
            //---> 9
            "رَبِّ اغْفِـرْ لي ، رَبِّ اغْفِـرْ لي",
            //---> 10
            "اللّهُـمَّ رَبَّ هَذِهِ الدّعْـوَةِ التّـامَّة وَالصّلاةِ القَـائِمَة آتِ محَـمَّداً الوَسيـلةَ وَالْفَضـيلَة وَابْعَـثْه مَقـامـاً مَحـموداً الَّذي وَعَـدْتَه",
            //---> 11
            "إِنَّ للهِ ما أَخَذ، وَلَهُ ما أَعْـطـى، وَكُـلُّ شَيءٍ عِنْـدَهُ بِأَجَلٍ مُسَـمَّى.فَلْتَصْـبِر وَلْتَحْـتَسِب. أَعْظَـمَ اللهُ أَجْـرَك، وَأَحْسَـنَ عَـزاءَ ك، وَغَفَـرَ لِمَـيِّتِك",
            //---> 12
            "رَبَّنَا آمَنَّا بِمَا أَنزَلَتْ وَاتَّبَعْنَا الرَّسُولَ فَاكْتُبْنَا مَعَ الشَّاهِدِينَ",
            //---> 13
            "اَللَّهُمَّ إنا نَسْتَعِينُكَ وَنَسْتَغْفِرُكَ وَنُؤْمِنُ بِكَ وَنَتَوَكَّلُ عَلَيْكَ وَنُثْنِئْ عَلَيْكَ الخَيْرَ وَنَشْكُرُكَ وَلَا نَكْفُرُكَ وَنَخْلَعُ وَنَتْرُكُ مَنْ ئَّفْجُرُكَ اَللَّهُمَّ إِيَّاكَ نَعْبُدُ وَلَكَ نُصَلِّئ وَنَسْجُدُ وَإِلَيْكَ نَسْعأئ وَنَحْفِدُ وَنَرْجُو رَحْمَتَكَ وَنَخْشآئ عَذَابَكَ إِنَّ عَذَابَكَ بِالكُفَّارِ مُلْحَقٌ",
            //---> 14
            "اللَّهُمَّ لَكَ صُمْتُ وَبِكَ آمنْتُ وَعَليْكَ تَوَكّلتُ وَ عَلى رِزْقِكَ أَفْطَرْتُ",
            //---> 15
            "رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنتَ السَّمِيعُ الْعَلِيمُ",
            //---> 16
            "اللَّهُمَّ عَافِنِي فِي بَدَنِي اللَّهُمَّ عَافِنِي فِي سَمْعِي اللَّهُمَّ عَافِنِي فِي بَصَرِي لاَ إِلَهَ إِلاَّ أَنْتَ",
            //---> 17
            "رَبَّنَا آتِنَا مِن لَّدُنكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا",
            //---> 18
            "أَعوذُ باللهِ العَظيـم وَبِوَجْهِـهِ الكَرِيـم وَسُلْطـانِه القَديـم مِنَ الشّيْـطانِ الرَّجـيم،[ بِسْـمِ الله، وَالصَّلاةُ وَالسَّلامُ عَلى رَسولِ الله]، اللّهُـمَّ افْتَـحْ لي أَبْوابَ رَحْمَتـِك",
            //---> 19
            "أَعوذُ باللهِ العَظيـم وَبِوَجْهِـهِ الكَرِيـم وَسُلْطـانِه القَديـم مِنَ الشّيْـطانِ الرَّجـيم،[ بِسْـمِ الله، وَالصَّلاةُ وَالسَّلامُ عَلى رَسولِ الله]، اللّهُـمَّ افْتَـحْ لي أَبْوابَ رَحْمَتـِك",
            //---> 20
            "بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا، بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ.",
            //---> 21
            "الحَمْـدُ لِلّهِ الّذي أَحْـيانا بَعْـدَ ما أَماتَـنا وَإليه النُّـشور",
        ];


        foreach ($enShortName as $key => $item) {
            \App\Models\Quran\Dua\Dua::create([
                'position' => $key+1,
                'en_short_name' => $enShortName[$key],
                'en_full_name' => $enFullName[$key],
                'ar_short_name' => $arShortName[$key],
                'ar_full_name' => $arFullName[$key],
            ]);
        }
    }
}
