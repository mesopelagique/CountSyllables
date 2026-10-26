// Compter les syllabes — driven by cs.hero.

Case of

		//______________________________________________________
	: (Form event code=On Load)

		Form.transition:=cs.hero.ElementTransition.new()
		Form.game:=cs.CountSyllables.new(Form.transition)

		//______________________________________________________
	: (Form event code=On Timer)

		Form.transition.onTimer()

		//______________________________________________________
	: (Form event code=On Clicked)

		var $name : Text:=FORM Event.objectName

		Case of
			: (Position("numBtn_"; $name)=1)
				Form.game.choose(Num(Substring($name; 8)))
			: (Position("lvlBtn_"; $name)=1)
				Form.game.selectLevel(Num(Substring($name; 8)))
			: ($name="btnSpeaker")
				Form.game.toggleSound()
		End case

		//______________________________________________________
	: (Form event code=On Unload)

		SET TIMER(0)

		//______________________________________________________
End case
