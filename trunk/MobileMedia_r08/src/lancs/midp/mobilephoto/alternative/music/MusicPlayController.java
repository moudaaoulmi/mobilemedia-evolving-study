// [NC] Added in the scenario 07
package lancs.midp.mobilephoto.alternative.music;

import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.List;

import ubc.midp.mobilephoto.core.ui.MainUIMidlet;
import ubc.midp.mobilephoto.core.ui.controller.AbstractController;
import ubc.midp.mobilephoto.core.ui.controller.ScreenSingleton;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;
import ubc.midp.mobilephoto.core.util.Constants;

public class MusicPlayController extends AbstractController{
	
	private PlayMediaScreen pmscreen;
	
	public MusicPlayController(MainUIMidlet midlet, AlbumData albumData,
			List albumListScreen, PlayMediaScreen pmscreen) {
		super(midlet, albumData, albumListScreen);
		this.pmscreen = pmscreen;
	}

	public boolean handleCommand(Command command) {
		String label = command.getLabel();
		System.out.println( "<* MusicPlayController.handleCommand() *> " + label);

		/** Case: Copy photo to a different album */
		if (label.equals("Start")) {
			pmscreen.startPlay();
			return true;
		}else if (label.equals("Stop")) {
			pmscreen.pausePlay();
				return true;
		}else if ((label.equals("Back"))||(label.equals("Cancel"))){
			pmscreen.pausePlay();
			// [NC] Changed in the scenario 07: just the first line below to support generic AbstractController
			((AlbumListScreen) getAlbumListScreen()).repaintListAlbum(getAlbumData().getAlbumNames());
			setCurrentScreen( getAlbumListScreen() );
			ScreenSingleton.getInstance().setCurrentScreenName(Constants.ALBUMLIST_SCREEN);
			return true;
		}
		
		return false;
	}
}
