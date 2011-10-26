package lancs.midp.mobilephoto.optional.copyPhoto;

import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.List;

import ubc.midp.mobilephoto.core.ui.MainUIMidlet;
import ubc.midp.mobilephoto.core.ui.controller.AbstractController;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;

public abstract class CopyPhotoTargets extends AbstractController {
	
	private String mediaName;
	
	public CopyPhotoTargets(MainUIMidlet midlet, AlbumData albumData,
			List albumListScreen) {
		super(midlet, albumData, albumListScreen);
	}
	
	  // [NC] Added in the scenario 07
	public String getMediaName() {
		return mediaName;
	}

	public void setMediaName(String mediaName) {
		this.mediaName = mediaName;
	}

	public abstract boolean handleCommand(Command command); 

}