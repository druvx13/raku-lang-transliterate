# Arabic Transliteration: In-Depth Analysis

This guide provides a comprehensive analysis of how Arabic transliteration works in the Lang::Transliterate library, including detailed explanations of the architecture, algorithms, and all 10 available Arabic transliteration schemes.

## Table of Contents

1. [Introduction](#introduction)
2. [Architecture Overview](#architecture-overview)
3. [How Transliteration Works](#how-transliteration-works)
4. [Available Arabic Schemes](#available-arabic-schemes)
5. [Practical Examples](#practical-examples)
6. [Technical Deep Dive](#technical-deep-dive)

## Introduction

Arabic transliteration is the process of converting Arabic script (Unicode characters in the Arabic block U+0600 to U+06FF) into Latin script. This library supports 10 different internationally-recognized transliteration standards, each with its own conventions and use cases.

### Why Multiple Schemes?

Different transliteration schemes serve different purposes:

- **Academic standards** (ALA-LC, EI, EALL) prioritize linguistic precision for scholarly work
- **Geographic standards** (BGN/PCGN, UNGEGN) optimize for place names and readability
- **National standards** (DIN 31635, BS 4280) serve specific country requirements
- **Technical standards** (ArabTeX) enable ASCII-only representations
- **Practical standards** (Hans Wehr) balance readability with accuracy for language learners

## Architecture Overview

The transliteration system is built on a modular, role-based architecture:

```
Lang::Transliterate (module)
    ├── Transliterator (role)
    │   ├── get-mappings() → Hash
    │   ├── get-reverse-mappings() → List
    │   ├── transliterate-context-aware(Str) → Str
    │   └── detransliterate-context-aware(Str) → Str
    │
    ├── apply-mapping(Str, Hash) → Str  [core algorithm]
    ├── transliterate(Str, Transliterator) → Str  [public API]
    └── detransliterate(Str, Transliterator) → Str  [public API]
```

### Key Components

1. **Transliterator Role**: Defines the interface all transliteration schemes must implement
2. **Character Mappings**: Hash tables mapping source characters to target characters
3. **Apply-Mapping Function**: The core algorithm that processes text intelligently
4. **Context-Aware Processing**: Handles multi-character sequences and case preservation

## How Transliteration Works

### The Algorithm

The `apply-mapping` function implements a greedy, longest-match-first algorithm:

```raku
# Pseudocode representation
for each position in text:
    for length in [3, 2, 1]:  # Try longest matches first
        substring = text[position : position + length]
        
        if substring exists in mapping:
            apply mapping
            handle case preservation
            advance position by length
            continue
        
        if length == 1 and no match:
            preserve original character
            advance position by 1
```

### Step-by-Step Process

Let's trace how the phrase "بسم الله" (bismillah) is transliterated using ALA-LC:

```
Input: بسم الله
Characters: ['ب', 'س', 'م', ' ', 'ا', 'ل', 'ل', 'ه']

Step 1: Position 0, try length 3: 'بسم' → no match
Step 2: Position 0, try length 2: 'بس' → no match
Step 3: Position 0, try length 1: 'ب' → 'b' ✓
        Result: "b", advance to position 1

Step 4: Position 1, try length 3: 'سم ' → no match
Step 5: Position 1, try length 2: 'سم' → no match
Step 6: Position 1, try length 1: 'س' → 's' ✓
        Result: "bs", advance to position 2

Step 7: Position 2, try length 3: 'م ا' → no match
Step 8: Position 2, try length 2: 'م ' → no match
Step 9: Position 2, try length 1: 'م' → 'm' ✓
        Result: "bsm", advance to position 3

Step 10: Position 3, character ' ' → preserve (no mapping)
         Result: "bsm ", advance to position 4

Step 11: Position 4, try length 3: 'الل' → no match
Step 12: Position 4, try length 2: 'ال' → 'al-' ✓ (definite article!)
         Result: "bsm al-", advance to position 6

Step 13: Position 6, try length 1: 'ل' → 'l' ✓
         Result: "bsm al-l", advance to position 7

Step 14: Position 7, try length 1: 'ه' → 'h' ✓
         Result: "bsm al-lh", advance to position 8

Final Result: "bsm al-lh"
```

### Multi-Character Mappings

The algorithm handles multi-character mappings in two ways:

1. **Source sequences** (e.g., 'ال' → 'al-'): Multiple source characters map to a target string
2. **Target sequences** (e.g., 'ث' → 'th'): Single source character maps to multiple target characters

Examples:
```
'ال' (U+0627 U+0644) → 'al-'  # 2 chars to 3 chars
'ث' (U+062B) → 'th'           # 1 char to 2 chars
'ح' (U+062D) → 'ḥ'            # 1 char to 1 char with diacritic
```

### Case Preservation

The algorithm intelligently preserves case for uppercase input:

```raku
# Example with case preservation
'Москва' → 'Moskva'  # First letter capitalized
'МОСКВА' → 'MOSKVA'  # All uppercase preserved

# Multi-character mapping with case
'Θ' → 'Th'   # Uppercase initial, lowercase remainder (default)
'Θ' → 'TH'   # All uppercase (in all-caps context)
```

## Available Arabic Schemes

### 1. ALA-LC (American Library Association - Library of Congress)

**Use Case**: Library cataloging, academic references

**Characteristics**:
- Uses special apostrophes: ʼ (hamza), ʻ (ayn)
- Macron for long vowels: ā, ī, ū
- Dot-under diacritics: ḥ, ṣ, ṭ, ḍ, ẓ
- Multi-char digraphs: th, kh, dh, sh, gh

**Example**:
```
بسم الله الرحمن الرحيم
→ bsm al-lh al-rḥmn al-rḥym
```

### 2. ArabTeX

**Use Case**: LaTeX typesetting, ASCII-only environments

**Characteristics**:
- Pure ASCII encoding
- Uses dots and underscores: .h, .s, .t, .d, .z
- No special Unicode characters
- Designed for TeX macro processing

**Example**:
```
بسم الله الرحمن الرحيم
→ bsm al-lh al-r.hmn al-r.hym
```

### 3. BGN/PCGN

**Use Case**: Geographic names (US/UK standard)

**Characteristics**:
- Optimized for pronounceability
- Capitalizes 'Al' in definite article
- Uses ḩ instead of ḥ for ح
- Practical over academic precision

**Example**:
```
بسم الله الرحمن الرحيم
→ bsm Al lh Al rḩmn Al rḩym
```

### 4. BS 4280:1968 (British Standard)

**Use Case**: British academic institutions

**Characteristics**:
- Similar to ALA-LC
- British academic conventions
- Standard diacritics

**Example**:
```
بسم الله الرحمن الرحيم
→ bsm al-lh al-rḥmn al-rḥym
```

### 5. DIN 31635 (Deutsche Norm)

**Use Case**: German-speaking academia

**Characteristics**:
- German standard
- Similar to ALA-LC with minor variations
- Used in German libraries and universities

**Example**:
```
بسم الله الرحمن الرحيم
→ bsm al-lh al-rḥmn al-rḥym
```

### 6. EALL (Encyclopedia of Arabic Language and Linguistics)

**Use Case**: Linguistic research

**Characteristics**:
- Academic linguistic standard
- Precise phonetic representation
- Used in linguistic publications

**Example**:
```
بسم الله الرحمن الرحيم
→ bsm al-lh al-rḥmn al-rḥym
```

### 7. EI (Encyclopaedia of Islam)

**Use Case**: Islamic studies scholarship

**Characteristics**:
- Long-established academic standard
- Used in major Islamic studies publications
- Consistent with historical transliteration practices

**Example**:
```
بسم الله الرحمن الرحيم
→ bsm al-lh al-rḥmn al-rḥym
```

### 8. ISO 233

**Use Case**: International standardization

**Characteristics**:
- International standard by ISO
- Unique diacritics: ǧ (jim), ẖ (kha), š (shin)
- ˈ for hamza instead of ʼ
- Designed for unambiguous computer processing

**Example**:
```
بسم الله الرحمن الرحيم
→ bsm al-lh al-rḥmn al-rḥym
```

### 9. UNGEGN (United Nations)

**Use Case**: UN documents and geographic names

**Characteristics**:
- UN standard for geographical names
- International readability focus
- Uses ḩ for ح

**Example**:
```
بسم الله الرحمن الرحيم
→ bsm al-lh al-rḩmn al-rḩym
```

### 10. Hans Wehr

**Use Case**: Arabic language learning, dictionary lookups

**Characteristics**:
- Based on Hans Wehr Arabic-English Dictionary (1961)
- Most popular among Arabic learners
- Uses: š (shin), ḵ (kha), ḡ (ghayn), ḏ (dhal), ṯ (tha)
- Balances readability with accuracy

**Example**:
```
بسم الله الرحمن الرحيم
→ bsm al-lh al-rḥmn al-rḥym
```

## Practical Examples

### Example 1: The Basmala

**Arabic**: بسم الله الرحمن الرحيم  
**Meaning**: "In the name of Allah, the Most Gracious, the Most Merciful"

**Transliterations**:
| Scheme | Result |
|--------|--------|
| ALA-LC | bsm al-lh al-rḥmn al-rḥym |
| ArabTeX | bsm al-lh al-r.hmn al-r.hym |
| BGN/PCGN | bsm Al lh Al rḩmn Al rḩym |
| Hans Wehr | bsm al-lh al-rḥmn al-rḥym |

### Example 2: Character Breakdown

Let's examine each character in "الله" (Allah):

| Position | Character | Unicode | Name | ALA-LC | ISO 233 | Hans Wehr |
|----------|-----------|---------|------|--------|---------|-----------|
| 0 | ا | U+0627 | alif | ā | ā | ā |
| 1 | ل | U+0644 | lam | l | l | l |
| 2 | ل | U+0644 | lam | l | l | l |
| 3 | ه | U+0647 | ha | h | h | h |

When "ال" appears together (positions 0-1), most schemes recognize it as the definite article and map it to "al-".

### Example 3: Emphatic Consonants

Arabic has several "emphatic" or "pharyngealized" consonants:

| Letter | Name | Unicode | ALA-LC | ISO 233 | ArabTeX |
|--------|------|---------|--------|---------|---------|
| ص | sad | U+0635 | ṣ | ṣ | .s |
| ض | dad | U+0636 | ḍ | ḍ | .d |
| ط | ta | U+0637 | ṭ | ṭ | .t |
| ظ | za | U+0638 | ẓ | ẓ | .z |

These are distinguished by dots under the letters in most schemes.

## Technical Deep Dive

### Implementation Details

Each Arabic transliteration scheme is implemented as a class that implements the `Transliterator` role:

```raku
use Lang::Transliterate :ALL;

unit class Lang::Transliterate::Ar::ALALC 
    does Lang::Transliterate::Transliterator;

my %base-mappings = (
    "\c[0x0621]" => 'ʼ',      # hamza (ء)
    "\c[0x0627]" => 'ā',      # alif (ا)
    "\c[0x0628]" => 'b',      # ba (ب)
    # ... more mappings
);

method get-mappings(--> Hash) {
    return %base-mappings;
}

method get-reverse-mappings(--> List) {
    return (
        'ʼ' => "\c[0x0621]",
        'ā' => "\c[0x0627]",
        'b' => "\c[0x0628]",
        # ... more reverse mappings
    );
}
```

### Unicode Considerations

Arabic script uses the Unicode block U+0600 to U+06FF. Key ranges:

- **U+0621-U+063A**: Basic letters
- **U+0641-U+064A**: Basic letters (continued)
- **U+064B-U+0652**: Diacritical marks (tashkeel)
- **U+0660-U+0669**: Arabic-Indic digits

### Performance Characteristics

The algorithm has the following performance profile:

- **Time Complexity**: O(n × k) where n is text length and k is max sequence length (3)
- **Space Complexity**: O(n) for the result string
- **Optimization**: Longest-match-first reduces backtracking

### Bidirectional Conversion

Most schemes support reverse transliteration (detransliteration):

```raku
use Lang::Transliterate;
use Lang::Transliterate::Ar::ALALC;

my $alalc = Lang::Transliterate::Ar::ALALC.new;

# Forward
my $latin = transliterate('محمد', $alalc);  # → 'mḥmd'

# Reverse
my $arabic = detransliterate('mḥmd', $alalc);  # → 'محمد'
```

**Note**: Reverse transliteration may not be perfect due to:
- Ambiguous mappings
- Lost vowel information
- Context-dependent rules

### Edge Cases

The implementation handles several edge cases:

1. **Combining Characters**: Diacritics that combine with base letters
2. **Normalization**: Unicode normalization (NFC vs NFD)
3. **Whitespace**: Preserves all whitespace characters
4. **Non-Arabic**: Preserves characters outside the Arabic block
5. **Case Sensitivity**: Intelligently handles uppercase in bi-directional conversion

## Comparison of Schemes

### Diacritic Usage Summary

| Feature | ALA-LC | ISO 233 | Hans Wehr | ArabTeX |
|---------|--------|---------|-----------|---------|
| Hamza | ʼ | ˈ | ʼ | ' |
| Ayn | ʻ | ʿ | ʿ | ` |
| Ha (ح) | ḥ | ḥ | ḥ | .h |
| Kha (خ) | kh | ẖ | ḵ | kh |
| Shin (ش) | sh | š | š | sh |
| Sad (ص) | ṣ | ṣ | ṣ | .s |
| Dad (ض) | ḍ | ḍ | ḍ | .d |
| Ta (ط) | ṭ | ṭ | ṭ | .t |
| Za (ظ) | ẓ | ẓ | ẓ | .z |
| Ghayn (غ) | gh | ġ | ḡ | gh |

### When to Use Each Scheme

**Choose ALA-LC when**:
- Working in American/international libraries
- Creating bibliographic records
- Maximum compatibility needed

**Choose ISO 233 when**:
- International standardization required
- Computer processing is priority
- Need unambiguous encoding

**Choose Hans Wehr when**:
- Teaching/learning Arabic
- Dictionary-based work
- Student materials

**Choose ArabTeX when**:
- Working in LaTeX
- Need ASCII-only
- Publishing in TeX-based systems

**Choose BGN/PCGN when**:
- Working with geographic names
- Need readable output
- Following US/UK government standards

## Running the Examples

To run the comprehensive analysis script:

```bash
cd examples
raku arabic-transliteration-analysis.raku
```

This will display:
- All 10 transliteration schemes
- Side-by-side comparison
- Character-by-character breakdown
- Implementation notes

## References

1. American Library Association & Library of Congress (2012). *ALA-LC Romanization Tables*
2. International Organization for Standardization (1984). *ISO 233: Documentation — Transliteration of Arabic characters into Latin characters*
3. Wehr, Hans (1961). *A Dictionary of Modern Written Arabic*
4. BGN/PCGN (1956). *Romanization System for Arabic*
5. Deutsche Norm (1982). *DIN 31635: Information and documentation — Romanization of the Arabic alphabet*

## Conclusion

The Lang::Transliterate library provides a comprehensive, well-architected solution for Arabic transliteration. Its modular design, context-aware processing, and support for 10 different international standards make it suitable for a wide range of applications from academic research to practical language learning.

The core `apply-mapping` algorithm efficiently handles multi-character sequences, preserves case, and maintains character fidelity while remaining simple and maintainable. Each transliteration scheme is cleanly separated into its own module, making it easy to add new schemes or customize existing ones.
