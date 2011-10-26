package lancs.midp.mobilephoto.alternative.video;

import java.io.InputStream;

import javax.microedition.lcdui.Alert;
import javax.microedition.lcdui.AlertType;
import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Display;

import lancs.midp.mobilephoto.alternative.musicvideo.MultiMediaData;
import lancs.midp.mobilephoto.alternative.photomusicvideo.SelectMediaController;
import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
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
import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;
import ubc.midp.mobilephoto.core.ui.screens.MediaListScreen;

public privileged aspect VideoAspect {
	// ********  MainUIMidlet  ********* //
	
	//(m v C) Controller
	// [NC] Added in the scenario 08

	public BaseController videoRootController;
	public AlbumData videoModel;
	
	//public void startApp()
	pointcut startApp(MainUIMidlet midlet):
		execution( public void MainUIMidlet.startApp() ) && this(midlet);
	
	before(MainUIMidlet midlet): startApp(midlet) {
		System.out.println("entrou before Video ..");
		videoModel = new VideoAlbumData();
		
		AlbumListScreen albumVideo = new AlbumListScreen();
		videoRootController = new BaseController(midlet, videoModel, albumVideo);
		
		MediaListController videoListController = new MediaListController(midlet, videoModel, albumVideo);
		videoListController.setNextController(videoRootController);
		
		AlbumController albumVideoController = new AlbumController(midlet, videoModel, albumVideo);
		albumVideoController.setNextController(videoListController);
		albumVideo.setCommandListener(albumVideoController);
		System.out.println("saiu before Video ..");
	}
	
	// ********  AlbumData  ********* //
	public void AlbumData.addVideoData(String videoname, String albumname, byte[] video)
	throws InvalidImageDataException, PersistenceMechanismException {
		if (mediaAccessor instanceof VideoMediaAccessor)
			((VideoMediaAccessor)mediaAccessor).addVideoData(videoname, albumname, video);
	}
	
	// ********  SelectMediaController  ********* //
	public BaseController SelectMediaController.videoController;
	public AlbumData SelectMediaController.videoAlbumData;

	
	public BaseController SelectMediaController.getVideoController() {
		return videoController;
	}

	public void SelectMediaController.setVideoController(BaseController videoController) {
		this.videoController = videoController;
	}

	public AlbumData SelectMediaController.getVideoAlbumData() {
		return videoAlbumData;
	}

	public void SelectMediaController.setVideoAlbumData(AlbumData videoAlbumData) {
		this.videoAlbumData = videoAlbumData;
	}
	
// ********  MediaController  ********* //
	
	//public boolean handleCommand(Command command)
	pointcut handleCommandAction(MediaController controller, Command c):
		execution(public boolean MediaController.handleCommand(Command)) && args(c) && this(controller);
	
	boolean around(MediaController controller, Command c): handleCommandAction(controller, c) {
		boolean handled = proceed(controller, c);
		
		if (handled) return true;
		
		String label = c.getLabel();
		System.out.println("<* VideoAspect.around handleCommandAction *> ::handleCommand: " + label);
		
		// [NC] Added in the scenario 07
		if (label.equals("Play Video")) {
			String selectedMediaName = controller.getSelectedMediaName();
			return controller.playVideoMedia(selectedMediaName);		
		}
		
		return false;
	}
	
	private boolean MediaController.playVideoMedia(String selectedMediaName) {
		InputStream storedMusic = null;
		try {
			MediaData mymedia = getAlbumData().getMediaInfo(selectedMediaName);
			
			if (mymedia instanceof MultiMediaData)
			{
				storedMusic = ((VideoAlbumData) getAlbumData()).getVideoFromRecordStore(getCurrentStoreName(), selectedMediaName);
				PlayVideoScreen playscree = new PlayVideoScreen(midlet,storedMusic, ((MultiMediaData)mymedia).getTypeMedia(),this);
				playscree.setVisibleVideo();
				PlayVideoController controller = new PlayVideoController(midlet, getAlbumData(), (AlbumListScreen) getAlbumListScreen(), playscree);
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
	public static final int MediaListScreen.PLAYVIDEO = 3;
	
	// [NC] Added in the scenario 07
	public static final Command playCommand = new Command("Play Video", Command.ITEM, 1);
	
	// public void initMenu()
	pointcut initMenu(MediaListScreen listScreen):
		execution(public void MediaListScreen.initMenu()) && this(listScreen);
	
	after(MediaListScreen listScreen) : initMenu(listScreen) {
		//Add the core application commands always
		// [NC] Added in the scenario 07: to support more than one screen purpose
		if (listScreen.getTypeOfScreen() == MediaListScreen.PLAYVIDEO)
			listScreen.addCommand(playCommand);
	}
	

	pointcut constructor(AbstractController controller) :
		call(MediaListScreen.new(..)) && this(controller);

	after(AbstractController controller) returning (MediaListScreen listScreen): constructor(controller) {
		// [NC] Added in the scenario 07	
		if (controller.getAlbumData() instanceof VideoAlbumData)
			listScreen.setTypeOfScreen(MediaListScreen.PLAYVIDEO);
	}

}
