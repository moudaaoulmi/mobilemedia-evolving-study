package lancs.midp.mobilephoto.alternative.photomusicvideo;

import javax.microedition.lcdui.Command;

import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;

public aspect PhotoOrMusicOrVideo {

		// ********  AlbumListScreen  ********* //
		
		//[NC] Added in the scenario 07
		public static final Command exitCommand = new Command("Back", Command.STOP, 2);
		
		//public void initMenu()
		pointcut initMenu(AlbumListScreen screen):
			execution( public void AlbumListScreen.initMenu() ) && this(screen);
		
		before(AlbumListScreen screen): initMenu(screen) {
			screen.addCommand(exitCommand);
		}
	}