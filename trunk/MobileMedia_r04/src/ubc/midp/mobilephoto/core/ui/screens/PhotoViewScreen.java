/*
 */

package ubc.midp.mobilephoto.core.ui.screens;
import javax.microedition.lcdui.Canvas;
import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Graphics;
import javax.microedition.lcdui.Image;

import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.util.Constants;

/**
 * This screen displays a selected image.
  */
public class PhotoViewScreen extends Canvas {

	String imageName = "";
	Image image;
	AlbumData model = null;
    
	public static final Command backCommand = new Command("Back", Command.BACK, 0);

	/**
	 * Constructor
	 * @param img
	 */
	public PhotoViewScreen(Image img) {

		//Instead of loading it from a list, pass the image in directly
		image = img;
		this.addCommand(backCommand);
	}
	
	/**
	 * Constructor
	 * @param mod
	 * @param name
	 */
	public PhotoViewScreen(AlbumData mod, String name) {
		imageName = name;
		model = mod;
		loadImage();
		this.addCommand(backCommand);
	}

	/**
	 * Get the current image from the hashtable stored in the parent midlet.
	 * @throws PersistenceMechanismException 
	 * @throws ImageNotFoundException 
	 */
	public void loadImage() throws ImageNotFoundException, PersistenceMechanismException {
			image = model.getImageFromRecordStore(null, imageName);
	}

	/*
	 *  (non-Javadoc)
	 * @see javax.microedition.lcdui.Canvas#paint(javax.microedition.lcdui.Graphics)
	 */
	protected void paint(Graphics g) {
		
	    g.setGrayScale (255);

	    //Draw the image - for now start drawing in top left corner of screen
	    g.fillRect (0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT);
	    System.out.println("Screen size:"+Constants.SCREEN_WIDTH+":"+ Constants.SCREEN_HEIGHT);

	    if (image == null) 
	    	System.out.println("PhotoViewScreen::paint(): Image object was null.");
	    	
	    g.drawImage (image, 0, 0, Graphics.TOP | Graphics.LEFT);
	    
	}
}