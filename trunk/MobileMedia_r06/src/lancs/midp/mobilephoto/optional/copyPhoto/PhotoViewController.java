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
import lancs.midp.mobilephoto.lib.exceptions.NullAlbumDataReference;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import ubc.midp.mobilephoto.core.ui.MainUIMidlet;
import ubc.midp.mobilephoto.core.ui.controller.AbstractController;
import ubc.midp.mobilephoto.core.ui.controller.ScreenSingleton;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.datamodel.ImageAccessor;
import ubc.midp.mobilephoto.core.ui.datamodel.ImageData;
import ubc.midp.mobilephoto.core.ui.screens.AddPhotoToAlbum;
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
		System.out.println( "<* PhotoViewController.handleCommand() *> " + label);

		/** Case: Copy photo to a different album */
		if (label.equals("Copy")) {
			AddPhotoToAlbum copyPhotoToAlbum = new AddPhotoToAlbum("Copy Photo to Album");
			
			/* [NC] Added in scenario 06 */
			processCopy(copyPhotoToAlbum);
			
			Display.getDisplay(midlet).setCurrent(copyPhotoToAlbum);
			
			return true;
		}
		
		/** Case: Save a copy in a new album */
		else if (label.equals("Save Photo")) {
			try {
				String photoname = ((AddPhotoToAlbum) getCurrentScreen()).getPhotoName();
				String albumname = ((AddPhotoToAlbum) getCurrentScreen()).getPath();
				ImageAccessor imageAccessor = getAlbumData().getImageAccessor();

				ImageData imageData = processImageData(imageAccessor, photoname, albumname);
				this.addImageData(imageAccessor, photoname, imageData, albumname);
								
				
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
		  	getAlbumListScreen().repaintListAlbum(getAlbumData().getAlbumNames());
			setCurrentScreen( getAlbumListScreen() );
			ScreenSingleton.getInstance().setCurrentScreenName(Constants.ALBUMLIST_SCREEN);

			return true;
		}
		
		return false;
	}

	/* [NC] Added as a result of a refactoring in scenario 06 */	
	private void processCopy(AddPhotoToAlbum copyPhotoToAlbum) {
		copyPhotoToAlbum.setPhotoName(imageName);
		copyPhotoToAlbum.setLabePhotoPath("Copy to Album:");
		copyPhotoToAlbum.setCommandListener(this);
	}
	
	/* [NC] Added as a result of a refactoring in scenario 06 */	
	private ImageData processImageData(ImageAccessor imageAccessor, String photoName, String albumname) throws InvalidImageDataException, PersistenceMechanismException {
		ImageData imageData = null;
		try {
			imageData = getAlbumData().getImageAccessor().getImageInfo(imageName);
		} catch (ImageNotFoundException e) {
			e.printStackTrace();
		} catch (NullAlbumDataReference e) {
			e.printStackTrace();
		}
		return imageData;
	}

	/* [NC] Added as a result of a refactoring in scenario 06 */
	public void addImageData(ImageAccessor imageAccessor, String photoname, ImageData imageData, String albumname) throws InvalidImageDataException, PersistenceMechanismException {
		imageAccessor.addImageData(photoname, imageData, albumname);		
	}
}
