/*
 * Lancaster University
 * Computing Department
 * 
 * Created by Eduardo Figueiredo
 * Date: 29 Aug 2007
 * 
 */
package lancs.midp.mobilephoto.alternative.music;

import java.io.InputStream;

import javax.microedition.lcdui.Alert;
import javax.microedition.lcdui.AlertType;
import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Display;
import javax.microedition.lcdui.TextField;
import javax.microedition.rms.RecordStoreFullException;

import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
import lancs.midp.mobilephoto.lib.exceptions.ImagePathNotValidException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import ubc.midp.mobilephoto.core.ui.MainUIMidlet;
import ubc.midp.mobilephoto.core.ui.controller.AbstractController;
import ubc.midp.mobilephoto.core.ui.controller.AlbumController;
import ubc.midp.mobilephoto.core.ui.controller.BaseController;
import ubc.midp.mobilephoto.core.ui.controller.MediaController;
import ubc.midp.mobilephoto.core.ui.controller.MediaListController;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;
import ubc.midp.mobilephoto.core.ui.screens.AddMediaToAlbum;
import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;
import ubc.midp.mobilephoto.core.ui.screens.MediaListScreen;

/**
 * @author Eduardo Figueiredo
 *
 */
public aspect MusicAspect {

	// ********  MainUIMidlet  ********* //
	
	// [NC] Added in the scenario 07
	// [EF] Attributes are public because PhotoAndMusicAspect uses them.
	public BaseController musicRootController;
	
	// [NC] Added in the scenario 07
	public AlbumData musicModel;

	//public void startApp()
	pointcut startApp(MainUIMidlet midlet):
		execution( public void MainUIMidlet.startApp() ) && this(midlet);
	
	before(MainUIMidlet midlet): startApp(midlet) {
		// [NC] Added in the scenario 07
		musicModel = new MusicAlbumData();
		
		// [NC] Added in the scenario 07
		AlbumListScreen albumMusic = new AlbumListScreen();
		musicRootController = new BaseController(midlet, musicModel, albumMusic);
		
		MediaListController musicListController = new MediaListController(midlet, musicModel, albumMusic);
		musicListController.setNextController(musicRootController);
		
		AlbumController albumMusicController = new AlbumController(midlet, musicModel, albumMusic);
		albumMusicController.setNextController(musicListController);
		albumMusic.setCommandListener(albumMusicController);
	}

	after(MainUIMidlet midlet): startApp(midlet) {
		musicRootController.init(musicModel);
	}
	
	
	// ********  MediaController  ********* //
	
	//public boolean handleCommand(Command command)
	pointcut handleCommandAction(MediaController controller, Command c):
		execution(public boolean MediaController.handleCommand(Command)) && args(c) && this(controller);
	
	boolean around(MediaController controller, Command c): handleCommandAction(controller, c) {
		boolean handled = proceed(controller, c);
		
		if (handled) return true;
		
		String label = c.getLabel();
		System.out.println("<* MusicAspect.around handleCommandAction *> ::handleCommand: " + label);
		
		// [NC] Added in the scenario 07
		if (label.equals("Play")) {
			String selectedMediaName = controller.getSelectedMediaName();
			return controller.playMultiMedia(selectedMediaName);		
		}
		
		return false;
	}
	
	// public void addNewMediaToAlbum(String, String, String) 
	pointcut addNewMediaToAlbum(AlbumData albumData, MediaController controller):
		call(public void AlbumData.addNewMediaToAlbum(..)) && target(albumData) && this(controller) 
		&& withincode(public boolean MediaController.handleCommand(Command));
	
	after(AlbumData albumData, MediaController controller) : addNewMediaToAlbum(albumData, controller) {
		try {
			// [NC] Added in the scenario 07
			if (albumData instanceof MusicAlbumData){
				albumData.loadMediaDataFromRMS( controller.getCurrentStoreName());
				MediaData mymedia = albumData.getMediaInfo(((AddMediaToAlbum) controller.getCurrentScreen()).getItemName());
				MultiMediaData mmedi = new MultiMediaData(mymedia, ((AddMediaToAlbum) controller.getCurrentScreen()).getItemType());
				albumData.updateMediaInfo(mymedia, mmedi);
			}
			
		// TODO [EF] Replicated handlers from the method handleCommandAction in MediaController. 
			// TODO Nelio, try to reuse these handlers somehow
		} catch (InvalidImageDataException e) {
			Alert alert = null;
			if (e instanceof ImagePathNotValidException)
				alert = new Alert("Error", "The path is not valid", null, AlertType.ERROR);
			else
				alert = new Alert("Error", "The file format is not valid", null, AlertType.ERROR);
			Display.getDisplay(controller.midlet).setCurrent(alert, Display.getDisplay(controller.midlet).getCurrent());
		} catch (PersistenceMechanismException e) {
			Alert alert = null;
			if (e.getCause() instanceof RecordStoreFullException)
				alert = new Alert("Error", "The mobile database is full", null, AlertType.ERROR);
			else
				alert = new Alert("Error", "The mobile database can not add a new photo", null, AlertType.ERROR);
			Display.getDisplay(controller.midlet).setCurrent(alert, Display.getDisplay(controller.midlet).getCurrent());
			
		} catch (ImageNotFoundException e) {
			Alert alert = new Alert("Error", "The selected item was not found in the mobile device", null, AlertType.ERROR);
			Display.getDisplay(controller.midlet).setCurrent(alert, Display.getDisplay(controller.midlet).getCurrent());
//			return true; // TODO [EF] This should be the return value from method handleCommandAction.
		}
	}
	
	// [NC] Added in the scenario 07
	public boolean MediaController.playMultiMedia(String selectedMediaName) {
		InputStream storedMusic = null;
		try {
			MediaData mymedia = getAlbumData().getMediaInfo(selectedMediaName);
			if (mymedia instanceof MultiMediaData)
			{
				storedMusic = ((MusicAlbumData) getAlbumData()).getMusicFromRecordStore(getCurrentStoreName(), selectedMediaName);
				PlayMediaScreen playscree = new PlayMediaScreen(midlet, storedMusic, ((MultiMediaData)mymedia).getTypeMedia(), this);
				MusicPlayController controller = new MusicPlayController(midlet, getAlbumData(), (AlbumListScreen) getAlbumListScreen(), playscree);
				this.setNextController(controller);
			}
			return true;
		} catch (ImageNotFoundException e) {
			Alert alert = new Alert( "Error", "The selected item was not found in the mobile device", null, AlertType.ERROR);
			Display.getDisplay(midlet).setCurrent(alert, Display.getDisplay(midlet).getCurrent());
		    return false;
		} 
		catch (PersistenceMechanismException e) {
			Alert alert = new Alert( "Error", "The mobile database can open this item 1", null, AlertType.ERROR);
			Display.getDisplay(midlet).setCurrent(alert, Display.getDisplay(midlet).getCurrent());
			return false;
		}
	
	}
	
	// ********  MediaListScreen  ********* //
	
	// [NC] Added in the scenario 07: to support more than one screen purpose
	public static final int PLAYMUSIC = 2;
	
	// [NC] Added in the scenario 07
	public static final Command playCommand = new Command("Play", Command.ITEM, 1);
	
	// public void initMenu()
	pointcut initMenu(MediaListScreen listScreen):
		execution(public void MediaListScreen.initMenu()) && this(listScreen);
	
	after(MediaListScreen listScreen) : initMenu(listScreen) {
		//Add the core application commands always
		// [NC] Added in the scenario 07: to support more than one screen purpose
		if (listScreen.getTypeOfScreen() == PLAYMUSIC)
			listScreen.addCommand(playCommand);
	}
	
	//public PhotoViewScreen.PhotoViewScreen(Image)
	
	pointcut constructor(AbstractController controller) :
		call(MediaListScreen.new(..)) && this(controller);

	after(AbstractController controller) returning (MediaListScreen listScreen): constructor(controller) {
		// [NC] Added in the scenario 07	
		if (controller.getAlbumData() instanceof MusicAlbumData)
			listScreen.setTypeOfScreen(PLAYMUSIC);
	}

	// ********  AddMediaToAlbum  ********* //
	
	// [NC] Added in the scenario 07
	TextField AddMediaToAlbum.itemtype = new TextField("Type of media", "", 20, TextField.ANY);
	
	pointcut newAddMediaToAlbum() :
		call(AddMediaToAlbum.new(..));
	
	after() returning (AddMediaToAlbum addMediaToAlbum): newAddMediaToAlbum() {
		// [NC] Added in the scenario 07
		addMediaToAlbum.append(addMediaToAlbum.getItemType());
	}

	// [NC] Added in the scenario 07
	public String AddMediaToAlbum.getItemType() {
		return itemtype.getString();
	}

}
