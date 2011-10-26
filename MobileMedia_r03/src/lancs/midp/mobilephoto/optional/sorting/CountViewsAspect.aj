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
public privileged aspect CountViewsAspect {

	// ********  BaseController  ********* //
	
	// TODO [EF] This pointcut is already defined in the ControllerAspectEH aspect
	//public void  BaseController.showImage() block 1 - Scenario 3
	pointcut showImage(BaseController controler, String selectedImageName): 
		 execution(public void  BaseController.showImage(String))&& this(controler) && args(selectedImageName);
	
	after(BaseController controler, String selectedImageName): showImage(controler, selectedImageName) {
      	// [EF] Added in the scenario 02
		// TODO Nelio, how can we aspectize this EH?
		try {
			ImageData image = controler.getModel().getImageAccessor().getImageInfo(selectedImageName);
			image.increaseNumberOfViews();
			controler.updateImage(image);
			System.out.println("<* BaseController.handleCommand() *> Image = "+selectedImageName+ "; # views = "+image.getNumberOfViews());
		} catch (ImageNotFoundException e) {
			Alert alert = new Alert( "Error", "The selected photo was not found in the mobile device", null, AlertType.ERROR);
			Display.getDisplay(controler.midlet).setCurrent(alert, Display.getDisplay(controler.midlet).getCurrent());
		} catch (NullAlbumDataReference e) {
			controler.model = new AlbumData();
			Alert alert = new Alert( "Error", "The operation is not available. Try again later !", null, AlertType.ERROR);
			Display.getDisplay(controler.midlet).setCurrent(alert, Display.getDisplay(controler.midlet).getCurrent());
		}
	}
	
	//public boolean BaseController.handleCommand(Command, Displayable)
	pointcut handleCommandAction(BaseController controller, Command c, Displayable d):
		execution(public boolean BaseController.handleCommand(Command, Displayable)) && args(c, d) && this(controller);
	
	boolean around(BaseController controller, Command c, Displayable d): handleCommandAction(controller, c, d) {
		boolean handled = proceed(controller, c, d);
		
		if (handled) return true;
		
		String label = c.getLabel();
		System.out.println("<* CountViewsAspect.around handleCommandAction *> ::handleCommand: " + label);
		
		/** Case: Sort photos by number of views
		 * [EF] Added in the scenario 02 **/
		if (label.equals("Sort by Views")) {
			// TODO set sort = true
			sort = true;
			controller.showImageList(controller.getCurrentStoreName());
			controller.setCurrentStoreName( Constants.IMAGELIST_SCREEN );
			return true;
		}
		return false;
	}
	
	boolean sort = false;
	
	//public void BaseController.appendImages(ImageData[], PhotoListScreen)
	pointcut appendImages(BaseController controller, ImageData[] images, PhotoListScreen imageList):
		call(public void BaseController.appendImages(ImageData[], PhotoListScreen)) && args(images, imageList) && this(controller);
	
	before(BaseController controller, ImageData[] images, PhotoListScreen imageList): appendImages(controller, images, imageList) {
		// [EF] Check if sort is true (Add in the Scenario 02)
		if (sort) {
			bubbleSort(images);
		}
		sort =false;
	}
	
	/**
	 * @param images
	 * @param pos1
	 * @param pos2
	 */
	private void exchange(ImageData[] images, int pos1, int pos2) {
		ImageData tmp = images[pos1];
		images[pos1] = images[pos2];
		images[pos2] = tmp;
	}

    /**
     * Sorts an int array using basic bubble sort
     * 
     * @param numbers the int array to sort
     */
	public void bubbleSort(ImageData[] images) {
		System.out.print("Sorting by BubbleSort...");		
		for (int end = images.length; end > 1; end --) {
			for (int current = 0; current < end - 1; current ++) {
				if (images[current].getNumberOfViews() > images[current+1].getNumberOfViews()) {
					exchange(images, current, current+1);
				}
			}
		}
		System.out.println("done.");
	}
	
	// ********  ImageData  ********* //
	
	// [EF] Added in the scenario 02 
	private int ImageData.numberOfViews = 0;
	
	/**
	 * [EF] Added in the scenario 02 
	 */
	public void ImageData.increaseNumberOfViews() {
		this.numberOfViews++;
	}

	/**
	 * [EF] Added in the scenario 02 
	 * @return the numberOfViews
	 */
	public int ImageData.getNumberOfViews() {
		return numberOfViews;
	}
	
	/**
	 * [EF] Added in the scenario 02 
	 * @param views
	 */
	public void ImageData.setNumberOfViews(int views) {
		this.numberOfViews = views;
	}
	
	// ********  PhotoListScreen  ********* //

	public static final Command sortCommand = new Command("Sort by Views", Command.ITEM, 1);

	//public void initMenu()
	pointcut initMenu(PhotoListScreen screen):
		execution(public void PhotoListScreen.initMenu()) && this(screen);
	
	after(PhotoListScreen screen) : initMenu(screen) {
		// [EF] Added in the scenario 02 
		screen.addCommand(sortCommand);
	}
	
	// ********  ImageUtil  ********* //
	
	//ImageData ImageUtil.createImageData(String, String, String, int, String)
	pointcut createImageData(ImageUtil imageUtil, String fidString, String albumLabel, String imageLabel, int endIndex, String iiString):
		execution(ImageData ImageUtil.createImageData(String, String, String, int, String)) && args(fidString, albumLabel, imageLabel, endIndex, iiString) && this(imageUtil);
	
	ImageData around(ImageUtil imageUtil, String fidString, String albumLabel, String imageLabel, int endIndex, String iiString) : createImageData(imageUtil, fidString, albumLabel, imageLabel, endIndex, iiString) {
		// [EF] Number of Views (Scenario 02)
		int startIndex = endIndex + 1;
		endIndex = iiString.indexOf(ImageUtil.DELIMITER, startIndex);
		
		if (endIndex == -1)
			endIndex = iiString.length();
		
		// [EF] Added in the scenario 02 
		int numberOfViews = 0;
		try {
			numberOfViews = Integer.parseInt(iiString.substring(startIndex, endIndex));
		} catch (RuntimeException e) {
			numberOfViews = 0;
			e.printStackTrace();
		}
		
		ImageData imageData = proceed(imageUtil, fidString, albumLabel, imageLabel, endIndex, iiString);
		
		imageData.setNumberOfViews(numberOfViews);

		return imageData;
	}
	
	// TODO [EF] This pointcut is already defined in the UtilAspectEH aspect
	//Method public String ImageUtil.getBytesFromImageInfo(ImageData ii) 1- block - Scenario 1
	pointcut getBytesFromImageInfo(ImageData ii): 
		 execution(public String ImageUtil.getBytesFromImageInfo(ImageData)) && args(ii);
	
	String around(ImageData ii) : getBytesFromImageInfo(ii) {
		String byteString = proceed(ii);
		
		// [EF] Added in scenatio 02
		byteString = byteString.concat(ImageUtil.DELIMITER);
		byteString = byteString.concat(""+ii.getNumberOfViews());
		
		return byteString;
	}
}
