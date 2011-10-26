/*
 * Lancaster University
 * Computing Department
 * 
 * Created by Eduardo Figueiredo
 * Date: 13 Aug 2007
 * 
 */
package lancs.midp.mobilephoto.optional.copyPhoto;

import javax.microedition.lcdui.Alert;
import javax.microedition.lcdui.AlertType;
import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Display;
import javax.microedition.lcdui.Image;
import javax.microedition.rms.RecordStore;
import javax.microedition.rms.RecordStoreException;
import javax.microedition.rms.RecordStoreFullException;
import javax.microedition.rms.RecordStoreNotOpenException;

import lancs.midp.mobilephoto.alternative.music.MusicPlayController;
import lancs.midp.mobilephoto.alternative.photo.PhotoViewScreen;
import lancs.midp.mobilephoto.alternative.video.PlayVideoController;
import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
import lancs.midp.mobilephoto.lib.exceptions.ImagePathNotValidException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import ubc.midp.mobilephoto.core.ui.controller.AbstractController;
import ubc.midp.mobilephoto.core.ui.controller.MediaController;
import ubc.midp.mobilephoto.core.ui.controller.ScreenSingleton;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaAccessor;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;
import ubc.midp.mobilephoto.core.ui.screens.AddMediaToAlbum;
import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;
import ubc.midp.mobilephoto.core.util.Constants;

/**
 * @author Eduardo Figueiredo
 * [EF] Become privileged in order to have access to private attributes 
 * in classes AlbumData, MediaAccessor and PlayMediaScreen.
 */
