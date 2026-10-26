/*
CountSyllables ("Compter les syllabes") — count the syllables in a word, animated by
Hero (cs.hero).

A picture appears with its word split into syllable chips (ba · na · ne) that light up
one by one — a visual "clap". The child taps how many syllables there are. Reveal, score,
and the next word slides in with a fresh colour.

Store the instance in Form.game.

(4D evaluates left-to-right with NO operator precedence, so arithmetic inside a comparison
or an index is parenthesised.)
*/

property transition : cs.hero.ElementTransition
property palette : Collection:=[0x00E8B84B; 0x005B9BD5; 0x006FB98F; 0x00E0736A; 0x009B8BC4]
property colorIdx : Integer:=0

// shared word list: emoji + word + its reading syllables
property words : Collection:=[\
{emoji: "🐱"; word: "chat"; syls: ["chat"]}; \
{emoji: "🐶"; word: "chien"; syls: ["chien"]}; \
{emoji: "🐺"; word: "loup"; syls: ["loup"]}; \
{emoji: "🏍️"; word: "moto"; syls: ["mo"; "to"]}; \
{emoji: "🐴"; word: "cheval"; syls: ["che"; "val"]}; \
{emoji: "🐰"; word: "lapin"; syls: ["la"; "pin"]}; \
{emoji: "🐢"; word: "tortue"; syls: ["tor"; "tue"]}; \
{emoji: "🦁"; word: "lion"; syls: ["li"; "on"]}; \
{emoji: "🏠"; word: "maison"; syls: ["mai"; "son"]}; \
{emoji: "🌞"; word: "soleil"; syls: ["so"; "leil"]}; \
{emoji: "🐷"; word: "cochon"; syls: ["co"; "chon"]}; \
{emoji: "🐮"; word: "vache"; syls: ["va"; "che"]}; \
{emoji: "🦆"; word: "canard"; syls: ["ca"; "nard"]}; \
{emoji: "🍎"; word: "pomme"; syls: ["pom"; "me"]}; \
{emoji: "🦋"; word: "papillon"; syls: ["pa"; "pi"; "llon"]}; \
{emoji: "🍫"; word: "chocolat"; syls: ["cho"; "co"; "lat"]}; \
{emoji: "🍌"; word: "banane"; syls: ["ba"; "na"; "ne"]}; \
{emoji: "🚗"; word: "voiture"; syls: ["voi"; "tu"; "re"]}; \
{emoji: "🦒"; word: "girafe"; syls: ["gi"; "ra"; "fe"]}; \
{emoji: "🍅"; word: "tomate"; syls: ["to"; "ma"; "te"]}; \
{emoji: "🐌"; word: "escargot"; syls: ["es"; "car"; "got"]}; \
{emoji: "🐊"; word: "crocodile"; syls: ["cro"; "co"; "di"; "le"]}]

property chipsMax : Integer:=4

property level : Text:="easy"              // easy = 1–2 syllables, normal = all
property wordMode : Text:="split"           // "split" = syllable chips · "whole" = one block
property curWord : Object                    // the word currently shown
property count : Integer                    // the true number of syllables
property choices : Collection               // the numbers on the buttons
property score : Integer:=0
property busy : Boolean:=False
property sound : Boolean:=True

Class constructor($transition : cs.hero.ElementTransition)

	This.transition:=$transition
	OBJECT SET VISIBLE(*; "glyph"; False)
	OBJECT SET VISIBLE(*; "truth"; False)
	This._highlightLevel(1)
	This._highlightWordMode(1)
	This.newQuestion()

	// === === === === === === === === === === === === === === === === === === === ===
Function selectLevel($i : Integer)

	If ($i=1)
		This.level:="easy"
	Else
		This.level:="normal"
	End if
	This._highlightLevel($i)
	This.newQuestion()

	// === === === === === === === === === === === === === === === === === === === ===
	// Word display: 1 = Séparé (syllable chips, easier) · 2 = Collé (one block, harder)
Function selectWordMode($i : Integer)

	If ($i=1)
		This.wordMode:="split"
	Else
		This.wordMode:="whole"
	End if
	This._highlightWordMode($i)
	This._renderChips()

	// === === === === === === === === === === === === === === === === === === === ===
Function toggleSound()

	This.sound:=Not(This.sound)
	If (This.sound)
		OBJECT SET TITLE(*; "speaker"; "🔊")
	Else
		OBJECT SET TITLE(*; "speaker"; "🔇")
	End if

	// === === === === === === === === === === === === === === === === === === === ===
