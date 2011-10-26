/*
 * Created on Sep 13, 2004
 *
 */
package ubc.midp.mobilephoto.core.ui.screens;

import javax.microedition.lcdui.Choice;
import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.List;

import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;


/**
 * @author trevor
 *
 * This screen shows a listing of all photos for a selected photo album.
 * This is the screen that contains most of the feature menu items. 
 * From this screen, a user can choose to view photos, add or delete photos,
 * send photos to other users etc.
 * 
 */
public class MediaListScreen extends List {
	
	//Add the core application commands always
	
	public static final Command addCommand = new Command("Add", Command.ITEM, 1);
	public static final Command deleteCommand = new Command("Delete", Command.ITEM, 1);
	public static final Command backCommand = new Command("Back", Command.BACK, 0);

	// [EF] Added in the scenario 02 
	public static final Command editLabelCommand = new Command("Edit Label", Command.ITEM, 1);
	
	// [EF] Aspects PhotoAspect and MusicAspect access it.
	private int typeOfScreen;
	
	public MediaListScreen() {
		super("Choose Items", Choice.IMPLICIT);
	}
	
	/**
	 * Initialize the menu items for this screen
	 */
	public void initMenu() {
		this.addCommand(addCommand);
		this.addCommand(deleteCommand);
		
		// [EF] Added in the scenario 02 
		this.addCommand(editLabelCommand);
		
		this.addCommand(backCommand);
	}

	/**
	 * [EF] Add in scenario 03 AO in order to expose joint point to FavouritesAspect aspect
	 * @param image
	 * @return
	 */
	public int append(MediaData media) {
		return append(media.getMediaLabel(), null);
	}
	
	/**
	 * @param typeOfScreen the typeOfScreen to set
	 */
	public void setTypeOfScreen(int typeOfScreen) {
		this.typeOfScreen = typeOfScreen;
	}

	/**
	 * @return the typeOfScreen
	 */
	public int getTypeOfScreen() {
		return typeOfScreen;
	}
	
}
