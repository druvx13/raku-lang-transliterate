# Arabic Phonetic Transliteration - Development Notes

## Objective

Create an Arabic transliteration system that produces output matching actual Quranic recitation/pronunciation, not just letter-by-letter conversion.

### Example Target

- **Input**: بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ
- **Expected Output**: bi-smi llāhi r-raḥmāni r-raḥīm
- **Current Basic Output**: bsm al-lh al-rḥmn al-rḥym

## Key Differences

### 1. Sun Letter Assimilation (Shamsiyyah)

When the definite article ال (al-) precedes a sun letter, the 'l' assimilates into the following consonant:

- **Sun letters**: ت ث د ذ ر ز س ش ص ض ط ظ ل ن
- **Moon letters**: ا ب ج ح خ ع غ ف ق ك م ه و ي

**Examples**:
- الشَّمْس → ash-shams (not al-shams)
- الرَّحْمَن → ar-raḥmān (not al-raḥmān)  
- الْقَمَر → al-qamar (moon letter, 'l' pronounced)

### 2. Shadda (Gemination)

The shadda mark ّ indicates doubling/gemination of a consonant:

- اللَّه → allāh (double 'l')
- مُحَمَّد → muḥammad (double 'm')

### 3. Short Vowels

Must include the vowel diacritics in pronunciation:

- َ (fatha) = a
- ِ (kasra) = i  
- ُ (damma) = u

**Example**: بِسْمِ = bi-smi (not bsm)

### 4. Long Vowels

Combinations of short vowels + matres lectionis:

- َا = ā (fatha + alif)
- ِي = ī (kasra + ya)
- ُو = ū (damma + waw)

### 5. Hamzat al-Wasl

The connecting hamza (alif wasla ٱ) is often elided in connected speech, especially after the definite article.

### 6. Tanween (Nunation)

Final vowels with -n sound:
- ً = an
- ٍ = in
- ٌ = un

## Implementation Challenges

### 1. Unicode Character Handling in Raku

Raku's hash literal syntax has issues with certain Arabic Unicode characters, particularly:
- Empty string values (` => ''`)
- Special combining characters
- Alif wasla (U+0671)

**Workaround needed**: Use Unicode code points (`.ord == 0x0671`) instead of character literals in certain contexts.

### 2. Context-Aware Processing

The transliteration requires looking ahead and behind to determine:
- Whether to assimilate the definite article
- Whether a consonant has shadda
- Whether vowel combinations form long vowels
- Whether ta marbuta is pronounced as 't' or 'h'

### 3. Word Boundary Detection

Arabic script doesn't have clear word boundaries like Latin script, making it challenging to determine:
- When hamzat al-wasl should be elided
- How to handle connected speech
- Where to place hyphens in the output

## Proposed Architecture

```raku
class Phonetic does Transliterator {
    # Sun letter detection
    method !is-sun-letter(Str $letter) { ... }
    
    # Process definite article with assimilation
    method !process-article($following-letter) { ... }
    
    # Main transliteration with lookahead
    method transliterate-context-aware(Str $text) {
        for each word {
            # Handle definite article
            # Process shadda
            # Handle long vowels
            # Apply base mappings
        }
    }
}
```

## Test Cases

### Surah Al-Fatiha (The Opening)

1. بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ
   - bi-smi llāhi r-raḥmāni r-raḥīm

2. ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ
   - al-ḥamdu lillāhi rabbi l-ʻālamīn

3. ٱلرَّحْمَٰنِ ٱلرَّحِيمِ
   - ar-raḥmāni r-raḥīm

4. مَٰلِكِ يَوْمِ ٱلدِّينِ
   - māliki yawmi d-dīn

5. إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ
   - iyyāka naʻbudu wa-iyyāka nastaʻīn

6. ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ
   - ihdinā ṣ-ṣirāṭa l-mustaqīm

7. صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ
   - ṣirāṭa lladhīna anʻamta ʻalayhim ghayri l-maghḍūbi ʻalayhim wa-lā ḍ-ḍāllīn

## Next Steps

1. **Fix Unicode handling**: Use hexadecimal code points for problematic characters
2. **Implement word-level processing**: Split by whitespace, process each word
3. **Add comprehensive tests**: Verify against known recitations
4. **Handle edge cases**: Ta marbuta variations, hamza forms, etc.
5. **Document limitations**: Note cases where perfect transliteration is ambiguous

## References

- [Arabic Phonology](https://en.wikipedia.org/wiki/Arabic_phonology)
- [Arabic Transliteration Standards](https://en.wikipedia.org/wiki/Romanization_of_Arabic)
- [Quranic Arabic Pronunciation Rules](https://en.wikipedia.org/wiki/Tajwid)
- [International Phonetic Alphabet for Arabic](https://en.wikipedia.org/wiki/Help:IPA/Arabic)

## Conclusion

Creating a phonetic Arabic transliteration system that accurately represents Quranic recitation is a complex task requiring:
- Deep understanding of Arabic grammar and phonology
- Careful handling of Unicode characters in Raku
- Context-aware processing with lookahead/lookbehind
- Comprehensive test coverage with authentic recitations

The framework has been established, but technical implementation requires more time to work through Raku's Unicode handling quirks and thoroughly test against real-world examples.