Function newQuestion()

	var $w : Object:=This._pickWord()
	This.curWord:=$w
	This.count:=$w.syls.length

	// number choices: the true count plus two nearby ones
	var $opts : Collection:=[This.count]
	While ($opts.length<3)
		var $sign : Integer:=1
		If ((Random % 2)=0)
			$sign:=-1
		End if
		var $d : Integer:=This.count+($sign*(1+(Random % 2)))
		If ($d<1)
			$d:=This.count+1+(Random % 2)
		End if
		If (($d>=1) & ($d<=5) & ($opts.indexOf($d)=-1))
			$opts.push($d)
		End if
	End while
	This.choices:=This._shuffle($opts)

	OBJECT SET TITLE(*; "emoji"; $w.emoji)
	This._renderChips()
	This._renderChoices()

	OBJECT SET TITLE(*; "score"; String(This.score))
	OBJECT SET VISIBLE(*; "glyph"; False)
	OBJECT SET VISIBLE(*; "truth"; False)

	This.colorIdx:=((This.colorIdx+1) % This.palette.length)
	This.transition.animate("card").to({backgroundColor: This.palette[This.colorIdx]}).duration(300).easing("easeInOutQuad").start()
	This._popIn("emoji")

	This.busy:=False

	// === === === === === === === === === === === === === === === === === === === ===
Function choose($i : Integer)

	If (This.busy)
		return
	End if
	This.busy:=True

	var $pick : Integer:=This.choices[($i-1)]
	var $right : Boolean:=($pick=This.count)

	OBJECT SET TITLE(*; "truth"; String(This.count)+" syllabes")
	OBJECT SET VISIBLE(*; "truth"; True)

	if ($right)
		This.score:=This.score+1
		OBJECT SET TITLE(*; "score"; String(This.score))
		This._bumpScore()
		This._showGlyph("✓")
	else
		This._showGlyph("✗")
		This._shakeCard()
		If (This.sound)
			BEEP
		End if
	end if

	This.transition.animate("tick").to({left: 1}).delay(1300).then(Formula(Form.game._advance())).start()

Function _advance()

	OBJECT SET COORDINATES(*; "tick"; 0; -10; 1; -9)
	This.newQuestion()

	// === === === === === === === === === === === === === === === === === === === ===
	// a word for the current level
Function _pickWord() : Object

	If (This.level="normal")
		return This.words[(Random % This.words.length)]
	End if
	var $pool : Collection:=[]
	var $w : Object
	For each ($w; This.words)
		If ($w.syls.length<=2)
			$pool.push($w)
		End if
	End for each
	return $pool[(Random % $pool.length)]

	// Show the word: either split into syllable chips that pop in one by one (easier),
	// or as one whole block the child must segment themselves (harder).
Function _renderChips()

	var $syls : Collection:=This.curWord.syls
	var $y : Integer:=(64+240)
	var $cw; $x : Integer

	If (This.wordMode="whole")

		$cw:=224
		$x:=190-($cw\2)
		var $fs : Integer:=This._wordFont(Length(This.curWord.word))
		OBJECT SET COORDINATES(*; "chip_1"; $x; $y; $x+$cw; $y+44)
		OBJECT SET COORDINATES(*; "chipLbl_1"; $x; $y; $x+$cw; $y+44)
		OBJECT SET TITLE(*; "chipLbl_1"; This.curWord.word)
		OBJECT SET VISIBLE(*; "chip_1"; True)
		OBJECT SET VISIBLE(*; "chipLbl_1"; True)
		This.transition.animate("chipLbl_1").from({fontSize: 10}).to({fontSize: $fs}).duration(280).easing("easeOutBack").start()
		var $j : Integer
		For ($j; 2; This.chipsMax)
			OBJECT SET VISIBLE(*; "chip_"+String($j); False)
			OBJECT SET VISIBLE(*; "chipLbl_"+String($j); False)
		End for
		return

	End if

	var $n : Integer:=$syls.length
	$cw:=56
	var $gap : Integer:=8
	var $total : Integer:=($n*$cw)+(($n-1)*$gap)
	var $startx : Integer:=190-($total\2)

	var $k : Integer
	For ($k; 1; This.chipsMax)
		var $pad : Text:="chip_"+String($k)
		var $lbl : Text:="chipLbl_"+String($k)
		If ($k<=$n)
			$x:=$startx+(($k-1)*($cw+$gap))
			OBJECT SET COORDINATES(*; $pad; $x; $y; $x+$cw; $y+44)
			OBJECT SET COORDINATES(*; $lbl; $x; $y; $x+$cw; $y+44)
			OBJECT SET TITLE(*; $lbl; $syls[($k-1)])
			OBJECT SET VISIBLE(*; $pad; True)
			OBJECT SET VISIBLE(*; $lbl; True)
			// pop each chip in turn — the "clap"
			This.transition.animate($lbl).from({fontSize: 8}).to({fontSize: 24}).delay(($k-1)*160).duration(240).easing("easeOutBack").start()
		Else
			OBJECT SET VISIBLE(*; $pad; False)
			OBJECT SET VISIBLE(*; $lbl; False)
		End if
	End for

	// --------------------------------------------------------------------------------
