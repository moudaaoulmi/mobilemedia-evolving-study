/*
 * Lancaster University
 * Computing Department
 * 
 * Created by Eduardo Figueiredo
 * Date: 11 Aug 2007
 * 
 */
package ubc.midp.mobilephoto.core.ui.controller;

import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Display;
import javax.microedition.lcdui.List;

import ubc.midp.mobilephoto.core.ui.MainUIMidlet;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;
import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;
import ubc.midp.mobilephoto.core.ui.screens.MediaListScreen;
import ubc.midp.mobilephoto.core.util.Constants;

/**
 * @author Eduardo Figueiredo
 *
 */
public class MediaListController extends AbstractController {

	/**
	 * @param midlet
	 * @param nextController
	 * @param albumData
	 * @param albumListScreen
	 */
	public MediaListController(MainUIMidlet midlet, AlbumData albumData, AlbumListScreen albumListScreen) {
		super(midlet, albumData, albumListScreen);
	}

	/* (non-Javadoc)
	 * @see ubc.midp.mobilephoto.core.ui.controller.ControllerInterface#handleCommand(java.lang.String)
	 */
	public boolean handleCommand(Command command) {
		String label = command.getLabel();
		/** Case: Select PhotoAlbum to view **/
		if (label.equals("Select")) {
			// Get the name of the PhotoAlbum selected, and load image list from
			// RecordStore
			List down = (List) Display.getDisplay(midlet).getCurrent();
			ScreenSingleton.getInstance().setCurrentStoreName(down.getString(down.getSelectedIndex()));
			showMediaList(getCurrentStoreName());
			ScreenSingleton.getInstance().setCurrentScreenName( Constants.IMAGELIST_SCREEN);
			return true;
		}
		
		return false;
	}

    /**
     * Show the list of images in the record store
	 * TODO: Refactor - Move this to ImageList class
	 */
	public void showMediaList(String recordName) {

		if (recordName == null)
			recordName = getCurrentStoreName();
		
		// [NC] Changed in the scenario 07: just the first line below to support generic AbstractController
		MediaController mediaController = new MediaController(midlet, getAlbumData(), (AlbumListScreen) getAlbumListScreen());
		mediaController.setNextController(this);
		
		// [NC] Changed in the scenario 07: defines the type of screen: Photo or Video
		MediaListScreen mediaList = new MediaListScreen();
		mediaList.setCommandListener(mediaController);
		
		//Command selectCommand = new Command("Open", Command.ITEM, 1);
		mediaList.initMenu();
		
		MediaData[] medias = null;

		medias = getAlbumData().getMedias(recordName);
		
		if (medias==null) return;
		
		appendMedias(medias, mediaList);
		setCurrentScreen(mediaList);
		//currentMenu = "list";
	}
	
	/**
	 * [EF] Scenario 02: Ectracted method in order to expose join point
	 * @param images
	 * @param imageList
	 * @return
	 */
	public void appendMedias(MediaData[] medias, MediaListScreen mediaList) {
		//loop through array and add labels to list
		for (int i = 0; i < medias.length; i++) {
			if (medias[i] != null) {
				//Add album name to menu list				
				mediaList.append(medias[i]);
				
			}
		}
	}
}
