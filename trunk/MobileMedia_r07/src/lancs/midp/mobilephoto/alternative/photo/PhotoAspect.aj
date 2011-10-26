/*
 * Lancaster University
 * Computing Department
 * 
 * Created by Eduardo Figueiredo
 * Date: 29 Aug 2007
 * 
 */
package lancs.midp.mobilephoto.alternative.photo;

import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Image;

import ubc.midp.mobilephoto.core.ui.MainUIMidlet;
import ubc.midp.mobilephoto.core.ui.controller.AbstractController;
import ubc.midp.mobilephoto.core.ui.controller.AlbumController;
import ubc.midp.mobilephoto.core.ui.controller.BaseController;
import ubc.midp.mobilephoto.core.ui.controller.MediaController;
import ubc.midp.mobilephoto.core.ui.controller.MediaListController;
import ubc.midp.mobilephoto.core.ui.controller.ScreenSingleton;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;
import ubc.midp.mobilephoto.core.ui.screens.MediaListScreen;
import ubc.midp.mobilephoto.core.util.Constants;

/**
 * @author Eduardo Figueiredo
 *
 */
public aspect PhotoAspect {

	// ********  MainUIMidlet  ********* //
	
	//(m v C) Controller
	// [NC] Added in the scenario 07
	// [EF] Attributes are public because SMSAspect uses them.
	// [EF] PhotoAndMusicAspect also uses.
	public BaseController imageRootController;

	//Model (M v c)
	// [NC] Added in the scenario 07
	public AlbumData imageModel;
	
	//public void startApp()
	pointcut startApp(MainUIMidlet midlet):
		execution( public void MainUIMidlet.startApp() ) && this(midlet);
	
	before(MainUIMidlet midlet): startApp(midlet) {
		// [NC] Added in the scenario 07
		imageModel = new ImageAlbumData();
		
		// [NC] Added in the scenario 07
		AlbumListScreen album = new AlbumListScreen();
		imageRootController = new BaseController(midlet, imageModel, album);
		
		// [EF] Add in scenario 04: initialize sub-controllers
		MediaListController photoListController = new MediaListController(midlet, imageModel, album);
		photoListController.setNextController(imageRootController);
		
		AlbumController albumController = new AlbumController(midlet, imageModel, album);
		albumController.setNextController(photoListController);
		album.setCommandListener(albumController);
	}
	
	after(MainUIMidlet midlet): startApp(midlet) {
		imageRootController.init(imageModel);
	}

	// ********  MediaController  ********* //
	
	//public boolean handleCommand(Command command)
	pointcut handleCommandAction(MediaController controller, Command c):
		execution(public boolean MediaController.handleCommand(Command)) && args(c) && this(controller);
	
	boolean around(MediaController controller, Command c): handleCommandAction(controller, c) {
		boolean handled = proceed(controller, c);
		
		if (handled) return true;
		
		String label = c.getLabel();
		System.out.println("<* PhotoAspect.around handleCommandAction *> ::handleCommand: " + label);
		
		// [NC] Added in the scenario 07
		if (label.equals("View")) {
			String selectedImageName = controller.getSelectedMediaName();
			controller.showImage(selectedImageName);
			ScreenSingleton.getInstance().setCurrentScreenName(Constants.IMAGE_SCREEN);
			return true;
		}
		return false;
	}

	/**
	 * Show the current image that is selected
	 */
	// [NC] Added in the scenario 07
	public void MediaController.showImage(String name) {
//[EF] Instead of replicating this code, I change to use the method "getSelectedImageName()". 		
		Image storedImage = null;
		storedImage = ((ImageAlbumData)getAlbumData()).getImageFromRecordStore(getCurrentStoreName(), name);
		//We can pass in the image directly here, or just the name/model pair and have it loaded
		PhotoViewScreen canv = new PhotoViewScreen(storedImage);
		canv.setCommandListener( this );
		AbstractController nextcontroller = getMediaController(name); 
		canv.setCommandListener( nextcontroller );
		setCurrentScreen(canv);
	}
	
	// ********  MediaListScreen  ********* //
	
	public static final int SHOWPHOTO = 1;
	
	// [NC] Added in the scenario 07
	public static final Command viewCommand = new Command("View", Command.ITEM, 1);
	
	// public void initMenu()
	pointcut initMenu(MediaListScreen listScreen):
		execution(public void MediaListScreen.initMenu()) && this(listScreen);
	
	after(MediaListScreen listScreen) : initMenu(listScreen) {
		//Add the core application commands always
		// [NC] Added in the scenario 07: to support more than one screen purpose
		if (listScreen.getTypeOfScreen() == SHOWPHOTO)
			listScreen.addCommand(viewCommand);
	}

	//public PhotoViewScreen.PhotoViewScreen(Image)
	pointcut constructor(AbstractController controller) :
		call(MediaListScreen.new(..)) && this(controller);

	after(AbstractController controller) returning (MediaListScreen listScreen): constructor(controller) {
		// [NC] Added in the scenario 07
		if (controller.getAlbumData() instanceof ImageAlbumData)
			listScreen.setTypeOfScreen(SHOWPHOTO);
	}


}