Function _wordFont($n : Integer) : Integer

	Case of
		: ($n<=4)
			return 30
		: ($n<=6)
			return 26
		: ($n<=8)
			return 22
		Else
			return 18
	End case

	// three number pads in a row, centred at y=388 (card-relative)
Function _renderChoices()

	var $pad : Integer:=72
	var $gap : Integer:=20
	var $total : Integer:=(3*$pad)+(2*$gap)
	var $startx : Integer:=190-($total\2)
	var $y : Integer:=(64+324)
	var $i : Integer
	For ($i; 1; 3)
		var $s : Text:=String($i)
		var $x : Integer:=$startx+(($i-1)*($pad+$gap))
		OBJECT SET COORDINATES(*; "numPad_"+$s; $x; $y; $x+$pad; $y+$pad)
		OBJECT SET COORDINATES(*; "numLbl_"+$s; $x; $y; $x+$pad; $y+$pad)
		OBJECT SET COORDINATES(*; "numBtn_"+$s; $x; $y; $x+$pad; $y+$pad)
		OBJECT SET TITLE(*; "numLbl_"+$s; String(This.choices[($i-1)]))
	End for

	// === === === === === === === === === === === === === === === === === === === ===
	// helpers
	// === === === === === === === === === === === === === === === === === === === ===
Function _shuffle($c : Collection) : Collection

	var $src : Collection:=$c.copy()
	var $out : Collection:=[]
	While ($src.length>0)
		var $k : Integer:=(Random % $src.length)
		$out.push($src[$k])
		$src.remove($k)
	End while
	return $out

Function _popIn($name : Text)

	var $s:=cs.hero.ElementState.new($name)
	var $cx : Integer:=$s.left+($s.width\2)
	var $cy : Integer:=$s.top+($s.height\2)
	OBJECT SET COORDINATES(*; $name; $cx; $cy; $cx; $cy)
	This.transition.animate($name).to({left: $s.left; top: $s.top; width: $s.width; height: $s.height}).duration(280).easing("easeOutBack").start()

Function _showGlyph($char : Text)

	OBJECT SET TITLE(*; "glyph"; $char)
	var $g:=cs.hero.ElementState.new("glyph")
	var $cx : Integer:=$g.left+($g.width\2)
	var $cy : Integer:=$g.top+($g.height\2)
	OBJECT SET COORDINATES(*; "glyph"; $cx; $cy; $cx; $cy)
	OBJECT SET VISIBLE(*; "glyph"; True)
	This.transition.animate("glyph").to({left: $g.left; top: $g.top; width: $g.width; height: $g.height}).duration(240).easing("easeOutBack").start()

Function _bumpScore()

	This.transition.animate("score").to({fontSize: 40}).duration(130).easing("easeOutQuad").then(Formula(Form.game._scoreBack())).start()

Function _scoreBack()

	This.transition.animate("score").to({fontSize: 28}).duration(180).easing("easeInOutCubic").start()

Function _shakeCard()

	var $c:=cs.hero.ElementState.new("card")
	This.transition.animate("card").from({left: $c.left-16}).to({left: $c.left}).duration(600).easing("easeOutElastic").start()

Function _highlightLevel($sel : Integer)

	var $i : Integer
	For ($i; 1; 2)
		If ($i=$sel)
			OBJECT SET RGB COLORS(*; "lvlPad_"+String($i); 0x00344054; 0x00344054)
			OBJECT SET RGB COLORS(*; "lvlLbl_"+String($i); 0x00FFFFFF; 0x00344054)
		Else
			OBJECT SET RGB COLORS(*; "lvlPad_"+String($i); 0x00E4E7EC; 0x00E4E7EC)
			OBJECT SET RGB COLORS(*; "lvlLbl_"+String($i); 0x00667085; 0x00E4E7EC)
		End if
	End for

Function _highlightWordMode($sel : Integer)

	var $i : Integer
	For ($i; 1; 2)
		If ($i=$sel)
			OBJECT SET RGB COLORS(*; "wmPad_"+String($i); 0x00344054; 0x00344054)
			OBJECT SET RGB COLORS(*; "wmLbl_"+String($i); 0x00FFFFFF; 0x00344054)
		Else
			OBJECT SET RGB COLORS(*; "wmPad_"+String($i); 0x00E4E7EC; 0x00E4E7EC)
			OBJECT SET RGB COLORS(*; "wmLbl_"+String($i); 0x00667085; 0x00E4E7EC)
		End if
	End for
