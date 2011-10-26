// [NC] Added in the scenario 07

package lancs.midp.mobilephoto.alternative.photomusicvideo;

import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Display;
import javax.microedition.lcdui.List;

import ubc.midp.mobilephoto.core.ui.MainUIMidlet;
import ubc.midp.mobilephoto.core.ui.controller.AbstractController;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;

public class SelectMediaController extends AbstractController {

	public SelectMediaController(MainUIMidlet midlet, AlbumData imageAlbumData,	List albumListScreen) {
		super(midlet, imageAlbumData, albumListScreen);
	}
	
	public boolean handleCommand(Command command) {
		String label = command.getLabel();
      	System.out.println( "<* SelectMediaController.handleCommand() *>: " + label);
		
     	if (label.equals("Select")) {
 			List down = (List) Display.getDisplay(midlet).getCurrent();
 	
 			if (down.getString(down.getSelectedIndex()).equals("Photos"))
 				imageController.init(imageAlbumData);
 
 			if (down.getString(down.getSelectedIndex()).equals("Music"))
 				musicController.init(musicAlbumData);
 
 			if (down.getString(down.getSelectedIndex()).equals("Videos"))
 				videoController.init(videoAlbumData);
      	}
      	return false;
	}

}
