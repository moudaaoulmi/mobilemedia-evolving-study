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

import lancs.midp.mobilephoto.alternative.musicvideo.MultiMediaData;
import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import ubc.midp.mobilephoto.core.ui.controller.MediaController;
import ubc.midp.mobilephoto.core.ui.controller.MediaListController;
import ubc.midp.mobilephoto.core.ui.controller.ScreenSingleton;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;
import ubc.midp.mobilephoto.core.ui.screens.MediaListScreen;
import ubc.midp.mobilephoto.core.util.Constants;
import ubc.midp.mobilephoto.core.util.MediaUtil;

/**
 * @author Eduardo Figueiredo
 *
 */
public privileged aspect FavouritesAspect {

	// ********  MediaController  ********* //

	// TODO [EF] This pointcut is already defined in the CountViewsAspect aspect
	//public boolean PhotoController.handleCommand(Command, Displayable)
	pointcut handleCommandAction(MediaController controller, Command c):
		execution(public boolean MediaController.handleCommand(Command)) && args(c) && this(controller);
	
	boolean around(MediaController controller, Command c): handleCommandAction(controller, c) {
		boolean handled = proceed(controller, c);
		
		if (handled) return true;
		
		String label = c.getLabel();
		System.out.println("<* FavouritesAspect.around handleCommandAction *> ::handleCommand: " + label);
		
		/** Case: Set photo as favorite 
		 * [EF] Added in the scenario 03 **/
		if (label.equals("Set Favorite")) {
		   	String selectedMediaName = controller.getSelectedMediaName();
			try {
				MediaData media= controller.getAlbumData().getMediaInfo(selectedMediaName);
				media.toggleFavorite();
				controller.updateMedia(media);
				System.out.println("<* FavouritesAspect.handleCommand() *> Image = "+selectedMediaName+ "; Favorite = "+media.isFavorite());
				
			// TODO Nelio, I add these handlers here just to remove errros. Please, check them.
			} catch (InvalidImageDataException e) { 
			} catch (PersistenceMechanismException e) {
				
			} catch (ImageNotFoundException e) {
				Alert alert = new Alert( "Error", "The selected photo was not found in the mobile device", null, AlertType.ERROR);
				Display.getDisplay(controller.midlet).setCurrent(alert, Display.getDisplay(controller.midlet).getCurrent());
			}
			return true;
				
		/** Case: View favorite photos 
		 * [EF] Added in the scenario 03 **/
		} else if (label.equals("View Favorites")) {
			favorite = true;
			controller.showMediaList(controller.getCurrentStoreName());
			ScreenSingleton.getInstance().setCurrentScreenName( Constants.IMAGELIST_SCREEN );
			return true;
		}
		
		return false;
	}
	
	boolean favorite = false;
	
	// ********  MediaListController  ********* //
	
	//public int PhotoListScreen.append(ImageData)
	pointcut append(MediaListController controller, MediaData media):
		call(public int MediaListScreen.append(MediaData)) && args(media) && this(controller);
	
	int around(MediaListController controller, MediaData media) : append(controller, media) {
//		System.out.println("<* FavouritesAspect.around append *> begins... ");
		boolean flag = true;
		// [EF] Check if favorite is true (Add in the Scenario 03)
		if (favorite) {
			if ( !(media.isFavorite()) ) flag = false;
		}
		if (flag) return proceed(controller, media);
		return 0;
	}
	
	// TODO [EF] This pointcut is already defined in the CountViewsAspect aspect
	//public void PhotoListController.appendImages(ImageData[], PhotoListScreen)
	pointcut appendMedias(MediaListController controller, MediaData[] medias, MediaListScreen mediaList):
		call(public void MediaListController.appendMedias(MediaData[], MediaListScreen)) && args(medias, mediaList) && this(controller);
	
	after(MediaListController controller, MediaData[] medias, MediaListScreen mediaList): appendMedias(controller, medias, mediaList) {
//		System.out.println("<* FavouritesAspect.around appendImages *> begins... ");
		favorite = false;
//		System.out.println("<* FavouritesAspect.around appendImages *> ...ends");
	}
	
	// ********  MediaData  ********* //
	
	// [EF] Added in the scenario 03 
	private boolean MediaData.favorite = false;
	
	/**
	 * [EF] Added in the scenario 03
	 */
	public void MediaData.toggleFavorite() {
		this.favorite = ! favorite;
	}
	
	/**
	 * [EF] Added in the scenario 03
	 * @param favorite
	 */
	public void MediaData.setFavorite(boolean favorite) {
		this.favorite = favorite;
	}

	/**
	 * [EF] Added in the scenario 03
	 * @return the favorite
	 */
	public boolean MediaData.isFavorite() {
		return favorite;
	}

	// ********  MediaListScreen  ********* //
	
	// [EF] Added in the scenario 03 
	public static final Command favoriteCommand = new Command("Set Favorite", Command.ITEM, 1);
	public static final Command viewFavoritesCommand = new Command("View Favorites", Command.ITEM, 1);
	
	// TODO [EF] This pointcut is already defined in the CountViewsAspect aspect
	//public void PhotoListScreen.initMenu()
	pointcut initMenu(MediaListScreen screen):
		execution(public void MediaListScreen.initMenu()) && this(screen);
	
	after(MediaListScreen screen) : initMenu(screen) {
		// [EF] Added in the scenario 03 
		screen.addCommand(favoriteCommand);
		screen.addCommand(viewFavoritesCommand);
	}
	
	// ********  MediaUtil  ********* //
	
	//ImageData ImageUtil.createImageData(String, String, String, int, String)
	pointcut createMediaData(MediaUtil mediaUtil, String fidString, String albumLabel, String mediaLabel, int endIndex, String iiString):
		execution(MediaData MediaUtil.createMediaData(String, String, String, int, String)) && args(fidString, albumLabel, mediaLabel, endIndex, iiString) && this(mediaUtil);
	
	MediaData around(MediaUtil mediaUtil, String fidString, String albumLabel, String mediaLabel, int endIndex, String iiString) : createMediaData(mediaUtil, fidString, albumLabel, mediaLabel, endIndex, iiString) {
//		System.out.println("<* FavouritesAspect.around createImageData *> begins...");
		// [EF] Favorite (Scenario 03)
		boolean favorite = false;
		int startIndex = mediaUtil.endIndex + 1;
		mediaUtil.endIndex = iiString.indexOf(MediaUtil.DELIMITER, startIndex);
		
		if (mediaUtil.endIndex == -1)
			mediaUtil.endIndex = iiString.length();

		favorite = (iiString.substring(startIndex, mediaUtil.endIndex)).equalsIgnoreCase("true");
		
		MediaData mediaData = proceed(mediaUtil, fidString, albumLabel, mediaLabel, mediaUtil.endIndex, iiString);
		
		mediaData.setFavorite(favorite);
//		System.out.println("<* FavouritesAspect.around createImageData *> ...ends:");
		return mediaData;
	}

	// ********  MultiMediaData  ********* //
	
	//ImageData ImageUtil.createImageData(String, String, String, int, String)
	pointcut newMultiMediaData(MultiMediaData multiMediaData, MediaData mdata, String type):
		execution(MultiMediaData.new(MediaData, String)) && args(mdata, type) && this(multiMediaData);

	after(MultiMediaData multiMediaData, MediaData mdata, String type) : newMultiMediaData(multiMediaData, mdata, type) {
		multiMediaData.setFavorite(mdata.isFavorite());
	}
	
}
