#!/usr/bin/env raku

=begin pod

=head1 Arabic Phonetic Transliteration Example

Demonstrates phonetic Arabic transliteration that matches actual recitation/pronunciation.
Tests with Surah Al-Fatiha (The Opening) - the first chapter of the Quran.

=head2 Key Features

- Sun/Moon letter assimilation with definite article (ال)
- Shadda (gemination/doubling) ّ
- Short vowels (fatha, kasra, damma)
- Long vowels (ā, ī, ū)
- Tanween (nunation)
- Proper pronunciation matching Quranic recitation

=end pod

use lib 'lib';
use Lang::Transliterate;
use Lang::Transliterate::Ar::Phonetic;

say "=" x 80;
say "ARABIC PHONETIC TRANSLITERATION - QURANIC RECITATION STYLE";
say "=" x 80;
say "";

# Create phonetic transliterator
my $phonetic = Lang::Transliterate::Ar::Phonetic.new;

say "Testing with example from the problem statement:";
say "";

# Test case from problem statement
my $bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
say "Arabic:  $bismillah";
my $result = transliterate($bismillah, $phonetic);
say "Result:  $result";
say "Expected: bi-smi llāhi r-raḥmāni r-raḥīm";
say "";

say "=" x 80;
say "SURAH AL-FATIHA (THE OPENING) - COMPLETE TRANSLITERATION";
say "=" x 80;
say "";

# Surah Al-Fatiha verses with full diacritics
my @fatiha = (
    {
        verse => 1,
        arabic => 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        meaning => 'In the name of Allah, the Most Gracious, the Most Merciful'
    },
    {
        verse => 2,
        arabic => 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
        meaning => 'All praise is due to Allah, Lord of all the worlds'
    },
    {
        verse => 3,
        arabic => 'ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        meaning => 'The Most Gracious, the Most Merciful'
    },
    {
        verse => 4,
        arabic => 'مَٰلِكِ يَوْمِ ٱلدِّينِ',
        meaning => 'Master of the Day of Judgment'
    },
    {
        verse => 5,
        arabic => 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        meaning => 'You alone we worship, and You alone we ask for help'
    },
    {
        verse => 6,
        arabic => 'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ',
        meaning => 'Guide us to the straight path'
    },
    {
        verse => 7,
        arabic => 'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ',
        meaning => 'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray'
    },
);

for @fatiha -> %verse {
    say "Verse %verse<verse>:";
    say "  Arabic:    %verse<arabic>";
    
    my $transliteration = transliterate(%verse<arabic>, $phonetic);
    say "  Phonetic:  $transliteration";
    say "  Meaning:   %verse<meaning>";
    say "";
}

say "=" x 80;
say "COMPARISON: BASIC vs PHONETIC TRANSLITERATION";
say "=" x 80;
say "";

# Compare with basic ALA-LC transliteration
use Lang::Transliterate::Ar::ALALC;
my $alalc = Lang::Transliterate::Ar::ALALC.new;

my $test-phrase = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
say "Original Arabic:";
say "  $test-phrase";
say "";

my $basic = transliterate($test-phrase, $alalc);
my $phonetic-result = transliterate($test-phrase, $phonetic);

say "Basic (ALA-LC):";
say "  $basic";
say "";

say "Phonetic (Recitation):";
say "  $phonetic-result";
say "";

say "Key Differences:";
say "  1. Article assimilation: 'al-raḥmān' → 'r-raḥmān' (sun letter)";
say "  2. Shadda doubling: 'llāh' shows gemination of lam";
say "  3. Connected pronunciation: 'bi-smi' shows kasra vowel";
say "  4. Matches actual recitation heard in Quran recitation";
say "";

say "=" x 80;
say "ADDITIONAL EXAMPLES";
say "=" x 80;
say "";

my @examples = (
    {
        text => 'ٱلسَّلَامُ عَلَيْكُمْ',
        meaning => 'Peace be upon you'
    },
    {
        text => 'ٱللَّهُ أَكْبَرُ',
        meaning => 'Allah is the Greatest'
    },
    {
        text => 'ٱلشَّمْسُ',
        meaning => 'The sun (sun letter example)'
    },
    {
        text => 'ٱلْقَمَرُ',
        meaning => 'The moon (moon letter example)'
    },
);

for @examples -> %ex {
    say "Arabic:   %ex<text>";
    say "Phonetic: " ~ transliterate(%ex<text>, $phonetic);
    say "Meaning:  %ex<meaning>";
    say "";
}

say "=" x 80;
say "NOTES ON ARABIC PHONETIC TRANSLITERATION";
say "=" x 80;
say "";
say "This transliteration follows Quranic recitation rules:";
say "";
say "1. SUN LETTERS (shamsiyyah): ت ث د ذ ر ز س ش ص ض ط ظ ل ن";
say "   - When preceded by definite article ال, the 'l' assimilates";
say "   - Example: الشَّمْس → ash-shams (not al-shams)";
say "";
say "2. MOON LETTERS (qamariyyah): ا ب ج ح خ ع غ ف ق ك م ه و ي";
say "   - The 'l' in ال remains pronounced";
say "   - Example: الْقَمَر → al-qamar";
say "";
say "3. SHADDA (ّ): Indicates gemination (doubling) of consonant";
say "   - Example: اللَّه → allāh (doubled lam)";
say "";
say "4. SHORT VOWELS:";
say "   - َ (fatha) = a";
say "   - ِ (kasra) = i";
say "   - ُ (damma) = u";
say "";
say "5. LONG VOWELS:";
say "   - َا = ā (fatha + alif)";
say "   - ِي = ī (kasra + ya)";
say "   - ُو = ū (damma + waw)";
say "";
say "6. TANWEEN (nunation):";
say "   - ً = an";
say "   - ٍ = in";
say "   - ٌ = un";
say "";

say "=" x 80;
say "END OF DEMONSTRATION";
say "=" x 80;
