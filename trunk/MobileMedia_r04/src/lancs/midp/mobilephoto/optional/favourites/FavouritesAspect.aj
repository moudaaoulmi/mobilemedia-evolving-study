/*
 * Lancaster University
 * Computing Department
 * 
 * Created by Eduardo Figueiredo
 * Date: 9 Aug 2007
 * 
 */
package lancs.midp.mobilephoto.optional.favourites;

import javax.microedition.lcdui.Alert;
import javax.microedition.lcdui.AlertType;
import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Display;
import javax.microedition.lcdui.Displayable;

import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
import lancs.midp.mobilephoto.lib.exceptions.NullAlbumDataReference;
import ubc.midp.mobilephoto.core.ui.controller.BaseController;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.datamodel.ImageData;
import ubc.midp.mobilephoto.core.ui.screens.PhotoListScreen;
import ubc.midp.mobilephoto.core.util.Constants;
import ubc.midp.mobilephoto.core.util.ImageUtil;

/**
 * @author Eduardo Figueiredo
 *
 */
public aspect FavouritesAspect {

	// ********  BaseController  ********* //
	
	// TODO [EF] This pointcut is already defined in the CountViewsAspect aspect
	//public boolean BaseController.handleCommand(Command, Displayable)
	pointcut handleCommandAction(BaseController controller, Command c, Displayable d):
		execution(public boolean BaseController.handleCommand(Command, Displayable)) && args(c, d) && this(controller);
	
	boolean around(BaseController controller, Command c, Displayable d): handleCommandAction(controller, c, d) {
		boolean handled = proceed(controller, c, d);
		
		if (handled) return true;
		
		String label = c.getLabel();
		System.out.println("<* FavouritesAspect.around handleCommandAction *> ::handleCommand: " + label);
		
		/** Case: Set photo as favorite 
		 * [EF] Added in the scenario 03 **/
		if (label.equals("Set Favorite")) {
		   	String selectedImageName = controller.getSelectedImageName();
			try {
				ImageData image = controller.getModel().getImageAccessor().getImageInfo(selectedImageName);
				image.toggleFavorite();
				controller.updateImage(image);
				System.out.println("<* FavouritesAspect.handleCommand() *> Image = "+selectedImageName+ "; Favorite = "+image.isFavorite());
			} catch (ImageNotFoundException e) {
				Alert alert = new Alert( "Error", "The selected photo was not found in the mobile device", null, AlertType.ERROR);
				Display.getDisplay(controller.midlet).setCurrent(alert, Display.getDisplay(controller.midlet).getCurrent());
			} catch (NullAlbumDataReference e) {
				controller.setModel( new AlbumData() );
				Alert alert = new Alert( "Error", "The operation is not available. Try again later !", null, AlertType.ERROR);
				Display.getDisplay(controller.midlet).setCurrent(alert, Display.getDisplay(controller.midlet).getCurrent());
			}
			return true;
				
		/** Case: View favorite photos 
		 * [EF] Added in the scenario 03 **/
		} else if (label.equals("View Favorites")) {
			favorite = true;
			controller.showImageList(controller.getCurrentStoreName());
			controller.setCurrentScreenName( Constants.IMAGELIST_SCREEN );
			return true;
		}
		
		return false;
	}
	
	boolean favorite = false;
	
	//public int PhotoListScreen.append(ImageData)
	pointcut append(BaseController controller, ImageData image):
		call(public int PhotoListScreen.append(ImageData)) && args(image) && this(controller);
	
	int around(BaseController controller, ImageData image) : append(controller, image) {
//		System.out.println("<* FavouritesAspect.around append *> begins... ");
		boolean flag = true;
		// [EF] Check if favorite is true (Add in the Scenario 03)
		if (favorite) {
			if ( !(image.isFavorite()) ) flag = false;
		}
		if (flag) return proceed(controller, image);
		return 0;
	}
	
	// TODO [EF] This pointcut is already defined in the CountViewsAspect aspect
	//public void BaseController.appendImages(ImageData[], PhotoListScreen)
	pointcut appendImages(BaseController controller, ImageData[] images, PhotoListScreen imageList):
		call(public void BaseController.appendImages(ImageData[], PhotoListScreen)) && args(images, imageList) && this(controller);
	
	after(BaseController controller, ImageData[] images, PhotoListScreen imageList): appendImages(controller, images, imageList) {
//		System.out.println("<* FavouritesAspect.around appendImages *> begins... ");
		favorite = false;
//		System.out.println("<* FavouritesAspect.around appendImages *> ...ends");
	}
	
	
	// ********  ImageData  ********* //
	
	// [EF] Added in the scenario 03 
	private boolean ImageData.favorite = false;
	
	/**
	 * [EF] Added in the scenario 03
	 */
	public void ImageData.toggleFavorite() {
		this.favorite = ! favorite;
	}
	
	/**
	 * [EF] Added in the scenario 03
	 * @param favorite
	 */
	public void ImageData.setFavorite(boolean favorite) {
		this.favorite = favorite;
	}

	/**
	 * [EF] Added in the scenario 03
	 * @return the favorite
	 */
	public boolean ImageData.isFavorite() {
		return favorite;
	}

	// ********  PhotoListScreen  ********* //
	
	// [EF] Added in the scenario 03 
	public static final Command favoriteCommand = new Command("Set Favorite", Command.ITEM, 1);
	public static final Command viewFavoritesCommand = new Command("View Favorites", Command.ITEM, 1);
	
	// TODO [EF] This pointcut is already defined in the CountViewsAspect aspect
	//public void PhotoListScreen.initMenu()
	pointcut initMenu(PhotoListScreen screen):
		execution(public void PhotoListScreen.initMenu()) && this(screen);
	
	after(PhotoListScreen screen) : initMenu(screen) {
		// [EF] Added in the scenario 03 
		screen.addCommand(favoriteCommand);
		screen.addCommand(viewFavoritesCommand);
	}
	
	// ********  ImageUtil  ********* //
	
	//ImageData ImageUtil.createImageData(String, String, String, int, String)
	pointcut createImageData(ImageUtil imageUtil, String fidString, String albumLabel, String imageLabel, int endIndex, String iiString):
		execution(ImageData ImageUtil.createImageData(String, String, String, int, String)) && args(fidString, albumLabel, imageLabel, endIndex, iiString) && this(imageUtil);
	
	ImageData around(ImageUtil imageUtil, String fidString, String albumLabel, String imageLabel, int endIndex, String iiString) : createImageData(imageUtil, fidString, albumLabel, imageLabel, endIndex, iiString) {
//		System.out.println("<* FavouritesAspect.around createImageData *> begins...");
		// [EF] Favorite (Scenario 03)
		boolean favorite = false;
		int startIndex = endIndex + 1;
		endIndex = iiString.indexOf(ImageUtil.DELIMITER, startIndex);
		
		if (endIndex == -1)
			endIndex = iiString.length();

		favorite = (iiString.substring(startIndex, endIndex)).equalsIgnoreCase("true");
		
		ImageData imageData = proceed(imageUtil, fidString, albumLabel, imageLabel, endIndex, iiString);
		
		imageData.setFavorite(favorite);

//		System.out.println("<* FavouritesAspect.around createImageData *> ...ends");
		return imageData;
	}
	
}
