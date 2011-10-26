package lancs.midp.mobilephoto.optional.sms;

import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Image;
import javax.microedition.rms.RecordStore;
import javax.microedition.rms.RecordStoreException;

import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import lancs.midp.mobilephoto.optional.copyPhoto.PhotoViewController;

import ubc.midp.mobilephoto.core.ui.screens.PhotoViewScreen;
import ubc.midp.mobilephoto.core.ui.screens.AddPhotoToAlbum;

import ubc.midp.mobilephoto.core.ui.MainUIMidlet;

import ubc.midp.mobilephoto.sms.SmsReceiverController;
import ubc.midp.mobilephoto.sms.SmsReceiverThread;
import ubc.midp.mobilephoto.sms.SmsSenderController;

import ubc.midp.mobilephoto.core.ui.controller.AbstractController;
import ubc.midp.mobilephoto.core.ui.controller.PhotoController;
import ubc.midp.mobilephoto.core.ui.datamodel.ImageAccessor;

import ubc.midp.mobilephoto.core.ui.datamodel.ImageData;
import ubc.midp.mobilephoto.core.util.ImageUtil;

privileged public aspect SMSAspect {

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

	// ********  AddPhotoToAlbum  ********* //	
	private Image AddPhotoToAlbum.image = null;
	
	public Image AddPhotoToAlbum.getImage() {
		return image;
	}

	public void AddPhotoToAlbum.setImage(Image image) {
		this.image = image;
	}
	
	
	// ********  MainUIMiddlet  ********* //
	pointcut startApplication(MainUIMidlet middlet):
		execution(public void MainUIMidlet.startApp())
		&& this(middlet);
	
	after(MainUIMidlet middlet): startApplication(middlet) {
		SmsReceiverController controller = new SmsReceiverController(middlet, middlet.model, middlet.album);
		controller.setNextController(middlet.albumController);
		SmsReceiverThread smsR = new SmsReceiverThread(middlet, middlet.model, middlet.album, controller);
		System.out.println("SmsController::Starting SMSReceiver Thread");
		new Thread(smsR).start();
	}
	
	// ********  ImageAccessor  ********* //
	
	public byte[] ImageAccessor.getByteFromImage(Image img){
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
	
	public void ImageAccessor.addImageData(String photoname, Image imgdata, String albumname)
				throws InvalidImageDataException, PersistenceMechanismException {
		try {
			imageRS = RecordStore.openRecordStore(ALBUM_LABEL + albumname, true);
			imageInfoRS = RecordStore.openRecordStore(INFO_LABEL + albumname, true);
			int rid; // new record ID for Image (bytes)
			int rid2; // new record ID for ImageData (metadata)
				
			ImageUtil converter = new ImageUtil();
			
			byte[] data1 = getByteFromImage(imgdata);
			rid = imageRS.addRecord(data1, 0, data1.length);
			ImageData ii = new ImageData(rid, ImageAccessor.ALBUM_LABEL	+ albumname, photoname);
			rid2 = imageInfoRS.getNextRecordID();				
			ii.setRecordId(rid2);
			String data1String = converter.getBytesFromImageInfo(ii); 
			data1 = data1String.getBytes();
			imageInfoRS.addRecord(data1, 0, data1.length);
			
			imageRS.closeRecordStore();
			
			imageInfoRS.closeRecordStore();
		} catch (RecordStoreException e) {
			throw new PersistenceMechanismException();
		}
	}


	// ********  PhotoController  ********* //
	
	//public AbstractController PhotoController.getPhotoController(String imageName)
	pointcut getPhotoController(PhotoController controller, String imageName): 
		 (call(public AbstractController PhotoController.getPhotoController(String)) && this(controller))&& args (imageName);
	
	AbstractController around (PhotoController controller, String imageName): getPhotoController(controller, imageName) {
		AbstractController nextcontroller = proceed(controller, imageName);
		SmsSenderController smscontroller = new SmsSenderController(controller.midlet, controller.getAlbumData(), controller.getAlbumListScreen(), imageName);
		smscontroller.setNextController(nextcontroller);
		return smscontroller;
	}
	
	// ********  PhotoViewController  ********* //	
	pointcut processCopy(PhotoViewController photoViewController, AddPhotoToAlbum copyPhotoToAlbum):
		execution(private void PhotoViewController.processCopy(AddPhotoToAlbum))
		&& this(photoViewController) && args(copyPhotoToAlbum);
	
	after(PhotoViewController photoViewController, AddPhotoToAlbum copyPhotoToAlbum): processCopy(photoViewController, copyPhotoToAlbum) {
		if (((PhotoViewScreen)photoViewController.getCurrentScreen()).isFromSMS()){
			copyPhotoToAlbum.setImage(((PhotoViewScreen)photoViewController.getCurrentScreen()).getImage());
		}
	}

	private Image img = null;	
	
	pointcut processImageData(PhotoViewController photoViewController, ImageAccessor imageAccessor, String photoName, String albumname):
		execution(private ImageData PhotoViewController.processImageData(ImageAccessor, String, String))
		&& this(photoViewController)
		&& args(imageAccessor, photoName, albumname);
	
	ImageData around (PhotoViewController photoViewController, ImageAccessor imageAccessor, String photoName, String albumname) throws InvalidImageDataException, PersistenceMechanismException :
		          processImageData(photoViewController, imageAccessor, photoName, albumname) {
		ImageData imageData = null;
		img = null;
		
		img = ((AddPhotoToAlbum)photoViewController.getCurrentScreen()).getImage();
		if (img == null){
		   imageData = proceed(photoViewController, imageAccessor, photoName, albumname);
		}
		if (img != null){
			imageAccessor.addImageData(photoName, img, albumname);
		}		

		return imageData;
	}
	
	pointcut addImageData():
		execution(public void addImageData(ImageAccessor, String, ImageData, String));
	
	void around(): addImageData(){
		if (img == null){
			proceed();
		}
	}
	
}
