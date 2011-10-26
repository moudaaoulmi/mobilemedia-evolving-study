/*
 * Lancaster University
 * Computing Department
 * 
 * Created by Eduardo Figueiredo
 * Date: 30 Aug 2007
 * 
 */
package lancs.midp.mobilephoto.alternative.photoMusic;

import javax.microedition.lcdui.Command;

import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;

/**
 * @author Eduardo Figueiredo
 *
 */
public aspect PhotoOrMusicAspect {

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
