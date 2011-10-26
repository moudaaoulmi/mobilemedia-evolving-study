package lancs.midp.mobilephoto.optional.capturevideo;


import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Display;
import javax.microedition.lcdui.List;

import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import lancs.midp.mobilephoto.optional.capturephotoandvideo.CaptureVideoScreen;
import ubc.midp.mobilephoto.core.ui.MainUIMidlet;
import ubc.midp.mobilephoto.core.ui.controller.AbstractController;
import ubc.midp.mobilephoto.core.ui.controller.ScreenSingleton;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.screens.AddMediaToAlbum;
import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;
import ubc.midp.mobilephoto.core.util.Constants;
import lancs.midp.mobilephoto.alternative.video.VideoAlbumData;

public class VideoCaptureController extends AbstractController{

	
	private CaptureVideoScreen pmscreen;
	private AddMediaToAlbum saveVideoToAlbum;
	public VideoCaptureController(MainUIMidlet midlet, AlbumData albumData,
			List albumListScreen, CaptureVideoScreen pmscreen) {
		super(midlet, albumData, albumListScreen);
		this.pmscreen = pmscreen;
	}

	public boolean handleCommand(Command command) {
		String label = command.getLabel();
		System.out.println( "<* VideoCaptureController.handleCommand() *> " + label);

		if (label.equals("Start")) {
			pmscreen.startCapture();
			return true;
		}else if (label.equals("Stop")) {
			pmscreen.pauseCapture();
			saveVideoToAlbum = new AddMediaToAlbum("Save Video");
			saveVideoToAlbum.setItemName("Capture video");
			saveVideoToAlbum.setLabePath("Save to Album:");
			saveVideoToAlbum.setCommandListener(this);
			saveVideoToAlbum.setCapturedMedia(pmscreen.getByteArrays());
	        Display.getDisplay(midlet).setCurrent(saveVideoToAlbum);
			return true;
		}
		else if (label.equals("Save Item")) {
					String videoname = ((AddMediaToAlbum) getCurrentScreen()).getItemName();
					String albumname = ((AddMediaToAlbum) getCurrentScreen()).getPath();
					try {
						((VideoAlbumData)getAlbumData()).addVideoData(videoname, albumname, saveVideoToAlbum.getCapturedMedia());
					} catch (InvalidImageDataException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (PersistenceMechanismException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
			}
		}else if ((label.equals("Back"))||(label.equals("Cancel"))){
			pmscreen.pauseCapture();
			// [NC] Changed in the scenario 07: just the first line below to support generic AbstractController
			((AlbumListScreen) getAlbumListScreen()).repaintListAlbum(getAlbumData().getAlbumNames());
			setCurrentScreen( getAlbumListScreen() );
			ScreenSingleton.getInstance().setCurrentScreenName(Constants.ALBUMLIST_SCREEN);
			return true;
		}
	
		
		return false;
	}

}