public privileged abstract aspect CopyPhotoAspect {

	

	declare parents : PlayVideoController extends CopyPhotoTargets;
	declare parents : MusicPlayController extends CopyPhotoTargets;
	// ********  PhotoController  ********* //
	
	//public AbstractController PhotoController.getMediaController(String imageName)
	pointcut getMediaController(MediaController controller, String imageName): 
		 (call(public AbstractController MediaController.getMediaController(String)) && this(controller))&& args (imageName);
	
	AbstractController around (MediaController controller, String imageName): getMediaController(controller, imageName) {
//		System.out.println("<* CopyPhotoAspect.after showImage *> begins...");
		AbstractController nextcontroller = proceed(controller, imageName);
		PhotoViewController control = new PhotoViewController(controller.midlet, controller.getAlbumData(), (AlbumListScreen) controller.getAlbumListScreen(), imageName);
		control.setNextController(nextcontroller);
		return control;
	}
	
	// ********  ImageMediaAccessor  ********* //
	
	// TODO see if these attributes are necessary in MediaAccessor
	protected String album_label; // "mpa- all album names
	protected String info_label; // "mpi- all album info
	protected String default_album_name; // default

	/**
	 * [EF] Add in scenario 05
	 * @param photoname
	 * @param imageData
	 * @param albumname
	 * @throws InvalidImageDataException
	 * @throws PersistenceMechanismException
	 */
	public void MediaAccessor.addMediaData(MediaData mediaData, String albumname) throws InvalidImageDataException, PersistenceMechanismException {
		try {
			mediaRS = RecordStore.openRecordStore(album_label + albumname, true);
			mediaInfoRS = RecordStore.openRecordStore(info_label + albumname, true);
			int rid2; // new record ID for ImageData (metadata)
			rid2 = mediaInfoRS.getNextRecordID();
			mediaData.setRecordId(rid2);
			byte[] data1 = this.getByteFromMediaInfo(mediaData);
			mediaInfoRS.addRecord(data1, 0, data1.length);
		} catch (RecordStoreException e) {
			throw new PersistenceMechanismException();
		}finally{
			try {
				mediaRS.closeRecordStore();
				mediaInfoRS.closeRecordStore();
			} catch (RecordStoreNotOpenException e) {
				e.printStackTrace();
			} catch (RecordStoreException e) {
				e.printStackTrace();
			}
		}
	}
	
	// ********  AlbumData  ********* //
	
	/**
	 * @param mediaData
	 * @param albumname
	 * @throws InvalidImageDataException
	 * @throws PersistenceMechanismException
	 */
	public void AlbumData.addMediaData(MediaData mediaData, String albumname) throws InvalidImageDataException, PersistenceMechanismException {
		mediaAccessor.addMediaData(mediaData, albumname); 
	}
	
	// ********  PhotoViewScreen  ********* //
	
	/* [EF] Added in scenario 05 */
	public static final Command copyCommand = new Command("Copy", Command.ITEM, 1);
	
	//public PhotoViewScreen.PhotoViewScreen(Image)
	pointcut constructor(Image image) :
		call(PhotoViewScreen.new(Image)) && args(image);

	after(Image image) returning (PhotoViewScreen f): constructor(image) {
		f.addCommand(copyCommand);
	}
	
	abstract pointcut newMediaController(String mediaName);

	after(String mediaName) returning (CopyPhotoTargets controller): newMediaController(mediaName) {
		controller.setMediaName(mediaName);
	}
	
	abstract pointcut handleCommandAction(CopyPhotoTargets controller, Command c);
	
	boolean around(CopyPhotoTargets controller, Command c): handleCommandAction(controller, c) {
		boolean handled = proceed(controller, c);
		
		if (handled) return true;
		
		String label = c.getLabel();
		System.out.println("<* AbstractCopyPhotoAspect.around handleCommandAction *> ::handleCommand:geral " + label);
		
	  	 // [NC] Added in the scenario 07
		/** Case: Copy photo to a different album */
		if (label.equals("Copy")) {
			AddMediaToAlbum copyPhotoToAlbum = new AddMediaToAlbum("Copy Media to Album");
			copyPhotoToAlbum.setItemName(controller.getMediaName());
			copyPhotoToAlbum.setLabePath("Copy to Album:");
			copyPhotoToAlbum.setCommandListener(controller);
	        Display.getDisplay(controller.midlet).setCurrent(copyPhotoToAlbum);
			return true;
			
		} else if (label.equals("Save Item")) {
			try {
				String medianame = ((AddMediaToAlbum) controller.getCurrentScreen()).getItemName();
				MediaData imageData = null;	
				try {
						imageData = controller.getAlbumData().getMediaInfo(medianame);
				} catch (ImageNotFoundException e) {
						Alert alert = new Alert("Error", "The selected photo was not found in the mobile device", null, AlertType.ERROR);
						Display.getDisplay(controller.midlet).setCurrent(alert, Display.getDisplay(controller.midlet).getCurrent());
				}
				String albumname = ((AddMediaToAlbum) controller.getCurrentScreen()).getPath();
				controller.getAlbumData().addMediaData(imageData, albumname); 
			} catch (InvalidImageDataException e) {
				Alert alert = null;
				if (e instanceof ImagePathNotValidException)
					alert = new Alert("Error", "The path is not valid", null, AlertType.ERROR);
				else
					alert = new Alert("Error", "The music file format is not valid", null, AlertType.ERROR);
				Display.getDisplay(controller.midlet).setCurrent(alert, Display.getDisplay(controller.midlet).getCurrent());
				return true;
				// alert.setTimeout(5000);
			} catch (PersistenceMechanismException e) {
				Alert alert = null;
				if (e.getCause() instanceof RecordStoreFullException)
					alert = new Alert("Error", "The mobile database is full", null, AlertType.ERROR);
				else
					alert = new Alert("Error", "The mobile database can not add a new music", null, AlertType.ERROR);
				Display.getDisplay(controller.midlet).setCurrent(alert, Display.getDisplay(controller.midlet).getCurrent());
			}
			//((PhotoController)this.getNextController()).showImageList(ScreenSingleton.getInstance().getCurrentStoreName(), false, false);
		    //ScreenSingleton.getInstance().setCurrentScreenName(Constants.IMAGELIST_SCREEN);
			// [NC] Changed in the scenario 07: just the first line below to support generic AbstractController
			((AlbumListScreen) controller.getAlbumListScreen()).repaintListAlbum(controller.getAlbumData().getAlbumNames());
			controller.setCurrentScreen( controller.getAlbumListScreen() );
			ScreenSingleton.getInstance().setCurrentScreenName(Constants.ALBUMLIST_SCREEN);
			return true;
		}
		
		return false;
	}
}
