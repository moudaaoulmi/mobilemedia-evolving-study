package lancs.midp.mobilephoto.optional.copyPhoto;

import javax.microedition.lcdui.Command;

import lancs.midp.mobilephoto.alternative.video.PlayVideoController;
import lancs.midp.mobilephoto.alternative.video.PlayVideoScreen;
import ubc.midp.mobilephoto.core.ui.controller.AbstractController;

public privileged aspect CopyPhotoAndVideo extends CopyPhotoAspect{
	// ********  PlayVideoController  ********* //
	
	  // [NC] Added in the scenario 07

	
	//PlayVideoController.new
	
	pointcut newMediaController(String mediaName) :
		call(public PlayVideoController.new(..)) 
		&& (withincode( public boolean AbstractController+.playVideoMedia(String)) && args(mediaName));

	//public boolean handleCommand(Command command)
	pointcut handleCommandAction(CopyPhotoTargets controller, Command c):
		execution(public boolean PlayVideoController.handleCommand(Command)) && args(c) && this(controller);
	
	
	// ********  PlayMediaScreen  ********* //
	
	// [NC] Added in the scenario 07
	public static final Command copy = new Command("Copy", Command.ITEM, 1);

	//private void initForm(AbstractController controller)
	pointcut initForm(PlayVideoScreen mediaScreen):
		execution(private void PlayVideoScreen.initForm()) && this(mediaScreen);

	before(PlayVideoScreen mediaScreen) : initForm(mediaScreen) {
		// [NC] Added in the scenario 07
		mediaScreen.addCommand(copy);
	}

}
