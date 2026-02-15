#!/usr/bin/env raku

=begin pod

=head1 Arabic Transliteration Analysis

This script provides an in-depth analysis of how Arabic transliteration works in the
Lang::Transliterate library, demonstrating all 10 available Arabic transliteration schemes.

=head2 How Transliteration Works

The library uses a character-mapping approach with the following components:

=head3 1. Architecture

The transliteration system is built on several key components:

- B<Transliterator Role>: All transliterators implement the C<Lang::Transliterate::Transliterator> role
- B<Character Mappings>: Each scheme defines a hash mapping source characters to target characters
- B<Context-Aware Processing>: The C<apply-mapping> function processes text intelligently:
  - Tries to match longest sequences first (up to 3 characters)
  - Preserves case for uppercase letters
  - Handles multi-character mappings
- B<Bidirectional Support>: Most schemes support both transliteration and detransliteration

=head3 2. Processing Algorithm

The C<apply-mapping> function works as follows:

1. Splits input text into characters
2. For each position, tries to match sequences of length 3, 2, then 1
3. When a match is found in the mapping hash:
   - Applies the mapped value
   - For uppercase letters with multi-char mappings, intelligently capitalizes
   - Checks context (surrounding characters) to determine capitalization strategy
4. If no match found, keeps the original character
5. Continues to next unmatched position

=head3 3. Character Mapping Example

Each Arabic transliteration scheme maps Unicode Arabic characters to Latin characters.
For example, in ALA-LC:
  - ب (U+0628) → 'b'
  - ت (U+062A) → 't'
  - ث (U+062B) → 'th' (multi-character mapping)
  - ح (U+062D) → 'ḥ' (diacritic)

=head3 4. Differences Between Schemes

Different transliteration schemes use different conventions:

- B<Diacritics>: Some use dots under/over letters (ḥ, ṣ, ṭ), others use different marks
- B<Multi-character representations>: 'th', 'kh', 'sh', 'gh' vs single characters
- B<Special symbols>: Different approaches for hamza (ʼ vs ˈ) and ayn (ʻ vs ʿ)
- B<Academic vs. practical>: Some optimize for readability, others for linguistic precision

=head2 Test Phrase: بسم الله الرحمن الرحيم

This is the Basmala (Bismillah), one of the most important phrases in Arabic.
It means "In the name of Allah, the Most Gracious, the Most Merciful."

Breaking down the phrase:
- بسم (bism) = "in the name"
- الله (Allah) = "God/Allah"
- الرحمن (ar-Rahman) = "the Most Gracious"
- الرحيم (ar-Rahim) = "the Most Merciful"

=end pod

use lib 'lib';
use Lang::Transliterate;

# Import all Arabic transliteration schemes
use Lang::Transliterate::Ar::ALALC;
use Lang::Transliterate::Ar::ArabTeX;
use Lang::Transliterate::Ar::BGNPCGN;
use Lang::Transliterate::Ar::BS;
use Lang::Transliterate::Ar::DIN31635;
use Lang::Transliterate::Ar::EALL;
use Lang::Transliterate::Ar::EI;
use Lang::Transliterate::Ar::ISO233;
use Lang::Transliterate::Ar::UNGEGN;
use Lang::Transliterate::Ar::Wehr;

# The test phrase: "In the name of Allah, the Most Gracious, the Most Merciful"
my $arabic-text = 'بسم الله الرحمن الرحيم';

say "=" x 80;
say "ARABIC TRANSLITERATION ANALYSIS";
say "=" x 80;
say "";
say "Original Arabic Text:";
say "  $arabic-text";
say "";
say "This phrase (Basmala/Bismillah) is one of the most important in Islam.";
say "It means: 'In the name of Allah, the Most Gracious, the Most Merciful'";
say "";

# Define all schemes with descriptions
my @schemes = (
    {
        name => 'ALA-LC',
        class => Lang::Transliterate::Ar::ALALC,
        description => 'American Library Association - Library of Congress romanization standard',
        notes => 'Widely used in libraries; uses special characters like ʼ for hamza and ʻ for ayn'
    },
    {
        name => 'ArabTeX',
        class => Lang::Transliterate::Ar::ArabTeX,
        description => 'ASCII-based transliteration for LaTeX typesetting',
        notes => 'Uses only ASCII characters; popular in academic typesetting'
    },
    {
        name => 'BGN/PCGN',
        class => Lang::Transliterate::Ar::BGNPCGN,
        description => 'US Board on Geographic Names / UK Permanent Committee on Geographical Names',
        notes => 'Official standard for geographic names; prioritizes pronounceability'
    },
    {
        name => 'BS 4280:1968',
        class => Lang::Transliterate::Ar::BS,
        description => 'British Standard for Arabic romanization',
        notes => 'British academic standard; similar to ALA-LC with some variations'
    },
    {
        name => 'DIN 31635',
        class => Lang::Transliterate::Ar::DIN31635,
        description => 'German standard (Deutsche Norm) for Arabic transliteration',
        notes => 'Used in German-speaking countries; distinctive diacritics'
    },
    {
        name => 'EALL',
        class => Lang::Transliterate::Ar::EALL,
        description => 'Encyclopedia of Arabic Language and Linguistics',
        notes => 'Academic linguistic standard; precise phonetic representation'
    },
    {
        name => 'EI',
        class => Lang::Transliterate::Ar::EI,
        description => 'Encyclopaedia of Islam transliteration system',
        notes => 'Scholarly standard for Islamic studies; well-established in academia'
    },
    {
        name => 'ISO 233',
        class => Lang::Transliterate::Ar::ISO233,
        description => 'International Organization for Standardization standard',
        notes => 'International standard; uses unique diacritics like ǧ and ẖ'
    },
    {
        name => 'UNGEGN',
        class => Lang::Transliterate::Ar::UNGEGN,
        description => 'United Nations Group of Experts on Geographical Names',
        notes => 'UN standard for place names; designed for international use'
    },
    {
        name => 'Hans Wehr',
        class => Lang::Transliterate::Ar::Wehr,
        description => 'Hans Wehr Dictionary system (English edition, 1961)',
        notes => 'Very popular among Arabic learners; used in the standard Arabic-English dictionary'
    },
);

