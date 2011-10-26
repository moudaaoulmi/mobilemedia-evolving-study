/*
 * Lancaster University
 * Computing Department
 * 
 * Created by Eduardo Figueiredo
 * Date: 22 Jul 2007
 * 
 */
package lancs.midp.mobilephoto.optional.copyPhoto;

import javax.microedition.lcdui.Alert;
import javax.microedition.lcdui.AlertType;
import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Display;
import javax.microedition.rms.RecordStoreFullException;

import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
import lancs.midp.mobilephoto.lib.exceptions.ImagePathNotValidException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import ubc.midp.mobilephoto.core.ui.MainUIMidlet;
import ubc.midp.mobilephoto.core.ui.controller.AbstractController;
import ubc.midp.mobilephoto.core.ui.controller.ScreenSingleton;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;
import ubc.midp.mobilephoto.core.ui.screens.AddMediaToAlbum;
import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;
import ubc.midp.mobilephoto.core.util.Constants;

/**
 * @author Eduardo Figueiredo
 * [EF] Added in Scenario 05
 */
public class PhotoViewController extends AbstractController {

	String imageName = "";
	
	/**
	 * @param midlet
	 * @param nextController
	 * @param albumData
	 * @param albumListScreen
	 * @param currentScreenName
	 */
	public PhotoViewController(MainUIMidlet midlet, AlbumData albumData, AlbumListScreen albumListScreen, String imageName) {
		super(midlet, albumData, albumListScreen);
		this.imageName = imageName;
	}

	/* (non-Javadoc)
	 * @see ubc.midp.mobilephoto.core.ui.controller.ControllerInterface#handleCommand(javax.microedition.lcdui.Command, javax.microedition.lcdui.Displayable)
	 */
	public boolean handleCommand(Command c) {
		String label = c.getLabel();
		System.out.println( "<* PhotoViewController.handleCommand() * photo copy geral> " + label);

		/** Case: Copy photo to a different album */
		if (label.equals("Copy")) {
			AddMediaToAlbum copyPhotoToAlbum = new AddMediaToAlbum("Copy Photo to Album");
			/* [NC] Added in scenario 06 */
			processCopy(copyPhotoToAlbum);
			Display.getDisplay(midlet).setCurrent(copyPhotoToAlbum);
			return true;
		}
		
		/** Case: Save a copy in a new album */
		else if (label.equals("Save Item")) {
			try {
				String photoname = ((AddMediaToAlbum) getCurrentScreen()).getItemName();
				String albumname = ((AddMediaToAlbum) getCurrentScreen()).getPath();

				MediaData imageData = processImageData(photoname, albumname);
				if (imageData != null)
					this.addImageData(imageData, albumname);
								
				
			} catch (InvalidImageDataException e) {
				Alert alert = null;
				if (e instanceof ImagePathNotValidException)
					alert = new Alert("Error", "The path is not valid", null, AlertType.ERROR);
				else
					alert = new Alert("Error", "The image file format is not valid", null, AlertType.ERROR);
				Display.getDisplay(midlet).setCurrent(alert, Display.getDisplay(midlet).getCurrent());
				return true;
				// alert.setTimeout(5000);
			} catch (PersistenceMechanismException e) {
				Alert alert = null;
				if (e.getCause() instanceof RecordStoreFullException)
					alert = new Alert("Error", "The mobile database is full", null, AlertType.ERROR);
				else
					alert = new Alert("Error", "The mobile database can not add a new photo", null, AlertType.ERROR);
				Display.getDisplay(midlet).setCurrent(alert, Display.getDisplay(midlet).getCurrent());
			}
//			((PhotoController)this.getNextController()).showImageList(ScreenSingleton.getInstance().getCurrentStoreName());
//		    ScreenSingleton.getInstance().setCurrentScreenName(Constants.IMAGELIST_SCREEN);
			((AlbumListScreen) getAlbumListScreen()).repaintListAlbum(getAlbumData().getAlbumNames());
			setCurrentScreen( getAlbumListScreen() );
			ScreenSingleton.getInstance().setCurrentScreenName(Constants.ALBUMLIST_SCREEN);

			return true;
		}else if ((label.equals("Cancel")) || (label.equals("Back"))){
			// [NC] Changed in the scenario 07: just the first line below to support generic AbstractController
			((AlbumListScreen) getAlbumListScreen()).repaintListAlbum(getAlbumData().getAlbumNames());
			setCurrentScreen( getAlbumListScreen() );
			ScreenSingleton.getInstance().setCurrentScreenName(Constants.ALBUMLIST_SCREEN);
			return true;
		}
		
		return false;
	}

	/* [NC] Added as a result of a refactoring in scenario 06 */	
	private void processCopy(AddMediaToAlbum copyPhotoToAlbum) {
		copyPhotoToAlbum.setItemName(imageName);
		copyPhotoToAlbum.setLabePath("Copy to Album:");
		copyPhotoToAlbum.setCommandListener(this);
	}
	
	/* [NC] Added as a result of a refactoring in scenario 06 */	
	private MediaData processImageData(String photoName, String albumname) throws InvalidImageDataException, PersistenceMechanismException {
		MediaData imageData = null;
		try {
			imageData = getAlbumData().getMediaInfo(imageName);
		} catch (ImageNotFoundException e) {
			e.printStackTrace();
		}
		return imageData;
	}

	// [EF] TODO method addImageData(MediaData, String) belongs to CopyPhotoAspect
	// [EF] we should not access it from here
	/* [NC] Added as a result of a refactoring in scenario 06 */
	public void addImageData(MediaData imageData, String albumname) throws InvalidImageDataException, PersistenceMechanismException {
		this.getAlbumData().addMediaData(imageData, albumname);		
	}
}
