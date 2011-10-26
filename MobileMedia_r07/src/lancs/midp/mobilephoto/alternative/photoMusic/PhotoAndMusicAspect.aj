/*
 * Lancaster University
 * Computing Department
 * 
 * Created by Eduardo Figueiredo
 * Date: 30 Aug 2007
 * 
 */
package lancs.midp.mobilephoto.alternative.photoMusic;

import javax.microedition.lcdui.Display;

import lancs.midp.mobilephoto.alternative.music.MusicAspect;
import lancs.midp.mobilephoto.alternative.photo.PhotoAspect;
import ubc.midp.mobilephoto.core.ui.MainUIMidlet;
import ubc.midp.mobilephoto.core.ui.controller.BaseController;
import ubc.midp.mobilephoto.core.ui.controller.ScreenSingleton;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;
import ubc.midp.mobilephoto.core.util.Constants;

/**
 * @author Eduardo Figueiredo
 *
 */
public aspect PhotoAndMusicAspect {

	declare precedence : MusicAspect, PhotoAspect, PhotoAndMusicAspect; // [EF] Check? 
	
	// ********  MainUIMidlet  ********* //
	
	//public void startApp()
	pointcut startApp(MainUIMidlet midlet):
		execution( public void MainUIMidlet.startApp() ) && this(midlet);
	
	after(MainUIMidlet midlet): startApp(midlet) {
		BaseController imageRootController = PhotoAspect.aspectOf().imageRootController;
		AlbumData imageModel = PhotoAspect.aspectOf().imageModel;

		BaseController musicRootController = MusicAspect.aspectOf().musicRootController;
		AlbumData musicModel = MusicAspect.aspectOf().musicModel;

		AlbumListScreen albumListScreen = (AlbumListScreen)imageRootController.getAlbumListScreen();
		
		// [NC] Added in the scenario 07
		SelectMediaController selectcontroller = new SelectMediaController(midlet, imageModel, musicModel, albumListScreen, imageRootController, musicRootController);
		selectcontroller.setNextController(imageRootController);
		
		SelectTypeOfMedia mainscreen = new SelectTypeOfMedia();
		mainscreen.initMenu();
		mainscreen.setCommandListener(selectcontroller);
		Display.getDisplay(midlet).setCurrent(mainscreen);
		setMainMenu(mainscreen);
	}

	// ********  BaseController  ********* //
	
	//private boolean goToPreviousScreen())
	pointcut goToPreviousScreen(BaseController controller):
		execution( private boolean BaseController.goToPreviousScreen() ) && this(controller);
	
	boolean around(BaseController controller) : goToPreviousScreen(controller) {
		boolean returned = proceed(controller);
		if (returned) return true;
		
    	String currentScreenName = ScreenSingleton.getInstance().getCurrentScreenName();
		// [NC] Added in the scenario 07
		if ((currentScreenName == null) || (currentScreenName.equals(Constants.ALBUMLIST_SCREEN))) {	
			controller.setCurrentScreen( getMainMenu() );
			return true;
		}
		return false;
	}
	
	// ********  ScreenSingleton  ********* //
	
	// [NC] Added in the scenario 07
	private SelectTypeOfMedia mainscreen;
	
	public SelectTypeOfMedia getMainMenu(){
		return mainscreen;
	}
	
	public void setMainMenu(SelectTypeOfMedia screen){
		mainscreen = screen;
	}
	
}
