#!/usr/bin/env raku

=begin pod

=head1 Sanskrit Transliteration Example

Demonstrates transliteration of Sanskrit text using the IAST
(International Alphabet of Sanskrit Transliteration) standard.

=end pod

use lib 'lib';
use Lang::Transliterate;
use Lang::Transliterate::Sa::IAST;

# Create the IAST transliterator
my $iast = Lang::Transliterate::Sa::IAST.new;

say "=" x 80;
say "SANSKRIT TRANSLITERATION - IAST STANDARD";
say "=" x 80;
say "";

# The Sanskrit phrase to transliterate
my $sanskrit-phrase = "नमस्कार सर्वेभ्यः";

say "Original Sanskrit (Devanagari script):";
say "  $sanskrit-phrase";
say "";
say "Meaning: Greetings to all";
say "";

# Transliterate to Latin script
my $transliterated = transliterate($sanskrit-phrase, $iast);

say "IAST Transliteration (Latin script):";
say "  $transliterated";
say "";

say "=" x 80;
say "CHARACTER-BY-CHARACTER BREAKDOWN";
say "=" x 80;
say "";

# Get the character mappings
my %mappings = $iast.get-mappings();

# Analyze each character
my @chars = $sanskrit-phrase.comb;
say "Input has {+@chars} characters";
say "";

for @chars.kv -> $i, $char {
    my $unicode = $char.ord.fmt("U+%04X");
    my $mapped = %mappings{$char} // '(no direct mapping - may be combined)';
    
    my $name = do given $unicode {
        when 'U+0928' { 'na (dental n)' }
        when 'U+092E' { 'ma' }
        when 'U+0938' { 'sa' }
        when 'U+094D' { 'virama (vowel suppressor)' }
        when 'U+0915' { 'ka' }
        when 'U+093E' { 'aa (long a vowel mark)' }
        when 'U+0930' { 'ra' }
        when 'U+0020' { 'space' }
        when 'U+0935' { 'va' }
        when 'U+0947' { 'e (vowel mark)' }
        when 'U+092D' { 'bha' }
        when 'U+092F' { 'ya' }
        when 'U+0903' { 'visarga (aspiration)' }
        default { 'unknown Devanagari character' }
    };
    
    say "  [$i] '$char' ($unicode) - $name → '$mapped'";
}

say "";
say "=" x 80;
say "MORE SANSKRIT EXAMPLES";
say "=" x 80;
say "";

# Additional examples
my @examples = (
    { devanagari => 'नमस्ते', meaning => 'Greetings/Hello' },
    { devanagari => 'भगवद्गीता', meaning => 'Bhagavad Gita (The Divine Song)' },
    { devanagari => 'योग', meaning => 'Yoga' },
    { devanagari => 'कर्म', meaning => 'Karma (Action)' },
    { devanagari => 'धर्म', meaning => 'Dharma (Righteousness)' },
    { devanagari => 'संस्कृत', meaning => 'Sanskrit' },
    { devanagari => 'वेद', meaning => 'Veda (Knowledge)' },
    { devanagari => 'शान्ति', meaning => 'Shanti (Peace)' },
);

say "Sanskrit Word".fmt("%-20s") ~ " │ " ~ "IAST".fmt("%-20s") ~ " │ " ~ "Meaning";
say "─" x 20 ~ "─┼─" ~ "─" x 20 ~ "─┼─" ~ "─" x 30;

for @examples -> %example {
    my $trans = transliterate(%example<devanagari>, $iast);
    say %example<devanagari>.fmt("%-20s") ~ " │ " ~ 
        $trans.fmt("%-20s") ~ " │ " ~ 
        %example<meaning>;
}

say "";
say "=" x 80;
say "BIDIRECTIONAL CONVERSION";
say "=" x 80;
say "";

say "Testing round-trip conversion (Sanskrit → Latin → Sanskrit):";
say "";

my $original = "योग";
say "Original:        $original";

my $romanized = transliterate($original, $iast);
say "Romanized:       $romanized";

my $back = detransliterate($romanized, $iast);
say "Back to script:  $back";
say "";

if $original eq $back {
    say "✓ Round-trip successful!";
} else {
    say "✗ Round-trip differs (this is common with complex diacritics)";
}

say "";
say "=" x 80;
say "ABOUT IAST (International Alphabet of Sanskrit Transliteration)";
say "=" x 80;
say "";
say "IAST is the most widely used standard for romanizing Sanskrit.";
say "";
say "Key features:";
say "  • Uses diacritical marks for precise phonetic representation";
say "  • Macrons for long vowels: ā, ī, ū";
say "  • Dot-under for retroflex consonants: ṭ, ḍ, ṇ, ṣ";
say "  • Dot-above for anusvara: ṃ";
say "  • Underdot for vocalic r: ṛ, ṝ";
say "  • Tilde for palatal nasal: ñ";
say "  • Acute accent for palatal sibilant: ś";
say "";
say "This makes IAST ideal for:";
say "  • Academic publications";
say "  • Linguistic analysis";
say "  • Scholarly editions of texts";
say "  • Unambiguous representation of Sanskrit phonology";
say "";
