/*
 * Lancaster University
 * Computing Department
 * 
 * Created by Eduardo Figueiredo
 * Date: 13 Aug 2007
 * 
 */
package lancs.midp.mobilephoto.optional.copyPhoto;

import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Image;
import javax.microedition.rms.RecordStore;
import javax.microedition.rms.RecordStoreException;
import javax.microedition.rms.RecordStoreNotOpenException;

import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import ubc.midp.mobilephoto.core.ui.controller.AbstractController;
import ubc.midp.mobilephoto.core.ui.controller.PhotoController;
import ubc.midp.mobilephoto.core.ui.datamodel.ImageAccessor;
import ubc.midp.mobilephoto.core.ui.datamodel.ImageData;
import ubc.midp.mobilephoto.core.ui.screens.PhotoViewScreen;
import ubc.midp.mobilephoto.core.util.ImageUtil;

/**
 * @author Eduardo Figueiredo
 *
 */
public aspect CopyPhotoAspect {

	// ********  PhotoController  ********* //
	
	//public AbstractController PhotoController.getPhotoController(String imageName)
	pointcut getPhotoController(PhotoController controller, String imageName): 
		 (call(public AbstractController PhotoController.getPhotoController(String)) && this(controller))&& args (imageName);
	
	AbstractController around (PhotoController controller, String imageName): getPhotoController(controller, imageName) {
//		System.out.println("<* CopyPhotoAspect.after showImage *> begins...");
		AbstractController nextcontroller = proceed(controller, imageName);
		PhotoViewController control = new PhotoViewController(controller.midlet, controller.getAlbumData(), controller.getAlbumListScreen(), imageName);
		control.setNextController(nextcontroller);
		return control;
	}
	
	// ********  ImageAccessor  ********* //
	
	/**
	 * [EF] Add in scenario 05
	 * @param photoname
	 * @param imageData
	 * @param albumname
	 * @throws InvalidImageDataException
	 * @throws PersistenceMechanismException
	 */
	public void ImageAccessor.addImageData(String photoname, ImageData imageData, String albumname) throws InvalidImageDataException, PersistenceMechanismException {
		try {
			imageRS = RecordStore.openRecordStore(ALBUM_LABEL + albumname, true);
			imageInfoRS = RecordStore.openRecordStore(INFO_LABEL + albumname, true);
			int rid2; // new record ID for ImageData (metadata)
			ImageUtil converter = new ImageUtil();
			rid2 = imageInfoRS.getNextRecordID();
			imageData.setRecordId(rid2);
			byte[] data1 = converter.getBytesFromImageInfo(imageData).getBytes();
			imageInfoRS.addRecord(data1, 0, data1.length);
		} catch (RecordStoreException e) {
			throw new PersistenceMechanismException();
		}finally{
			try {
				imageRS.closeRecordStore();
				imageInfoRS.closeRecordStore();
			} catch (RecordStoreNotOpenException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (RecordStoreException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
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
	
}