say "=" x 80;
say "TRANSLITERATION RESULTS";
say "=" x 80;
say "";

for @schemes -> %scheme {
    my $transliterator = %scheme<class>.new;
    my $result = transliterate($arabic-text, $transliterator);
    
    say "┌" ~ "─" x 78 ~ "┐";
    say "│ %scheme<name>".fmt("%-76s") ~ " │";
    say "├" ~ "─" x 78 ~ "┤";
    say "│ Description: %scheme<description>".fmt("%-76s") ~ " │";
    say "│ Notes: %scheme<notes>".fmt("%-76s") ~ " │";
    say "├" ~ "─" x 78 ~ "┤";
    say "│ Result: $result".fmt("%-76s") ~ " │";
    say "└" ~ "─" x 78 ~ "┘";
    say "";
}

say "=" x 80;
say "COMPARISON TABLE";
say "=" x 80;
say "";

# Print header
say "Scheme".fmt("%-15s") ~ " │ " ~ "Transliteration";
say "─" x 15 ~ "─┼─" ~ "─" x 60;

for @schemes -> %scheme {
    my $transliterator = %scheme<class>.new;
    my $result = transliterate($arabic-text, $transliterator);
    say %scheme<name>.fmt("%-15s") ~ " │ $result";
}

say "";
say "=" x 80;
say "DETAILED CHARACTER-BY-CHARACTER ANALYSIS";
say "=" x 80;
say "";
say "Using ALA-LC as example to show how individual characters are mapped:";
say "";

# Analyze character by character using ALA-LC
my $alalc = Lang::Transliterate::Ar::ALALC.new;
my %mappings = $alalc.get-mappings();

say "Input Phrase: $arabic-text";
say "";
say "Character breakdown:";
my @arabic-chars = $arabic-text.comb;
for @arabic-chars.kv -> $i, $char {
    my $unicode = $char.ord.fmt("U+%04X");
    my $mapped = %mappings{$char} // '(no mapping)';
    my $name = do given $char {
        when 'ب' { 'ba' }
        when 'س' { 'sin' }
        when 'م' { 'mim' }
        when ' ' { 'space' }
        when 'ا' { 'alif' }
        when 'ل' { 'lam' }
        when 'ه' { 'ha' }
        when 'ر' { 'ra' }
        when 'ح' { 'ha (emphatic)' }
        when 'ن' { 'nun' }
        when 'ي' { 'ya' }
        default { 'unknown' }
    };
    
    say "  [$i] '$char' ($unicode) - $name → '$mapped'";
}

say "";
say "=" x 80;
say "KEY OBSERVATIONS";
say "=" x 80;
say "";
say "1. DEFINITE ARTICLE HANDLING:";
say "   - 'ال' (alif-lam) is often rendered as 'al-'";
say "   - Some schemes use different approaches for sun and moon letters";
say "";
say "2. DIACRITICAL MARKS:";
say "   - Different schemes use different diacritics:";
say "     * ALA-LC: ḥ, ṣ, ṭ, ḍ, ẓ";
say "     * ISO 233: ḥ, ṣ, ṭ, ḍ, ẓ, ǧ, ẖ";
say "     * Hans Wehr: ḥ, ṣ, ṭ, ḍ, ẓ, š, ḡ, ḵ, ḏ, ṯ";
say "";
say "3. HAMZA AND AYN:";
say "   - Hamza (ء): Different symbols (ʼ, ˈ, ʾ)";
say "   - Ayn (ع): Different symbols (ʻ, ʿ, ʽ)";
say "";
say "4. READABILITY VS. PRECISION:";
say "   - Some schemes (BGN/PCGN, UNGEGN) prioritize readability";
say "   - Others (EALL, EI) prioritize linguistic precision";
say "";
say "5. VOWEL REPRESENTATION:";
say "   - Short vowels are often not represented without diacritics";
say "   - Long vowels use macrons (ā, ī, ū) in most schemes";
say "";

say "=" x 80;
say "IMPLEMENTATION NOTES";
say "=" x 80;
say "";
say "The transliteration engine:";
say "  1. Processes text character-by-character";
say "  2. Tries to match multi-character sequences first (e.g., 'ال' → 'al-')";
say "  3. Falls back to single-character mappings";
say "  4. Preserves characters not in the mapping table";
say "  5. Intelligently handles case preservation for uppercase text";
say "";
say "Each scheme is defined by:";
say "  - A hash mapping Arabic Unicode characters to Latin equivalents";
say "  - A reverse mapping for detransliteration (where applicable)";
say "  - Context-aware rules for special cases";
say "";

say "=" x 80;
say "END OF ANALYSIS";
say "=" x 80;
