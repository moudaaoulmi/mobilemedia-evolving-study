/*
 * Lancaster University
 * Computing Department
 * 
 * Created by Eduardo Figueiredo
 * Date: 7 Aug 2007
 * 
 */
package lancs.midp.mobilephoto.optional.sorting;

import javax.microedition.lcdui.Alert;
import javax.microedition.lcdui.AlertType;
import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Display;

import lancs.midp.mobilephoto.alternative.music.MultiMediaData;
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
@Feature(name="CountViews", parent="MobileMediaAO", type=FeatureType.optional)
public privileged aspect CountViewsAspect {

	// ******** MediaController ********* //

	// TODO [EF] This pointcut is already defined in the ControllerAspectEH
	// aspect
	// public void PhotoController.showImage() block 1 - Scenario 3
	public pointcut showImage(MediaController controler, String selectedImageName):
		(execution(public void MediaController.showImage(String)) ||
		execution(public boolean MediaController.playMultiMedia(String))) && this(controler) && args(selectedImageName);

	after(MediaController controler, String selectedImageName): showImage(controler, selectedImageName) {
//		System.out.println("<* CountViewsAspect.after showImage *> begins...");
		// [EF] Added in the scenario 02
		// TODO Nelio, how can we aspectize this EH?
		try {
			MediaData image = controler.getAlbumData().getMediaInfo(selectedImageName);
			image.increaseNumberOfViews();
			controler.updateMedia(image);
			System.out.println("<* BaseController.handleCommand() *> Image = "
					+ selectedImageName + "; # views = "
					+ image.getNumberOfViews());
		
		// TODO Nelio, I add these handlers here just to remove errros. Please, check them.
		} catch (InvalidImageDataException e) { 
		} catch (PersistenceMechanismException e) {
			
		} catch (ImageNotFoundException e) {
			Alert alert = new Alert("Error",
					"The selected photo was not found in the mobile device",
					null, AlertType.ERROR);
			Display.getDisplay((controler.midlet)).setCurrent(alert,
					Display.getDisplay(controler.midlet).getCurrent());
		}
	}

	// public boolean PhotoController.handleCommand(Command, Displayable)
	pointcut handleCommandAction(MediaController controller, Command c):
		execution(public boolean MediaController.handleCommand(Command)) && args(c) && this(controller);

	boolean around(MediaController controller, Command c): handleCommandAction(controller, c) {
		boolean handled = proceed(controller, c);

		if (handled)
			return true;

		String label = c.getLabel();
		System.out
				.println("<* CountViewsAspect.around handleCommandAction *> ::handleCommand: "
						+ label);

		/***********************************************************************
		 * Case: Sort photos by number of views [EF] Added in the scenario 02
		 **********************************************************************/
		if (label.equals("Sort by Views")) {
			sort = true;
			controller.showMediaList(controller.getCurrentStoreName());
			ScreenSingleton.getInstance().setCurrentStoreName(
					Constants.IMAGELIST_SCREEN);
			return true;
		}
		return false;
	}

	boolean sort = false;

	// ******** PhotoListController ********* //

	// public void PhotoListController.appendImages(ImageData[],
	// PhotoListScreen)
	pointcut appendMedias(MediaListController controller, MediaData[] medias,
			MediaListScreen mediaList):
		call(public void MediaListController.appendMedias(MediaData[], MediaListScreen)) && args(medias, mediaList) && this(controller);

	before(MediaListController controller, MediaData[] medias,
			MediaListScreen mediaList): appendMedias(controller, medias, mediaList) {
		// System.out.println("<* CountViewsAspect.around appendImages *>
		// begins... sort");
		// [EF] Check if sort is true (Add in the Scenario 02)
		if (sort) {
			bubbleSort(medias);
		}
		sort = false;
		// System.out.println("<* CountViewsAspect.around appendImages *>
		// ...ends");
	}

	/**
	 * @param images
	 * @param pos1
	 * @param pos2
	 */
	private void exchange(MediaData[] medias, int pos1, int pos2) {
		MediaData tmp = medias[pos1];
		medias[pos1] = medias[pos2];
		medias[pos2] = tmp;
	}

	/**
	 * Sorts an int array using basic bubble sort
	 * 
	 * @param numbers
	 *            the int array to sort
	 */
	public void bubbleSort(MediaData[] medias) {
		System.out.print("Sorting by BubbleSort...");
		for (int end = medias.length; end > 1; end--) {
			for (int current = 0; current < end - 1; current++) {
				if (medias[current].getNumberOfViews() > medias[current + 1]
						.getNumberOfViews()) {
					exchange(medias, current, current + 1);
				}
			}
		}
		System.out.println("done.");
	}

	// ******** ImageData ********* //

	// [EF] Added in the scenario 02
	private int MediaData.numberOfViews = 0;

	/**
	 * [EF] Added in the scenario 02
	 */
	public void MediaData.increaseNumberOfViews() {
		this.numberOfViews++;
	}

	/**
	 * [EF] Added in the scenario 02
	 * 
	 * @return the numberOfViews
	 */
	public int MediaData.getNumberOfViews() {
		return numberOfViews;
	}

	/**
	 * [EF] Added in the scenario 02
	 * 
	 * @param views
	 */
	public void MediaData.setNumberOfViews(int views) {
		this.numberOfViews = views;
	}

	// ******** PhotoListScreen ********* //

	public static final Command sortCommand = new Command("Sort by Views",
			Command.ITEM, 1);

	// public void PhotoListScreen.initMenu()
	pointcut initMenu(MediaListScreen screen):
		execution(public void MediaListScreen.initMenu()) && this(screen);

	after(MediaListScreen screen) : initMenu(screen) {
		// [EF] Added in the scenario 02
		screen.addCommand(sortCommand);
	}

	// ******** ImageUtil ********* //

	// ImageData ImageUtil.createImageData(String, String, String, int, String)
	pointcut createMediaData(MediaUtil mediaUtil, String fidString,
			String albumLabel, String mediaLabel, int endIndex, String iiString):
		execution(MediaData MediaUtil.createMediaData(String, String, String, int, String)) && args(fidString, albumLabel, mediaLabel, endIndex, iiString) && this(mediaUtil);

	MediaData around(MediaUtil mediaUtil, String fidString, String albumLabel,
			String mediaLabel, int endIndex, String iiString) : createMediaData(mediaUtil, fidString, albumLabel, mediaLabel, endIndex, iiString) {
		// System.out.println("<* CountViewsAspect.around createImageData *>
		// begins...");
		// [EF] Number of Views (Scenario 02)
		int startIndex = mediaUtil.endIndex + 1;
		mediaUtil.endIndex = iiString.indexOf(MediaUtil.DELIMITER, startIndex);

		if (mediaUtil.endIndex == -1)
			mediaUtil.endIndex = iiString.length();

		// [EF] Added in the scenario 02
		int numberOfViews = 0;
		try {
			numberOfViews = Integer.parseInt(iiString.substring(startIndex,
					mediaUtil.endIndex));
		} catch (RuntimeException e) {
			numberOfViews = 0;
			e.printStackTrace();
		}

		MediaData mediaData = proceed(mediaUtil, fidString, albumLabel,
				mediaLabel, mediaUtil.endIndex, iiString);

		mediaData.setNumberOfViews(numberOfViews);
//		 System.out.println("<* CountViewsAspect.around createImageData *> ...ends"+mediaUtil.endIndex+", in string:"+fidString);
		return mediaData;
	}

	// TODO [EF] This pointcut is already defined in the UtilAspectEH aspect
	// Method public String ImageUtil.getBytesFromImageInfo(ImageData ii) 1-
	// block - Scenario 1
	pointcut getBytesFromImageInfo(MediaData ii): 
		 execution(public String MediaUtil.getBytesFromMediaInfo(MediaData)) && args(ii);

	String around(MediaData ii) : getBytesFromImageInfo(ii) {
		// System.out.println("<* CountViewsAspect.around getBytesFromImageInfo
		// *> begins...");
		String byteString = proceed(ii);

		// [EF] Added in scenatio 02
		byteString = byteString.concat(MediaUtil.DELIMITER);
		byteString = byteString.concat("" + ii.getNumberOfViews());

		// System.out.println("<* CountViewsAspect.around getBytesFromImageInfo
		// *> ...ends");
		return byteString;
	}

	// ********  MultiMediaData  ********* //
	
	//ImageData ImageUtil.createImageData(String, String, String, int, String)
	pointcut newMultiMediaData(MultiMediaData multiMediaData, MediaData mdata, String type):
		execution(MultiMediaData.new(MediaData, String)) && args(mdata, type) && this(multiMediaData);

	after(MultiMediaData multiMediaData, MediaData mdata, String type) : newMultiMediaData(multiMediaData, mdata, type) {
		multiMediaData.setNumberOfViews(mdata.getNumberOfViews());
	}
	
}
