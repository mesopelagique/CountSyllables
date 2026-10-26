# CountSyllables

**"Compter les syllabes" — a syllable-awareness game for kids.** A picture appears with its
word split into syllable chips (ba · na · ne) that pop in one by one; tap **how many syllables**
there are. Built on [Hero](https://github.com/mesopelagique/Hero) (`cs.hero`).

## Play

Open the project — `On Startup` launches it. Count the syllable chips, tap the right number.
A correct call bumps the **score**; a wrong one reveals the count, shakes and beeps (tap **🔊**
to mute). **Facile** uses 1–2 syllable words, **Normal** up to four.

## `cs.CountSyllables`

| Function | Action |
|:-|:-|
| `.newQuestion()` | Pick a word, show its syllable chips, offer number choices. |
| `.choose($i)` | Judge the tapped number, reveal, score, advance. |
| `.selectLevel($i)` | `1` = Facile (≤2), else Normal. |
