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
import ubc.midp.mobilephoto.core.ui.datamodel.ImageData;
import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;
import ubc.midp.mobilephoto.core.ui.screens.PhotoListScreen;
import ubc.midp.mobilephoto.core.util.Constants;

/**
 * @author Eduardo Figueiredo
 *
 */
public class PhotoListController extends AbstractController {

	/**
	 * @param midlet
	 * @param nextController
	 * @param albumData
	 * @param albumListScreen
	 */
	public PhotoListController(MainUIMidlet midlet, AlbumData albumData, AlbumListScreen albumListScreen) {
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
			showImageList(getCurrentStoreName());
			ScreenSingleton.getInstance().setCurrentScreenName( Constants.IMAGELIST_SCREEN);
			return true;
		}
		
		return false;
	}

    /**
     * Show the list of images in the record store
	 * TODO: Refactor - Move this to ImageList class
	 */
	public void showImageList(String recordName) {

		if (recordName == null)
			recordName = getCurrentStoreName();
		
		PhotoController photoController = new PhotoController(midlet, getAlbumData(), getAlbumListScreen());
		photoController.setNextController(this);
		
		PhotoListScreen imageList = new PhotoListScreen();
		imageList.setCommandListener(photoController);
		
		//Command selectCommand = new Command("Open", Command.ITEM, 1);
		imageList.initMenu();
		
		ImageData[] images = null;
		
		images = getAlbumData().getImages(recordName);
		
		if (images==null) return;
		
		appendImages(images, imageList);
		setCurrentScreen(imageList);
		//currentMenu = "list";
	}
	
	/**
	 * [EF] Scenario 02: Ectracted method in order to expose join point
	 * @param images
	 * @param imageList
	 * @return
	 */
	public void appendImages(ImageData[] images, PhotoListScreen imageList) {
		//loop through array and add labels to list
		for (int i = 0; i < images.length; i++) {
			if (images[i] != null) {
				//Add album name to menu list
				
				imageList.append(images[i]);
				
			}
		}
	}
}
