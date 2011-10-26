package lancs.midp.mobilephoto.optional.sms;

import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Image;
import javax.microedition.rms.RecordStoreException;

import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import lancs.midp.mobilephoto.optional.copyPhotoOrSMS.PhotoViewController;
import lancs.midp.mobilephoto.alternative.photo.PhotoViewScreen;

import lancs.midp.mobilephoto.alternative.photo.PhotoAspect;
import lancs.midp.mobilephoto.alternative.photo.ImageMediaAccessor;

import ubc.midp.mobilephoto.core.ui.screens.*;

import ubc.midp.mobilephoto.core.ui.MainUIMidlet;

import ubc.midp.mobilephoto.sms.SmsReceiverController;
import ubc.midp.mobilephoto.sms.SmsReceiverThread;
import ubc.midp.mobilephoto.sms.SmsSenderController;

import ubc.midp.mobilephoto.core.ui.controller.*;
import ubc.midp.mobilephoto.core.ui.datamodel.*;

@Feature(name="SMSTransfer", parent="MobileMediaAO", type=FeatureType.optional)
public privileged aspect SMSAspect {

	// ********  PhotoViewScreen  ********* //
	
	/* [EF] Added in scenario 06 */
	public static final Command smscopyCommand = new Command("Send Photo by SMS", Command.ITEM, 1);
	
	pointcut constructor(Image image) :
		call(PhotoViewScreen.new(Image)) && args(image);

	after(Image image) returning (PhotoViewScreen f): constructor(image) {
		f.addCommand(smscopyCommand);
	}
	
	private boolean PhotoViewScreen.fromSMS = false;
		
	public Image PhotoViewScreen.getImage(){
		return image;
	}
	
	public boolean PhotoViewScreen.isFromSMS() {
		return fromSMS;
	}
	
	public void PhotoViewScreen.setFromSMS(boolean fromSMS) {
		this.fromSMS = fromSMS;
	}
	
	pointcut loadImage(PhotoViewScreen screen):
		execution(public void PhotoViewScreen.loadImage()) && this(screen);

	void around(PhotoViewScreen screen): loadImage(screen) {
		if (screen.fromSMS){
		   return;
		}else {
		   proceed(screen);
		}
	}

	// ********  AddMediaToAlbum  ********* //	
	
	private Image AddMediaToAlbum.image = null;
	
	public Image AddMediaToAlbum.getImage() {
		return image;
	}

	public void AddMediaToAlbum.setImage(Image image) {
		this.image = image;
	}
	
	// ********  MainUIMiddlet  ********* //
	
	pointcut startApplication(MainUIMidlet middlet):
		execution(public void MainUIMidlet.startApp())
		&& this(middlet);
	
	after(MainUIMidlet middlet): startApplication(middlet) {
		BaseController imageRootController = PhotoAspect.aspectOf().imageRootController;
		AlbumData imageModel = PhotoAspect.aspectOf().imageModel;
		
		AlbumListScreen albumListScreen = (AlbumListScreen)imageRootController.getAlbumListScreen(); // [EF]
		SmsReceiverController controller = new SmsReceiverController(middlet, imageModel, albumListScreen);
		controller.setNextController(imageRootController);
		SmsReceiverThread smsR = new SmsReceiverThread(middlet, imageModel, albumListScreen, controller);
		System.out.println("SmsController::Starting SMSReceiver Thread");
		new Thread(smsR).start();
	}

	// ********  ImageAccessor  ********* //
	
	public byte[] ImageMediaAccessor.getByteFromImage(Image img){
		int w = img.getWidth();
		int h = img.getHeight();
		int data_int[] = new int[ w * h ];
		img.getRGB( data_int, 0, w, 0, 0, w, h );
		byte[] data_byte = new byte[ w * h * 3 ];
		for ( int i = 0; i < w * h; ++i )
		{
		int color = data_int[ i ];
		int offset = i * 3;
		data_byte[ offset ] = ( byte ) ( ( color & 0xff0000 ) >> 16 );
		data_byte[ offset +
		1 ] = ( byte ) ( ( color & 0xff00 ) >> 8 );
		data_byte[ offset + 2 ] = ( byte ) ( ( color & 0xff ) );
		}
		return data_byte;
	}
	
	public void ImageMediaAccessor.addImageData(String photoname, Image imgdata, String albumname)
				throws InvalidImageDataException, PersistenceMechanismException {
		try {
			byte[] data1 = getByteFromImage(imgdata);
			addMediaArrayOfBytes(photoname, albumname, data1);
		} catch (RecordStoreException e) {
			throw new PersistenceMechanismException();
		}
	}
	
	// ******** AlbumData *******************//
	
	public void AlbumData.addNewMediaToAlbum(String photoName, Image img, String albumname) {
		try{
		((ImageMediaAccessor)mediaAccessor).addImageData(photoName, img, albumname);
		}catch(Exception e){
			System.out.println("Error "+e.getMessage());
		}
	}

	// ********  MediaController  ********* //
	
	//public AbstractController PhotoController.getMediaController(String imageName)
	pointcut getMediaController(MediaController controller, String imageName): 
		 (call(public AbstractController MediaController.getMediaController(String)) && this(controller))&& args (imageName);
	
	AbstractController around (MediaController controller, String imageName): getMediaController(controller, imageName) {
		AbstractController nextcontroller = proceed(controller, imageName);
		SmsSenderController smscontroller = new SmsSenderController(controller.midlet, controller.getAlbumData(), controller.getAlbumListScreen(), imageName);
		smscontroller.setNextController(nextcontroller);
		return smscontroller;
	}
	
	// ********  PhotoViewController  ********* //
	
	pointcut processCopy(PhotoViewController photoViewController, AddMediaToAlbum copyPhotoToAlbum):
		execution(private void PhotoViewController.processCopy(AddMediaToAlbum))
		&& this(photoViewController) && args(copyPhotoToAlbum);
	
	after(PhotoViewController photoViewController, AddMediaToAlbum copyPhotoToAlbum): processCopy(photoViewController, copyPhotoToAlbum) {
		if (((PhotoViewScreen)photoViewController.getCurrentScreen()).isFromSMS()){
			copyPhotoToAlbum.setImage(((PhotoViewScreen)photoViewController.getCurrentScreen()).getImage());
		}
	}

	private Image img = null;	
	
	pointcut processImageData(PhotoViewController photoViewController, String photoName, String albumname):
		execution(private MediaData PhotoViewController.processImageData(String, String))
		&& this(photoViewController)
		&& args(photoName, albumname);
	
	MediaData around (PhotoViewController photoViewController, String photoName, String albumname) throws InvalidImageDataException, PersistenceMechanismException :
		          processImageData(photoViewController,photoName, albumname) {
		MediaData imageData = null;
		img = null;
		
		img = ((AddMediaToAlbum)photoViewController.getCurrentScreen()).getImage();
		System.out.println("Image is:"+img);
		if (img == null){
		   imageData = proceed(photoViewController, photoName, albumname);
		}else if (img != null) {
			photoViewController.getAlbumData().addNewMediaToAlbum(photoName, img, albumname);
		}		

		
		return imageData;
	}
	
	pointcut addImageData():
		execution(public void addImageData(MediaAccessor, String, MediaData, String));
	
	void around(): addImageData(){
		if (img == null){
			proceed();
		}
	}
}
