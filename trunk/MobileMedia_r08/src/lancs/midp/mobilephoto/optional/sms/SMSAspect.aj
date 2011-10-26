package lancs.midp.mobilephoto.optional.sms;

import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Image;

import lancs.midp.mobilephoto.alternative.photo.PhotoAspect;
import lancs.midp.mobilephoto.alternative.photo.PhotoViewScreen;
import ubc.midp.mobilephoto.core.ui.MainUIMidlet;
import ubc.midp.mobilephoto.core.ui.controller.AbstractController;
import ubc.midp.mobilephoto.core.ui.controller.BaseController;
import ubc.midp.mobilephoto.core.ui.controller.MediaController;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.screens.AddMediaToAlbum;
import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;
import ubc.midp.mobilephoto.sms.SmsReceiverController;
import ubc.midp.mobilephoto.sms.SmsReceiverThread;
import ubc.midp.mobilephoto.sms.SmsSenderController;

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
		System.out.println("After SMSAspect begin ...");
		BaseController imageRootController = PhotoAspect.aspectOf().imageRootController;
		AlbumData imageModel = PhotoAspect.aspectOf().imageModel;
		
		AlbumListScreen albumListScreen = (AlbumListScreen)imageRootController.getAlbumListScreen(); // [EF]
		SmsReceiverController controller = new SmsReceiverController(middlet, imageModel, albumListScreen);
		controller.setNextController(imageRootController);
		SmsReceiverThread smsR = new SmsReceiverThread(middlet, imageModel, albumListScreen, controller);
		System.out.println("SmsController::Starting SMSReceiver Thread");
		new Thread(smsR).start();
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
}
