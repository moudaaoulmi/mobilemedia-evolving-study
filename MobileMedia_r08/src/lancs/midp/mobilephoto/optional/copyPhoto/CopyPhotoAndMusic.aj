package lancs.midp.mobilephoto.optional.copyPhoto;

import javax.microedition.lcdui.Command;

import lancs.midp.mobilephoto.alternative.music.MusicPlayController;
import lancs.midp.mobilephoto.alternative.music.PlayMediaScreen;
import ubc.midp.mobilephoto.core.ui.controller.MediaController;

public privileged aspect CopyPhotoAndMusic extends CopyPhotoAspect{
	// ********  MusicPlayController  ********* //
	
	pointcut newMediaController(String mediaName) :
		call(MusicPlayController.new(..)) 
		&& (withincode( public boolean MediaController.playMultiMedia(String)) && args(mediaName));



	//public boolean handleCommand(Command command)
	pointcut handleCommandAction(CopyPhotoTargets controller, Command c):
		execution(public boolean MusicPlayController.handleCommand(Command)) && args(c) && this(controller);
	
	
	
	// ********  PlayMediaScreen  ********* //
	
	// [NC] Added in the scenario 07
	public static final Command copy = new Command("Copy", Command.ITEM, 1);

	//private void initForm(AbstractController controller)
	pointcut initForm(PlayMediaScreen mediaScreen):
		execution(private void PlayMediaScreen.initForm()) && this(mediaScreen);

	before(PlayMediaScreen mediaScreen) : initForm(mediaScreen) {
		// [NC] Added in the scenario 07
		mediaScreen.form.addCommand(copy);
	}

}
